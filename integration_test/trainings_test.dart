import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmadrid_natacion/main.dart' as app_main;
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Screenshot test example', (tester) async {
    await tester.runAsync(() async {
      await app_main.main(envFileName: 'assets/.test.env');
      await tester.pumpAndSettle();

      // await Future.delayed(Duration(seconds: 3));
      expect(find.text('GMadrid Natación'), findsOneWidget);
      await tester.pumpAndSettle();

      var bytes = await binding.takeScreenshot('screen1');
      await tester.pumpAndSettle();
      //
      // await Future.delayed(Duration(seconds: 3));
      // expect(find.text('GMadrid Natación'), findsOneWidget);
      //
      // bytes = await binding.takeScreenshot('screen1');
      // await tester.pumpAndSettle();
      //
      await expectLater(
        bytes,
        matchesGoldenFile('goldens/screen1.png'),
      );

      // new File('screenshot-1.png').writeAsBytes(bytes);
      // print(Directory.current.path);
      // print('envvar -----');
      // print(const String.fromEnvironment("SOMEENVVAR"));
      // const screenshotDir = const String.fromEnvironment("ANIMAL");
      // print(const String.fromEnvironment('ANIMAL'));
      // final File image =
      //     await File('${screenshotDir}/screen1.png').create(recursive: true);
      // image.writeAsBytesSync(bytes);
      // // print(bytes);
    });
  });
}
