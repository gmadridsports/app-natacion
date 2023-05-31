import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'app.dart';
import 'app_config.dart';
import 'firebase_options.dart';

Future<bool> main(
    {String envFileName = 'assets/.staging.env',
    Client? httpClient,
    AppConfig Function(Widget child)? configToRun}) async {
  await WidgetsFlutterBinding.ensureInitialized();
  int initAttempt = 0;

  while (++initAttempt > 0 && initAttempt <= 10) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // FlutterError.onError =
      //     FirebaseCrashlytics.instance.recordFlutterFatalError;

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

  await runAppWithOptions(
      envFileName: envFileName, httpClient: httpClient, appConfig: configToRun);
  return true;
}
