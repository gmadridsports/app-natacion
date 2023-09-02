import 'dart:math';

class TestUserPassword {
  String _password;

  TestUserPassword._internal(this._password);
  TestUserPassword.newTestUserPassword()
      : this._internal(generateRandomString(15));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestUserPassword && toString() == other.toString();

  @override
  int get hashCode => _password.hashCode;

  @override
  String toString() {
    return _password;
  }
}

String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
