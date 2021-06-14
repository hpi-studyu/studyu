import 'dart:io';

import 'package:path/path.dart' as p;

Iterable<File> allFilesInDir(String dirPath, {String? fileExtension}) {
  final allFiles = Directory(dirPath).listSync(recursive: true).whereType<File>();
  return fileExtension != null ? allFiles.where((file) => p.extension(file.path) == fileExtension) : allFiles;
}
