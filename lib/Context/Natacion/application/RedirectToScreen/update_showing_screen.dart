import '../../../../shared/dependency_injection.dart';
import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/screen/screen.dart';
import '../../domain/screen/showing_screen_repository.dart';

class UpdateShowingScreen {
  late final ShowingScreenRepository _showingScreenRepository;
  late final EventBus _eventBus;

  UpdateShowingScreen() {
    _showingScreenRepository =
        DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  @override
  call(Screen showingScreen) {
    final currentShowingScreen = _showingScreenRepository.getShowingScreen();
    if (currentShowingScreen == null) {
      return;
    }
    currentShowingScreen.updateToScreen(showingScreen);

    _showingScreenRepository.save(currentShowingScreen);
    _eventBus.publish(currentShowingScreen.pullDomainEvents());
  }
}
