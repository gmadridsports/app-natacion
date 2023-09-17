import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../NamedRouteScreen.dart';
import '../splash-screen/splash-screen.dart';

class Profile extends StatelessWidget implements NamedRouteScreen {
  static String get routeName => '/profile';

  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GMadrid Natación'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
                SplashScreen.routeName, (route) => false);
          },
          child: const Text('Salir'),
        ),
      ),
    );
  }
}
