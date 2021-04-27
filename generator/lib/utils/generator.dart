import 'dart:io';

import 'package:dotenv/dotenv.dart' as dot_env show env;
import 'package:generator/utils/gitlab.dart';
import 'package:path/path.dart' as p;
import 'package:pretty_json/pretty_json.dart';
import 'package:studyou_core/core.dart';
import 'package:studyou_core/env.dart' as env;

import 'cli.dart';
import 'notebook_uploader.dart';

Future<void> generateRepo(String studyId) async {
  print('Generating repo...');
  final generatedProjectPath = dot_env.env['PROJECT_PATH'] ?? 'generated';

  // Fetch study schema and subjects data
  print('Fetching study data...');
  final study = await SupabaseQuery.getById<Study>(studyId);
  final subjects = SupabaseQuery.extractSupabaseList<StudySubject>(await env
      .client
      .from(StudySubject.tableName)
      .select('*,study(*),subject_progress(*)')
      .eq('studyId', studyId)
      .execute());

  print('Creating gitlab repo ${study.title}');
  // Create Gitlab project
  final gl = GitlabClient(
      '65724655cb9247403d40d161c66c0958cda32253f9a0f82b60db5292c84c503b');
  final projectId = await gl.createProject(study.title!);
  if (projectId == null) {
    print('Could not fetch projectId');
    return;
  }

  // Generate files from nbconvert-template copier CLI
  print('Generating project files with copier...');
  await CliService.generateCopierProject(generatedProjectPath, study.title!);

  // Save study schema and subjects data
  print('Saving study schema and subjects as json...');
  await File(p.join(generatedProjectPath, 'data', 'study.schema.json'))
      .writeAsString(prettyJson(study.toJson()));
  await File(p.join(generatedProjectPath, 'data', 'subjects.json'))
      .writeAsString(prettyJson(subjects));

  // Read all files in generated and make commit
  print('Collecting files into Gitlab commit...');
  final commitActions = allFilesInDir(generatedProjectPath).map((file) {
    final unixFilePath = p.Context(style: p.Style.posix)
        .joinAll(p.split(p.relative(file.path, from: generatedProjectPath)));

    return gl.commitAction(
        filePath: unixFilePath, content: file.readAsStringSync());
  }).toList();

  print('Committing to Gitlab...');
  await gl.makeCommit(
      projectId: projectId,
      message:
      'Generated project from copier-studyu\n\nhttps://github.com/hpi-studyu/copier-studyu',
      actions: commitActions);

  // Generate Notebook html from files nbconvert CLI
  print('Generating html for all notebooks');
  print(allFilesInDir(generatedProjectPath, fileExtension: '.ipynb').length);

  for (final File notebookFile
  in allFilesInDir(generatedProjectPath, fileExtension: '.ipynb')) {
    print('Generating html for ${notebookFile.path}');
    await CliService.generateNotebookHtml(notebookFile.path);

    final htmlFileName = p.setExtension(notebookFile.path, '.html');
    print('Uploading html to notebook-widgets/$studyId/$htmlFileName');
    await uploadNotebookToSupabase(htmlFileName, studyId);
  }
  print('Deleting generated files...');
  File(generatedProjectPath).deleteSync(recursive: true);
  print('Finished generating project');

}

Iterable<File> allFilesInDir(String dirPath, {String? fileExtension}) {
  final allFiles =
  Directory(dirPath).listSync(recursive: true).whereType<File>();
  return fileExtension != null
      ? allFiles.where((file) => p.extension(file.path) == fileExtension)
      : allFiles;
}
