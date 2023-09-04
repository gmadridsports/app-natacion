import 'package:gmadrid_natacion/models/user/MembershipStatus.dart';
import 'package:gmadrid_natacion/models/user/UserRepository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gmadrid_natacion/models/user/User.dart' as User;

class SupabaseUserRepository implements UserRepository {
  @override
  Future<User.User?> getCurrentSessionUser() async {
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    if (supabaseUser == null) {
      return null;
    }

    final user = new User.User.from(
        supabaseUser.id, MembershipStatus.fromString(supabaseUser.id));

    return user;
  }
}
