import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_providers.dart';

class AuthenticationOptions extends StatefulWidget {
  final bool isEditable;

  const AuthenticationOptions({
    super.key,
    required this.isEditable,
  });

  @override
  State<AuthenticationOptions> createState() => _AuthenticationOptionsState();
}

class _AuthenticationOptionsState extends State<AuthenticationOptions> {
  bool googleEnabled = false;
  bool msAuthEnabled = false;
  bool biometricEnabled = false;
  bool biometricSupported = true;
  final BiometricAuthService _biometricService = BiometricAuthService();
  final Set<String> _loading = {};

  @override
  void initState() {
    super.initState();
    _loadAuthOptions();
  }

  Future<void> _loadAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final supported = await _biometricService.canCheck();
    setState(() {
  // Default OFF: user must enable and complete OAuth successfully.
  googleEnabled = prefs.getBool('google_auth_enabled') ?? false;
  msAuthEnabled = prefs.getBool('ms_auth_enabled') ?? false;
      biometricEnabled = prefs.getBool('biometric_auth_enabled') ?? false; // Biometric must be explicitly enabled.
      biometricSupported = supported;
    });
  }

  Future<void> _saveAuthOption(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _handleGoogleAuth(bool value) async {
    if (_loading.contains('google')) return;
    setState(() { _loading.add('google'); });
    if (value) {
      // Start OAuth; only mark enabled on success via BlocListener.
      context.read<AuthCubit>().startGoogleOAuth(redirectSchemeHost: 'prompeteer://oauth/google');
    } else {
      // Immediate disable
      if (!mounted) return;
      setState(() {
        googleEnabled = false;
        _loading.remove('google');
      });
      await _saveAuthOption('google_auth_enabled', false);
    }
  }

  void _handleMsAuth(bool value) async {
    if (_loading.contains('ms')) return;
    setState(() { _loading.add('ms'); });
    if (value) {
      context.read<AuthCubit>().startMicrosoftOAuth(redirectSchemeHost: 'prompeteer://oauth/microsoft');
    } else {
      if (!mounted) return;
      setState(() {
        msAuthEnabled = false;
        _loading.remove('ms');
      });
      await _saveAuthOption('ms_auth_enabled', false);
    }
  }

  // OpenRouter removed

  void _handleBiometricAuth(bool value) async {
    if (_loading.contains('biometric')) return;
    setState(() { _loading.add('biometric'); });
    bool success = true;
    if (value) {
      final can = await _biometricService.canCheck();
      final types = await _biometricService.availableTypes();
      if (!can) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric not supported on device')));
      } else if (types.isEmpty) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No biometrics enrolled. Add fingerprint/face in system settings first.')));
      } else {
        success = await _biometricService.authenticate();
      }
    } else {
      await _biometricService.disable();
    }
    if (!mounted) return;
    setState(() {
      biometricEnabled = success ? value : biometricEnabled;
      _loading.remove('biometric');
    });
    if (success) {
      await _saveAuthOption('biometric_auth_enabled', value);
      // Inform AuthCubit about preference change.
      if (mounted) context.read<AuthCubit>().applyBiometricPreferenceChanged(value);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric auth failed or unavailable')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        // On OAuth success, enable and persist the specific provider toggle.
        if (state is AuthOAuthSuccess) {
          if (state.provider == 'google') {
            setState(() { googleEnabled = true; _loading.remove('google'); });
            await _saveAuthOption('google_auth_enabled', true);
          } else if (state.provider == 'microsoft') {
            setState(() { msAuthEnabled = true; _loading.remove('ms'); });
            await _saveAuthOption('ms_auth_enabled', true);
          }
        } else if (state is AuthOAuthError) {
          // Revert toggles on failure and clear loading state
          if (state.provider == 'google') {
            setState(() { googleEnabled = false; _loading.remove('google'); });
            await _saveAuthOption('google_auth_enabled', false);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
          } else if (state.provider == 'microsoft') {
            setState(() { msAuthEnabled = false; _loading.remove('ms'); });
            await _saveAuthOption('ms_auth_enabled', false);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microsoft sign-in failed')));
          }
        }
      },
  child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Authentication', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('OAuth Providers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Card(
          child: Column(
            children: [
              // OpenRouter removed
              _AuthSwitch(
                title: 'Google',
                subtitle: 'Enable to show Google Sign-In on login screen',
                value: googleEnabled,
                loading: _loading.contains('google'),
                onChanged: widget.isEditable ? _handleGoogleAuth : null,
              ),
              _AuthSwitch(
                title: 'Microsoft',
                subtitle: 'Enable to show Microsoft Sign-In on login screen',
                value: msAuthEnabled,
                loading: _loading.contains('ms'),
                onChanged: widget.isEditable ? _handleMsAuth : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Device Security', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Card(
          child: Column(
            children: [
              if (!biometricSupported)
                ListTile(
                  leading: const Icon(Icons.fingerprint, color: Colors.grey),
                  title: const Text('Biometric not available'),
                  subtitle: const Text('Your device does not support biometric authentication'),
                )
              else
                _AuthSwitch(
                  title: 'Biometric Authentication',
                  subtitle: 'Require fingerprint/face to unlock after login',
                  value: biometricEnabled,
                  loading: _loading.contains('biometric'),
                  onChanged: widget.isEditable ? _handleBiometricAuth : null,
                ),
            ],
          ),
        )
      ],
    ),
  );
  }
}

class _AuthSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final bool loading;
  final ValueChanged<bool>? onChanged;
  const _AuthSwitch({required this.title, this.subtitle, required this.value, required this.loading, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      secondary: loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : null,
      value: value,
      onChanged: loading ? null : onChanged,
    );
  }
}
