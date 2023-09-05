import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/screens/training-week/training-week.dart';
import 'package:gmadrid_natacion/screens/waiting-approval/waiting-approval.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../dependency_injection.dart';
import '../NamedRouteScreen.dart';
import '../login/login.dart';

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

    final user = await DependencyInjection.of(context)!
        .userRepository
        .getCurrentSessionUser();

    // if (!context.isDefinedAndNotNull) {
    //   // todo manage better
    //   return;
    // }

    if (user == null) {
      Navigator.of(context).pushReplacementNamed(Login.routeName);
    }

    if (!(user?.canUseApp() ?? false)) {
      Navigator.of(context).pushReplacementNamed(WaitingApproval.routeName);
      return;
    }

    Navigator.of(context).pushReplacementNamed(TrainingWeek.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
