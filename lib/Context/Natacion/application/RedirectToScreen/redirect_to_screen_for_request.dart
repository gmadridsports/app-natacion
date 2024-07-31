import 'package:gmadrid_natacion/Context/Natacion/domain/user/UserRepository.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/navigation_request/navigation_request.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/MembershipStatus.dart';

class RedirectToScreenForRequest {
  late final ShowingScreenRepository _showingScreenRepository;
  late final UserRepository _userRepository;
  late final EventBus _eventBus;

  RedirectToScreenForRequest() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call(NavigationRequest? navigationRequest) async {
    final user = await _userRepository.getCurrentSessionUser();
    final showingScreen = _showingScreenRepository.getShowingScreen();

    if (showingScreen == null) {
      // not running
      return;
    }

    showingScreen.changeCurrentScreenForNavigationRequest(
        navigationRequest, user?.membership);

    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
