enum MembershipStatus {
  user(level: 'user'),
  member(level: 'member'),
  exMember(level: 'ex-member');

  const MembershipStatus({required this.level});
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

  final String level;

  bool canUseApp() {
    return level == 'member';
  }
}
