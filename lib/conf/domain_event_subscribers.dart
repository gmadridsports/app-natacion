import '../Context/Natacion/application/RedirectToScreen/RedirectToLoginScreenOnLogout.dart';
import '../Context/Natacion/application/RedirectToScreen/RedirectToProperScreenOnLogin.dart';
import '../Context/Natacion/application/RedirectToScreen/RedirectToProperScreenOnMembershipApproved.dart';
import '../Context/Shared/domain/DomainEventSubscriber.dart';

List<DomainEventSubscriber> domainEventSubscribers = [
  RedirectToProperScreenOnMembershipApproved(),
  RedirectToLoginOnLogout(),
  RedirectToProperScreenOnLogin()
];
