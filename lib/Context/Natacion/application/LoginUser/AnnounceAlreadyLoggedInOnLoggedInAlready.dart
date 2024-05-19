import 'package:gmadrid_natacion/Context/Natacion/domain/user/ListenedEvents/UserReopenedAppWithValidSession.dart';

import '../../../Shared/domain/DomainEventSubscriber.dart';
import 'AnnounceAlreadyLoggedIn.dart';

class AnnounceAlreadyLoggedInOnUserReopenedAppWithValidSession
    implements DomainEventSubscriber<UserReopenedAppWithValidSession> {
  @override
  get subscribedTo => UserReopenedAppWithValidSession;

  AnnounceAlreadyLoggedInOnUserReopenedAppWithValidSession();

  @override
  call(UserReopenedAppWithValidSession domainEvent) {
    AnnounceAlreadyLoggedIn()();
  }
}
