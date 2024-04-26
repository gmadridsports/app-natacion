import 'package:timezone/standalone.dart';

import 'package:timezone/standalone.dart' as tz;
import '../../../Shared/domain/value_object.dart';

final madridTimezone = tz.getLocation('Europe/Madrid');

/// It represents date-time always considered as it were on the Madrid timezone.
class MadridDateTime extends ValueObject {
  final TZDateTime _value;

  MadridDateTime._internal(int year, int month, int day, int hour, int minute,
      int second, int millisecond, int microsecond, bool isUtc)
      : _value = tz.TZDateTime(madridTimezone, year, month, day, hour, minute,
            second, millisecond, microsecond) {
    if (!isUtc) {
      throw Exception("EventDayTime must be created with a UTC DateTime");
    }
  }

  /// It creates a VO from a DateTime considering the Madrid timezone.
  /// i.e.
  /// 20/02/2024 15:23:03 UTC -> will be treated as 20/02/2024 15:23:03 Europe/Madrid
  MadridDateTime.fromDateTimeUtc(DateTime dateTime)
      : this._internal(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
            dateTime.second,
            dateTime.millisecond,
            dateTime.microsecond,
            dateTime.isUtc);

  MadridDateTime.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch)
      : this._internal(
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch).year,
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch).month,
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch).day,
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch).hour,
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch).minute,
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch).second,
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch)
                .millisecond,
            DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch)
                .microsecond,
            true);

  bool isSameDateOf(MadridDateTime other) {
    return _value.day == other._value.day &&
        _value.month == other._value.month &&
        _value.year == other._value.year;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MadridDateTime &&
            runtimeType == other.runtimeType &&
            _value == other._value;
  }

  bool operator <(MadridDateTime other) {
    return _value.isBefore((other)._value);
  }

  bool operator >(MadridDateTime other) {
    return _value.isAfter((other)._value);
  }

  @override
  int get hashCode => _value.hashCode;

  int get microSecondsSinceEpoch => DateTime.utc(
          _value.year,
          _value.month,
          _value.day,
          _value.hour,
          _value.minute,
          _value.second,
          _value.millisecond,
          _value.microsecond)
      .microsecondsSinceEpoch;

  bool sameDayAs(MadridDateTime other) {
    return _value.day == other._value.day &&
        _value.month == other._value.month &&
        _value.year == other._value.year;
  }

  String toString() => _value.toIso8601String();

  /// Returns the DateTime representing the time of Madrid as it were on local timezone.
  /// i.e.
  /// if on Portugal timezone:
  /// 20/03/24 15:43:23 Europe/Madrid -> 20/03/24 15:43:23 Europe/Lisbon
  DateTime toDateTime() => DateTime(_value.year, _value.month, _value.day,
      _value.hour, _value.minute, _value.second, _value.millisecond);
}
