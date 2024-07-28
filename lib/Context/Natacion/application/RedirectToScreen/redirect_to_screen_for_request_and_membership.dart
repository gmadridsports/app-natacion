import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/navigation_request/navigation_request.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/MembershipStatus.dart';

class RedirectToScreenForRequestAndMembership {
  late final ShowingScreenRepository _showingScreenRepository;
  late final EventBus _eventBus;

  // todo change name navigateToScreen..
  RedirectToScreenForRequestAndMembership() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call(MembershipStatus membershipStatus,
      NavigationRequest? navigationRequest) async {
    final showingScreen = _showingScreenRepository.getShowingScreen();

    if (showingScreen == null) {
      // not running
      return;
    }

    showingScreen.changeCurrentScreenForNavigationRequest(
        navigationRequest, membershipStatus);

    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
