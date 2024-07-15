import 'package:gmadrid_natacion/Context/Natacion/domain/navigation_request/navigation_request.dart';

import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import '../user/MembershipStatus.dart';
import 'ChangedCurrentScreenDomainEvent.dart';
import 'NotChangedCurrentScreenDomainEvent.dart';
import 'screen.dart';
import 'schowing_screen_id.dart';

class ShowingScreen extends AggregateRoot {
  ShowingScreenId _id;
  Screen _currentScreen;

  ShowingScreen._internal(this._id, this._currentScreen);

  ShowingScreen.from(ShowingScreenId id, Screen currentScreen)
      : this._internal(id, currentScreen);

  changeCurrentScreenIfCurrentStatusChangesIt(
      MembershipStatus? accordingToMembershipStatus) {
    final nextCurrentScreen =
        _currentScreen.nextScreen(accordingToMembershipStatus);

    if (nextCurrentScreen == _currentScreen) {
      record(NotChangedCurrentScreenDomainEvent(
          _id, DateTime.now(), _currentScreen.path));
      return;
    }

    _currentScreen = nextCurrentScreen;
    record(ChangedCurrentScreenDomainEvent(
        _id, DateTime.now(), _currentScreen.path, false));
  }

  changeCurrentScreenForNavigationRequest(
      NavigationRequest? forNavigationRequest,
      MembershipStatus? accordingToMembershipStatus) {
    switch (forNavigationRequest?.navigationType) {
      case null:
        changeCurrentScreenIfCurrentStatusChangesIt(
            accordingToMembershipStatus);
        return;
      case RequestType.screen:
        final requestedScreen = forNavigationRequest!.destination;
        final nextCurrentScreen = _currentScreen.nextFromRequestedScreen(
            accordingToMembershipStatus, requestedScreen);

        if (nextCurrentScreen == _currentScreen) {
          record(NotChangedCurrentScreenDomainEvent(
              _id, DateTime.now(), _currentScreen.path));
          return;
        }

        _currentScreen = nextCurrentScreen;
        record(ChangedCurrentScreenDomainEvent(
            _id, DateTime.now(), _currentScreen.path, false));

      default:
        throw ArgumentError(
            'Cannot change current screen for a navigation type ${forNavigationRequest?.navigationType}');
    }
  }

  resetToLogin() {
    _currentScreen = Screen.mainScreen(MainScreen.login);

    record(ChangedCurrentScreenDomainEvent(
        _id, DateTime.now(), _currentScreen.path, false));
  }

  updateToScreen(Screen newScreen) {
    _currentScreen = newScreen;
    record(ChangedCurrentScreenDomainEvent(
        _id, DateTime.now(), _currentScreen.path, true));
  }
}
