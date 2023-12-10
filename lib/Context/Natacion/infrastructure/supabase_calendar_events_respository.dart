import 'dart:convert';

import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event_repository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day_bound.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day_time.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:timezone/standalone.dart' as tz;

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

    final res =
        await Supabase.instance.client.functions.invoke('calendar-events',
            body: {
              'fromIncluded': from.millisecondsSinceEpochInt,
              'toIncluded': to.millisecondsSinceEpochInt
            },
            responseType: ResponseType.text);

    final data = json.decode(res.data);

    for (final event in data['items']) {
      final eventStartDateTime = tz.TZDateTime.from(
          (DateTime.parse(event['start']['dateTime'])),
          tz.getLocation(event['start']['timeZone']));
      final eventEndDateTime = tz.TZDateTime.from(
          (DateTime.parse(event['end']['dateTime'])),
          tz.getLocation(event['end']['timeZone']));

      final dayKey = EventDay.fromDateTimeUtc(DateTime.utc(
          eventStartDateTime.year,
          eventStartDateTime.month,
          eventStartDateTime.day));
      eventsToReturn[dayKey]?.add(CalendarEvent.from(
        'id',
        event['summary'],
        event['description'],
        EventDayTime.fromDateTimeUtc(DateTime.utc(
            eventStartDateTime.year,
            eventStartDateTime.month,
            eventStartDateTime.day,
            eventStartDateTime.hour,
            eventStartDateTime.minute,
            eventStartDateTime.second,
            eventStartDateTime.millisecond,
            eventStartDateTime.microsecond)),
        EventDayTime.fromDateTimeUtc(DateTime.utc(
            eventEndDateTime.year,
            eventEndDateTime.month,
            eventEndDateTime.day,
            eventEndDateTime.hour,
            eventEndDateTime.minute,
            eventEndDateTime.second,
            eventEndDateTime.millisecond,
            eventEndDateTime.microsecond)),
      ));
    }

    return eventsToReturn;
  }
}
