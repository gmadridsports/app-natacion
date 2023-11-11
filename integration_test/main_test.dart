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
import 'models/TestVersionBuilder.dart';

class MockySupabaseBucketsTrainingURLRepository extends Mock
    implements TrainingRepository {}

class MockyDateTimeRepository extends Mock implements DateTimeRepository {}

class MockySupabaseVersionRepository extends Mock
    implements VersionRepository {}

final VersionRepository mockedVersionRepository =
    MockySupabaseVersionRepository();

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
    injectionInstances.add((VersionRepository, mockedVersionRepository));

    DependencyInjection(instances: injectionInstances);
  }

  patrolTest(
    'User with member level can log in, see training weeks, and logout',
    nativeAutomation: true,
    (PatrolIntegrationTester $) async {
      const envName = const String.fromEnvironment('ENV', defaultValue: 'test');
      await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

      // given
      final testUserBuilder = new SupabaseTestUserBuilder();
      testUserBuilder.withMember(true);
      final givenUser = await testUserBuilder.build();

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

      final givenRunningVersion = TestAppVersionBuilder()
          .withCurrentAppVersion(
              TestVersionBuilder().build(), TestVersionBuilder().build())
          .build();
      when(() => mockedVersionRepository.getRunningVersion())
          .thenAnswer((_) => Future.value(givenRunningVersion));
      when(() => mockedVersionRepository.getLatestAvailableVersion())
          .thenAnswer((_) => Future.value(givenRunningVersion));

      // when
      app_main.main(
        configToRun: configToRun,
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
      await $('GMadrid Natación').waitUntilVisible();

      await $(#profile).tap();
      await $(givenUser.email.toString()).waitUntilVisible();

      await $(#logout).tap();

      // then
      await $('Acceso').waitUntilVisible();
    },
  );
}
