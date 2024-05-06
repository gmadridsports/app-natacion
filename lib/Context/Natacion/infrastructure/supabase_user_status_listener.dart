import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/user/ListenedEvents/UserReopenedAppWithValidSession.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Shared/domain/Bus/Event/EventBus.dart';
import '../domain/user/ListenedEvents/MembershipStatusChangedFromBackoffice.dart';

class SupabaseUserStatusListener {
  static final String _membershipColumn = 'membership_level';

  late StreamSubscription _streamSubscription;
  bool _firstEvent = true;
  bool _refreshing = false;
  String? _previousMembershipLevel;

  void refresh() async {
    try {
      await _streamSubscription.cancel();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
    _previousMembershipLevel = null;
    _refreshing = true;
    _streamSubscription = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id']).listen(_listener);
  }

  void _listener(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return;

    if (_firstEvent) {
      _previousMembershipLevel = data.first[_membershipColumn];
      _firstEvent = false;
      return;
    }

    if (_refreshing == true) {
      DependencyInjection().getInstanceOf<EventBus>().publish([
        UserReopenedAppWithValidSession(
          data.first['id'],
          DateTime.now(),
          data.first[_membershipColumn],
        )
      ]);

      _refreshing = false;
      return;
    }

    if (_previousMembershipLevel == data.first[_membershipColumn]) {
      return;
    }

    DependencyInjection().getInstanceOf<EventBus>().publish([
      MembershipStatusChangedFromBackoffice(
        data.first['id'],
        DateTime.now(),
        data.first[_membershipColumn],
      )
    ]);
  }

  SupabaseUserStatusListener() {
    _streamSubscription = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id']).listen(_listener);
  }

  dispose() {
    _streamSubscription.cancel();
  }
}
