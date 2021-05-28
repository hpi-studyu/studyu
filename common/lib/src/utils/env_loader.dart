import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studyou_core/env.dart' as env;

const envsAssetPath = 'packages/studyu_flutter_common/envs';

// load env from envs/.env or from the filename specified in the ENV runtime-variable
String envFilePath() {
  const env = String.fromEnvironment('ENV');
  return env.isNotEmpty ? '$envsAssetPath/$env' : '$envsAssetPath/.env';
}

Future<void> loadEnv() async {
  await dotenv.load(fileName: envFilePath());
  env.loadEnv(dotenv.env);
}
