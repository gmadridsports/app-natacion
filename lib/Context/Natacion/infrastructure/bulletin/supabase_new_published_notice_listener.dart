import '../../../Shared/domain/Bus/Event/EventBus.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/bulletin/listened_events/new_published_notice_received.dart';
import '../../domain/bulletin/new_published_notice_listener.dart';

class SupabaseNewPublishedNoticeListener extends NewPublishedNoticeListener {
  static const String _bulletinTable = 'bulletin_board';
  static const String _isPublishedColumn = 'is_published';
  static const String _idColumn = 'id';
  static const String _pubblicationDateColumn = 'publication_date';
  static const String _originColumn = 'origin_source';
  static const String _bodyMessageColumn = 'body_message';

  RealtimeChannel? _channel;

  SupabaseNewPublishedNoticeListener() {}

  void listen() {
    _channel = Supabase.instance.client.channel("public:${_bulletinTable}");
    _channel
        ?.onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: _bulletinTable,
            callback: _listener)
        .subscribe();
  }

  void _listener(dynamic data, [dynamic ref]) {
    if (data.isEmpty) return;

    final notice = data['new'];

    if (notice == null || notice[_isPublishedColumn] == false) return;

    DependencyInjection().getInstanceOf<EventBus>().publish([
      NewPublishedNoticeReceived(
          notice[_idColumn],
          DateTime.now(),
          notice[_bodyMessageColumn],
          notice[_originColumn],
          DateTime.parse("${notice[_pubblicationDateColumn]}Z"))
    ]);
  }

  void stopListening() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
  }
}
