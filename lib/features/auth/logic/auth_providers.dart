import 'dart:async';
import 'package:djangoflow_oauth/djangoflow_oauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic OAuth Provider definitions (Google, Microsoft, Django)
class StaticOAuthProvider implements OAuthProvider {
  @override
  final String clientId;
  @override
  final String authorizationEndpoint;
  @override
  final String tokenEndpoint;
  @override
  final String redirectUrl;
  @override
  final List<String> scopes;
  StaticOAuthProvider({
    required this.clientId,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.redirectUrl,
    required this.scopes,
  });
}

class OAuthUnifiedService {
  final _storage = const FlutterSecureStorage();
  final Map<String, OAuthProvider> _providers = {};

  OAuthUnifiedService() {
    _initFromEnv();
  }

  void _initFromEnv() {
    // Google
    final gClient = dotenv.env['GOOGLE_CLIENT_ID'];
    if (gClient != null && gClient.isNotEmpty) {
      _providers['google'] = StaticOAuthProvider(
        clientId: gClient,
        authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
        tokenEndpoint: 'https://oauth2.googleapis.com/token',
        redirectUrl: dotenv.env['GOOGLE_REDIRECT_URI'] ?? 'com.example.app:/oauth2redirect',
        scopes: _splitScopes(dotenv.env['GOOGLE_SCOPES'] ?? 'email,profile,openid'),
      );
    }
    // Microsoft
    final mClient = dotenv.env['MS_CLIENT_ID'];
    if (mClient != null && mClient.isNotEmpty) {
      final authority = dotenv.env['MS_TENANT'] ?? 'common';
      _providers['microsoft'] = StaticOAuthProvider(
        clientId: mClient,
        authorizationEndpoint: 'https://login.microsoftonline.com/$authority/oauth2/v2.0/authorize',
        tokenEndpoint: 'https://login.microsoftonline.com/$authority/oauth2/v2.0/token',
        redirectUrl: dotenv.env['MS_REDIRECT_URI'] ?? 'msauth.com.example.app://auth',
        scopes: _splitScopes(dotenv.env['MS_SCOPES'] ?? 'openid,profile,email,offline_access'),
      );
    }
    // Django (django-oauth-toolkit typical endpoints)
    final dClient = dotenv.env['DJANGO_CLIENT_ID'];
    if (dClient != null && dClient.isNotEmpty) {
      final base = dotenv.env['DJANGO_BASE_URL'] ?? 'https://example.com';
      _providers['django'] = StaticOAuthProvider(
        clientId: dClient,
        authorizationEndpoint: dotenv.env['DJANGO_AUTH_URL'] ?? '$base/o/authorize/',
        tokenEndpoint: dotenv.env['DJANGO_TOKEN_URL'] ?? '$base/o/token/',
        redirectUrl: dotenv.env['DJANGO_REDIRECT_URI'] ?? 'com.example.app:/oauth2redirect',
        scopes: _splitScopes(dotenv.env['DJANGO_SCOPES'] ?? 'read,write'),
      );
    }
  }

  static List<String> _splitScopes(String raw) => raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<bool> signIn(String providerKey) async {
    final provider = _providers[providerKey];
    if (provider == null) return false;
    try {
      final flow = PKCEFlow(provider);
      final code = await flow.authorize();
      if (code == null) return false;
      final tokenResponse = await flow.exchangeAuthCodeForToken({});
      if (tokenResponse == null) return false;
      await _persistTokens(providerKey, tokenResponse);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut(String providerKey) async {
    // (Optional) call revocation endpoint if available; here we just wipe local tokens.
    await _storage.delete(key: _kAccess(providerKey));
    await _storage.delete(key: _kRefresh(providerKey));
  }

  Future<bool> isSignedIn(String providerKey) async {
    final token = await _storage.read(key: _kAccess(providerKey));
    return token != null && token.isNotEmpty;
  }

  Future<void> _persistTokens(String providerKey, Map<String, dynamic> json) async {
    final access = json['access_token']?.toString();
    final refresh = json['refresh_token']?.toString();
    if (access != null) await _storage.write(key: _kAccess(providerKey), value: access);
    if (refresh != null) await _storage.write(key: _kRefresh(providerKey), value: refresh);
  }

  String _kAccess(String p) => 'oauth_${p}_access_token';
  String _kRefresh(String p) => 'oauth_${p}_refresh_token';
}

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheck() async {
    try { return await _auth.canCheckBiometrics || await _auth.isDeviceSupported(); } catch (_) { return false; }
  }

  Future<List<BiometricType>> availableTypes() async {
    try { return await _auth.getAvailableBiometrics(); } catch (_) { return []; }
  }

  Future<bool> authenticate() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Authenticate to enable biometric sign-in',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_auth_enabled', true);
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_auth_enabled', false);
  }
}
