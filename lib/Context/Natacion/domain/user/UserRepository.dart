import 'User.dart';

abstract class UserRepository {
  Future<User?> getCurrentSessionUser();
  Future<void> deleteCurrentSessionUser();
  Future<void> save(User user);
}
