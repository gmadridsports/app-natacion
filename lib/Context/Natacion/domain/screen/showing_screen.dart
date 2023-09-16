import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import '../user/MembershipStatus.dart';
import 'ChangedCurrentScreenDomainEvent.dart';
import 'Screen.dart';
import 'schowing_screen_id.dart';

class ShowingScreen extends AggregateRoot {
  ShowingScreenId _id;
  Screen _currentScreen;

  ShowingScreen._internal(this._id, this._currentScreen);

  ShowingScreen.from(ShowingScreenId id, Screen currentScreen)
      : this._internal(id, currentScreen);

  changeCurrentScreen(MembershipStatus? accordingToMembershipStatus) {
    _currentScreen =
        _currentScreen.nextShowingScreen(accordingToMembershipStatus);

    record(ChangedCurrentScreenDomainEvent(
        _id, DateTime.now(), _currentScreen.name));
  }

  resetToLogin() {
    _currentScreen = Screen.login;

    record(ChangedCurrentScreenDomainEvent(
        _id, DateTime.now(), _currentScreen.name));
  }

  // changeCurrentScreen(User? accordingToUser) {
  //   if(accordingToUser == null) {
  //
  //     return;
  //   }
  // }
}
