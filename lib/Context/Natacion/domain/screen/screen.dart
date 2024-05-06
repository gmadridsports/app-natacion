import 'package:gmadrid_natacion/Context/Natacion/domain/screen/sub_screen.dart';
import '../user/MembershipStatus.dart';

enum MainScreen {
  login(name: '/login'),
  waitingApproval(name: '/waiting-approval'),
  memberApp(name: '/member-app'),
  splash(name: '/splash');

  final String name;

  const MainScreen({required this.name});

  factory MainScreen.fromString(String fullPath) {
    final rootPath = fullPath.trim().split('/')[1];
    switch (rootPath) {
      case 'login':
        return MainScreen.login;
      case 'waiting-approval':
        return MainScreen.waitingApproval;
      case 'member-app':
        return MainScreen.memberApp;
      case 'splash':
        return MainScreen.splash;
      default:
        throw ArgumentError('Invalid screen : $fullPath');
    }
  }
}

class Screen {
  static const _pathValidationRegex =
      "^(\\/[a-zA-Z\\_\\-0-9]+){1}(\\/[a-zA-Z\\_\\-0-9]+)*\$";

  final String _fullpath;
  final MainScreen _mainScreen;
  final SubScreen? _subScreen;

  MainScreen get mainScreen => _mainScreen;

  SubScreen? get subScreen => _subScreen;

  String get path => _fullpath;

  Screen._from(this._fullpath, this._mainScreen, this._subScreen);

  @override
  bool operator ==(Object other) {
    return other is Screen && _fullpath == other._fullpath;
  }

  @override
  int get hashCode => _fullpath.hashCode;

  factory Screen.fromString(String fullPath) {
    RegExp regExp =
        RegExp(_pathValidationRegex, caseSensitive: false, multiLine: false);
    if (!regExp.hasMatch(fullPath)) {
      throw ArgumentError();
    }

    MainScreen mainScreen =
        MainScreen.fromString(regExp.firstMatch(fullPath)![0]!);

    switch (mainScreen) {
      case MainScreen.memberApp:
        return Screen._from(
            fullPath, mainScreen, SubScreen.fromString(mainScreen, fullPath));
      default:
        return Screen._from(fullPath, mainScreen, null);
    }
  }

  factory Screen.mainScreen(MainScreen mainScreen) {
    return Screen.fromString(mainScreen.name);
  }

  Screen nextScreen(MembershipStatus? accordingToMembershipStatus) {
    if (accordingToMembershipStatus == null) {
      return Screen._from(MainScreen.login.name, MainScreen.login, null);
    }

    switch (_mainScreen) {
      case MainScreen.login:
        if (!accordingToMembershipStatus.canUseApp()) {
          return Screen._from(MainScreen.waitingApproval.name,
              MainScreen.waitingApproval, null);
        } else {
          return Screen._from(
              MainScreen.memberApp.name, MainScreen.memberApp, null);
        }
      case MainScreen.memberApp:
        if (!accordingToMembershipStatus.canUseApp()) {
          return Screen._from(MainScreen.waitingApproval.name,
              MainScreen.waitingApproval, null);
        }
        return Screen._from(
            _subScreen!.fullPath,
            MainScreen.memberApp,
            _subScreen != null
                ? SubScreen.fromString(
                    MainScreen.memberApp, _subScreen!.fullPath)
                : SubScreen.defaultSubscreenForMainScreen(
                    MainScreen.memberApp));
      default:
        if (accordingToMembershipStatus.canUseApp()) {
          return Screen._from(MainScreen.memberApp.name, MainScreen.memberApp,
              SubScreen.defaultSubscreenForMainScreen(MainScreen.memberApp));
        }
        return Screen._from(
            MainScreen.waitingApproval.name, MainScreen.waitingApproval, null);
    }
  }

  Screen nextFromRequestedScreen(
      MembershipStatus? withMembershipStatus, Screen requestedScreen) {
    if (withMembershipStatus == null) {
      return Screen._from(MainScreen.login.name, MainScreen.login, null);
    }

    switch (requestedScreen.mainScreen) {
      case MainScreen.memberApp:
        if (withMembershipStatus.canUseApp()) {
          return Screen.fromString(requestedScreen._fullpath);
        }

        return Screen._from(
            MainScreen.waitingApproval.name, MainScreen.waitingApproval, null);
      default:
        return Screen.fromString(requestedScreen._fullpath);
    }
  }
}
