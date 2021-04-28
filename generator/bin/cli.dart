import 'dart:io';

import 'package:args/args.dart';
import 'package:studyou_core/env.dart' as env;

const lineNumber = 'line-number';
const supabaseToken = 'token';
const studyId = 'study-id';

late final ArgResults argResults;

void main(List<String> arguments) {
  exitCode = 0; // presume success
  final parser = ArgParser()
    ..addOption(supabaseToken, abbr: 't', mandatory: true)
    ..addOption(studyId, abbr: 's', mandatory: true);

  argResults = parser.parse(arguments);

  convertAndUploadNotebooks(
      argResults[supabaseToken] as String, argResults[studyId] as String);
}

Future<void> convertAndUploadNotebooks(String token, String studyId) async {
  final res = await env.client.auth.recoverSession(token);
  if (res.error != null) {
    print('Could not authenticate: ${res.error!.message}');
  }

  await convertAndUploadNotebooks('.', studyId);
}

Future _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}
