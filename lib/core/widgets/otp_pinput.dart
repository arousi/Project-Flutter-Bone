import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// Reusable OTP/PIN input widget built on top of Pinput 5.x.
/// Focuses first cell automatically, exposes onCompleted when all digits entered.
class OtpPinput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final TextEditingController? controller; // optional external controller
  final EdgeInsetsGeometry padding;

  const OtpPinput({
    super.key,
    this.length = 5,
    this.onCompleted,
    this.enabled = true,
    this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  State<OtpPinput> createState() => OtpPinputState();
}

enum _OtpStatus { idle, error, success }

class OtpPinputState extends State<OtpPinput> {
  late final TextEditingController _internalController;
  TextEditingController get _controller => widget.controller ?? _internalController;
  final FocusNode _focusNode = FocusNode();
  _OtpStatus _status = _OtpStatus.idle;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  /// Public API: show an error state (red border, optional clear + refocus)
  void showError({bool clear = true}) {
    if (!mounted) return;
    setState(() => _status = _OtpStatus.error);
    if (clear) _controller.clear();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _status = _OtpStatus.idle);
      _focusNode.requestFocus();
    });
  }

  /// Public API: show a transient success state (green border)
  void showSuccess() {
    if (!mounted) return;
    setState(() => _status = _OtpStatus.success);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _status = _OtpStatus.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400),
    );
    final primary = Theme.of(context).colorScheme.primary;
    final focusedBase = baseDecoration.copyWith(
      border: Border.all(color: primary, width: 2),
      boxShadow: [
        BoxShadow(color: primary.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2)),
      ],
    );
    final errorDecoration = baseDecoration.copyWith(border: Border.all(color: Colors.red.shade400, width: 2));
    final successDecoration = baseDecoration.copyWith(border: Border.all(color: Colors.green.shade500, width: 2));

    BoxDecoration pickDeco() {
      switch (_status) {
        case _OtpStatus.error:
          return errorDecoration;
        case _OtpStatus.success:
          return successDecoration;
        case _OtpStatus.idle:
        default:
          return baseDecoration;
      }
    }

    BoxDecoration pickFocused() {
      switch (_status) {
        case _OtpStatus.error:
          return errorDecoration;
        case _OtpStatus.success:
          return successDecoration;
        case _OtpStatus.idle:
        default:
          return focusedBase;
      }
    }
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: pickDeco(),
    );

    return Padding(
      padding: widget.padding,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.45,
          child: Pinput(
            autofocus: true,
            length: widget.length,
            controller: _controller,
            enabled: widget.enabled,
            focusNode: _focusNode,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(decoration: pickFocused()),
            errorPinTheme: defaultPinTheme.copyWith(decoration: errorDecoration),
            keyboardType: TextInputType.number,
            onCompleted: widget.onCompleted,
          ),
        ),
      ),
    );
  }
}
