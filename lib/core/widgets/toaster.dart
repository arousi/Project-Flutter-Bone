import 'package:flutter/material.dart';

class Toaster {
  static OverlayEntry? _entry;
  static DateTime? _shownAt;

  static void show(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
    _entry?.remove();
    _entry = null;

  final overlay = Overlay.of(context);
    _shownAt = DateTime.now();
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 16,
        right: 16,
        bottom: 24,
        child: IgnorePointer(
          ignoring: true,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 150),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);

    Future.delayed(duration, () {
      // prevent early removal when a newer toast is being displayed
      final since = _shownAt;
      if (since != null && DateTime.now().difference(since) < duration) return;
      _entry?.remove();
      _entry = null;
    });
  }
}
