import '../../../../shared/dependency_injection.dart';
import '../../../Shared/domain/Bus/Event/EventBus.dart';
import '../../domain/user/MembershipStatus.dart';
import '../../domain/user/UserRepository.dart';

class UpdateUserMembership {
  late final UserRepository _userRepository;
  late final EventBus _eventBus;

  UpdateUserMembership() {
    _userRepository = DependencyInjection().getInstanceOf<UserRepository>();
    _eventBus = DependencyInjection().getInstanceOf<EventBus>();
  }

  void call(MembershipStatus membershipStatus) async {
    final user = await _userRepository.getCurrentSessionUser();

    if (user == null) {
      return;
    }

    user.changeMembership(membershipStatus);
    await _userRepository.save(user);

    _eventBus.publish(user.pullDomainEvents());
  }
}
