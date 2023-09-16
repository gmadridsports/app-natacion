import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/user/user_logout_event.dart';
import 'RedirectToLogin.dart';

class RedirectToLoginOnLogout
    implements DomainEventSubscriber<UserLogoutEvent> {
  @override
  get subscribedTo => UserLogoutEvent;

  RedirectToLoginOnLogout();

  @override
  call(UserLogoutEvent domainEvent) {
    RedirectToLogin()();
  }
}
