import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gmadrid_natacion/infrastructure/SupabaseBucketsTrainingURLRepository.dart';
import 'package:gmadrid_natacion/infrastructure/SystemDateTimeRepository.dart';
import 'package:gmadrid_natacion/models/DateTimeRepository.dart';
import 'package:gmadrid_natacion/models/TrainingDate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart';
import 'dependency_injection.dart';
import 'firebase_options.dart';
import 'package:clock/clock.dart';

Future<bool> runAppWithOptions(
    {String envFileName = 'assets/.prod.env',
    Client? httpClient,
    DependencyInjection Function(Widget child)? appConfig,
    required int year}) async {
  await dotenv.load(fileName: envFileName, mergeWith: {});

  await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
      debug: false,
      httpClient: httpClient);

  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print(fcmToken);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    print('new token');
    print(fcmToken);
    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
  }).onError((err) {
    // Error getting token.
    print('error refreshing token');
    throw (err);
  });

  // todo improve this
  final configToRun = appConfig ??
      (Widget child) => DependencyInjection.hydrateWithInstances(
            SupabaseBucketsTrainingURLRepository(),
            SystemDateTimeRepository(),
            child: child,
          );

  runApp(configToRun(App(clock.now().year)));

  return true;
}

class AppError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('error!'),
    );
  }
}

class App extends StatelessWidget {
  final int year;
  late final int my_year;
  MyHomePage hp = MyHomePage(
    title: 'GMadrid Natación ',
  );

  App(this.year, {super.key}) {
    this.my_year = clock.now().year;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final year = clock.now().year;
    return MaterialApp(
        title:
            'GMadrid Natación ${DependencyInjection.of(context)!.dateTimeRepository.now().year} ${year}',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: hp);
    // home: Padding(
    //   padding: const EdgeInsets.all(48.0),
    //   child: Text('${this.my_year} ${this.year}'),
    // ));
  }
}

class MyHomePage extends StatefulWidget {
  late final int my_year;

  MyHomePage({super.key, required this.title}) {
    this.my_year = clock.now().year;
  }

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  String? _trainingURL = null;
  Uint8List? _trainingPDF = null;
  final kToday = clock.now();
  late final kFirstDay;
  // DateTime(clock.now().year, clock.now().month - 3, clock.now().day);
  late final kLastDay;
  // DateTime(clock.now().year, clock.now().month + 3, clock.now().day);

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_trainingURL != null) {
      return;
    }

    final now = DependencyInjection.of(context)!.dateTimeRepository.now();
    _focusedDay = now;
    kFirstDay = DateTime(now.year, now.month - 3, now.day);
    kLastDay = DateTime(now.year, now.month + 3, now.day);

    print('------');
    print(_focusedDay);
    final firstTraining = await DependencyInjection.of(context)!
        .trainingRepository
        .getTrainingURL(TrainingDate.from(2023, 4, 24));
    //
    // // throw Exception('Test to see it in crashlytics');
    final downloadedPdf = await DependencyInjection.of(context)!
        .trainingRepository
        .getTrainingPDF(TrainingDate.from(2023, 4, 24));

    setState(() {
      _trainingURL = firstTraining;
      _trainingPDF = downloadedPdf;
    });
  }

  void _incrementCounter() async {
    setState(() {
      _trainingURL = null;
    });

    final downloadedTrainings =
        await Supabase.instance.client.storage.listBuckets();

    downloadedTrainings.forEach((element) {
      print(element.name);
    });

    final trainingURLToShow = await DependencyInjection.of(context)!
        .trainingRepository
        .getTrainingURL(TrainingDate.from(2023, 4, 17));

    final trainingPDFToShow = await DependencyInjection.of(context)!
        .trainingRepository
        .getTrainingPDF(TrainingDate.from(2023, 4, 17));

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _file = downloadedTraining;
      _trainingURL = trainingURLToShow;
      _trainingPDF = trainingPDFToShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('GMadrid Natación'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              currentDay: _focusedDay,
              calendarFormat: _calendarFormat,
              // selectedDayPredicate: (day) {
              //   // Use `selectedDayPredicate` to determine which day is currently selected.
              //   // If this returns true, then `day` will be marked as selected.
              //
              //   // Using `isSameDay` is recommended to disregard
              //   // the time-part of compared DateTime objects.
              //   return isSameDay(_selectedDay, day);
              // }
            ),
            Expanded(
              child: _trainingURL != null
                  ? SfPdfViewer.memory(_trainingPDF!)
                  : Center(child: CircularProgressIndicator()),
            ),
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
