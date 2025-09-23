import 'package:flutter/material.dart';
import '../../../../responsive.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? sidebar;

  const AuthLayout({super.key, required this.title, required this.child, this.sidebar});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final card = Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );

    return Container(
      color: bg,
      child: SafeArea(
        child: Responsive(
          mobile: Center(child: SingleChildScrollView(child: card)),
          desktop: Row(
            children: [
              Expanded(
                flex: 3,
                child: sidebar ?? _DefaultAuthSidebar(),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 2,
                child: Center(child: SingleChildScrollView(child: card)),
              ),
            ],
          ),
          tablet: Center(child: SingleChildScrollView(child: card)),
        ),
      ),
    );
  }
}

class _DefaultAuthSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Starter App', style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          Text(
            'Welcome! Sign in to continue. Built with a responsive layout.',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
