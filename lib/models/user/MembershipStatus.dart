enum MembershipStatus {
  user(level: 'user'),
  member(level: 'member'),
  exMember(level: 'ex-member');

  const MembershipStatus({required this.level});
  // todo socio xx-xxA factory constructor
  // https://dart.dev/language/enums
  const MembershipStatus.fromString(String level) : this(level: level);

  final String level;

  bool canAccessApp() {
    return level == 'user';
  }
}
