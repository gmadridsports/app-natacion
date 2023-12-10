import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day_time.dart';

import '../../../Shared/application/QueryResponse.dart';
import '../../domain/calendar_event/calendar_event.dart' as domainCalendarEvent;

class CalendarEvent {
  final String title;
  final String description;

  /// dateTime must be considered as it were on the Madrid timezone.
  /// the timezone is always on UTC, but the date time is considered as it were on the Madrid timezone.
  /// i.e. 20/01/2024 15:04 UTC -> is describing a 20/01/2024 15:04 Europe/Madrid
  final DateTime startDateMadridTz;

  /// dateTime must be considered as it were on the Madrid timezone.
  /// the timezone is always on UTC, but the date time is considered as it were on the Madrid timezone.
  /// i.e. 20/01/2024 15:04 UTC -> is describing a 20/01/2024 15:04 Europe/Madrid
  final DateTime endDateMadridTz;

  CalendarEvent(this.title, this.description, this.startDateMadridTz,
      this.endDateMadridTz);
}

extension on EventDay {
  DateTime get toUtcMadridTz =>
      DateTime.fromMicrosecondsSinceEpoch(microSecondsSinceEpoch).toUtc();
}

extension on EventDayTime {
  DateTime get toUtcMadridTz {
    return DateTime.fromMicrosecondsSinceEpoch(microSecondsSinceEpoch).toUtc();
  }
}

class GetCalendarEventsResponse implements QueryResponse {
  /// dateTime must be considered as it were on the Madrid timezone.
  /// the timezone is always on UTC, but the date time is considered as it were on the Madrid timezone.
  /// i.e. 20/01/2024 15:04 UTC -> is describing a 20/01/2024 15:04 Europe/Madrid
  final Map<DateTime, List<CalendarEvent>> events;

  GetCalendarEventsResponse._internal(this.events);

  GetCalendarEventsResponse.fromDomain(
      Map<EventDay, List<domainCalendarEvent.CalendarEvent>> events)
      : this._internal(events.map((key, value) {
          return MapEntry(
              key.toUtcMadridTz,
              value
                  .map((e) => CalendarEvent(e.title, e.bodyMarkdown,
                      e.startDate.toUtcMadridTz, e.endDate.toUtcMadridTz))
                  .toList());
        }));
}
