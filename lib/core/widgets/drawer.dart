import 'package:flutter/material.dart';

/// Minimal placeholder drawer retained only to avoid breaking imports.
/// Admin dashboard uses `screens/main/components/side_menu.dart` instead.
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, this.onConversationTap});
  final void Function(dynamic conversation)? onConversationTap;

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: SafeArea(
        child: Center(child: Text('Drawer')),
      ),
    );
  }
}