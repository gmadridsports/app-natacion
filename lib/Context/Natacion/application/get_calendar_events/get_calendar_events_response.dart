import '../../../Shared/application/QueryResponse.dart';

class CalendarEvent {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String type;

  CalendarEvent(
      this.title, this.description, this.startDate, this.endDate, this.type);
}

class GetCalendarEventsResponse implements QueryResponse {
  final Map<DateTime, List<CalendarEvent>> events;

  GetCalendarEventsResponse(this.events);
}
