import 'TestUser.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:dart_dotenv/dart_dotenv.dart';
import 'package:supabase/supabase.dart';

class TestUserBuilder {
  String email =
      '${generateRandomString(10)}+${DateTime.now().millisecondsSinceEpoch}@gmadridnatacion.bertamini.net';
  String password = generateRandomString(15);
  String useCaseDescription = 'Registered, non-member user, that can login';
  bool isMember = false;

  static const String supabaseCreationFunctionName = 'generate_user';

  Future<TestUser> build() async {
    const envName = const String.fromEnvironment('ENV', defaultValue: 'test');
    //todo remove ../
    // final dotEnv = DotEnv(filePath: 'assets/.${envName}.env');
    // dotEnv.getDotEnv();

    final newTestUser =
        new TestUser(email, password, useCaseDescription, isMember);

    // final supabase = await SupabaseClient('http://localhost:54321',
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0');
    final supabase = await SupabaseClient(
        dotenv.get('SUPABASE_URL', fallback: ''),
        dotenv.get('SUPABASE_ANON_KEY', fallback: ''));

    await supabase.auth.signInWithPassword(
        email: TestUser.forbiddenCreationEmail, password: 'password');

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
