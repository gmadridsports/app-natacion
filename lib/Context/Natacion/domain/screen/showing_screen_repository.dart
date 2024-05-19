import 'showing_screen.dart';

abstract class ShowingScreenRepository {
  ShowingScreen? getShowingScreen();
  save(ShowingScreen showingScreen);
}
