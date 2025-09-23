import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:pos_saas/shared_preferences.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// Initialize desktop window (size, position, chrome behaviors).
/// Safe to call on all platforms; it no-ops on mobile/web.
Future<void> initDesktopShell({
  String title = 'ITSE500',
  Size initialSize = const Size(1280, 800),
  bool fixed = false,
  bool centerOnPrimary = true,
}) async {
  if (kIsWeb) return;
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return;

  // Ensure window_manager is initialized
  await windowManager.ensureInitialized();
  final options = WindowOptions(
    size: initialSize,
    minimumSize: fixed ? initialSize : const Size(960, 640),
    maximumSize: fixed ? initialSize : null,
    center:
        !centerOnPrimary, // we'll do manual centering below for multi-monitor control
    title: title,
    backgroundColor: const Color(0xFFFFFFFF),
    titleBarStyle: TitleBarStyle.normal,
  );
  // restore previous window bounds if present
  final sp = SharedPref();
  final lastW = await sp.getDouble('win_w');
  final lastH = await sp.getDouble('win_h');
  final lastX = await sp.getDouble('win_x');
  final lastY = await sp.getDouble('win_y');

  await windowManager.waitUntilReadyToShow(options, () async {
    // Manual center on primary screen if requested
    if (centerOnPrimary &&
        (lastW == null || lastH == null || lastX == null || lastY == null)) {
      try {
        final primary = await screenRetriever.getPrimaryDisplay();
        final bounds = primary.visibleSize;
        final origin = primary.visiblePosition;
        if (bounds != null && origin != null) {
          final x = origin.dx + (bounds.width - initialSize.width) / 2;
          final y = origin.dy + (bounds.height - initialSize.height) / 2;
          await windowManager.setBounds(
              Rect.fromLTWH(x, y, initialSize.width, initialSize.height));
        }
      } catch (_) {}
    }
    // Apply last known bounds if available
    if (lastW != null && lastH != null && lastX != null && lastY != null) {
      await windowManager.setBounds(Rect.fromLTWH(lastX, lastY, lastW, lastH));
    }
    await windowManager.show();
    await windowManager.focus();
  });

  // Listen to move/resize to persist bounds
  windowManager.addListener(_WindowPersistenceListener());

  // Setup tray (basic)
  try {
    await trayManager
        .setIcon('assets/icon.ico'); // ensure file exists or replace path
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: 'Show'),
      MenuItem.separator(),
      MenuItem(key: 'exit', label: 'Exit'),
    ]));
  } catch (_) {}

  // Global hotkey example: Ctrl+Shift+T toggles window
  try {
    await hotKeyManager.register(
      HotKey(
        key: LogicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (_) async {
        final isVisible = await windowManager.isVisible();
        if (isVisible) {
          await windowManager.hide();
        } else {
          await windowManager.show();
          await windowManager.focus();
        }
      },
    );
  } catch (_) {}

  // Register protocol for deep link (myapp://)
  try {
    await protocolHandler.register('myapp');
  } catch (_) {}
}

class _WindowPersistenceListener with WindowListener {
  final SharedPref _sp = SharedPref();
  Future<void> _save() async {
    try {
      final b = await windowManager.getBounds();
      await _sp.saveDouble('win_x', b.left);
      await _sp.saveDouble('win_y', b.top);
      await _sp.saveDouble('win_w', b.width);
      await _sp.saveDouble('win_h', b.height);
    } catch (_) {}
  }

  @override
  void onWindowResize() {
    _save();
  }

  @override
  void onWindowMove() {
    _save();
  }
}

/// Optional behaviors you may enable later:
/// - Minimize to tray using tray_manager
/// - Global hotkeys via hotkey_manager
/// - Always-on-top toggling via windowManager.setAlwaysOnTop(true)
