import 'package:gmadrid_natacion/Context/Shared/domain/value_object.dart';

enum MembershipStatus implements ValueObject {
  user(level: 'user'),
  member(level: 'member'),
  exMember(level: 'ex-member');

  const MembershipStatus({required String level}) : _level = level;
  factory MembershipStatus.fromString(String level) {
    switch (level.trim()) {
      case 'user':
        return MembershipStatus.user;
      case 'member':
        return MembershipStatus.member;
      case 'ex-member':
        return MembershipStatus.exMember;
      default:
        throw new ArgumentError('Invalid membership status: $level');
    }
  }

  final String _level;

  bool canUseApp() {
    return _level == 'member';
  }

  @override
  String toString() {
    return _level;
  }
}
