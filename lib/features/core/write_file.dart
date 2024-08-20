import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class WriteDebugFile {
  static Future<void> execute({required String content, required String filename}) async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/$filename.md';

    File file = File(filePath);
    await file.writeAsString(content);
    debugPrint('>> $filePath');
  }
}
