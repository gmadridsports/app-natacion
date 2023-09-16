import '../../../application/RedirectToScreen/redirect_to_first_screen_for_user.dart';
import '../command_interface.dart';

class RedirectToFirstScreenForCurrentUser implements CommandInterface {
  @override
  void call() async {
    RedirectToFirstScreenForUser()();
  }
}
