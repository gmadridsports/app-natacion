import 'dart:async';

import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Shared/domain/Bus/Event/EventBus.dart';
import '../domain/user/ListenedEvents/MembershipStatusChanged.dart';

class SupabaseUserStatusListener {
  late final StreamSubscription _streamSubscription;

  SupabaseUserStatusListener() {
    _streamSubscription = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      if (data.isEmpty) return;

      DependencyInjection().getInstanceOf<EventBus>().publish([
        MembershipStatusChanged(
          data.first['id'],
          DateTime.now(),
          data.first['membership_level'],
        )
      ]);
    });
  }

  dispose() {
    _streamSubscription.cancel();
  }
}
