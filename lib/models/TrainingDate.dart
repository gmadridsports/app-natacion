class TrainingDate {
  final DateTime _dateTime;

  TrainingDate._(int year, int month, int day)
      : _dateTime = new DateTime(year, month, day);

  TrainingDate.from(int year, int month, int day) : this._(year, month, day);

  @override
  String toString() {
    return "${_dateTime.year}-${_dateTime.month}-${_dateTime.day}";
  }
}
