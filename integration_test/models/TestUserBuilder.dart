import 'TestUser.dart';
import 'dart:math';

import 'TestUserEmail.dart';
import 'TestUserPassword.dart';

abstract class TestUserBuilder {
  TestUserEmail email = TestUserEmail.newTestUserEmail();
  TestUserPassword password = TestUserPassword.newTestUserPassword();
  String useCaseDescription = 'Registered, non-member user, that can login';
  bool isMember = false;

  static const String supabaseCreationFunctionName = 'generate_user';

  Future<TestUser> build();
}
