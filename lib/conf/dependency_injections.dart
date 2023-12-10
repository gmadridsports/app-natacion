import 'package:gmadrid_natacion/Context/Natacion/domain/app/VersionRepository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/calendar_event/calendar_event_repository.dart';
import 'package:gmadrid_natacion/Context/Natacion/infrastructure/SupabaseVersionRepository.dart';
import 'package:gmadrid_natacion/shared/infrastructure/notification_service.dart';

import '../Context/Natacion/infrastructure/supabase_calendar_events_respository.dart';
import '../shared/domain/DateTimeRepository.dart';
import '../Context/Natacion/domain/TrainingRepository.dart';
import '../Context/Natacion/domain/screen/Screen.dart';
import '../Context/Natacion/domain/screen/showing_screen.dart';
import '../Context/Natacion/domain/screen/showing_screen_repository.dart';
import '../Context/Natacion/domain/user/UserRepository.dart';
import '../Context/Natacion/infrastructure/SupabaseBucketsTrainingURLRepository.dart';
import '../Context/Natacion/infrastructure/SupabaseUserRepository.dart';
import '../shared/infrastructure/SystemDateTimeRepository.dart';
import '../Context/Natacion/infrastructure/in_memory_showing_screen_repository.dart';
import '../Context/Shared/domain/Bus/Event/EventBus.dart';
import '../Context/Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';

import 'package:event_bus/event_bus.dart' as LibEventBus;

import 'domain_event_subscribers.dart';

List<(Type, Object)> dependencyInjectionInstances() {
  final eventBus = LibEventBus.EventBus();
  final libEventBus =
      LibEventBusEventBus(eventBus, subscribers: domainEventSubscribers);

  return [
    (DateTimeRepository, const SystemDateTimeRepository()),
    (UserRepository, const SupabaseUserRepository()),
    (LibEventBus.EventBus, eventBus),
    (LibEventBusEventBus, libEventBus),
    (
      ShowingScreenRepository,
      InMemoryShowingScreenRepository(
          // todo uuid
          ShowingScreen.from('1', Screen.splash))
    ),
    (EventBus, libEventBus),
    (
      TrainingRepository,
      const SupabaseBucketsTrainingURLRepository(SystemDateTimeRepository())
    ),
    (VersionRepository, const SupabaseVersionRepository()),
    (NotificationService, NotificationService()),
    (CalendarEventRepository, SupabaseCalendarEventsRepository()),
  ];
}
