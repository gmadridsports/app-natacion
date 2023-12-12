import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import 'event_day_time.dart';

class CalendarEvent extends AggregateRoot {
  final String id;
  final String title;
  final String bodyMarkdown;
  final EventDayTime startDate;
  final EventDayTime endDate;

  CalendarEvent._internal(
      this.id, this.title, this.bodyMarkdown, this.startDate, this.endDate);

  CalendarEvent.from(String id, String title, String bodyMarkdown,
      EventDayTime startDate, EventDayTime endDate)
      : this._internal(id, title, bodyMarkdown.replaceAll('\\n', '\n'),
            startDate, endDate);
}
