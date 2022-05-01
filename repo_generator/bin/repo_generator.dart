import 'package:dotenv/dotenv.dart';
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

  await startServer(args);
}
