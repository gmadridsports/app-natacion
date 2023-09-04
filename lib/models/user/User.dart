import 'package:gmadrid_natacion/models/user/MembershipStatus.dart';

import 'UserId.dart';

class User {
  final UserId _id;
  final MembershipStatus _membership;

  User._internal(this._id, this._membership);

  User.from(UserId id, MembershipStatus membership)
      : this._internal(id, membership);
}
