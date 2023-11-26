import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

import '../launchURL.dart';

class CalendarEvents extends StatefulWidget {
  const CalendarEvents({super.key});

  @override
  State<CalendarEvents> createState() => _CalendarEventsState();
}

class MyEvent {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String type;

  MyEvent(
      this.title, this.description, this.startDate, this.endDate, this.type);
}

final events = [
  MyEvent(
      '✨👙🐚 EVENTO BIENVENIDA TEMPORADA 23/24 🏊🏾🧜🏼‍♀👩‍👩‍👧‍👦',
      """
Sirenas y pececillos:
Ya llevamos más de un mes de temporada, hay muchas caras nuevas y entre series en los entrenos no da tiempo a conocerse 😜 Por eso desde el comité de eventos queremos organizar algo y hemos pensado en una excursioncita al **Parque de Atracciones de Madrid**, también por recuperar una tradición perdida 🥰

Si somos 20+ sirenes podemos conseguir el descuento por grupo y entrar por 23,90€. En el Parque de Atracciones puedes llevar tu propia comida y bebida 🦐🍹hay una zona de picnic donde poder consumirla. ¡Animense que seguro que lo pasamos bien (como en todos los eventos 😋) y será una buena ocasión para hacer nuevos amiguis y conocernos mejor antiguas, nuevos y veteranes ❤️‍🔥

Lanzamos votación para elegir el día 🍁🍂 Porfa, para tener una idea de cuanta gente se apuntaría, vota aunque te vengan bien las tres opciones, se puede votar más de una a [este enlace](https://gmadridnatacion.bertamini.net)""",
      DateTime(2021, 12, 12),
      DateTime(2021, 12, 12),
      'Tipo 1'),
  MyEvent('Evento 2', 'Descripción 2', DateTime(2021, 12, 12),
      DateTime(2021, 12, 12), 'Tipo 2'),
  MyEvent('Evento 3', 'Descripción 3', DateTime(2021, 12, 12),
      DateTime(2021, 12, 12), 'Tipo 3'),
  MyEvent('Evento 4', 'Descripción 4', DateTime(2021, 12, 12),
      DateTime(2021, 12, 12), 'Tipo 4'),
  MyEvent('Evento 5', 'Descripción 5', DateTime(2021, 12, 12),
      DateTime(2021, 12, 12), 'Tipo 5'),
  MyEvent('Evento 6', 'Descripción 6', DateTime(2021, 12, 12),
      DateTime(2021, 12, 12), 'Tipo 6'),
  MyEvent('Evento 7', 'Descripción 7', DateTime(2021, 12, 12),
      DateTime(2021, 12, 12), 'Tipo 7'),
];

// todo test calling supabase edge
Future<Map<DateTime, List<MyEvent>>> _getEvents(
    DateTime fromIncluded, DateTime toIncluded) async {
  final dayBuckets =
      Iterable<int>.generate(toIncluded.difference(fromIncluded).inDays);

  final Map<DateTime, List<MyEvent>> eventsToReturn = {
    for (int dayPos in dayBuckets)
      DateTime(
          fromIncluded.year, fromIncluded.month, fromIncluded.day + dayPos): []
  };

  // todo handle errors
  final res = await Supabase.instance.client.functions.invoke('calendar-events',
      body: {
        'fromIncluded': fromIncluded.millisecondsSinceEpoch.toString(),
        'toIncluded': toIncluded.millisecondsSinceEpoch.toString()
      },
      responseType: ResponseType.text);
  final data = json.decode(res.data);

  for (final event in data['items']) {
    final eventDateTime = (DateTime.parse(event['start']['dateTime']));
    final dayKey =
        DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);
    eventsToReturn[dayKey]?.add(MyEvent(event['summary'], event['description'],
        DateTime.now(), DateTime.now(), 'ocio'));
  }

  return eventsToReturn;
}

class _CalendarEventsState extends State<CalendarEvents> {
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  int selected = 0;
  bool _isLoadingEvents = true;
  List<MyEvent> _events = [];

  // final List<bool> _states = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    // _states.addAll([for (var event in events) false]);
    _loadEvents();
  }

  // todo into the bounded context
  void _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
    });

    final returnedEvents = await _getEvents(
        DateTime.now(), DateTime.now().add(Duration(days: 30)));

    final newEvents = returnedEvents[
            DateTime(DateTime.now().year, DateTime.now().month, 27)] ??
        [];

    setState(() {
      _isLoadingEvents = false;
      _events = newEvents;
    });

    // // todo load events from supabase
    // final res = await Supabase.instance.client.functions
    //     .invoke('calendar-events', body: {}, responseType: ResponseType.text);
    // final data = json.decode(res.data);
    // print(res);
    //
    // _isLoadingEvents = false;
    // print(data);
    //
    // final newEvents = _events;
    // for (final event in data['items']) {
    //   print(event['summary']);
    //   newEvents.add(MyEvent(event['summary'], event['description'],
    //       DateTime.now(), DateTime.now(), 'ocio'));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(00),
        color: Colors.white,
        child: Column(children: [
          TableCalendar(
              locale: 'es_ES',
              pageJumpingEnabled: false,
              eventLoader: (day) {
                return [events[0], events[5]];
                // return [events[0], events[5]];
              },
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: (context, day, events) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, day, events) {
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
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ));
                },
                outsideBuilder: (context, day, _) {
                  return Center(
                    child: Text(
                      '${day.day}',
                    ),
                  );
                },
              ),
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              }),
          Expanded(
              child: _isLoadingEvents
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: ExpansionPanelList(
                          expansionCallback: (int index, bool value) {
                            setState(() {
                              selected = (selected == index) ? -1 : index;
                            });
                          },
                          children: [
                          for (var i = 0; i < _events.length; i++)
                            ExpansionPanel(
                                isExpanded: i == selected,
                                headerBuilder: (BuildContext context,
                                        bool isExpanded) =>
                                    ListTile(
                                      // leading: Icon(Icons.person),
                                      title: Text(_events[i].title),
                                      onTap: () {
                                        setState(() {
                                          selected = (selected == i) ? -1 : i;
                                        });
                                      },
                                    ),
                                body: Container(
                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                                    alignment: Alignment.topLeft,
                                    child: MarkdownBody(
                                      onTapLink: (text, href, title) {
                                        launchURL(href.toString(), context);
                                      },
                                      data: _events[i].description,
                                      selectable: true,
                                    )))
                        ])))
        ]));
  }
}
