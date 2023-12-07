import '../../../Shared/domain/value_object.dart';

enum EventDayBoundType { lowerBound, upperBound }

class EventDayBound implements ValueObject {
  final DateTime _dateTime;
  final bool representsLowerBound;

  // todo datetime with a specific timezone, not the local one which could be different from the Madrid one (i.e. travelling)
  EventDayBound._internal(
      int year, int month, int day, this.representsLowerBound, bool isUtc)
      : _dateTime = DateTime.utc(
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

  EventDayBound.from(int year, int month, int day)
      : this._internal(year, month, day, true, true);

  EventDayBound.fromDateTime(
      DateTime dateTime, EventDayBoundType eventDayBoundType)
      : this._internal(dateTime.year, dateTime.month, dateTime.day,
            eventDayBoundType == EventDayBoundType.lowerBound, dateTime.isUtc);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventDayBound &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => _dateTime.hashCode;

  @override
  String toString() {
    return "${_dateTime.microsecondsSinceEpoch}";
  }

  String toMillisecondsSinceEpoch() {
    return "${_dateTime.millisecondsSinceEpoch}";
  }
}
