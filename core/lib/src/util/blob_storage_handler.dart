import 'dart:io';

import 'package:studyu_core/src/env/env.dart' as env;

class BlobStorageHandler {
  static const String _observationsBucketName = 'observations';

  Future<void> uploadObservation(String aFileName, File aFile) async {
    await env.client.storage
        .from(_observationsBucketName)
        .upload(aFileName, aFile);
  }
}
