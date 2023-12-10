import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day.dart';

// todo improve this builder with more complex scenarios (not only empty cases)
class TestAppCalendarEventsBuilder {
  DateTime from = DateTime.utc(2023, 03, 27);
  DateTime to = DateTime.utc(2023, 04, 30);
  CalendarEvent? calendarEvent = null;

  TestAppCalendarEventsBuilder withFromDateTimeUtc(DateTime fromDateTimeUtc) {
    from = fromDateTimeUtc;
    return this;
  }

  TestAppCalendarEventsBuilder withToDateTimeUtc(DateTime toDateTimeUtc) {
    to = toDateTimeUtc;
    return this;
  }

  // todo implement this for more complex scenarios
  // withCalendarEvent(CalendarEvent calendarEvent) {
  //   return this;
  // }

  Map<EventDay, List<CalendarEvent>> build() {
    final dayBuckets = Iterable<int>.generate(to.difference(from).inDays + 2);

    final Map<EventDay, List<CalendarEvent>> eventsToReturn = {
      for (int dayPos in dayBuckets)
        EventDay.fromDateTimeUtc(from.add(Duration(days: dayPos))): []
    };

    return eventsToReturn;
  }
}
