import '../models/TestUser.dart';
import '../models/TestUserBuilder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

import '../models/TestUserEmail.dart';

class SupabaseTestUserBuilder extends TestUserBuilder {
  Future<TestUser> build() async {
    const adminPassword = String.fromEnvironment('SUPABASE_ADMIN_TEST_PASSWORD',
        defaultValue: 'test');
    final newTestUser =
        new TestUser(email, password, useCaseDescription, isMember);

    final supabase = await SupabaseClient(
        dotenv.get('SUPABASE_URL', fallback: ''),
        dotenv.get('SUPABASE_ANON_KEY', fallback: ''));

    await supabase.auth.signInWithPassword(
        email: TestUserEmail.forbiddenCreationEmail, password: adminPassword);

    await supabase.from('test_users').insert({
      'email': this.email.toString(),
      'password': this.password.toString(),
      'is_member': this.isMember
    });

    await supabase.auth.signOut();

    return newTestUser;
  }
}
