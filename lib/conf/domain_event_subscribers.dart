import 'package:gmadrid_natacion/Context/Natacion/application/listen_new_remote_published_notices/notify_new_bulletin_notice_on_new_published_notice_received.dart';

import '../Context/Natacion/application/LoginUser/AnnounceAlreadyLoggedInOnLoggedInAlready.dart';
import '../Context/Natacion/application/RedirectToScreen/RedirectToLoginScreenOnLogout.dart';
import '../Context/Natacion/application/RedirectToScreen/RedirectToProperScreenOnLogin.dart';
import '../Context/Natacion/application/RedirectToScreen/RedirectToProperScreenOnMembershipChangedFromBackoffice.dart';
import '../Context/Natacion/application/RedirectToScreen/redirect_to_proper_screen_on_user_already_logged_in.dart';
import '../Context/Natacion/application/update_user/UpdateUserMembershipOnMembershipChanged.dart';
import '../Context/Shared/domain/DomainEventSubscriber.dart';

List<DomainEventSubscriber> domainEventSubscribers = [
  RedirectToProperScreenOnMembershipApproved(),
  RedirectToLoginOnLogout(),
  RedirectToProperScreenOnLogin(),
  UpdateUserMembershipOnMembershipChanged(),
  AnnounceAlreadyLoggedInOnUserReopenedAppWithValidSession(),
  RedirectToProperScreenOnUserAlreadyLoggedIn(),
  NotifyNewBulletinNoticeOnNewNotice()
];
