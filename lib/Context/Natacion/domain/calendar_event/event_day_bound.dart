import 'package:timezone/standalone.dart';

import '../../../Shared/domain/value_object.dart';
import 'package:timezone/standalone.dart' as tz;

enum EventDayBoundType { lowerBound, upperBound }

final madridTimezone = tz.getLocation('Europe/Madrid');

/// It represents the lower/upper time included bound of any event in the calendar.
/// The bound is always considered as it were on the Madrid timezone.
class EventDayBound implements ValueObject {
  final TZDateTime _dateTime;
  final bool representsLowerBound;

  EventDayBound._internal(
      int year, int month, int day, this.representsLowerBound, bool isUtc)
      : _dateTime = tz.TZDateTime(
            madridTimezone,
            year,
            month,
            day,
            representsLowerBound ? 0 : 23,
            representsLowerBound ? 0 : 59,
            representsLowerBound ? 0 : 59,
            representsLowerBound ? 0 : 999,
            representsLowerBound ? 0 : 999) {
    if (!isUtc)
      throw Exception("EventDayBound must be created with a UTC DateTime");
  }

  /// It creates an EventDayBound from a year, month and day considering the Madrid timezone.
  /// i.e.
  /// 20/01/2024 -> will be treated as 20/01/2024 Europe/Madrid
  EventDayBound.from(int year, int month, int day)
      : this._internal(year, month, day, true, true);

  /// It creates an EventDayBound from a DateTime in UTC.
  /// The input datetime, althgough is must be an UTC datetime, is considered as it were on the Madrid timezone.
  ///
  /// i.e.
  /// 20/01/2024 15:00 UTC -> will be treated as 20/01/2024 15:00 Europe/Madrid
  EventDayBound.fromDateTimeUtc(
      DateTime dateTime, EventDayBoundType eventDayBoundType)
      : this._internal(dateTime.year, dateTime.month, dateTime.day,
            eventDayBoundType == EventDayBoundType.lowerBound, dateTime.isUtc);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventDayBound &&
          runtimeType == other.runtimeType &&
          millisecondsSinceEpochInt == other.millisecondsSinceEpochInt;

  @override
  int get hashCode => _dateTime.hashCode;

  @override
  String toString() {
    return "${_dateTime.microsecondsSinceEpoch}";
  }

  String toMillisecondsSinceEpochString() {
    return "${_dateTime.millisecondsSinceEpoch}";
  }

  int get millisecondsSinceEpochInt => DateTime.utc(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          _dateTime.hour,
          _dateTime.minute,
          _dateTime.second,
          _dateTime.millisecond,
          _dateTime.microsecond)
      .millisecondsSinceEpoch;

  DateTime get dateTimeUtc => DateTime.utc(
      _dateTime.year,
      _dateTime.month,
      _dateTime.day,
      _dateTime.hour,
      _dateTime.minute,
      _dateTime.second,
      _dateTime.millisecond,
      _dateTime.microsecond);

  int daysDifference(EventDayBound eventDay) {
    if (eventDay.representsLowerBound == this.representsLowerBound) {
      throw new Exception(
          "Both represents the same bound lowerBound: $representsLowerBound");
    }

    if (this.representsLowerBound) {
      return eventDay._dateTime.difference(this._dateTime).inDays;
    }

    return this._dateTime.difference(eventDay._dateTime).inDays;
  }
}
