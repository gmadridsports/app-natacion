import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import '../../../Shared/domain/date_time/madrid_date_time.dart';

class CalendarEvent extends AggregateRoot {
  final String id;
  final String title;
  final String bodyMarkdown;
  final MadridDateTime startDate;
  final MadridDateTime endDate;

  CalendarEvent._internal(
      this.id, this.title, this.bodyMarkdown, this.startDate, this.endDate);

  CalendarEvent.from(String id, String title, String bodyMarkdown,
      MadridDateTime startDate, MadridDateTime endDate)
      : this._internal(id, title, bodyMarkdown.replaceAll('\\n', '\n'),
            startDate, endDate);
}
