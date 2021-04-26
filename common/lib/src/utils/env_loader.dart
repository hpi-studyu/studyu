import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:studyou_core/env.dart' as env;

Future<void> loadEnv() async {
  await dot_env.load(fileName: env.envFilePath());
  env.loadEnv(dot_env.env);
}
