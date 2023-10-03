import '../../../../shared/dependency_injection.dart';
import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/user/UserRepository.dart';

class AnnounceAlreadyLoggedIn {
  late final EventBus _eventBus;
  late final UserRepository _userRepository;

  AnnounceAlreadyLoggedIn() {
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
  }

  void call() {
    final user = _userRepository.getCurrentSessionUser();

    user.then((value) {
      if (value == null) {
        return;
      }

      value.declareAlreadyLoggedIn();
      _userRepository.save(value);
      _eventBus.publish(value.pullDomainEvents() ?? []);
    });
  }
}
