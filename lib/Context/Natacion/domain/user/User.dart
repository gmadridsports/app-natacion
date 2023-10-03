import 'package:gmadrid_natacion/Context/Natacion/domain/user/user_logged_in_event.dart';

import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import '../Email.dart';
import 'ListenedEvents/UserAppUsagePermissionsChanged.dart';
import 'MembershipStatus.dart';
import 'UserId.dart';
import 'user_login_event.dart';
import 'user_logout_event.dart';

class User extends AggregateRoot {
  final UserId _id;
  MembershipStatus _membership;
  final Email email;

  get membership => _membership;

  User._internal(this._id, this._membership, this.email);

  User.from(UserId id, MembershipStatus membership, Email email)
      : this._internal(id, membership, email);

  bool canUseApp() {
    return _membership.canUseApp();
  }

  logout() {
    this.domainEvents.add(UserLogoutEvent(_id, DateTime.now()));
  }

  login() {
    domainEvents
        .add(UserLoginEvent(_id, DateTime.now(), _membership.toString()));
  }

  declareAlreadyLoggedIn() {
    domainEvents.add(
        UserAlreadyLoggedInEvent(_id, DateTime.now(), _membership.toString()));
  }

  changeMembership(MembershipStatus newMembershipStatus) {
    _membership = newMembershipStatus;

    domainEvents.add(UserAppUsagePermissionsChanged(
        _id, DateTime.now(), _membership.canUseApp()));
  }
}
