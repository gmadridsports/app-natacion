import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/TrainingDate.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/TrainingRepository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/app/VersionRepository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event_repository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/event_day_bound.dart';
import 'package:gmadrid_natacion/conf/dependency_injections.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:gmadrid_natacion/shared/domain/DateTimeRepository.dart';
import 'package:patrol/patrol.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart';

import 'infrastructure/SupabaseTestUserBuilder.dart';
import 'models/TestUser.dart';
import 'models/test_app_calendar_events_builder.dart';
import 'package:timezone/data/latest.dart' as tz;

final DateTimeRepository mockedDateTimeRepository = MockyDateTimeRepository();

class MockyDateTimeRepository extends Mock implements DateTimeRepository {}

class MockySupabaseBucketsTrainingURLRepository extends Mock
    implements TrainingRepository {}

final TrainingRepository mockedTrainingRepository =
    MockySupabaseBucketsTrainingURLRepository();

class MockySupabaseVersionRepository extends Mock
    implements VersionRepository {}

class MockySupabaseCalendarEventRepository extends Mock
    implements CalendarEventRepository {}

final CalendarEventRepository mockedCalendarEventRepository =
    MockySupabaseCalendarEventRepository();

final VersionRepository mockedVersionRepository =
    MockySupabaseVersionRepository();

var setupBeforeAllRun = false;
var givenAppLoggedInRun = false;
late TestUser givenUser;

void main() {
  registerFallbackValue(TrainingDate.from(2019, 03, 03));
  registerFallbackValue(DateTime(2019, 03, 03, 0, 0, 0));
  tz.initializeTimeZones();

  group('events', () {
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
      injectionInstances
          .add((CalendarEventRepository, mockedCalendarEventRepository));

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

    // todo more test scenarios
    Map<String, Map<String, dynamic>> cases = Map.of({
      'user can see events': Map.of({
        'givenDayToSelect': 3,
        'expectedMessage': 'Ningún evento para esta fecha.'
      }),
    });

    for (var testCase in cases.keys) {
      patrolTest(
        testCase,
        nativeAutomation: true,
        (PatrolIntegrationTester $) async {
          await setupBeforeAll();

          final givenDayToSelect = cases[testCase]!['givenDayToSelect'];

          final givenCurrentDateTime = DateTime.utc(2023, 03, 27);
          final givenEventsToReturn = TestAppCalendarEventsBuilder()
              .withFromDateTimeUtc(givenCurrentDateTime)
              .withToDateTimeUtc(
                  givenCurrentDateTime.add(const Duration(days: 5)))
              .build();

          when(() => mockedCalendarEventRepository.getCalendarEventsStarting(
                  EventDayBound.fromDateTimeUtc(
                      DateTime.utc(2023, 03, 27), EventDayBoundType.lowerBound),
                  EventDayBound.fromDateTimeUtc(DateTime.utc(2023, 04, 30),
                      EventDayBoundType.upperBound)))
              .thenAnswer((_) => Future.value(givenEventsToReturn));

          await givenAppLoggedIn($);
          await $('GMadrid Natación')
              .waitUntilVisible(timeout: const Duration(seconds: 2));

          await $(#calendar).tap();

          // todo fix datetimes
          // await $(givenDayToSelect).tap();
          // await $(cases[testCase]!['expectedMessage'])
          //     .waitUntilVisible(timeout: const Duration(seconds: 2));

          // after
          await setupAfterEach($);
        },
      );
    }
  });
}
