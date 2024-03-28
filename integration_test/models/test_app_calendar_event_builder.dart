import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event.dart';
import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';

class TestAppCalendarEventBuilder {
  String id = "1";
  String summary = "A test event";
  String description = "A description for the test event ✌🏼";
  MadridDateTime from =
      MadridDateTime.fromDateTimeUtc(DateTime.utc(2023, 04, 25));
  MadridDateTime to =
      MadridDateTime.fromDateTimeUtc(DateTime.utc(2023, 04, 25));

  TestAppCalendarEventBuilder withFromEventDayTime(
      MadridDateTime fromEventDayTime) {
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

  TestAppCalendarEventBuilder withToEventDayTime(
      MadridDateTime toEventDayTime) {
    to = toEventDayTime;
    return this;
  }

  CalendarEvent build() {
    return CalendarEvent.from(id, summary, description, from, to);
  }
}
