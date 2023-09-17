import 'showing_screen.dart';

abstract class ShowingScreenRepository {
  ShowingScreen? getScreen();
  save(ShowingScreen showingScreen);
}
