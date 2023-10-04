import '../user/MembershipStatus.dart';
import '../user/User.dart';

enum Screen {
  login(name: '/login'),
  waitingApproval(name: '/waiting-approval'),
  memberApp(name: '/member-app'),
  splash(name: '/splash');

  const Screen({required this.name});

  factory Screen.fromString(String name) {
    switch (name.trim()) {
      case '/login':
        return Screen.login;
      case '/waiting-approval':
        return Screen.waitingApproval;
      case '/member-app':
        return Screen.memberApp;
      default:
        throw new ArgumentError('Invalid screen : $name');
    }
  }

  Screen nextShowingScreen(MembershipStatus? accordingToMembershipStatus) {
    if (accordingToMembershipStatus == null) {
      return Screen.login;
    }

    switch (this) {
      case Screen.login:
      case Screen.memberApp:
        if (!accordingToMembershipStatus.canUseApp()) {
          return Screen.waitingApproval;
        } else {
          return Screen.memberApp;
        }
      default:
        if (accordingToMembershipStatus.canUseApp()) {
          return Screen.memberApp;
        } else {
          return Screen.waitingApproval;
        }
    }
  }

  final String name;
}
