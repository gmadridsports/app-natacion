import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart';
import 'Context/Natacion/application/RedirectToScreen/RedirectToLogin.dart';
import 'Context/Natacion/application/save_navigation_request/save_navigation_request.dart';
import 'Context/Natacion/domain/navigation_request/navigation_request.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/standalone.dart' as tz;

Future<bool> main({
  Client? httpClient,
  Function()? configToRun,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  tzData.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

  int initAttempt = 0;

  while (++initAttempt > 0 && initAttempt <= 10) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      initAttempt = -1;
    } catch (error) {
      continue;
    }
  }

  if (initAttempt == 10) {
    exit(1);
  }

  initializeDateFormatting();

  await runAppWithOptions(
      envName: const String.fromEnvironment('ENV', defaultValue: 'prod'),
      httpClient: httpClient,
      appConfig: configToRun);

  return true;
}
