import 'dart:convert';

import 'package:gmadrid_natacion/Context/Natacion/domain/event/event_day_bound.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Shared/application/Query.dart';
import '../../domain/TrainingRepository.dart';

import 'package:timezone/standalone.dart' as tz;

import 'get_calendar_events_response.dart';

class GetCalendarEvents implements Query {
  final TrainingRepository _trainingRepository;

  GetCalendarEvents()
      : _trainingRepository =
            DependencyInjection().getInstanceOf<TrainingRepository>();

  /// the dates will be treated as it they were from Madrid local time, irrespective of their timezone
  /// i.e.
  /// 20/01/2024 15:00 UTC -> will be treated as 20/01/2024 15:00 Europe
  Future<GetCalendarEventsResponse> call(DateTime fromIncludedDayMonthYear,
      DateTime toIncludedDayMonthYear) async {
    print('called');
    var madrid = tz.getLocation('Europe/Madrid');
    var tzFrom = tz.TZDateTime(
        madrid,
        fromIncludedDayMonthYear.year,
        fromIncludedDayMonthYear.month,
        fromIncludedDayMonthYear.day,
        fromIncludedDayMonthYear.hour,
        fromIncludedDayMonthYear.minute,
        fromIncludedDayMonthYear.second,
        fromIncludedDayMonthYear.millisecond,
        fromIncludedDayMonthYear.microsecond);
    var tzTo = tz.TZDateTime(
        madrid,
        toIncludedDayMonthYear.year,
        toIncludedDayMonthYear.month,
        toIncludedDayMonthYear.day,
        toIncludedDayMonthYear.hour,
        toIncludedDayMonthYear.minute,
        toIncludedDayMonthYear.second,
        toIncludedDayMonthYear.millisecond,
        toIncludedDayMonthYear.microsecond);

    // final lowerEventDayBound =
    //     EventDayBound.fromDateTime(tzFrom, EventDayBoundType.lowerBound);
    // final upperEventDayBound =
    //     EventDayBound.fromDateTime(tzTo, EventDayBoundType.upperBound);

    print('lower event bound: $tzFrom');
    print('upper event bound: $tzTo');
    final dayBuckets = Iterable<int>.generate(
        toIncludedDayMonthYear.difference(fromIncludedDayMonthYear).inDays);

    final Map<DateTime, List<CalendarEvent>> eventsToReturn = {
      for (int dayPos in dayBuckets)
        DateTime(fromIncludedDayMonthYear.year, fromIncludedDayMonthYear.month,
            fromIncludedDayMonthYear.day + dayPos): []
    };
    print("events to return: $eventsToReturn");

    final res =
        await Supabase.instance.client.functions.invoke('calendar-events',
            body: {
              'fromIncluded': tzFrom.millisecondsSinceEpoch,
              'toIncluded': tzTo.millisecondsSinceEpoch
            },
            responseType: ResponseType.text);

    final data = json.decode(res.data);

    for (final event in data['items']) {
      print(event['start']['dateTime']);

      final eventDateTime = tz.TZDateTime.from(
          (DateTime.parse(event['start']['dateTime'])), madrid);
      print('daytime> $eventDateTime');
      final dayKey =
          DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);
      eventsToReturn[dayKey]?.add(CalendarEvent(event['summary'],
          event['description'], DateTime.now(), DateTime.now(), 'ocio'));
    }
    print(eventsToReturn);
    return GetCalendarEventsResponse(eventsToReturn);
  }
}
