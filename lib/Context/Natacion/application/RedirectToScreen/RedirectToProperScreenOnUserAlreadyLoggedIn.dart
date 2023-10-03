import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/MembershipStatus.dart';
import '../../domain/user/user_logged_in_event.dart';
import 'RedirectToFirstScreenForMembership.dart';

class RedirectToProperScreenOnUserAlreadyLoggedIn
    implements DomainEventSubscriber<UserAlreadyLoggedInEvent> {
  @override
  get subscribedTo => UserAlreadyLoggedInEvent;

  RedirectToProperScreenOnUserAlreadyLoggedIn();

  @override
  call(UserAlreadyLoggedInEvent domainEvent) {
    final membershipLevel =
        MembershipStatus.fromString(domainEvent.membershipLevel);
    RedirectToFirstScreenForMembership()(membershipLevel);
  }
}
