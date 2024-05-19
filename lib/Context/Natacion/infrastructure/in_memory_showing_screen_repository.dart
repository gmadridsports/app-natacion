import '../../../shared/dependency_injection.dart';
import '../../Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';
import '../domain/screen/showing_screen.dart';
import '../domain/screen/showing_screen_repository.dart';

class InMemoryShowingScreenRepository implements ShowingScreenRepository {
  static ShowingScreen? _showingScreen;

  InMemoryShowingScreenRepository(ShowingScreen initialShowingScreen) {
    _showingScreen = initialShowingScreen;
  }

  @override
  ShowingScreen? getShowingScreen() {
    return _showingScreen;
  }

  @override
  save(ShowingScreen showingScreen) {
    _showingScreen = showingScreen;

    DependencyInjection()
        .getInstanceOf<LibEventBusEventBus>()
        .publishApp(showingScreen.domainEvents);
  }
}
