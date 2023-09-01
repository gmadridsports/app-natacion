import 'TestUserEmail.dart';
import 'TestUserPassword.dart';

class TestUser {
  TestUserEmail email;
  TestUserPassword password;
  String useCaseDescription;
  bool isMember = false;

  TestUser(this.email, this.password, this.useCaseDescription, this.isMember);
  toEncodable() {
    return {
      'email': email.toString(),
      'password': password.toString(),
      'useCaseDescription': useCaseDescription,
      'isMember': isMember
    };
  }
}
