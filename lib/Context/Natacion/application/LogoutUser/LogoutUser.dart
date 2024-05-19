import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/UserRepository.dart';

class LogoutUser {
  late final ShowingScreenRepository _showingScreenRepository;
  late final EventBus _eventBus;
  late final UserRepository _userRepository;

  LogoutUser() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
  }

  void call() {
    final showingScreen = _showingScreenRepository.getShowingScreen();

    if (showingScreen == null) {
      // not running
      return;
    }

    final user = _userRepository.getCurrentSessionUser();
    user.then((value) {
      value?.logout();
      _eventBus.publish(value?.pullDomainEvents() ?? []);
    });

    _userRepository.deleteCurrentSessionUser();
  }
}
