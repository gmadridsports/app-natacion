import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/MembershipStatus.dart';
import '../../domain/user/user_login_event.dart';
import 'RedirectToFirstScreenForMembership.dart';

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
