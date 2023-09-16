import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/Training/GetTrainingPDF.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/TrainingDate/GetTrainingDatesBoundaries.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/TrainingDate/IsATrainingWeek.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../Context/Natacion/application/LogoutUser/LogoutUser.dart';
import '../../../Context/Natacion/application/TrainingDate/GetTrainingBoundariesResponse.dart';
import '../../../shared/domain/DateTimeRepository.dart';
import '../../../Context/Natacion/domain/TrainingDate.dart';
import '../NamedRouteScreen.dart';
import '../splash-screen/splash-screen.dart';

class TrainingWeek extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => '/training-week';

  @override
  State<TrainingWeek> createState() => _TrainingWeekState();
}

// todo socio-xx-xx move into infra?
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
  final DateTimeRepository _dateTimeRepository;

  _TrainingWeekState()
      : _dateTimeRepository =
            DependencyInjection().getInstanceOf<DateTimeRepository>();

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

    final downloadedPdf =
        (await GetTrainingPDF()(_calendarSelectorSelectedDay)).rawBytes;
    setState(() {
      _pdfRaw = downloadedPdf;
      _isTrainingLoading = false;
    });
  }

  void _loadFirstCalendarProps() async {
    // todo socio-xx-xx continue here
    final trainingBoundaries = await GetTrainingDatesBoundaries()();

    if (trainingBoundaries is GetTrainingBoundariesNegativeResponse) {
      return;
    }

    trainingBoundaries as GetTrainingBoundariesPositiveResponse;
    setState(() {
      _calendarSelectionUpperBound = trainingBoundaries.upperBound;
      _calendarSelectionLowerBound = trainingBoundaries.lowerBound;
      _isCalendarSelectorWeekAvailable = true;
      _calendarSelectorSelectedDay = trainingBoundaries.lastTrainingDate;
      _isCalendarSelectorLoading = false;
      _isInInitialLoading = false;
    });

    _loadTrainingPDF();
  }

  @override
  void didChangeDependencies() async {
    _isCalendarSelectorLoading = true;
    _now = _dateTimeRepository.now();
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
                LogoutUser()();
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.event_note), label: 'Entrenos'),
            BottomNavigationBarItem(icon: Icon(Icons.pool), label: 'Piscinas'),
            BottomNavigationBarItem(
                icon: Icon(
                  key: Key('exit'),
                  Icons.exit_to_app,
                  semanticLabel: 'Salir',
                ),
                label: 'Salir')
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

    if (!(await IsATrainingWeek()(date)).isATrainingWeek) {
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
