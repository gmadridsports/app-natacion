import '../../domain/user/notification_preferences.dart'
    as DomainNotificationPreferences;
import '../../../../shared/dependency_injection.dart';
import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/user/UserRepository.dart';

class ChangeNotificationPreferenceRequest {
  final String notification;
  final bool enabled;

  ChangeNotificationPreferenceRequest(this.notification, this.enabled);
}

class ChangeNotificationPreference {
  late final UserRepository _userRepository;
  late final EventBus _eventBus;

  ChangeNotificationPreference() {
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call(ChangeNotificationPreferenceRequest request) async {
    final user = await _userRepository.getCurrentSessionUser();

    if (user == null) {
      throw Exception("No user available");
    }
    final newPreferences = user.notificationPreferences.changePreference(
        DomainNotificationPreferences.NotificationPreferenceType.fromString(
            request.notification),
        request.enabled);
    user.changeNotificationPreferences(newPreferences);

    await _userRepository.save(user);

    _eventBus.publish(user.pullDomainEvents());
  }
}
