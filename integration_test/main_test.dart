import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/dependency_injection.dart';
import 'package:gmadrid_natacion/models/DateTimeRepository.dart';
import 'package:gmadrid_natacion/models/TrainingDate.dart';
import 'package:gmadrid_natacion/models/TrainingRepository.dart';
import 'package:patrol/patrol.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart';

class MockySupabaseBucketsTrainingURLRepository extends Mock
    implements TrainingRepository {}

class MockyDateTimeRepository extends Mock implements DateTimeRepository {}

Uint8List fixture(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/integration_test')) {
    dir = dir.replaceAll('/integration_test', '');
  }
  return File('$dir/integration_test/$name').readAsBytesSync();
}

void main() {
  final TrainingRepository mockedTrainingRepository =
      MockySupabaseBucketsTrainingURLRepository();
  final DateTimeRepository mockedDateTimeRepository = MockyDateTimeRepository();

  registerFallbackValue(TrainingDate.from(2019, 03, 03));
  registerFallbackValue(DateTime(2019, 03, 03, 0, 0, 0));

  configToRun(Widget child) => DependencyInjection.hydrateWithInstances(
        mockedTrainingRepository,
        mockedDateTimeRepository,
        child: child,
      );

  patrolTest(
    'Happy path show training of the week',
    nativeAutomation: true,
    (PatrolTester $) async {
      final givenCurrentDateTime = DateTime(2018, 03, 03);

      const givenIp = String.fromEnvironment('HOST_IP');
      final givenTrainingURL =
          'http://${givenIp}:54321/storage/v1/object/public/general/trainings/test.pdf';

      // todo another pdf for test purposes
      Response response =
          await get(Uri.parse('https://www.bertamini.net/api/cv'));

      when(() => mockedTrainingRepository.getTrainingURL(any()))
          .thenAnswer((_) => Future.value(givenTrainingURL));

      when(() => mockedTrainingRepository.getTrainingPDF(any()))
          .thenAnswer((_) => Future.value(response.bodyBytes));

      when(() => mockedDateTimeRepository.now())
          .thenReturn(givenCurrentDateTime);

      app_main.main(
        envFileName: 'assets/.test.env',
        configToRun: configToRun,
      );

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
