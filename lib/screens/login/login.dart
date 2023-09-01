import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/models/RunningMode.dart';
import 'package:gmadrid_natacion/screens/training-week/training-week.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../NamedRouteScreen.dart';

class Login extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => '/login';

  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (RunningMode.fromEnvironment().isTestingMode()) {
        final response = await Supabase.instance.client.auth.signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
      } else {
        await Supabase.instance.client.auth.signInWithOtp(
          email: _emailController.text.trim(),
          emailRedirectTo: kIsWeb
              ? null
              : 'https://authgmadridnatacion.bertamini.net/login-callback',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Controla tu buzón y pincha el enlace de acceso!')),
        );
        _emailController.clear();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed(TrainingWeek.routeName);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  String? validateEmail(String? value) {
    print('validateEmail');
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Usa un email válido'
        : null;
  }

  String? get _errorText {
    final text = _emailController.value.text;
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return text!.isNotEmpty && !regex.hasMatch(text)
        ? 'Usa un email válido'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final testPasswordField = TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
    );

    final scaffoldElements = [
      const Image(
          image: AssetImage('assets/images/logo-mascota.png'), height: 250),
      // const Text(
      //   'Accede a la aplicación con tu email',
      //   style: TextStyle(fontSize: 20),
      //   textAlign: TextAlign.center,
      // ),
      const SizedBox(height: 18),
      TextField(
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
        onSubmitted: (_) => _signIn(),
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          labelStyle: const TextStyle(fontSize: 22),
          labelText: 'Email',
          errorText: _errorText,
          errorStyle: const TextStyle(fontSize: 16),
        ),
      ),
      testPasswordField,
      const SizedBox(height: 18),
      ElevatedButton(
          onPressed: _isLoading ? null : _signIn,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(_isLoading ? 'Loading' : 'Envíame el enlace de acceso',
              style: TextStyle(fontSize: 18))),
    ];

    if (!RunningMode.fromEnvironment().isTestingMode()) {
      scaffoldElements.remove(testPasswordField);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Acceso')),
      body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          children: scaffoldElements),
    );
  }
}
