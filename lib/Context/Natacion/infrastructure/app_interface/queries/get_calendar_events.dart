import '../../../application/get_calendar_events/get_calendar_events_response.dart';
import '../../../application/get_calendar_events/get_calendar_events.dart'
    as AppGetCalendarEvents;
import '../query_interface.dart';

class GetCalendarEvents implements QueryInterface<Future<GetCalendarEvents>> {
  @override
  Future<GetCalendarEventsResponse> call(
      DateTime fromIncludedDayMonthYear, DateTime toIncludedDayMonthYear) {
    return AppGetCalendarEvents.GetCalendarEvents()(
        fromIncludedDayMonthYear, toIncludedDayMonthYear);
  }
}
