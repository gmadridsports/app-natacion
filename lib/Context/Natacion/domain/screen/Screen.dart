import '../user/MembershipStatus.dart';
import '../user/User.dart';

enum Screen {
  login(name: '/login'),
  waitingApproval(name: '/waiting-approval'),
  trainingWeek(name: '/training-week'),
  splash(name: '/splash');

  const Screen({required this.name});

  factory Screen.fromString(String name) {
    switch (name.trim()) {
      case '/login':
        return Screen.login;
      case '/waiting-approval':
        return Screen.waitingApproval;
      case '/training-week':
        return Screen.trainingWeek;
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
      case Screen.trainingWeek:
        if (!accordingToMembershipStatus.canUseApp()) {
          return Screen.waitingApproval;
        } else {
          return Screen.trainingWeek;
        }
      default:
        if (accordingToMembershipStatus.canUseApp()) {
          return Screen.trainingWeek;
        } else {
          return Screen.waitingApproval;
        }
    }
  }

  final String name;
}
