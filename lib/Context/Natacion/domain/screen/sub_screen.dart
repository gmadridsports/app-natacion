import 'package:gmadrid_natacion/main.dart';

import 'screen.dart';

/// While MainScreen represents a fullscreen limited fixed set of screens that
/// are showed to the user, a subscreen represents what a MainScreen could
/// potentially show.
/// The member-app screen, for instance, has several tabs, which show a subscreen each.
/// Other Mainscreen only have a single interface to show, so they will only have
/// a single subscreen.
class SubScreen {
  static const _pathValidationRegex =
      "^(\\/[a-zA-Z\\_\\-0-9]+){1}(\\/[a-zA-Z\\_\\-0-9]+)*\$";
  final String fullPath;
  final MainScreen _parent;

  SubScreen._private(this.fullPath, this._parent);

  factory SubScreen.defaultSubscreenForMainScreen(MainScreen mainScreen) {
    switch (mainScreen) {
      case MainScreen.memberApp:
        return SubScreen._private(
            "${MainScreen.memberApp.name}/training-week", MainScreen.memberApp);
      default:
        throw ArgumentError("There is no subscreen for this main screen");
    }
  }

  factory SubScreen.fromString(MainScreen mainScreen, String fullPath) {
    RegExp regExp =
        RegExp(_pathValidationRegex, caseSensitive: false, multiLine: false);
    if (!regExp.hasMatch(fullPath)) {
      throw ArgumentError();
    }

    switch (mainScreen) {
      case MainScreen.memberApp:
        final match = regExp.firstMatch(fullPath);
        return ((match?.groupCount ?? 0) <= 1)
            ? SubScreen.defaultSubscreenForMainScreen(mainScreen)
            : SubScreen._private(fullPath, mainScreen);
      default:
        throw ArgumentError();
    }
  }
}
