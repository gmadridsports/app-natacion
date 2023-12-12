import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event_repository.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/application/Query.dart';

import '../../domain/calendar_event/event_day_bound.dart';
import 'get_calendar_events_response.dart';

class GetCalendarEvents implements Query {
  final CalendarEventRepository _calendarEventRepository;

  GetCalendarEvents()
      : _calendarEventRepository =
            DependencyInjection().getInstanceOf<CalendarEventRepository>();

  /// the dates will be treated as it they were from Madrid local time, irrespective of their timezone
  /// i.e.
  /// 20/01/2024 15:00 UTC -> will be treated as 20/01/2024 15:00 Europe/Madrid
  Future<GetCalendarEventsResponse> call(DateTime fromIncludedDayMonthYear,
      DateTime toIncludedDayMonthYear) async {
    final boundFrom = EventDayBound.fromDateTimeUtc(
        fromIncludedDayMonthYear, EventDayBoundType.lowerBound);
    final boundTo = EventDayBound.fromDateTimeUtc(
        toIncludedDayMonthYear, EventDayBoundType.upperBound);

    final eventsToReturn = await _calendarEventRepository
        .getCalendarEventsStarting(boundFrom, boundTo);

    return GetCalendarEventsResponse.fromDomain(eventsToReturn);
  }
}
