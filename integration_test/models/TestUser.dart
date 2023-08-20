class TestUser {
  String email;
  String password;
  String useCaseDescription;
  bool isMember = false;

  static const emailSuffix = '@gmadridnatacion.bertamini.net';
  static const forbiddenCreationEmail =
      'test+admin@gmadridnatacion.bertamini.net';

  TestUser(this.email, this.password, this.useCaseDescription, this.isMember);
  toEncodable() {
    return {
      'email': email,
      'password': password,
      'useCaseDescription': useCaseDescription,
      'isMember': isMember
    };
  }
}
