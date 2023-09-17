import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/showing_screen_repository.dart';

class RedirectToLogin {
  late final ShowingScreenRepository _showingScreenRepository;
  late final EventBus _eventBus;

  RedirectToLogin() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call() {
    final showingScreen = _showingScreenRepository.getScreen();

    if (showingScreen == null) {
      // not running
      return;
    }

    showingScreen.resetToLogin();
    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
