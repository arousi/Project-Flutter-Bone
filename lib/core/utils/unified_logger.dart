import 'dart:async';

import 'package:logger/logger.dart' as rt;

import 'structured_logger.dart';

/// Unified logger that mirrors logs to runtime console and structured JSONL files.
/// Use this everywhere instead of creating ad-hoc Logger() or manual file writes.
class UnifiedLogger {
  UnifiedLogger._internal()
      : _console = rt.Logger(
          printer: rt.PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 100,
            colors: true,
            printEmojis: true,
            dateTimeFormat: rt.DateTimeFormat.dateAndTime,
          ),
        );

  static final UnifiedLogger instance = UnifiedLogger._internal();

  final rt.Logger _console;

  // Convenience severity methods -------------------------------------------------
  Future<void> d(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    _console.d(message, error: error, stackTrace: stack);
    await _file('debug', message, error: error, stack: stack, ctx: ctx);
  }

  Future<void> i(String message, {Map<String, dynamic>? ctx}) async {
    _console.i(message);
    await _file('info', message, ctx: ctx);
  }

  Future<void> w(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    _console.w(message, error: error, stackTrace: stack);
    await _file('warn', message, error: error, stack: stack, ctx: ctx);
  }

  Future<void> e(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    _console.e(message, error: error, stackTrace: stack);
    await _file('error', message, error: error, stack: stack, ctx: ctx);
  }

  /// Structured event logging. Appears in both console and JSONL with metadata.
  Future<void> event(
    String event, {
    Map<String, dynamic> payload = const {},
    String? category,
    String? className,
    String? methodName,
    String? conversationId,
    String? messageId,
    String? requestId,
    String? responseId,
    String? outputId,
    String? providerId,
    String? model,
    String? phase,
    String? status,
    int? httpStatus,
    int? durationMs,
    String? url,
  }) async {
    // Delegate pretty console + JSONL to StructuredLogger to avoid duplicates
    await StructuredLogger.instance.log(
      event,
      payload,
      category: category,
      className: className,
      methodName: methodName,
      httpStatus: httpStatus,
      durationMs: durationMs,
      url: url,
    );
  }

  Future<int> cleanOldLogs({int retainDays = 7}) {
    return StructuredLogger.instance.cleanOldLogs(retainDays: retainDays);
  }

  // Internal helper to write to structured log
  Future<void> _file(String level, String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) {
    final payload = {
      'level': level,
      'message': message,
      if (error != null) 'error': error.toString(),
      if (stack != null) 'stack': stack.toString(),
      if (ctx != null) ...ctx,
    };
    return StructuredLogger.instance.log(
      'log',
      payload,
      category: level,
    );
  }
}
