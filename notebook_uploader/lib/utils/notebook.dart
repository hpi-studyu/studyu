import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:studyu_core/env.dart' as env;

Future<void> uploadNotebookToSupabase(String filePath, String studyId) async {
  final file = File(filePath);
  final fileName = p.basename(file.path);

  await _uploadToSupabaseStorage(studyId, fileName, file, 'notebook-widgets');
}

Future<void> _uploadToSupabaseStorage(String studyId, String fileName, File file, String bucketId) async {
  final listFilesResponse = await env.client.storage.from(bucketId).list(path: studyId);
  print(listFilesResponse.data);
  if (listFilesResponse.hasError) {
    print(listFilesResponse.error!.message);
    exit(1);
  }

  final filePresent = listFilesResponse.data!.any((file) => file.name == fileName);
  final updateResponse = filePresent
      ? await env.client.storage.from(bucketId).update('$studyId/$fileName', file)
      : await env.client.storage.from(bucketId).upload('$studyId/$fileName', file);
  if (updateResponse.hasError) {
    print(updateResponse.error!.message);
    exit(1);
  } else {
    print(updateResponse.data);
  }
}
