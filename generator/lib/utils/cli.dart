import 'dart:io';

const copierBin = 'copier';
const copierTemplate = 'gh:hpi-studyu/copier-studyu';

const nbConvertBin = 'jupyter nbconvert';

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
    try {
      File(projectPath).deleteSync(recursive: true);
    } catch (e) {}
    await runProcess(copierBin, [
      copierTemplate,
      projectPath,
      '--force',
      '--data',
      'study_title=$studyTitle',
    ]);
  }

  static Future<void> generateNotebookHtml(String filePath) async {
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
}
