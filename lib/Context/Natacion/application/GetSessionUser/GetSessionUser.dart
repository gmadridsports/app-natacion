import '../../../../shared/dependency_injection.dart';
import '../../domain/screen/showing_screen_repository.dart';
import '../../domain/user/UserRepository.dart';
import 'GetSessionUserResponse.dart';

class GetSessionUser {
  late final UserRepository _userRepository;
  GetSessionUser() {
    DependencyInjection().getInstanceOf<ShowingScreenRepository>();
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
  }

  Future<GetSessionUserResponse> call() async {
    final user = await _userRepository.getCurrentSessionUser();

    if (user == null) {
      return GetSessionUserResponse(
          false, '', false, NotificationPreferences(false, false, false), '');
    }

    return GetSessionUserResponse(
        true,
        user.email.toString(),
        user.canUseApp(),
        NotificationPreferences(
            user.notificationPreferences.trainingWeek,
            user.notificationPreferences.bulletinBoard,
            user.notificationPreferences.other),
        user.membership.toString());
  }
}
