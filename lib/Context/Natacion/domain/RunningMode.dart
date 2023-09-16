import '../../Shared/domain/value_object.dart';

class RunningMode implements ValueObject {
  final String _mode;

  // todo socio-xx-xx auth-login only expected values
  RunningMode._internal(String mode) : _mode = mode;

  bool isTestingMode() {
    return _mode == 'test';
  }

  RunningMode.from(String mode) : this._internal(mode);

  RunningMode.fromEnvironment()
      : this._internal(
            const String.fromEnvironment('MODE', defaultValue: 'prod'));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunningMode &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => _mode.hashCode;

  @override
  String toString() {
    return _mode;
  }
}
