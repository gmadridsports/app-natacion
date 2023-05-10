import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('failing test example', (tester) async {
    // await tester.pumpWidget(app_main.main(envFileName: 'assets/.test.env'));
    app_main.main(envFileName: 'assets/.test.env');
    await tester.pumpAndSettle();
    // Build the app.

    // This is required prior to taking the screenshot (Android only).
    // await binding.convertFlutterSurfaceToImage();

    // Trigger a frame.
    // await tester.pumpAndSettle();
    final bytes = await binding.takeScreenshot('screenshot-1');
    // new File('screenshot-1.png').writeAsBytes(bytes);
    print(Directory.current.path);
    print('envvar -----');
    print(const String.fromEnvironment("SOMEENVVAR"));
    const screenshotDir = const String.fromEnvironment("ANIMAL");
    print(const String.fromEnvironment('ANIMAL'));
    final File image =
        await File('${screenshotDir}/screen1.png').create(recursive: true);
    image.writeAsBytesSync(bytes);
    // print(bytes);
  });
}
