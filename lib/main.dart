import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

void main({
  String envFileName = 'assets/.staging.env',
}) async {
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

  runAppWithOptions(envFileName: envFileName);
}
