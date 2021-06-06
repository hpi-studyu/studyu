import 'package:dotenv/dotenv.dart' as dot_env show load, env;
import 'package:generator/server.dart';
import 'package:studyu_core/env.dart' as env;

void loadEnv() {
  dot_env.load();
  env.loadEnv(dot_env.env);
}

Future<void> main(List<String> args) async {
  // load environment
  loadEnv();

  await startServer(args);
}
