import '../../../Shared/domain/value_object.dart';

enum NotificationPreferenceType implements ValueObject {
  trainingWeek(name: 'training-week'),
  other(name: 'other'),
  bulletinBoard(name: 'bulletin-board');

  const NotificationPreferenceType({required String name}) : _name = name;

  factory NotificationPreferenceType.fromString(String name) {
    switch (name.trim()) {
      case 'training-week':
        return NotificationPreferenceType.trainingWeek;
      case 'bulletin-board':
        return NotificationPreferenceType.bulletinBoard;
      case 'other':
        return NotificationPreferenceType.other;
      default:
        throw ArgumentError("Not admitted value $name");
    }
  }

  final String _name;

  get name => _name;

  @override
  String toString() {
    return _name;
  }
}

class NotificationPreferences implements ValueObject {
  final bool _trainingWeek;
  final bool _bulletinBoard;
  final bool _other;

  get trainingWeek => _trainingWeek;

  get bulletinBoard => _bulletinBoard;

  get other => _other;

  NotificationPreferences.fromPrimitives(Map<String, dynamic> raw)
      : _trainingWeek =
            raw[NotificationPreferenceType.trainingWeek.name] as bool,
        _bulletinBoard =
            raw[NotificationPreferenceType.bulletinBoard.name] as bool,
        _other = raw[NotificationPreferenceType.other.name] as bool;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          _trainingWeek == other._trainingWeek &&
          _bulletinBoard == other._bulletinBoard &&
          _other == other._other;

  @override
  int get hashCode =>
      _trainingWeek.hashCode ^ _bulletinBoard.hashCode ^ _other.hashCode;

  Map<String, bool> toPrimitives() {
    return (Map.of({
      NotificationPreferenceType.bulletinBoard.name: _bulletinBoard,
      NotificationPreferenceType.trainingWeek.name: _trainingWeek,
      NotificationPreferenceType.other.name: _other
    }));
  }

  NotificationPreferences changePreference(
      NotificationPreferenceType type, bool enabled) {
    final current = this.toPrimitives();
    current[type.name] = enabled;

    return NotificationPreferences.fromPrimitives(current);
  }
}
