import '../../../Shared/domain/DomainEvent.dart';

class UserLogoutEvent extends DomainEvent {
  static const String EVENT_NAME = 'user.logged_out';

  UserLogoutEvent._internal(
      super.aggregateId, super.occurredOn, super.eventName);

  UserLogoutEvent(String aggregateId, DateTime occurredOn)
      : this._internal(aggregateId, occurredOn, EVENT_NAME);
}
