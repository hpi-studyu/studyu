import 'dart:io';

import 'package:args/args.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_notebook_uploader/utils/notebook.dart';

const supabaseToken = 'token';
const studyId = 'study-id';

late final ArgResults argResults;

void loadEnv() {
  env.loadEnv(Platform.environment);
}

Future<void> main(List<String> arguments) async {
  // load environment
  loadEnv();

  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addOption(supabaseToken, abbr: 't', mandatory: true)
    ..addOption(studyId, abbr: 's', mandatory: true);

  argResults = parser.parse(arguments);
  final htmlFilePath = argResults.rest;

  await uploadNotebook(argResults[supabaseToken] as String, argResults[studyId] as String, htmlFilePath.first);
  exit(0);
}

Future<void> uploadNotebook(String token, String studyId, String htmlFilePath) async {
  final res = await env.client.auth.recoverSession(token);
  if (res.error != null) {
    print('Could not authenticate: ${res.error!.message}');
    exit(1);
  }

  await uploadNotebookToSupabase(htmlFilePath, studyId);
}
