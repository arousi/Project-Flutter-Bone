// sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../widgets/signup_form.dart';
import '../widgets/auth_layout.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.i('Building #SignUpScreen');
    return GestureDetector(
      onTap: () {
        logger.t('Tapped outside input fields');
        // Dismiss keyboard when tapping outside input fields.
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AuthLayout(
          title: 'Create Account',
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}
