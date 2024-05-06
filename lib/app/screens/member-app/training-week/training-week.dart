import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gmadrid_natacion/app/screens/member-app/RefreshTrainingWeekEvent.dart';
import 'package:gmadrid_natacion/app/screens/member-app/launchURL.dart';
import 'package:gmadrid_natacion/app/screens/member-app/member_app.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_bus/event_bus.dart' as LibEventBus;
import '../../../../Context/Natacion/application/TrainingDate/GetTrainingBoundariesResponse.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/queries/get_training_dates_boundaries.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/queries/get_training_pdf.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/queries/is_a_trainining_week.dart';
import '../../../../shared/domain/DateTimeRepository.dart';
import '../../../../Context/Natacion/domain/TrainingDate.dart';
import '../../NamedRouteScreen.dart';

class TrainingWeek extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => "${MemberApp.routeName}/training-week";

  const TrainingWeek({super.key});

  @override
  State<TrainingWeek> createState() => _TrainingWeekState();
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
    // todo handle errors while retrieving

    final downloadedPdf =
        (await GetTrainingPDF()(_calendarSelectorSelectedDay)).rawBytes;
    setState(() {
      _pdfRaw = downloadedPdf;
      _isTrainingLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    DependencyInjection()
        .getInstanceOf<LibEventBus.EventBus>()
        .on<RefreshTrainingWeekEvent>()
        .listen((event) async {
      _isInInitialLoading = true;
      _isCalendarSelectorLoading = true;
      _isTrainingLoading = true;
      _trainingDateShowed = null;

      _loadFirstCalendarProps();
    });
  }

  void _loadFirstCalendarProps() async {
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
    return Container(
      color: Colors.white,
      child: (Center(
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
                  : SfPdfViewer.memory(_pdfRaw, maxZoomLevel: 7.0,
                      onHyperlinkClicked: (details) {
                      launchURL(details.uri, context);
                    }),
            ),
          ],
        ),
      )),
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
