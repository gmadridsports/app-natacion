import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/UserRepository.dart';

class RedirectToFirstScreenForUser {
  late final ShowingScreenRepository _showingScreenRepository;
  late final UserRepository _userRepository;
  late final EventBus _eventBus;

  RedirectToFirstScreenForUser() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call() async {
    final showingScreen = _showingScreenRepository.getScreen();
    final currentUser = await _userRepository.getCurrentSessionUser();

    if (showingScreen == null) {
      // not running
      return;
    }

    showingScreen.changeCurrentScreen(currentUser?.membership);
    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
