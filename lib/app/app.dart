import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import 'package:event_bus/event_bus.dart' as LibEventBus;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart';
import '../Context/Natacion/domain/screen/ChangedCurrentScreenDomainEvent.dart';
import '../Context/Natacion/infrastructure/supabase_user_status_listener.dart';
import '../Context/Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';
import '../conf/dependency_injections.dart';
import './screens/profile/profile.dart';
import './screens/splash-screen/splash-screen.dart';
import 'screens/login/login.dart';
import 'screens/training-week/training-week.dart';
import 'screens/waiting-approval/waiting-approval.dart';

Future<bool> runAppWithOptions({
  String envName = 'prod',
  Client? httpClient,
  Function()? appConfig,
}) async {
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

  try {
    String? token = await messaging.getToken();
    if (kDebugMode) {
      print('Registration Token=$token');
    }
  } catch (e) {
    print('Error getting token');
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
  }

  (appConfig ??
      () {
        DependencyInjection(instances: dependencyInjectionInstances());
      })();

  SupabaseUserStatusListener();

  runApp(App());

  return true;
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DependencyInjection()
        .getInstanceOf<LibEventBus.EventBus>()
        .on<AppEventType>()
        .listen((event) {
      if (event.payload.eventName !=
          ChangedCurrentScreenDomainEvent.EVENT_NAME) {
        return;
      }

      _navigator.currentState?.pushReplacementNamed(
          (event.payload as ChangedCurrentScreenDomainEvent).newScreenName);
    });

    return MaterialApp(
        title: 'GMadrid Natación',
        // initialRoute: ,
        navigatorKey: _navigator,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          WaitingApproval.routeName: (context) => WaitingApproval(),
          TrainingWeek.routeName: (context) => TrainingWeek(),
          SplashScreen.routeName: (context) => SplashScreen(),
          Profile.routeName: (context) => Profile(),
          Login.routeName: (context) => Login(),
          // WaitingMembership.routeName: (context) => WaitingMembership(),
        });
  }
}
