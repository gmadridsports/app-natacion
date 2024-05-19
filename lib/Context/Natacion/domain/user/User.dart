import 'package:gmadrid_natacion/Context/Natacion/domain/user/notification_preferences.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/user/user_logged_in_event.dart';

import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import '../Email.dart';
import 'ListenedEvents/UserAppUsagePermissionsChanged.dart';
import 'MembershipStatus.dart';
import 'UserId.dart';
import 'user_app_notification_preferences_changed_event.dart';
import 'user_login_event.dart';
import 'user_logout_event.dart';

class User extends AggregateRoot {
  final UserId id;
  MembershipStatus _membership;
  NotificationPreferences _notificationPreferences;
  final Email email;

  get membership => _membership;
  get notificationPreferences => _notificationPreferences;

  User._internal(
      this.id, this._membership, this.email, this._notificationPreferences);

  User.from(UserId id, MembershipStatus membership, Email email,
      NotificationPreferences notificationPreferences)
      : this._internal(id, membership, email, notificationPreferences);

  bool canUseApp() {
    return _membership.canUseApp();
  }

  logout() {
    domainEvents.add(UserLogoutEvent(id, DateTime.now()));
  }

  login() {
    domainEvents
        .add(UserLoginEvent(id, DateTime.now(), _membership.toString()));
  }

  declareAlreadyLoggedIn() {
    domainEvents.add(
        UserAlreadyLoggedInEvent(id, DateTime.now(), _membership.toString()));
  }

  changeMembership(MembershipStatus newMembershipStatus) {
    if (_membership == newMembershipStatus) {
      return;
    }

    _membership = newMembershipStatus;
    domainEvents.add(UserAppUsagePermissionsChanged(
        id, DateTime.now(), _membership.canUseApp()));
  }

  changeNotificationPreferences(NotificationPreferences preferences) {
    _notificationPreferences = preferences;

    domainEvents.add(UserAppNotificationPreferencesChanged(
        id, DateTime.now(), _notificationPreferences.toPrimitives()));
  }
}
