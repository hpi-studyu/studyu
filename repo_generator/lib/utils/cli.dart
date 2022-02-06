import 'dart:convert';
import 'dart:io';

Future<bool> runCliProcess(String executable, List<String> arguments) async {
  final result = await Process.run(
    executable,
    arguments,
    runInShell: true,
  );
  print('stdout of command: ${result.stdout}');
  if (result.exitCode != 0) {
    print('stderr of command: ${result.stderr}');
    return false;
  } else {
    return true;
  }
}

Future<void> cliGenerateCopierProject(
  String projectPath,
  String studyTitle,
  List<String> outcomes,
  String gitUrl,
) async {
  const copierBin = 'copier';
  const copierTemplate = 'gh:hpi-studyu/copier-studyu';
  try {
    File(projectPath).deleteSync(recursive: true);
  } catch (e) {
    print(e);
  }
  await runCliProcess(copierBin, [
    copierTemplate,
    projectPath,
    '--force',
    '--data',
    'study_title=$studyTitle',
    '--data',
    'outcomes=${jsonEncode(outcomes)}',
    '--data',
    'git_url=$gitUrl'
  ]);
}

Future<void> cliGenerateSshKey({String filePath = 'gitlabkey'}) async {
  // ssh-keygen -b 2048 -t rsa -f gitlabkey -q -N ""
  const sshkeygenBin = 'ssh-keygen';
  await runCliProcess(sshkeygenBin, [
    '-f',
    filePath,
    '-q',
    '-N',
    '',
  ]);
}
