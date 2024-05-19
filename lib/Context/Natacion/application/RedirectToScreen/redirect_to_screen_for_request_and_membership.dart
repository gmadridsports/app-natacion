import 'package:gmadrid_natacion/Context/Natacion/domain/navigation_request/navigation_request_repository.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/MembershipStatus.dart';

class RedirectToScreenForRequestAndMembership {
  late final ShowingScreenRepository _showingScreenRepository;
  late final NavigationRequestRepository _navigationRequestRepository;
  late final EventBus _eventBus;

  RedirectToScreenForRequestAndMembership() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _navigationRequestRepository =
        DependencyInjection().getInstanceOf<NavigationRequestRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call(MembershipStatus membershipStatus) async {
    final showingScreen = _showingScreenRepository.getShowingScreen();

    if (showingScreen == null) {
      // not running
      return;
    }

    final latestNavigationRequest =
        await _navigationRequestRepository.pullLatestNavigationRequest();
    showingScreen.changeCurrentScreenForNavigationRequest(
        latestNavigationRequest, membershipStatus);

    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
