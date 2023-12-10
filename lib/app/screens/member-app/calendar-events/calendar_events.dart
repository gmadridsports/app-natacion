import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gmadrid_natacion/shared/domain/DateTimeRepository.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../Context/Natacion/application/get_calendar_events/get_calendar_events_response.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/queries/get_calendar_events.dart';
import '../../../../shared/dependency_injection.dart';
import '../launchURL.dart';

class CalendarEvents extends StatefulWidget {
  const CalendarEvents({super.key});

  @override
  State<CalendarEvents> createState() => _CalendarEventsState();
}

class _CalendarEventsState extends State<CalendarEvents> {
  final DateTimeRepository _dateTimeRepository;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  late DateTime _selected;
  int? _selectedEventDayItem = null;
  bool _isLoadingEvents = true;
  Map<DateTime, List<CalendarEvent>> _events = {};
  bool _shouldShowErrorLoading = false;

  _CalendarEventsState()
      : _dateTimeRepository =
            DependencyInjection().getInstanceOf<DateTimeRepository>();

  @override
  void initState() {
    super.initState();
    _selected = _dateTimeRepository.now();
    _loadCurrentMonthEvents();
  }

  void _loadCurrentMonthEvents() async {
    setState(() {
      _shouldShowErrorLoading = false;
      _isLoadingEvents = true;
    });

    final calendarLimits = _getCalendarLimits();

    try {
      final returnedEvents =
          await GetCalendarEvents()(calendarLimits.$1, calendarLimits.$2);

      setState(() {
        _isLoadingEvents = false;
        _events = returnedEvents.events;
        _selectedEventDayItem =
            ((_events[_selected]?.length ?? 0) == 1) ? 0 : null;
      });
    } catch (e) {
      setState(() {
        _isLoadingEvents = false;
        _shouldShowErrorLoading = true;
      });
    }
  }

  (DateTime, DateTime) _getCalendarLimits() {
    final firstDay = DateTime.utc(_selected.year, _selected.month, 1).subtract(
        Duration(
            days:
                DateTime.utc(_selected.year, _selected.month, 1).weekday - 1));
    final lastDay = DateTime.utc(_selected.year, _selected.month + 1, 0).add(
        Duration(
            days: 7 -
                DateTime.utc(_selected.year, _selected.month + 1, 0).weekday -
                1,
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
            microseconds: 999));

    return (firstDay, lastDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(00),
        color: Colors.white,
        child: Column(children: [
          TableCalendar(
              locale: 'es_ES',
              pageJumpingEnabled: false,
              eventLoader: <CalendarEvent>(day) {
                final selectedDay = DateTime.utc(day.year, day.month, day.day);
                return _events[selectedDay] ?? [];
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              enabledDayPredicate: (day) => !_isLoadingEvents,
              focusedDay: _selected,
              weekendDays: const [DateTime.saturday, DateTime.sunday],
              availableCalendarFormats: const {
                CalendarFormat.twoWeeks: 'Semana',
                CalendarFormat.month: 'Mes'
              },
              selectedDayPredicate: (day) {
                return (!_isLoadingEvents && day == _selected);
              },
              firstDay: DateTime.utc(2023, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                final focusedDayToSelect = focusedDay;
                // DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
                setState(() {
                  _selectedEventDayItem = null;
                  _selected = focusedDayToSelect;
                  _loadCurrentMonthEvents();
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedEventDayItem = null;
                  _selected = selectedDay;
                  _selectedEventDayItem =
                      ((_events[_selected]?.length ?? 0) == 1) ? 0 : null;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (_shouldShowErrorLoading || _isLoadingEvents) return null;

                  if (events.isEmpty) return null;

                  return Container(
                      height: 20,
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 20,
                        width: 25,
                        padding: EdgeInsets.all(3),
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        // color: Colors.blue,
                        child: Text('${events.length}',
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                      ));
                },
              )),
          Expanded(
              child: _isLoadingEvents
                  ? const Center(child: CircularProgressIndicator())
                  : _shouldShowErrorLoading
                      ? (Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.error_outline_rounded,
                                  size: 40, color: Colors.orange),
                            ),
                            const Text(
                                "Uy, ha ocurrido un error al cargar los eventos",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.center),
                            TextButton(
                                onPressed: () {
                                  _loadCurrentMonthEvents();
                                },
                                child: const Text("Reintentar",
                                    style: TextStyle(fontSize: 16)))
                          ],
                        )))
                      : (_events[_selected]?.length ?? 0) == 0
                          ? const Center(
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.event_busy_outlined,
                                      size: 40, color: Colors.blue),
                                ),
                                Text("Ningún evento para esta fecha."),
                              ],
                            ))
                          : SingleChildScrollView(
                              child: ExpansionPanelList(
                                  expansionCallback: (int index, bool value) {
                                    setState(() {
                                      _selectedEventDayItem =
                                          value ? index : null;
                                      // selected = (selected == index) ? -1 : index;
                                    });
                                  },
                                  children: [
                                  for (var i = 0;
                                      i < (_events[_selected]?.length ?? 0);
                                      i++)
                                    ExpansionPanel(
                                        isExpanded: i == _selectedEventDayItem,
                                        headerBuilder: (BuildContext context,
                                                bool isExpanded) =>
                                            ListTile(
                                              // leading: Icon(Icons.person),
                                              title: Text(
                                                  _events[_selected]![i].title),
                                              onTap: () {
                                                setState(() {
                                                  _selectedEventDayItem == i
                                                      ? _selectedEventDayItem =
                                                          null
                                                      : _selectedEventDayItem =
                                                          i;
                                                });
                                              },
                                            ),
                                        body: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 0, 0, 20),
                                            alignment: Alignment.topLeft,
                                            child: MarkdownBody(
                                              onTapLink: (text, href, title) {
                                                launchURL(
                                                    href.toString(), context);
                                              },
                                              data: _events[_selected]![i]
                                                  .description,
                                              selectable: true,
                                            )))
                                ])))
        ]));
  }
}
