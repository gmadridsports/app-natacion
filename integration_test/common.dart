import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/Context/Natacion/infrastructure/supabase_user_status_listener.dart';
import 'package:gmadrid_natacion/app/app.dart';
import 'package:gmadrid_natacion/conf/dependency_injections.dart';
import 'package:gmadrid_natacion/firebase_options.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:patrol/patrol.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

final _patrolTesterConfig = PatrolTesterConfig();
final _nativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20), // 10 seconds is too short for some CIs
);

Future<void> createApp(PatrolIntegrationTester $, Function()? appConfig) async {
  const envName = const String.fromEnvironment('ENV', defaultValue: 'prod');
  await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
    debug: false,
    // httpClient: httpClient,
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

  await $.pumpWidget(App());
}

void patrol(
  String description,
  Future<void> Function(PatrolIntegrationTester) callback, {
  bool? skip,
  NativeAutomatorConfig? nativeAutomatorConfig,
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fadePointers,
}) {
  patrolTest(
    description,
    config: _patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
    nativeAutomation: true,
    framePolicy: framePolicy,
    skip: skip,
    callback,
  );
}
