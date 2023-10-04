import '../../../Shared/domain/DomainEvent.dart';

class UserAlreadyLoggedInEvent extends DomainEvent {
  static const String EVENT_NAME = 'user.logged_in_already';
  final String membershipLevel;

  UserAlreadyLoggedInEvent._internal(super.aggregateId, super.occurredOn,
      super.eventName, this.membershipLevel);

  UserAlreadyLoggedInEvent(
      String aggregateId, DateTime occurredOn, String membershipLevel)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, membershipLevel);
}
