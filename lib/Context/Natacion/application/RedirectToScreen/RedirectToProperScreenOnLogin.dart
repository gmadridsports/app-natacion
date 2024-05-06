import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/MembershipStatus.dart';
import '../../domain/user/user_login_event.dart';
import 'redirect_to_first_screen_for_membership.dart';

class RedirectToProperScreenOnLogin
    implements DomainEventSubscriber<UserLoginEvent> {
  @override
  get subscribedTo => UserLoginEvent;

  RedirectToProperScreenOnLogin();

  @override
  call(UserLoginEvent domainEvent) {
    final membershipLevel =
        MembershipStatus.fromString(domainEvent.membershipLevel);
    RedirectToFirstScreenForMembership()(membershipLevel);
  }
}
