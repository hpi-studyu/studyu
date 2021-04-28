import 'dart:io';

import 'package:dotenv/dotenv.dart' as dot_env show env;
import 'package:generator/utils/gitlab.dart';
import 'package:path/path.dart' as p;
import 'package:pretty_json/pretty_json.dart';

import 'cli.dart';
import 'database.dart';
import 'file.dart';
import 'notebook.dart';

Future<void> generateRepo(String studyId) async {
  print('Generating repo...');
  final generatedProjectPath = dot_env.env['PROJECT_PATH'] ?? 'generated';

  // Fetch study schema and subjects data
  print('Fetching study data...');
  final study = await fetchStudySchema(studyId);
  final subjects = await fetchSubjects(studyId);

  print('Creating gitlab repo ${study.title}');
  // Create Gitlab project
  final gl = GitlabClient('65724655cb9247403d40d161c66c0958cda32253f9a0f82b60db5292c84c503b');
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
  await File(p.join(generatedProjectPath, 'data', 'study.schema.json')).writeAsString(prettyJson(study.toJson()));
  await File(p.join(generatedProjectPath, 'data', 'subjects.json')).writeAsString(prettyJson(subjects));

  // Read all files in generated and make commit
  print('Collecting files into Gitlab commit...');
  final commitActions = allFilesInDir(generatedProjectPath).map((file) {
    final unixFilePath =
        p.Context(style: p.Style.posix).joinAll(p.split(p.relative(file.path, from: generatedProjectPath)));

    return gl.commitAction(filePath: unixFilePath, content: file.readAsStringSync());
  }).toList();

  print('Committing to Gitlab...');
  await gl.makeCommit(
      projectId: projectId,
      message: 'Generated project from copier-studyu\n\nhttps://github.com/hpi-studyu/copier-studyu',
      actions: commitActions);

  // Generate Notebook html from files nbconvert CLI
  print('Generating html for all notebooks');
  await convertAndUploadNotebooks(generatedProjectPath, studyId);
  print('Deleting generated files...');
  File(generatedProjectPath).deleteSync(recursive: true);
  print('Finished generating project');
}

Future<void> updateRepo(String projectId, String studyId) async {
  // Setup CI for updating htmls
  // Generat ssh key
  // Add ssh private key as env var
  // Add public key to deploy keys (with write)
  // Add supabase secret as well

  final study = await fetchStudySchema(studyId);
  final subjects = await fetchSubjects(studyId);
  // Make git commit

  // Fetch git project
  // install python dependencies
  // Generate notebook htmls
  // Upload notebook htmls
}
