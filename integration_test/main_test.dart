import 'package:patrol/patrol.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;

void main() {
  patrolTest(
    'Happy path show training of the week',
    nativeAutomation: true,
    (PatrolTester $) async {
      app_main.main(envFileName: 'assets/.test.env');

      if (await $.native
          .isPermissionDialogVisible(timeout: Duration(seconds: 10))) {
        await $.native.grantPermissionWhenInUse();
      }

      await $.pumpAndSettle();

      await $('GMadrid Natación').waitUntilVisible();

      // todo enable as soon as https://github.com/leancodepl/patrol/issues/788
      // var bytes = await binding.takeScreenshot('screen1');
      // print(bytes);
    },
  );
}
