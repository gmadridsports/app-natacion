import '../../../../Shared/domain/ListenedDomainEvent.dart';

class MembershipStatusChangedFromBackoffice extends ListenedDomainEvent {
  final String membershipLevel;
  static const String EVENT_NAME =
      'user.membership_status_changed_from_backoffice';

  MembershipStatusChangedFromBackoffice._internal(super.aggregateId,
      super.occurredOn, super.eventName, this.membershipLevel);

  MembershipStatusChangedFromBackoffice(
      String aggregateId, DateTime occurredOn, String membershipLevel)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, membershipLevel);
}
