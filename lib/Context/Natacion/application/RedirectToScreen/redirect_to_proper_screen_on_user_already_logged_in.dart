import '../../../../shared/dependency_injection.dart';
import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/navigation_request/navigation_request_repository.dart';
import '../../domain/user/MembershipStatus.dart';
import '../../domain/user/user_logged_in_event.dart';
import 'redirect_to_screen_for_request_and_membership.dart';

class RedirectToProperScreenOnUserAlreadyLoggedIn
    implements DomainEventSubscriber<UserAlreadyLoggedInEvent> {
  @override
  get subscribedTo => UserAlreadyLoggedInEvent;

  RedirectToProperScreenOnUserAlreadyLoggedIn() {}

  @override
  call(UserAlreadyLoggedInEvent domainEvent) async {
    final navigationRequestRepository =
        DependencyInjection().getInstanceOf<NavigationRequestRepository>();
    final membershipLevel =
        MembershipStatus.fromString(domainEvent.membershipLevel);
    final latestNavigationRequest =
        await navigationRequestRepository.pullLatestNavigationRequest();
    RedirectToScreenForRequestAndMembership()(
        membershipLevel, latestNavigationRequest);
  }
}
