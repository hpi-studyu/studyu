import 'dart:io';

import 'package:studyu_core/src/env/env.dart' as env;

class BlobStorageHandler {
  Future<void> uploadObservation(File aFile) async {}

  Future<void> uploadIntervention(File aFile) async {
    print(await env.client.storage.listBuckets().then((value) => value.length));
    await env.client.storage.from("intervention").upload("sample.png", aFile);
  }
}
