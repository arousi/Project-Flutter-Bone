import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:protocol_handler/protocol_handler.dart';

/// Listen to OS-delivered deep links (myapp://...) and route accordingly.
void attachProtocolRouting(GoRouter router) {
  if (kIsWeb || !(Platform.isWindows || Platform.isMacOS)) return;
  protocolHandler.addListener(_ProtocolRouter(router));
}

class _ProtocolRouter with ProtocolListener {
  final GoRouter router;
  _ProtocolRouter(this.router);

  @override
  void onProtocolUrlReceived(String url) {
    try {
      // Map myapp://profile?id=123 -> /profile/123 or /profile?id=...
      final uri = Uri.parse(url);
      if (uri.scheme != 'myapp') return;
      if (uri.host == 'profile' || uri.pathSegments.contains('profile')) {
        final id = uri.queryParameters['id'];
        if (id != null) {
          router.go('/profile/$id');
          return;
        }
        router.go('/profile');
        return;
      }
      if (uri.host == 'chat' || uri.pathSegments.contains('chat')) {
        final cid = uri.queryParameters['cid'];
        router.go(cid != null ? '/chat/$cid' : '/chat');
        return;
      }
      // default fallback
      router.go('/');
    } catch (_) {}
  }
}