import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:studyou_core/env.dart' as env;

Future<void> uploadNotebookToSupabase(String filePath, String studyId) async {
  final file = File(filePath);
  final fileName = p.basename(file.path);

  await _uploadToSupabaseStorage('$studyId/$fileName', file, 'notebook-widgets');
}

Future<void> _uploadToSupabaseStorage(String filePath, File file, String bucketId) async {
  final res = await env.client.storage.from(bucketId).update(filePath, file);
  print(res.data);

  if (res.hasError) {
    if (res.error!.statusCode == '404') {
      print('Notebook does not exist. Use upload instead of update');
      final res = await env.client.storage.from(bucketId).upload(filePath, file);
      print(res.data);
      if (res.hasError) {
        print(res.error!.message);
        exit(1);
      }
    } else {
      print(res.error!.message);
      exit(1);
    }
  }
}
