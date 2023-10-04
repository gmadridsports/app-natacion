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

  const SupabaseUserRepository();

  @override
  Future<User.User?> getCurrentSessionUser() async {
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    if (supabaseUser == null) {
      return null;
    }

    final List<dynamic> userProfiles = await Supabase.instance.client
        .from(_profileTable)
        .select(_membershipLevelColumn);
    final membershipStatus = MembershipStatus.fromString(
        userProfiles.firstOrNull[_membershipLevelColumn] as String);
    final userEmail = Email.fromString(supabaseUser.email ?? '');

    final user = User.User.from(supabaseUser.id, membershipStatus, userEmail);
    return user;
  }

  Future<void> deleteCurrentSessionUser() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future<void> save(User.User user) async {
    // at this very moment we don't need to update the user. the app does not allow it
    // we simply publish the events and the app will react to it
    DependencyInjection()
        .getInstanceOf<LibEventBusEventBus>()
        .publishApp(user.domainEvents);
  }
}
