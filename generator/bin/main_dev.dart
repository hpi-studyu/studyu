import 'package:dotenv/dotenv.dart' as dot_env show load, env;
import 'package:generator/server.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:studyu_core/env.dart' as env;

void loadEnv() {
  dot_env.load();
  env.loadEnv(dot_env.env);
}

Future<void> main(List<String> args) async {
  // load environment
  loadEnv();

  // Enable hot reloader
  withHotreload(() {
    print('Reloading server ...');
    return startServer(args);
  });
}
