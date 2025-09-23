
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.person),
      label: const Text('PROFILE'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () {
        Navigator.of(context).pop();
  // Navigate to profile allowing back navigation
  context.pushNamed('profile');
      },
    );
  }
}