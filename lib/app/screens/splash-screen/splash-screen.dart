import 'package:flutter/material.dart';
import '../../../Context/Natacion/infrastructure/app_interface/commands/redirect_to_first_screen_for_current_user.dart';
import '../NamedRouteScreen.dart';

class SplashScreen extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => '/splash';

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    RedirectToFirstScreenForCurrentUser()();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
