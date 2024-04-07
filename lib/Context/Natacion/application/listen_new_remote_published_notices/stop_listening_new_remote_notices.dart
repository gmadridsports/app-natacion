import '../../../../shared/dependency_injection.dart';
import '../../domain/bulletin/new_published_notice_listener.dart';

class StopListeningNewRemoteNotices {
  NewPublishedNoticeListener _listener;

  call() async {
    _listener.stopListening();
  }

  StopListeningNewRemoteNotices()
      : _listener =
            DependencyInjection().getInstanceOf<NewPublishedNoticeListener>();
}
