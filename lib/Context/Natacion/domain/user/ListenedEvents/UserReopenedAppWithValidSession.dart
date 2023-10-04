import '../../../../Shared/domain/ListenedDomainEvent.dart';

class UserReopenedAppWithValidSession extends ListenedDomainEvent {
  final String membershipLevel;
  static const String EVENT_NAME = 'user.user_already_logged_in';

  UserReopenedAppWithValidSession._internal(super.aggregateId, super.occurredOn,
      super.eventName, this.membershipLevel);

  UserReopenedAppWithValidSession(
      String aggregateId, DateTime occurredOn, String membershipLevel)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, membershipLevel);
}
