import 'package:flutter/material.dart';

class Pools extends StatelessWidget {
  const Pools({super.key});

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
              '¡Ups! 🤓',
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
              'Esta funcionalidad no ha sido todavía desarrollada y estará disponible en futuras versiones.',
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
          ],
        ),
      ),
    );
  }
}
