import 'package:studyu_core/env.dart' as env;
import 'package:supabase/supabase.dart';

Future<List<FileObject>> getStudyNotebooks(String studyId) async {
  final res = await env.client.storage.from('notebook-widgets').list(path: studyId);
  // ignore: only_throw_errors
  if (res.hasError) throw res.error.message;
  return res.data;
}

Future<String> downloadFromStorage(String path) async {
  final res = await env.client.storage.from('notebook-widgets').download(path);
  // ignore: only_throw_errors
  if (res.hasError) throw res.error.message;
  return String.fromCharCodes(res.data);
}
