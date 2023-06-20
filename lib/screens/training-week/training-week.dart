import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gmadrid_natacion/screens/NamedRouteScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:week_of_year/date_week_extensions.dart';

import '../../dependency_injection.dart';
import '../../models/TrainingDate.dart';

class TrainingWeek extends StatefulWidget implements NamedRouteScreen {
  @override
  static String get routeName => '/training-week';

  @override
  State<TrainingWeek> createState() => _TrainingWeekState();
}

// move into infra?
extension ToPrimitiveTrainingDate on TrainingDate {
  DateTime toDateTime() {
    final stringToParse = '${this.toString()}T00:00:00Z';
    return DateTime.parse(stringToParse);
  }
}

enum _TrainingShowError { loading, noErrors, noTrainingsFound }

enum _Loading { initialLoading, pdfLoading, loaded, error }

class _TrainingWeekState extends State<TrainingWeek> {
  late DateTime _now;
  bool _isCalendarSelectorLoading = true;
  late DateTime _calendarSelectionLowerBound;
  late DateTime _calendarSelectionUpperBound;
  late DateTime _calendarSelectorSelectedDay;
  late bool _isCalendarSelectorWeekAvailable;
  // late int _calendarSelectorWeekOfYearDisplayed;

  _Loading _loading = _Loading.pdfLoading;

  Future<Uint8List> _testDownload() async {
    // // throw Exception('Test to see it in crashlytics');
    final downloadedPdf = await DependencyInjection.of(context)!
        .trainingRepository
        .getTrainingPDF(TrainingDate.from(2023, 4, 24));
    return downloadedPdf;
  }

  void _loadFirstCalendarProps() async {
    TrainingDate? firstTrainingDate = (await DependencyInjection.of(context)!
            .trainingRepository
            .getFirstTrainingDate())
        ?.firstTrainingDateWithinTheWeek();

    final lastTrainingDate = (await DependencyInjection.of(context)!
        .trainingRepository
        .getLastTrainingDate());

    if (firstTrainingDate == null || lastTrainingDate == null) {
      // _calendarSelectionLowerBound = _now;
      // _calendarSelectionUpperBound = _now;
      // todo handle no training dates
      return;
    }

    TrainingDate lastUsefulTrainingDate =
        lastTrainingDate.lastTrainingDateWithinTheWeek();

    setState(() {
      _calendarSelectionUpperBound = lastUsefulTrainingDate.toDateTime();
      _calendarSelectionLowerBound = firstTrainingDate.toDateTime();
      // _calendarSelectorWeekOfYearDisplayed =
      //     lastTrainingDate.toDateTime().weekOfYear;
      _isCalendarSelectorWeekAvailable = true;
      _calendarSelectorSelectedDay = lastTrainingDate.toDateTime();

      _isCalendarSelectorLoading = false;
    });
  }

  @override
  void didChangeDependencies() async {
    _isCalendarSelectorLoading = true;
    _now = DependencyInjection.of(context)!.dateTimeRepository.now();
    _calendarSelectorSelectedDay = _now;
    _calendarSelectionLowerBound = _now;
    _calendarSelectionUpperBound = _now;
    _isCalendarSelectorWeekAvailable = false;

    _loadFirstCalendarProps();
  }

  @override
  Widget build(BuildContext context) {
    print(_calendarSelectorSelectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text('GMadrid Natación'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (_loading != _Loading.initialLoading)
              TableCalendar(
                  locale: 'es_ES',
                  calendarFormat: CalendarFormat.week,
                  availableCalendarFormats: const {
                    CalendarFormat.week: 'Semana',
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  firstDay: _calendarSelectionLowerBound,
                  lastDay: _calendarSelectionUpperBound,
                  focusedDay: _calendarSelectorSelectedDay,
                  selectedDayPredicate: (day) {
                    // print(day);
                    // print(_calendarSelectorSelectedDay);
                    // print('--');
                    return (!_isCalendarSelectorLoading &&
                        _isCalendarSelectorWeekAvailable &&
                        day == _calendarSelectorSelectedDay);
                  },
                  enabledDayPredicate: (day) =>
                      !_isCalendarSelectorLoading &&
                      _isCalendarSelectorWeekAvailable,
                  onPageChanged: _onCalendarSelectorChangeWeek,
                  onDaySelected: _onCalendarSelectorChangeDay,
                  pageJumpingEnabled: false,
                  calendarBuilders: CalendarBuilders(
                    outsideBuilder: (context, day, _) {
                      return Center(
                        child: Text(
                          '${day.day}',
                        ),
                      );
                    },
                  )),
            const Expanded(
              child: const Center(child: const CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  void _onCalendarSelectorChangeDay(DateTime date, _) async {
    setState(() {
      _calendarSelectorSelectedDay = date;
    });
  }

  void _onCalendarSelectorChangeWeek(DateTime date) async {
    setState(() {
      _isCalendarSelectorLoading = true;
      _calendarSelectorSelectedDay = date;
    });

    if (!await DependencyInjection.of(context)!
        .trainingRepository
        .trainingExistsForWeek(
            TrainingDate.fromDateTime(date).firstTrainingDateWithinTheWeek())) {
      setState(() {
        _isCalendarSelectorWeekAvailable = false;
        _isCalendarSelectorLoading = false;
      });

      return;
    }

    setState(() {
      _isCalendarSelectorLoading = false;
      _isCalendarSelectorWeekAvailable = true;
    });
  }
}
