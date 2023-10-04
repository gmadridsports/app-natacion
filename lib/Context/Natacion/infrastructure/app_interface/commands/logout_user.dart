import '../../../application/LogoutUser/LogoutUser.dart' as AppLogoutUser;
import '../command_interface.dart';

class LogoutUser implements CommandInterface {
  @override
  void call() async {
    AppLogoutUser.LogoutUser()();
  }
}
