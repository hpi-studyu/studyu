import 'package:dotenv/dotenv.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_repo_generator/server.dart';

void loadEnv() {
  final dotEnv = DotEnv()..load();
  env.setEnv(
    dotEnv['STUDYU_SUPABASE_URL']!,
    dotEnv['STUDYU_SUPABASE_PUBLIC_ANON_KEY']!,
    envAppUrl: dotEnv['STUDYU_APP_URL'],
    envProjectGeneratorUrl: dotEnv['STUDYU_PROJECT_GENERATOR_URL'],
  );
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
