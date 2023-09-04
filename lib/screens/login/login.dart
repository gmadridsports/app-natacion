import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/models/RunningMode.dart';
import 'package:gmadrid_natacion/screens/training-week/training-week.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Email.dart';
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

      if (_emailController.text.isEmpty) {
        return;
      }

      final email = Email.fromString(_emailController.text);

      if (RunningMode.fromEnvironment().isTestingMode()) {
        final response = await Supabase.instance.client.auth.signInWithPassword(
            email: email.toString(), password: _passwordController.text.trim());
      } else {
        await Supabase.instance.client.auth.signInWithOtp(
          email: email.toString(),
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
        content: const Text('Ha ocurrido un error inesperado'),
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
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  String? get _errorText {
    if (_emailController.value.text.isEmpty) return null;

    try {
      Email.fromString(_emailController.value.text);
    } catch (error) {
      return error.toString();
    }

    return null;
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
      const SizedBox(height: 18),
      TextField(
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
        enabled: !_isLoading,
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
          child: Text(
              _isLoading ? 'Enviando...' : 'Envíame el enlace de acceso',
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
