import 'package:gmadrid_natacion/Context/Natacion/domain/navigation_request/navigation_request_repository.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/MembershipStatus.dart';

class RedirectToFirstScreenForMembership {
  late final ShowingScreenRepository _showingScreenRepository;
  late final NavigationRequestRepository _navigationRequestRepository;
  late final EventBus _eventBus;

  RedirectToFirstScreenForMembership() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
    _navigationRequestRepository =
        DependencyInjection().getInstanceOf<NavigationRequestRepository>();
  }

  void call(MembershipStatus? membershipStatus) async {
    final showingScreen = _showingScreenRepository.getShowingScreen();

    if (showingScreen == null) {
      // not running
      return;
    }

    final potentialNavigationRequest =
        await _navigationRequestRepository.pullLatestNavigationRequest();
    showingScreen.changeCurrentScreenForNavigationRequest(
        potentialNavigationRequest, membershipStatus);
    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
