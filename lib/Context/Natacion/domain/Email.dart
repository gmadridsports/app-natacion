import '../../Shared/domain/value_object.dart';

class Email implements ValueObject {
  final String _email;
  static const _validityPattern =
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';

  Email._internal(String email) : _email = email;

  Email.fromString(String email) : _email = email.trim() {
    final regex = RegExp(_validityPattern);
    if (!regex.hasMatch(_email)) {
      throw ArgumentError('Correo inválido');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Email &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => _email.hashCode;

  @override
  String toString() {
    return _email;
  }
}
