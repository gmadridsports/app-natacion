import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart';
import 'app/app.dart';
import 'firebase_options.dart';

Future<bool> main({
  Client? httpClient,
  Function()? configToRun,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
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
    print('too many init attempts');
    exit(1);
  }

  initializeDateFormatting();

  await runAppWithOptions(
      envName: const String.fromEnvironment('ENV', defaultValue: 'prod'),
      httpClient: httpClient,
      appConfig: configToRun);

  return true;
}
