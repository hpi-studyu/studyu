import 'dart:io';

import 'package:dotenv/dotenv.dart' as dot_env show env;
import 'package:path/path.dart' as p;
import 'package:pretty_json/pretty_json.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;

import 'cli.dart';
import 'database.dart';
import 'file.dart';
import 'gitlab.dart';

Future<void> generateRepo(GitlabClient gl, String studyId) async {
  print('Generating repo...');
  final generatedProjectPath = dot_env.env['STUDYU_PROJECT_PATH'] ?? 'generated';

  // Fetch study schema and subjects data
  print('Fetching study data...');
  final study = await fetchStudySchema(studyId);
  final subjects = await fetchSubjects(studyId);

  print('Creating gitlab repo ${study.title}');
  // Create Gitlab project
  final projectId = await gl.createProject(study.title!);
  if (projectId == null) {
    print('Could not fetch projectId');
    return;
  }

  // Generate ssh key
  print('Generating RSA key pair...');
  try {
    File('gitlabkey.pub').deleteSync();
    File('gitlabkey').deleteSync();
  } catch (e) {
    print(e);
  }
  await CliService.generateSshKey();
  final public = File('gitlabkey.pub').readAsStringSync();
  final private = File('gitlabkey').readAsStringSync();

  print('Adding deploy key...');
  await gl.addDeployKey(projectId: projectId, title: 'update_key', key: public, canPush: true);

  print('Creating project variables for session, studyId and key');
  await gl.createProjectVariable(
      projectId: projectId, key: 'session', value: env.client.auth.session()!.persistSessionString);
  await gl.createProjectVariable(projectId: projectId, key: 'study_id', value: studyId);
  await gl.createProjectVariable(projectId: projectId, key: 'key', value: private);

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

  print('Add repo entry to database...');
  try {
    await Repo(projectId, env.client.auth.user()!.id, studyId, GitProvider.gitlab).save();
  } catch (e) {
    print(e);
  }

  print('Deleting generated files...');
  File(generatedProjectPath).deleteSync(recursive: true);
  print('Finished generating project');
}

Future<void> updateRepo(GitlabClient gl, String projectId, String studyId) async {
  // Update sessionToken project var
  print('Updating project session variable...');
  gl.updateProjectVariable(
      projectId: projectId, key: 'session', value: env.client.auth.session()!.persistSessionString);

  print('Fetching study schema and subjects');
  final study = await fetchStudySchema(studyId);
  final subjects = await fetchSubjects(studyId);

  print('Committing to Gitlab...');
  await gl.makeCommit(projectId: projectId, message: 'Updating data and triggering CI notebook html refresh', actions: [
    gl.commitAction(filePath: 'data/study.schema.json', content: prettyJson(study.toJson()), action: 'update'),
    gl.commitAction(filePath: 'data/subjects.json', content: prettyJson(subjects), action: 'update'),
  ]);
  // Make git commit
}
