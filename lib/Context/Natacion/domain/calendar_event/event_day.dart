import 'package:gmadrid_natacion/Context/Shared/domain/value_object.dart';

import 'package:timezone/standalone.dart' as tz;

import 'event_day_time.dart';

final madridTimezone = tz.getLocation('Europe/Madrid');

class EventDay extends ValueObject {
  final tz.TZDateTime _value;

  EventDay._internal(int year, int month, int day, bool isUtc)
      : _value =
            tz.TZDateTime(madridTimezone, year, month, day, 0, 0, 0, 0, 0) {
    if (!isUtc)
      throw Exception("EventDayBound must be created with a UTC DateTime");
  }

  /// It creates an EventDay from a year, month and day considering the Madrid timezone.
  /// i.e.
  /// 20/01/2024 -> will be treated as 20/01/2024 Europe/Madrid
  EventDay.from(int year, int month, int day)
      : this._internal(year, month, day, true);

  /// It creates an EventDay from a DateTime in UTC.
  /// The input datetime, although is must be an UTC datetime, is considered as it were on the Madrid timezone.
  ///
  /// i.e.
  /// 20/01/2024 15:00 UTC -> will be treated as 20/01/2024 15:00 Europe/Madrid
  EventDay.fromDateTimeUtc(DateTime dateTime)
      : this._internal(
            dateTime.year, dateTime.month, dateTime.day, dateTime.isUtc);

  EventDay.fromEventDayTime(EventDayTime eventDateTime)
      : this._internal(
            DateTime.fromMicrosecondsSinceEpoch(
                    eventDateTime.microSecondsSinceEpoch)
                .toUtc()
                .year,
            DateTime.fromMicrosecondsSinceEpoch(
                    eventDateTime.microSecondsSinceEpoch)
                .toUtc()
                .month,
            DateTime.fromMicrosecondsSinceEpoch(
                    eventDateTime.microSecondsSinceEpoch)
                .toUtc()
                .day,
            true);

  int get microSecondsSinceEpoch =>
      DateTime.utc(_value.year, _value.month, _value.day)
          .microsecondsSinceEpoch;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EventDay &&
            runtimeType == other.runtimeType &&
            _value == other._value;
  }

  @override
  int get hashCode => _value.hashCode;
}
