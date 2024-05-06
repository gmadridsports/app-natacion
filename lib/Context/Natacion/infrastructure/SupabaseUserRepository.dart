import 'dart:convert';

import 'package:gmadrid_natacion/Context/Natacion/domain/user/notification_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/dependency_injection.dart';
import '../../Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';
import '../domain/Email.dart';
import '../domain/user/MembershipStatus.dart';
import '../domain/user/User.dart' as User;
import '../domain/user/UserRepository.dart';

class SupabaseUserRepository implements UserRepository {
  static const String _profileTable = 'profiles';
  static const String _membershipLevelColumn = 'membership_level';
  static const String _notificationPreferencesColumn =
      'notification_preferences';

  const SupabaseUserRepository();

  @override
  Future<User.User?> getCurrentSessionUser() async {
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    if (supabaseUser == null) {
      return null;
    }

    final List<dynamic> userProfiles = await Supabase.instance.client
        .from(_profileTable)
        .select("$_membershipLevelColumn, $_notificationPreferencesColumn");
    final membershipStatus = MembershipStatus.fromString(
        userProfiles.firstOrNull[_membershipLevelColumn] as String);
    print(userProfiles.firstOrNull[_notificationPreferencesColumn]);
    print(NotificationPreferenceType.trainingWeek.name);
    final notificationPreferences = NotificationPreferences.fromPrimitives(
        userProfiles.firstOrNull[_notificationPreferencesColumn]
            as Map<String, dynamic>);
    final userEmail = Email.fromString(supabaseUser.email ?? '');
    print(userProfiles.firstOrNull[_notificationPreferencesColumn]);
    final user = User.User.from(
        supabaseUser.id, membershipStatus, userEmail, notificationPreferences);
    return user;
  }

  Future<void> deleteCurrentSessionUser() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> save(User.User user) async {
    await Supabase.instance.client.from(_profileTable).update({
      _notificationPreferencesColumn:
          user.notificationPreferences.toPrimitives(),
    }).eq('id', user.id);

    DependencyInjection()
        .getInstanceOf<LibEventBusEventBus>()
        .publishApp(user.domainEvents);
  }
}
