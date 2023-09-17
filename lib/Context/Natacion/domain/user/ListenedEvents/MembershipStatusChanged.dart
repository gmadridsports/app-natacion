import '../../../../Shared/domain/ListenedDomainEvent.dart';

class MembershipStatusChanged extends ListenedDomainEvent {
  final String membershipLevel;
  static const String EVENT_NAME = 'user.membership_status_changed';

  MembershipStatusChanged._internal(super.aggregateId, super.occurredOn,
      super.eventName, this.membershipLevel);

  MembershipStatusChanged(
      String aggregateId, DateTime occurredOn, String membershipLevel)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, membershipLevel);
}
