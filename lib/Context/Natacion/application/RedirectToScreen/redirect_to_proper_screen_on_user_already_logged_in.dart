import 'package:gmadrid_natacion/Context/Natacion/application/RedirectToScreen/redirect_to_screen_for_request_and_membership.dart';

import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/MembershipStatus.dart';
import '../../domain/user/user_logged_in_event.dart';

class RedirectToProperScreenOnUserAlreadyLoggedIn
    implements DomainEventSubscriber<UserAlreadyLoggedInEvent> {
  @override
  get subscribedTo => UserAlreadyLoggedInEvent;

  RedirectToProperScreenOnUserAlreadyLoggedIn();

  @override
  call(UserAlreadyLoggedInEvent domainEvent) {
    final membershipLevel =
        MembershipStatus.fromString(domainEvent.membershipLevel);
    RedirectToScreenForRequestAndMembership()(membershipLevel);
  }
}
