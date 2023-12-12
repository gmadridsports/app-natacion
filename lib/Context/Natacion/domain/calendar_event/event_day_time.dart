import 'package:timezone/standalone.dart';

import 'package:timezone/standalone.dart' as tz;
import '../../../Shared/domain/value_object.dart';

final madridTimezone = tz.getLocation('Europe/Madrid');

/// It represents date-time of an event in the calendar.
/// The date-time is always considered as it were on the Madrid timezone.
class EventDayTime extends ValueObject {
  final TZDateTime _value;

  EventDayTime._internal(int year, int month, int day, int hour, int minute,
      int second, int millisecond, int microsecond, bool isUtc)
      : _value = tz.TZDateTime(madridTimezone, year, month, day, hour, minute,
            second, millisecond, microsecond) {
    if (!isUtc) {
      throw Exception("EventDayTime must be created with a UTC DateTime");
    }
  }

  /// It creates an EventDayTime from a DateTime considering the Madrid timezone.
  /// i.e.
  /// 20/02/2024 15:23:03 UTC -> will be treated as 20/02/2024 15:23:03 Europe/Madrid
  EventDayTime.fromDateTimeUtc(DateTime dateTime)
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

  bool isSameDateOf(EventDayTime other) {
    return _value.day == other._value.day &&
        _value.month == other._value.month &&
        _value.year == other._value.year;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EventDayTime &&
            runtimeType == other.runtimeType &&
            _value == other._value;
  }

  bool operator <(EventDayTime other) {
    return _value.isBefore((other)._value);
  }

  bool operator >(EventDayTime other) {
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
}
