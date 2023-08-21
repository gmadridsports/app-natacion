import 'TestUser.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase/supabase.dart';

// todo auth-login move to infrastructure
class TestUserBuilder {
  String email =
      '${generateRandomString(10)}+${DateTime.now().millisecondsSinceEpoch}@gmadridnatacion.bertamini.net';
  String password = generateRandomString(15);
  String useCaseDescription = 'Registered, non-member user, that can login';
  bool isMember = false;

  static const String supabaseCreationFunctionName = 'generate_user';

  Future<TestUser> build() async {
    const adminPassword = const String.fromEnvironment(
        'SUPABASE_ADMIN_TEST_PASSWORD',
        defaultValue: 'test');

    final newTestUser =
        new TestUser(email, password, useCaseDescription, isMember);

    final supabase = await SupabaseClient(
        dotenv.get('SUPABASE_URL', fallback: ''),
        dotenv.get('SUPABASE_ANON_KEY', fallback: ''));

    await supabase.auth.signInWithPassword(
        email: TestUser.forbiddenCreationEmail, password: adminPassword);

    await supabase.from('test_users').insert({
      'email': this.email,
      'password': this.password,
      'is_member': this.isMember
    });

    await supabase.auth.signOut();

    return newTestUser;
  }
}

String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
