import 'dart:io';

class CliService {
  static Future<bool> runProcess(String executable, List<String> arguments) async {
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

  static Future<void> generateCopierProject(String projectPath, String studyTitle) async {
    const copierBin = 'copier';
    const copierTemplate = 'gh:hpi-studyu/copier-studyu';
    try {
      File(projectPath).deleteSync(recursive: true);
    } catch (e) {
      print(e);
    }
    await runProcess(copierBin, [
      copierTemplate,
      projectPath,
      '--force',
      '--data',
      'study_title=$studyTitle',
    ]);
  }

  static Future<void> generateNotebookHtml(String filePath) async {
    const nbConvertBin = 'jupyter nbconvert';
    await runProcess(nbConvertBin, [
      '--execute',
      '--to',
      'html',
      filePath,
      '--no-prompt',
      '--template',
      'nbconvert-template/',
    ]);
  }

  static Future<void> generateSshKey({String filePath = 'gitlabkey'}) async {
    // ssh-keygen -b 2048 -t rsa -f gitlabkey -q -N ""
    const sshkeygenBin = 'ssh-keygen';
    await runProcess(sshkeygenBin, [
      '-f',
      filePath,
      '-q',
      '-N',
      '',
    ]);
  }
}
