import '../../../../Shared/domain/ListenedDomainEvent.dart';

class UserAppUsagePermissionsChanged extends ListenedDomainEvent {
  final bool canUseApp;
  static const String EVENT_NAME = 'user.app_usage_permissions_changed';

  UserAppUsagePermissionsChanged._internal(
      super.aggregateId, super.occurredOn, super.eventName, this.canUseApp);

  UserAppUsagePermissionsChanged(
      String aggregateId, DateTime occurredOn, bool canUseApp)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, canUseApp);
}
