import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/dependency_injection.dart';
import 'package:gmadrid_natacion/models/DateTimeRepository.dart';
import 'package:gmadrid_natacion/models/TrainingDate.dart';
import 'package:gmadrid_natacion/models/TrainingRepository.dart';
import 'package:patrol/patrol.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart';

import 'models/TestUserBuilder.dart';

class MockySupabaseBucketsTrainingURLRepository extends Mock
    implements TrainingRepository {}

class MockyDateTimeRepository extends Mock implements DateTimeRepository {}

// Uint8List fixture(String name) {
//   var dir = Directory.current.path;
//   if (dir.endsWith('/integration_test')) {
//     dir = dir.replaceAll('/integration_test', '');
//   }
//   return File('$dir/integration_test/$name').readAsBytesSync();
// }

void main() {
  final testUserBuilder = new TestUserBuilder();
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
    'Unauthenticated user should see login screen',
    nativeAutomation: true,
    (PatrolTester $) async {
      const envName = String.fromEnvironment('ENV', defaultValue: 'test');
      await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

      // given
      final givenUser = await testUserBuilder.build();

      // when
      app_main.main(
        configToRun: configToRun,
      );

      if (await $.native
          .isPermissionDialogVisible(timeout: Duration(seconds: 10))) {
        await $.native.grantPermissionWhenInUse();
      }

      await $.pumpAndSettle();

      // then
      await $('Acceso').waitUntilVisible();
    },
  );

  patrolTest(
    'Can authenticate with the right credentials',
    nativeAutomation: true,
    (PatrolTester $) async {
      const envName = String.fromEnvironment('ENV', defaultValue: 'test');
      await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

      // given
      final givenUser = await testUserBuilder.build();

      final givenFirstTrainingDateTime = DateTime.utc(2023, 03, 27);
      final givenLastTrainingDateTime = DateTime.utc(2023, 04, 04);
      final givenCurrentDateTime = DateTime.utc(2023, 04, 04);
      final givenIpAddressPort = dotenv.get('SUPABASE_URL');

      final givenTrainingURL =
          '${givenIpAddressPort}/storage/v1/object/public/general/trainings/2023-04-17.pdf';
      final givenFirstTrainingDate =
          TrainingDate.fromDateTime(givenFirstTrainingDateTime);
      final givenLastTrainingDate =
          TrainingDate.fromDateTime(givenLastTrainingDateTime);

      Response response = await get(Uri.parse(
          '${givenIpAddressPort}/storage/v1/object/public/general/trainings/2023-04-17.pdf'));

      when(() => mockedTrainingRepository.getFirstTrainingDate())
          .thenAnswer((_) => Future.value(givenFirstTrainingDate));

      when(() => mockedTrainingRepository.getLastTrainingDate())
          .thenAnswer((_) => Future.value(givenLastTrainingDate));

      when(() => mockedTrainingRepository.getTrainingURL(any()))
          .thenAnswer((_) => Future.value(givenTrainingURL));

      when(() => mockedTrainingRepository.trainingExistsForWeek(any()))
          .thenAnswer((_) => Future.value(true));

      when(() => mockedTrainingRepository.getTrainingPDF(any()))
          .thenAnswer((_) => Future.value(response.bodyBytes));

      when(() => mockedDateTimeRepository.now())
          .thenReturn(givenCurrentDateTime);

      // when
      app_main.main(
        configToRun: configToRun,
      );

      if (await $.native
          .isPermissionDialogVisible(timeout: Duration(seconds: 10))) {
        await $.native.grantPermissionWhenInUse();
      }

      await $.pumpAndSettle();

      // then
      await $('Acceso').waitUntilVisible();

      // and when
      await $.native.enterText(
        Selector(text: 'Email'),
        text: givenUser.email,
      );

      await $.native.tap(Selector(text: 'Envíame el enlace de acceso'));

      await $.pumpAndSettle();
      await $('GMadrid Natación').waitUntilVisible();
    },
  );

  // todo do the login test with auth/unauth and the logout
  // patrolTest(
  //   'Happy path show training of the week',
  //   nativeAutomation: true,
  //   (PatrolTester $) async {
  //     final givenFirstTrainingDateTime = DateTime.utc(2023, 03, 27);
  //     final givenLastTrainingDateTime = DateTime.utc(2023, 04, 04);
  //     final givenCurrentDateTime = DateTime.utc(2023, 04, 04);
  //
  //     const envName = String.fromEnvironment('ENV', defaultValue: 'test');
  //     await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});
  //     final givenIpAddressPort = dotenv.get('SUPABASE_URL');
  //
  //     final givenTrainingURL =
  //         '${givenIpAddressPort}/storage/v1/object/public/general/trainings/2023-04-17.pdf';
  //     final givenFirstTrainingDate =
  //         TrainingDate.fromDateTime(givenFirstTrainingDateTime);
  //     final givenLastTrainingDate =
  //         TrainingDate.fromDateTime(givenLastTrainingDateTime);
  //
  //     Response response = await get(Uri.parse(
  //         '${givenIpAddressPort}/storage/v1/object/public/general/trainings/2023-04-17.pdf'));
  //
  //     when(() => mockedTrainingRepository.getFirstTrainingDate())
  //         .thenAnswer((_) => Future.value(givenFirstTrainingDate));
  //
  //     when(() => mockedTrainingRepository.getLastTrainingDate())
  //         .thenAnswer((_) => Future.value(givenLastTrainingDate));
  //
  //     when(() => mockedTrainingRepository.getTrainingURL(any()))
  //         .thenAnswer((_) => Future.value(givenTrainingURL));
  //
  //     when(() => mockedTrainingRepository.trainingExistsForWeek(any()))
  //         .thenAnswer((_) => Future.value(true));
  //
  //     when(() => mockedTrainingRepository.getTrainingPDF(any()))
  //         .thenAnswer((_) => Future.value(response.bodyBytes));
  //
  //     when(() => mockedDateTimeRepository.now())
  //         .thenReturn(givenCurrentDateTime);
  //
  //     app_main.main(
  //       configToRun: configToRun,
  //     );
  //
  //     if (await $.native
  //         .isPermissionDialogVisible(timeout: Duration(seconds: 10))) {
  //       await $.native.grantPermissionWhenInUse();
  //     }
  //
  //     await $.pumpAndSettle();
  //
  //     await $('Acceso').waitUntilVisible();
  //     // todo complete the login path
  //     // await $('GMadrid Natación').waitUntilVisible();
  //
  //     // todo enable as soon as https://github.com/leancodepl/patrol/issues/788
  //     // var bytes = await binding.takeScreenshot('screen1');
  //     // print(bytes);
  //   },
  // );
}
