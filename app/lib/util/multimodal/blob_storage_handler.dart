import 'dart:io';

import 'package:studyu_core/env.dart' as env;

class BlobStorageHandler {
  static const String _observationsBucketName = 'observations';

  Future<void> uploadObservation(String aFileName, File aFile) async {
    // we use uploadBinary instead of upload until this is fixed: https://github.com/supabase/supabase-flutter/issues/685
    await env.client.storage.from(_observationsBucketName).uploadBinary(aFileName, aFile.readAsBytesSync());
  }
}
