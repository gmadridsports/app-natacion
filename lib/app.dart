import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gmadrid_natacion/infrastructure/SupabaseBucketsTrainingURLRepository.dart';
import 'package:gmadrid_natacion/infrastructure/SystemDateTimeRepository.dart';
import 'package:gmadrid_natacion/screens/login/login.dart';
import 'package:gmadrid_natacion/screens/training-week/training-week.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart';
import 'dependency_injection.dart';
import 'screens/profile/profile.dart';
import 'screens/splash-screen/splash-screen.dart';

Future<bool> runAppWithOptions(
    {String envName = 'prod',
    Client? httpClient,
    DependencyInjection Function(Widget child)? appConfig,
    required int year}) async {
  await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
    debug: false,
    httpClient: httpClient,
  );

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

  String? token = await messaging.getToken();

  if (kDebugMode) {
    print('Registration Token=$token');
  }

  const dateTimeRepository = SystemDateTimeRepository();

  final configToRun = appConfig ??
      (Widget child) => DependencyInjection.hydrateWithInstances(
            SupabaseBucketsTrainingURLRepository(dateTimeRepository),
            dateTimeRepository,
            child: child,
          );

  runApp(configToRun(App()));

  return true;
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'GMadrid Natación',
        // initialRoute: ,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          TrainingWeek.routeName: (context) => TrainingWeek(),
          SplashScreen.routeName: (context) => SplashScreen(),
          Profile.routeName: (context) => Profile(),
          Login.routeName: (context) => Login(),
        });
    // home: Padding(
    //   padding: const EdgeInsets.all(48.0),
    //   child: Text('${this.my_year} ${this.year}'),
    // ));
  }
}
