import 'calendar_event.dart';
import 'event_day.dart';
import 'event_day_bound.dart';

abstract class CalendarEventRepository {
  Future<Map<EventDay, List<CalendarEvent>>> getCalendarEventsStarting(
      EventDayBound from, EventDayBound to);
}
