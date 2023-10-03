import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/ListenedEvents/MembershipStatusChangedFromBackoffice.dart';
import '../../domain/user/MembershipStatus.dart';
import 'RedirectToFirstScreenForMembership.dart';

class RedirectToProperScreenOnMembershipApproved
    implements DomainEventSubscriber<MembershipStatusChangedFromBackoffice> {
  @override
  get subscribedTo => MembershipStatusChangedFromBackoffice;

  RedirectToProperScreenOnMembershipApproved();

  @override
  call(MembershipStatusChangedFromBackoffice domainEvent) {
    final membershipLevel =
        MembershipStatus.fromString(domainEvent.membershipLevel);
    RedirectToFirstScreenForMembership()(membershipLevel);
  }
}
