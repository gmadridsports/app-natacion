import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gmadrid_natacion/screens/NamedRouteScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:week_of_year/date_week_extensions.dart';

import '../../dependency_injection.dart';
import '../../domain/TrainingDate.dart';
import '../profile/profile.dart';
import '../splash-screen/splash-screen.dart';

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

class _TrainingWeekState extends State<TrainingWeek> {
  late DateTime _now;
  bool _isCalendarSelectorLoading = true;
  bool _isTrainingLoading = true;
  bool _isInInitialLoading = true;
  late DateTime _calendarSelectionLowerBound;
  late DateTime _calendarSelectionUpperBound;
  late DateTime _calendarSelectorSelectedDay;
  late bool _isCalendarSelectorWeekAvailable;

  TrainingDate? _trainingDateShowed;
  late Uint8List _pdfRaw;
  // late int _calendarSelectorWeekOfYearDisplayed;

  void _loadTrainingPDF() async {
    final trainingDatePdfShowing =
        TrainingDate.fromDateTime(_calendarSelectorSelectedDay)
            .firstTrainingDateWithinTheWeek();

    if (trainingDatePdfShowing == _trainingDateShowed) {
      return;
    }

    setState(() {
      _trainingDateShowed = trainingDatePdfShowing;
      _isTrainingLoading = true;
    });
    // todo handle error

    final downloadedPdf = await DependencyInjection.of(context)!
        .trainingRepository
        .getTrainingPDF(TrainingDate.fromDateTime(_calendarSelectorSelectedDay)
            .firstTrainingDateWithinTheWeek());

    setState(() {
      _pdfRaw = downloadedPdf;
      _isTrainingLoading = false;
    });
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
      _isInInitialLoading = false;
    });

    _loadTrainingPDF();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('GMadrid Natación'),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (element) async {
            switch (element) {
              case 0:
                break;
              case 1:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todavía no disponible.')),
                );
                break;
              default:
                await Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    SplashScreen.routeName, (route) => false);
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.event_note), label: 'Entrenos'),
            BottomNavigationBarItem(icon: Icon(Icons.pool), label: 'Piscinas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.exit_to_app), label: 'Salir'),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.person_2), label: 'Perfil'),
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (!_isInInitialLoading)
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
            Expanded(
              child: _isTrainingLoading == true
                  ? const Center(child: CircularProgressIndicator())
                  : SfPdfViewer.memory(_pdfRaw!),
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
    _loadTrainingPDF();
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
    _loadTrainingPDF();
  }
}
