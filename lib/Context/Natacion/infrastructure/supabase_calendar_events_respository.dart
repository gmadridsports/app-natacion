import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event_repository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day_bound.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:timezone/standalone.dart' as tz;

import '../../Shared/domain/date_time/madrid_date_time.dart';
import '../domain/calendar_event/calendar_event.dart';

class SupabaseCalendarEventsRepository implements CalendarEventRepository {
  @override
  Future<Map<EventDay, List<CalendarEvent>>> getCalendarEventsStarting(
      EventDayBound from, EventDayBound to) async {
    final dayBuckets = Iterable<int>.generate(to.daysDifference(from) + 2);

    final Map<EventDay, List<CalendarEvent>> eventsToReturn = {
      for (int dayPos in dayBuckets)
        EventDay.fromDateTimeUtc(from.dateTimeUtc.add(Duration(days: dayPos))):
            []
    };

    final res = await Supabase.instance.client.functions
        .invoke('calendar-events', body: {
      'fromIncluded': from.millisecondsSinceEpochInt,
      'toIncluded': to.millisecondsSinceEpochInt
    });
    final data = res.data;

    // we could move this into a domain service, or value object.
    // this way, we could test this properly with an integration test, starting from the JSON response.
    for (final event in data['items']) {
      final eventStartDateTime = tz.TZDateTime.from(
          (DateTime.parse(
              event['start']['dateTime'] ?? event['start']['date'])),
          tz.getLocation(event['start']['timeZone'] ?? 'Europe/Madrid'));
      final eventEndDateTime = tz.TZDateTime.from(
          (DateTime.parse(event['end']['dateTime'] ?? event['end']['date'])),
          tz.getLocation(event['end']['timeZone'] ?? 'Europe/Madrid'));

      final calendarEvent = CalendarEvent.from(
        'id',
        event['summary'],
        event['description'],
        MadridDateTime.fromDateTimeUtc(DateTime.utc(
            eventStartDateTime.year,
            eventStartDateTime.month,
            eventStartDateTime.day,
            eventStartDateTime.hour,
            eventStartDateTime.minute,
            eventStartDateTime.second,
            eventStartDateTime.millisecond,
            eventStartDateTime.microsecond)),
        MadridDateTime.fromDateTimeUtc(DateTime.utc(
            eventEndDateTime.year,
            eventEndDateTime.month,
            eventEndDateTime.day,
            eventEndDateTime.hour,
            eventEndDateTime.minute,
            eventEndDateTime.second,
            eventEndDateTime.millisecond,
            eventEndDateTime.microsecond)),
      );

      final daysBuckets = [
        for (var day = 0;
            day <
                (eventEndDateTime.difference(eventStartDateTime).inDays < 1
                    ? 1
                    : eventEndDateTime.difference(eventStartDateTime).inDays);
            day++)
          EventDay.fromDateTimeUtc(DateTime.utc(eventStartDateTime.year,
                  eventStartDateTime.month, eventStartDateTime.day)
              .add(Duration(days: day)))
      ];

      daysBuckets.forEach((dayKey) {
        eventsToReturn[dayKey]?.add(calendarEvent);
      });
    }

    return eventsToReturn;
  }
}
