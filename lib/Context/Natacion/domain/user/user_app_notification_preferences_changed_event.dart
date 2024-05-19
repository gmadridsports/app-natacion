import '../../../Shared/domain/DomainEvent.dart';

class UserAppNotificationPreferencesChanged extends DomainEvent {
  static const String EVENT_NAME = 'user.notification_preferences_changed';
  final Map<String, bool> preferences;

  UserAppNotificationPreferencesChanged._internal(
      super.aggregateId, super.occurredOn, super.eventName, this.preferences);

  UserAppNotificationPreferencesChanged(
      String aggregateId, DateTime occurredOn, Map<String, bool> newPreferences)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, newPreferences);
}
