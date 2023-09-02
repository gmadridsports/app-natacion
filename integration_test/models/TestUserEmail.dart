import 'dart:math';

class TestUserEmail {
  String _email;

  static const emailSuffix = '@gmadridnatacion.bertamini.net';
  static const forbiddenCreationEmail =
      'test+admin@gmadridnatacion.bertamini.net';

  TestUserEmail._internal(this._email);
  TestUserEmail.newTestUserEmail()
      : this._internal(
            '${generateRandomString(10)}+${DateTime.now().millisecondsSinceEpoch}${emailSuffix}');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestUserEmail && toString() == other.toString();

  @override
  int get hashCode => _email.hashCode;

  @override
  String toString() {
    return _email;
  }
}

String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
