import '../../../Shared/domain/DomainEvent.dart';

class UserLoginEvent extends DomainEvent {
  static const String EVENT_NAME = 'user.logged_in';
  final String membershipLevel;

  UserLoginEvent._internal(super.aggregateId, super.occurredOn, super.eventName,
      this.membershipLevel);

  UserLoginEvent(
      String aggregateId, DateTime occurredOn, String membershipLevel)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, membershipLevel);
}
