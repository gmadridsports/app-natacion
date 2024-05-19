import '../../../../shared/dependency_injection.dart';
import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/user/UserRepository.dart';

class LoginUser {
  late final EventBus _eventBus;
  late final UserRepository _userRepository;

  LoginUser() {
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
  }

  void call() {
    final user = _userRepository.getCurrentSessionUser();

    user.then((value) {
      if (value == null) {
        return;
      }

      value.login();
      _userRepository.save(value, skipSyncWithBackend: true);
    });
  }
}
