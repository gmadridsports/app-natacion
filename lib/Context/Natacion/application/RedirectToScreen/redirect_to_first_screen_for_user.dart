import 'package:gmadrid_natacion/Context/Natacion/domain/navigation_request/navigation_request_repository.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/UserRepository.dart';

class RedirectToFirstScreenForUser {
  late final ShowingScreenRepository _showingScreenRepository;
  late final NavigationRequestRepository _navigationRequestRepository;
  late final UserRepository _userRepository;
  late final EventBus _eventBus;

  RedirectToFirstScreenForUser() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
    _navigationRequestRepository =
        DependencyInjection().getInstanceOf<NavigationRequestRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call() async {
    final showingScreen = _showingScreenRepository.getShowingScreen();
    final currentUser = await _userRepository.getCurrentSessionUser();

    if (showingScreen == null) {
      // not running
      return;
    }
    final navigationRequest =
        await _navigationRequestRepository.pullLatestNavigationRequest();

    showingScreen.changeCurrentScreenForNavigationRequest(
        navigationRequest, currentUser?.membership);
    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
