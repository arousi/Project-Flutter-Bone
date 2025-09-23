import 'dart:io' show Platform, File;

import 'package:file_selector/file_selector.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';

Future<File?> pickFile({String? initialDirectory}) async {
  if (kIsWeb) return null;
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return null;
  final typeGroup = const XTypeGroup(label: 'any');
  final file = await openFile(acceptedTypeGroups: [typeGroup], initialDirectory: initialDirectory);
  if (file == null) return null;
  return File(file.path);
}

Future<String?> saveFile({required String suggestedName, List<int>? bytes, String mimeType = 'application/octet-stream'}) async {
  if (kIsWeb) return null;
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return null;
  final loc = await getSaveLocation(suggestedName: suggestedName);
  if (loc == null) return null;
  if (bytes != null) {
    final xf = XFile.fromData(Uint8List.fromList(bytes), mimeType: mimeType, name: suggestedName);
    await xf.saveTo(loc.path);
  }
  return loc.path;
}

Future<void> printBytes(List<int> bytes, {String name = 'Document'}) async {
  await Printing.layoutPdf(
    name: name,
    onLayout: (_) async => Uint8List.fromList(bytes),
  );
}