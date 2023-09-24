import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/ListenedEvents/MembershipStatusChangedFromBackoffice.dart';
import '../../domain/user/MembershipStatus.dart';
import 'UpdateUserMembership.dart';

class UpdateUserMembershipOnMembershipChanged
    implements DomainEventSubscriber<MembershipStatusChangedFromBackoffice> {
  @override
  get subscribedTo => MembershipStatusChangedFromBackoffice;

  UpdateUserMembershipOnMembershipChanged();

  @override
  call(MembershipStatusChangedFromBackoffice domainEvent) async {
    UpdateUserMembership()(
        MembershipStatus.fromString(domainEvent.membershipLevel));
  }
}
