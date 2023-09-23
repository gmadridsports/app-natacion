import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import '../Email.dart';
import 'MembershipStatus.dart';
import 'UserId.dart';
import 'user_login_event.dart';
import 'user_logout_event.dart';

class User extends AggregateRoot {
  final UserId _id;
  final MembershipStatus membership;
  final Email email;

  User._internal(this._id, this.membership, this.email);

  User.from(UserId id, MembershipStatus membership, Email email)
      : this._internal(id, membership, email);

  bool canUseApp() {
    return membership.canUseApp();
  }

  logout() {
    this.domainEvents.add(UserLogoutEvent(_id, DateTime.now()));
  }

  login() {
    domainEvents
        .add(UserLoginEvent(_id, DateTime.now(), membership.toString()));
  }
}
