import '../../Shared/domain/value_object.dart';

class TrainingDate implements ValueObject {
  final DateTime _dateTime;
  bool get representsTrainingWeek => _dateTime.weekday == DateTime.monday;

  TrainingDate._internal(int year, int month, int day,
      {int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0})
      : _dateTime = DateTime.utc(
            year, month, day, hour, minute, second, millisecond, microsecond);

  TrainingDate._internalDateTime(this._dateTime);

  TrainingDate.from(int year, int month, int day)
      : this._internal(year, month, day);

  TrainingDate.fromString(String string)
      : this._internalDateTime(DateTime.parse('${string}T00:00:00Z'));

  TrainingDate.fromDateTime(this._dateTime) {
    if (!_dateTime.isUtc) {
      throw Error();
    }
  }

  TrainingDate firstTrainingDateWithinTheWeek() {
    DateTime newTrainingDateTime = _dateTime.copyWith().subtract(Duration(
        days:
            _dateTime.weekday != DateTime.monday ? _dateTime.weekday - 1 : 0));

    return TrainingDate._internal(newTrainingDateTime.year,
        newTrainingDateTime.month, newTrainingDateTime.day);
  }

  TrainingDate lastTrainingDateWithinTheWeek() {
    DateTime newTrainingDateTime = _dateTime
        .copyWith()
        .add(Duration(days: DateTime.friday - _dateTime.weekday));

    return TrainingDate._internalDateTime(newTrainingDateTime);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingDate &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => _dateTime.hashCode;

  @override
  String toString() {
    return "${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}";
  }
}
