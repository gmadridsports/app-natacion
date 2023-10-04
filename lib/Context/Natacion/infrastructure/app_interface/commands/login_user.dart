import '../../../application/LoginUser/LoginUser.dart' as AppLoginUser;
import '../command_interface.dart';

class LoginUser implements CommandInterface {
  @override
  void call() async {
    AppLoginUser.LoginUser()();
  }
}
