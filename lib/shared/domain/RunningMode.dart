import '../../Context/Shared/domain/value_object.dart';

enum RunningMode implements ValueObject {
  test(mode: 'test'),
  prod(mode: 'prod'),
  local(mode: 'local');

  final String _mode;

  const RunningMode({required String mode}) : _mode = mode;
  factory RunningMode.fromString(String mode) {
    switch (mode.trim()) {
      case 'test':
        return RunningMode.test;
      case 'prod':
        return RunningMode.prod;
      case 'local':
        return RunningMode.local;
      default:
        throw ArgumentError('Invalid running mode: $mode');
    }
  }

  factory RunningMode.fromEnvironment() {
    const mode = String.fromEnvironment('MODE', defaultValue: 'prod');
    return RunningMode.fromString(mode);
  }

  bool get isTestingMode => _mode == 'test';

  @override
  String toString() {
    return _mode;
  }
}
