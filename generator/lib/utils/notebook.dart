import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:studyou_core/env.dart' as env;

import 'cli.dart';
import 'file.dart';

Future<void> uploadNotebookToSupabase(String filePath, String studyId) async {
  final file = File(filePath);
  final fileName = p.basename(file.path);

  await _uploadToSupabaseStorage('$studyId/$fileName', file, 'notebook-widgets');
}

Future<void> _uploadToSupabaseStorage(String filePath, File file, String bucketId) async {
  final res = await env.client.storage.from(bucketId).upload(filePath, file);

  if (res.hasError) {
    print(res.error!.message);
  } else {
    print(res.data);
  }
}

Future<void> convertAndUploadNotebooks(String projectPath, String studyId) async {
  for (final File notebookFile in allFilesInDir(projectPath, fileExtension: '.ipynb')) {
    print('Generating html for ${notebookFile.path}');
    await CliService.generateNotebookHtml(notebookFile.path);

    final htmlFileName = p.setExtension(notebookFile.path, '.html');
    print('Uploading html to notebook-widgets/$studyId/$htmlFileName');
    await uploadNotebookToSupabase(htmlFileName, studyId);
  }
}
