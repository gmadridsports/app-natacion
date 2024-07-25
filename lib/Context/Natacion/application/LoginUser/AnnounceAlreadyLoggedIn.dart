import '../../../../shared/dependency_injection.dart';
import '../../domain/user/UserRepository.dart';

class AnnounceAlreadyLoggedIn {
  late final UserRepository _userRepository;

  AnnounceAlreadyLoggedIn() {
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
  }

  void call() {
    final user = _userRepository.getCurrentSessionUser();

    user.then((value) {
      if (value == null) {
        return;
      }

      value.declareAlreadyLoggedIn();
      _userRepository.save(value, skipSyncWithBackend: true);
    });
  }
}
