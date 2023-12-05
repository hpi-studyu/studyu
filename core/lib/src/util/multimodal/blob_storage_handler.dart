import 'dart:io';
import 'dart:typed_data';

import 'package:studyu_core/env.dart' as env;
import 'package:supabase/supabase.dart';

class BlobStorageHandler {
  static const String _observationsBucketName = 'observations';

  Future<void> uploadObservation(String aFileName, File aFile) async {
    // we use uploadBinary instead of upload until this is fixed: https://github.com/supabase/supabase-flutter/issues/685
    await env.client.storage.from(_observationsBucketName).uploadBinary(aFileName, await aFile.readAsBytes());
  }

  Future<Uint8List> downloadObservation(String aFile) async {
    return await env.client.storage.from(_observationsBucketName).download(aFile);
  }

  Future<List<FileObject>> removeObservation(List<String> paths) async {
    return await env.client.storage.from(_observationsBucketName).remove(paths);
  }
}
