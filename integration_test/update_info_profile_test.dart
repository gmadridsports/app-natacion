import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/TrainingDate.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/TrainingRepository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/app/VersionRepository.dart';
import 'package:gmadrid_natacion/conf/dependency_injections.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:gmadrid_natacion/shared/domain/DateTimeRepository.dart';
import 'package:patrol/patrol.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart';

import 'infrastructure/SupabaseTestUserBuilder.dart';
import 'models/TestAppVersionBuilder.dart';
import 'models/TestUser.dart';
import 'models/TestVersionBuilder.dart';

final DateTimeRepository mockedDateTimeRepository = MockyDateTimeRepository();

class MockyDateTimeRepository extends Mock implements DateTimeRepository {}

class MockySupabaseBucketsTrainingURLRepository extends Mock
    implements TrainingRepository {}

final TrainingRepository mockedTrainingRepository =
    MockySupabaseBucketsTrainingURLRepository();

class MockySupabaseVersionRepository extends Mock
    implements VersionRepository {}

final VersionRepository mockedVersionRepository =
    MockySupabaseVersionRepository();

var setupBeforeAllRun = false;
var givenAppLoggedInRun = false;
late TestUser givenUser;

void main() {
  registerFallbackValue(TrainingDate.from(2019, 03, 03));
  registerFallbackValue(DateTime(2019, 03, 03, 0, 0, 0));

  group('version check', () {
    Future<void> setupBeforeAll() async {
      if (setupBeforeAllRun) {
        return;
      }
      setupBeforeAllRun = true;

      const envName = const String.fromEnvironment('ENV', defaultValue: 'test');
      await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

      // given
      final testUserBuilder = SupabaseTestUserBuilder();
      testUserBuilder.withMember(true);
      givenUser = await testUserBuilder.build();

      // and
      final givenFirstTrainingDateTime = DateTime.utc(2023, 03, 27);
      final givenLastTrainingDateTime = DateTime.utc(2023, 04, 17);
      final givenCurrentDateTime = DateTime.utc(2023, 04, 25);
      final givenIpAddressPort = dotenv.get('SUPABASE_URL');

      final givenTrainingURL =
          '${givenIpAddressPort}/storage/v1/object/public/general/test.pdf';
      final givenFirstTrainingDate =
          TrainingDate.fromDateTime(givenFirstTrainingDateTime);
      final givenLastTrainingDate =
          TrainingDate.fromDateTime(givenLastTrainingDateTime);

      Response response = await get(Uri.parse(
          '${givenIpAddressPort}/storage/v1/object/public/general/test.pdf'));

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
    }

    givenConfigToRun() {
      final injectionInstances = dependencyInjectionInstances()
          .where((el) =>
              el.$1 != DateTimeRepository && el.$1 != TrainingRepository)
          .toList();

      injectionInstances.add((DateTimeRepository, mockedDateTimeRepository));
      injectionInstances.add((TrainingRepository, mockedTrainingRepository));
      injectionInstances.add((VersionRepository, mockedVersionRepository));

      DependencyInjection(instances: injectionInstances);
    }

    Future<void> givenAppLoggedIn(PatrolIntegrationTester $) async {
      // when
      app_main.main(
        configToRun: givenConfigToRun,
      );

      if (await $.native
          .isPermissionDialogVisible(timeout: const Duration(seconds: 10))) {
        await $.native.grantPermissionWhenInUse();
      }
      await $.pumpAndSettle();

      // then
      await $('Acceso').waitUntilVisible(timeout: const Duration(seconds: 2));

      // and when
      await $(#Password).scrollTo();
      await $(#Password).enterText(givenUser.password.toString());

      await $(#Email).scrollTo();
      await $(#Email).enterText(givenUser.email.toString());

      await $(#access).scrollTo();
      await $(#access).tap();

      await $.pumpAndSettle();
      await $('Controla tu buzón y pincha el enlace de acceso!')
          .waitUntilVisible();
      await Future.delayed(const Duration(seconds: 5));

      await $.pumpAndSettle();
    }

    Future<void> setupAfterEach(PatrolIntegrationTester $) async {
      await $(#profile).tap();
      await $(givenUser.email.toString()).waitUntilVisible();

      await $(#logout).tap();
    }

    Map<String, Map<String, dynamic>> cases = Map.of({
      'user is notified about a new available version': Map.of({
        'givenCurrentBuildNumber': 3,
        'givenRemoteBuildNumber': 4,
        'expectedUpdatedVersionCondition': findsOneWidget
      }),
      'current up to date version is showed': Map.of({
        'givenCurrentBuildNumber': 3,
        'givenRemoteBuildNumber': 3,
        'expectedUpdatedVersionCondition': findsNothing
      })
    });

    for (var testCase in cases.keys) {
      patrolTest(
        testCase,
        nativeAutomation: true,
        (PatrolIntegrationTester $) async {
          await setupBeforeAll();

          final givenCurrentBuildNumber =
              cases[testCase]!['givenCurrentBuildNumber'];
          final givenRemoteBuildNumber =
              cases[testCase]!['givenRemoteBuildNumber'];

          final givenRunningVersion = TestAppVersionBuilder()
              .withCurrentAppVersion(
                  TestVersionBuilder()
                      .withBuildNumber(givenCurrentBuildNumber)
                      .build(),
                  TestVersionBuilder()
                      .withBuildNumber(givenRemoteBuildNumber)
                      .build())
              .build();
          when(() => mockedVersionRepository.getRunningVersion())
              .thenAnswer((_) => Future.value(givenRunningVersion));

          final givenRemoteVersion = TestAppVersionBuilder()
              .withLatestRemoteAppVersion(
                  TestVersionBuilder()
                      .withBuildNumber(givenRemoteBuildNumber)
                      .build(),
                  'https://gmadridnatacion.bertamini.net')
              .build();
          when(() => mockedVersionRepository.getLatestAvailableVersion())
              .thenAnswer((_) => Future.value(givenRemoteVersion));
          final expectedUpdatedCondition =
              cases[testCase]!['expectedUpdatedVersionCondition'];

          await givenAppLoggedIn($);
          await $('GMadrid Natación')
              .waitUntilVisible(timeout: const Duration(seconds: 2));

          await $(#profile).tap();

          expect($('Versión ${givenRunningVersion.version.toString()}').exists,
              equals(true));

          expect(
              find.text(
                  "Actualización disponible: ${givenRemoteVersion.version.toString()}"),
              expectedUpdatedCondition);

          // after
          await setupAfterEach($);
        },
      );
    }
  });
}
