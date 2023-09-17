import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/MembershipStatus.dart';

class RedirectToFirstScreenForMembership {
  late final ShowingScreenRepository _showingScreenRepository;
  late final EventBus _eventBus;

  RedirectToFirstScreenForMembership() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call(MembershipStatus? membershipStatus) {
    final showingScreen = _showingScreenRepository.getScreen();

    if (showingScreen == null) {
      // not running
      return;
    }

    showingScreen.changeCurrentScreen(membershipStatus);
    _showingScreenRepository.save(showingScreen);
    _eventBus.publish(showingScreen.pullDomainEvents());
  }
}
