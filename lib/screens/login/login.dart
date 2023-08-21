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
          emailRedirectTo:
              kIsWeb ? null : 'net.bertamini.gmadridnatacion://login-callback/',
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

  @override
  Widget build(BuildContext context) {
    final testPasswordField = TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
    );

    final scaffoldElements = [
      const Text('Accede a la aplicación con tu email'),
      const SizedBox(height: 18),
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      testPasswordField,
      const SizedBox(height: 18),
      ElevatedButton(
          onPressed: _isLoading ? null : _signIn,
          child: Text(_isLoading ? 'Loading' : 'Envíame el enlace de acceso')),
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
