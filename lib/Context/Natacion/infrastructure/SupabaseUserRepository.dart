import 'package:supabase_flutter/supabase_flutter.dart';

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

    final user = User.User.from(supabaseUser.id, membershipStatus);
    return user;
  }

  Future<void> deleteCurrentSessionUser() async {
    await Supabase.instance.client.auth.signOut();
  }
}
