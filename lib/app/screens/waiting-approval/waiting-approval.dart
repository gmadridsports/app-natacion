import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Context/Natacion/infrastructure/app_interface/commands/logout_user.dart';
import '../NamedRouteScreen.dart';

class WaitingApproval extends StatelessWidget implements NamedRouteScreen {
  @override
  static String get routeName => '/waiting-approval';

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 10000),
              turns: 5.0,
              child: Image.asset(
                'assets/images/logo.png',
                width: 100,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Pendiente de revisión',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 30,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decorationStyle: null,
                  decorationColor: Colors.blue),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'En un plazo de 24h revisaremos que tu correo haga parte de la lista de socios, y podrás usar la app.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                  decorationStyle: null,
                  decorationColor: Colors.blue),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              key: Key('logout-from-approval'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                LogoutUser()();
              },
              child: Text('Prefiero cerrar sesión',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
