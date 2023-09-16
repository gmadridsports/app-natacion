import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/ListenedEvents/MembershipStatusChanged.dart';
import '../../domain/user/MembershipStatus.dart';
import 'RedirectToFirstScreenForMembership.dart';

class RedirectToProperScreenOnMembershipApproved
    implements DomainEventSubscriber<MembershipStatusChanged> {
  @override
  get subscribedTo => MembershipStatusChanged;

  RedirectToProperScreenOnMembershipApproved();

  @override
  call(MembershipStatusChanged domainEvent) {
    final membershipLevel =
        MembershipStatus.fromString(domainEvent.membershipLevel);
    RedirectToFirstScreenForMembership()(membershipLevel);
  }
}
