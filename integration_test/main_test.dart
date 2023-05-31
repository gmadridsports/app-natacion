import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/app_config.dart';
import 'package:gmadrid_natacion/models/TrainingDate.dart';
import 'package:gmadrid_natacion/models/TrainingRepository.dart';
import 'package:patrol/patrol.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:mocktail/mocktail.dart';

class MockySupabaseBucketsTrainingURLRepository extends Mock
    implements TrainingRepository {}

void main() {
  final AppConfig Function(Widget child)? configToRun;
  late TrainingRepository mockedTrainingRepository;

  registerFallbackValue(TrainingDate.from(2023, 03, 03));
  mockedTrainingRepository = MockySupabaseBucketsTrainingURLRepository();
  configToRun = (Widget child) => AppConfig(
        mockedTrainingRepository,
        child: child,
      );

  patrolTest(
    'Happy path show training of the week',
    nativeAutomation: true,
    (PatrolTester $) async {
      final givenTrainingURL =
          'https://eiigsbxyppavpwbagvzd.supabase.co/storage/v1/object/public/general/trainings/2023-03-03.pdf';
      when(() => mockedTrainingRepository.getTrainingURL(any()))
          .thenAnswer((_) => Future.value(givenTrainingURL));

      app_main.main(envFileName: 'assets/.test.env', configToRun: configToRun);

      if (await $.native
          .isPermissionDialogVisible(timeout: Duration(seconds: 10))) {
        await $.native.grantPermissionWhenInUse();
      }

      await $.pumpAndSettle();

      await $('GMadrid Natación').waitUntilVisible();

      // todo enable as soon as https://github.com/leancodepl/patrol/issues/788
      // var bytes = await binding.takeScreenshot('screen1');
      // print(bytes);
    },
  );

  // patrolTest(
  //   'Happy path show training of the week',
  //   nativeAutomation: true,
  //   (PatrolTester $) async {
  //     app_main.main(envFileName: 'assets/.test.env');
  //
  //     if (await $.native
  //         .isPermissionDialogVisible(timeout: Duration(seconds: 10))) {
  //       await $.native.grantPermissionWhenInUse();
  //     }
  //
  //     await $.pumpAndSettle();
  //
  //     await $('GMadrid Natación').waitUntilVisible();
  //
  //     // todo enable as soon as https://github.com/leancodepl/patrol/issues/788
  //     // var bytes = await binding.takeScreenshot('screen1');
  //     // print(bytes);
  //   },
  // );
}
