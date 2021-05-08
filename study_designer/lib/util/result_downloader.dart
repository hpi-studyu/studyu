import 'dart:convert';
import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:studyou_core/core.dart';
import 'package:supabase/supabase.dart';
import 'package:universal_html/html.dart' as html;

class ResultDownloader {
  static const participantHeader = 'participant';

  Study study;
  SupabaseClient client;

  ResultDownloader({this.client, this.study});

  List<StudyResult> availableResults() => study.results;

  List<List<dynamic>> getResultsFor(List<StudySubject> instances, {StudyResult result}) {
    final header = [participantHeader, ...result.getHeaders(study)];
    return [
      header,
      ...instances.map((e) => [e.userId, ...result.getValues(e)])
    ];
  }

  Future<List<List<dynamic>>> loadResultsFor(StudyResult result) async {
    final instances = await StudySubject.getUserStudiesFor(study);
    return getResultsFor(instances, result: result);
  }

  Future<Map<StudyResult, List<List<dynamic>>>> loadAllResults() async {
    final instances = await StudySubject.getUserStudiesFor(study);
    final results = <StudyResult, List<List<dynamic>>>{};
    for (final result in availableResults()) {
      results[result] = getResultsFor(instances, result: result);
    }
    return results;
  }
}

Future<void> downloadFile(String contentString, String filename) async {
  if (kIsWeb) {
    final bytes = utf8.encode(contentString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body.children.add(anchor);

    anchor.click();

    html.document.body.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } else {
    final dirPath = Platform.isIOS
        ? (await getApplicationDocumentsDirectory()).path
        : await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOCUMENTS);

    File('$dirPath/$filename').writeAsString(contentString);
  }
}
