import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:studyu_core/env.dart' as env;
import 'package:supabase/supabase.dart';

Future<void> uploadNotebookToSupabase(String filePath, String studyId) async {
  final file = File(filePath);
  final fileName = p.basename(file.path);

  await _uploadToSupabaseStorage(studyId, fileName, file, 'notebook-widgets');
}

Future<void> _uploadToSupabaseStorage(String studyId, String fileName, File file, String bucketId) async {
  final uploadResponse = await env.client.storage
      .from(bucketId)
      .upload('$studyId/$fileName', file, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

  if (uploadResponse.hasError) {
    print(uploadResponse.error!.message);
    exit(1);
  } else {
    print(uploadResponse.data);
  }
}
