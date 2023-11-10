import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/TrainingDate.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/TrainingRepository.dart';
import 'package:gmadrid_natacion/conf/dependency_injections.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:gmadrid_natacion/shared/domain/DateTimeRepository.dart';
import 'package:patrol/patrol.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:mocktail/mocktail.dart';

import 'common.dart';
import 'infrastructure/SupabaseTestUserBuilder.dart';

class MockySupabaseBucketsTrainingURLRepository extends Mock
    implements TrainingRepository {}

class MockyDateTimeRepository extends Mock implements DateTimeRepository {}

void main() {
  final TrainingRepository mockedTrainingRepository =
      MockySupabaseBucketsTrainingURLRepository();
  final DateTimeRepository mockedDateTimeRepository = MockyDateTimeRepository();

  registerFallbackValue(TrainingDate.from(2019, 03, 03));
  registerFallbackValue(DateTime(2019, 03, 03, 0, 0, 0));

  configToRun() {
    final injectionInstances = dependencyInjectionInstances()
        .where(
            (el) => el.$1 != DateTimeRepository && el.$1 != TrainingRepository)
        .toList();

    injectionInstances.add((DateTimeRepository, mockedDateTimeRepository));
    injectionInstances.add((TrainingRepository, mockedTrainingRepository));

    DependencyInjection(instances: injectionInstances);
  }

  patrolTest(
    'Auth user level can log in and log out on the waiting approval screen',
    nativeAutomation: true,
    (PatrolIntegrationTester $) async {
      const envName = String.fromEnvironment('ENV', defaultValue: 'test');
      await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

      // given
      final testUserBuilder = new SupabaseTestUserBuilder();
      final givenUser = await testUserBuilder.build();

      // when
      app_main.main(
        configToRun: configToRun,
      );

      if (await $.native
          .isPermissionDialogVisible(timeout: Duration(seconds: 10))) {
        await $.native.grantPermissionWhenInUse();
      }

      // then
      await $('Acceso').waitUntilVisible();

      // and when
      await $('Acceso').tap();

      await $(#Password).scrollTo();
      await $(#Password).enterText(givenUser.password.toString());

      await $(#Email).scrollTo();
      await $(#Email).enterText(givenUser.email.toString());

      await $(#access).scrollTo();
      await $(#access).tap();

      await $.pumpAndSettle();
      await $('Pendiente de revisión').waitUntilVisible();

      // and when
      await $(Key('logout-from-approval')).tap();
      await $.pumpAndSettle();

      // then
      await $('Acceso').waitUntilVisible();
    },
  );

  patrolTest(
      'update information is shown when there is a new version available',
      nativeAutomation: true, (PatrolIntegrationTester $) async {
    // todo complete this with mocks!
  });

  patrolTest(
      'no update information is shown when there\'s no new version available',
      nativeAutomation: true, (PatrolIntegrationTester $) async {
    // todo complete this with mocks!
  });

  // todo test the new backend
  // todo update the staging and testing environments
}
