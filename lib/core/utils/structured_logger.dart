import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as rt;

class StructuredLogger {
  StructuredLogger._();
  static final StructuredLogger instance = StructuredLogger._();
  final rt.Logger _console = rt.Logger(
    printer: rt.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: rt.DateTimeFormat.dateAndTime,
    ),
  );

  static const _filePrefix = 'app-telemetry';
  Future<File> _resolveFile() async {
    // Fallback to system temp if path_provider is unavailable
    final dir = Directory.systemTemp;
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
  final base = File('${dir.path}${Platform.pathSeparator}$_filePrefix-$y-$m-$d.jsonl');
    if (!await base.exists()) return base.create(recursive: true);
    return base;
  }

  Map<String, dynamic> _redact(Map<String, dynamic> m) {
    const sensitiveKeys = {
      'authorization',
      'api_key',
      'api-key',
      'x-api-key',
      'x-goog-api-key',
      'access_token',
      'refresh_token',
    };
    Map<String, dynamic> out = {};
    m.forEach((k, v) {
      if (sensitiveKeys.contains(k.toString().toLowerCase())) {
        out[k] = '***';
      } else if (v is Map<String, dynamic>) {
        out[k] = _redact(v);
      } else if (v is List) {
        out[k] = v.map((e) => e is Map<String, dynamic> ? _redact(e) : e).toList();
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  Future<void> log(
    String event,
    Map<String, dynamic> payload, {
    String? category,
    String? className,
    String? methodName,
    int? httpStatus,
    int? durationMs,
    String? url,
  }) async {
    try {
      final file = await _resolveFile();
      final redPayload = _redact(payload);
      final record = {
        'ts': DateTime.now().toIso8601String(),
        'event': event,
        if (category != null) 'category': category,
        'payload': redPayload,
        'platform': defaultTargetPlatform.toString(),
        if (className != null) 'class': className,
        if (methodName != null) 'method': methodName,
        if (httpStatus != null) 'httpStatus': httpStatus,
        if (durationMs != null) 'durationMs': durationMs,
        if (url != null) 'url': url,
      };

      final isError = (httpStatus != null && httpStatus >= 400) || (category == 'error');
      final tag = [category, event].whereType<String>().where((s) => s.isNotEmpty).join(' | ');
      if (isError) {
        _console.e(tag.isEmpty ? 'error' : tag);
      } else {
        _console.i(tag.isEmpty ? 'event' : tag);
      }

      await file.writeAsString(jsonEncode(record) + '\n', mode: FileMode.append, flush: true);
    } catch (_) {
      // ignore logging errors
    }
  }

  Future<int> cleanOldLogs({int retainDays = 7}) async {
    try {
  final now = DateTime.now();
  final files = Directory(Directory.systemTemp.path).listSync().whereType<File>();
      int deleted = 0;
      for (final f in files) {
        final name = f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : f.path.split(Platform.pathSeparator).last;
        final m = RegExp('^${RegExp.escape(_filePrefix)}-(\\d{4})-(\\d{2})-(\\d{2})\\.jsonl').firstMatch(name);
        if (m != null) {
          final y = int.tryParse(m.group(1)!);
          final mo = int.tryParse(m.group(2)!);
          final d = int.tryParse(m.group(3)!);
          if (y != null && mo != null && d != null) {
            final fileDate = DateTime(y, mo, d);
            if (now.difference(fileDate).inDays > retainDays) {
              try { await f.delete(); deleted++; } catch (_) {}
            }
          }
        }
      }
      return deleted;
    } catch (_) {
      return 0;
    }
  }
}
