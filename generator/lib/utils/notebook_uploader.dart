import 'dart:io';

import 'package:studyou_core/env.dart' as env;
import 'package:path/path.dart' as p;

Future<void> uploadNotebookToSupabase(String filePath, String studyId) async {
  final file = File(filePath);
  final fileName = p.basename(file.path);

  await uploadToSupabaseStorage('$studyId/$fileName', file, 'notebook-widgets');
}

Future<void> uploadToSupabaseStorage(
    String filePath, File file, String bucketId) async {
  final res = await env.client.storage.from(bucketId).upload(filePath, file);

  if (res.hasError) {
    print(res.error!.message);
  } else {
    print(res.data);
  }
}
