import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day_time.dart';

class TestAppCalendarEventBuilder {
  String id = "1";
  String summary = "A test event";
  String description = "A description for the test event ✌🏼";
  EventDayTime from = EventDayTime.fromDateTimeUtc(DateTime.utc(2023, 04, 25));
  EventDayTime to = EventDayTime.fromDateTimeUtc(DateTime.utc(2023, 04, 25));

  TestAppCalendarEventBuilder withFromEventDayTime(
      EventDayTime fromEventDayTime) {
    from = fromEventDayTime;
    return this;
  }

  TestAppCalendarEventBuilder withId(String id) {
    this.id = id;
    return this;
  }

  TestAppCalendarEventBuilder withSummary(String summary) {
    this.summary = summary;
    return this;
  }

  TestAppCalendarEventBuilder withDescription(String description) {
    this.description = description;
    return this;
  }

  TestAppCalendarEventBuilder withToEventDayTime(EventDayTime toEventDayTime) {
    to = toEventDayTime;
    return this;
  }

  CalendarEvent build() {
    return CalendarEvent.from(id, summary, description, from, to);
  }
}
