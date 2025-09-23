import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../widgets/loginform.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final logger = Logger();
  @override
  Widget build(BuildContext context) {
    logger.i('Building LoginScreen');
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AuthLayout(
        title: 'Sign In',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}
