import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_flutter_common/src/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const envsAssetPath = 'packages/studyu_flutter_common/envs';

// load env from envs/.env or from the filename specified in the STUDYU_ENV runtime-variable
String envFilePath() {
  const env = String.fromEnvironment('STUDYU_ENV');
  return env.isNotEmpty ? '$envsAssetPath/$env' : '$envsAssetPath/.env';
}

String? getEnv(String name) {
  return dotenv.env[name] ?? (bool.hasEnvironment(name) ? String.fromEnvironment(name) : null);
}

Future<void> loadEnv() async {
  await dotenv.load(fileName: envFilePath());
  final supabaseUrl = getEnv('STUDYU_SUPABASE_URL');
  final supabaseAnonKey = getEnv('STUDYU_SUPABASE_PUBLIC_ANON_KEY');
  final envAppUrl = getEnv('STUDYU_APP_URL');
  final envDesignerUrl = getEnv('STUDYU_DESIGNER_URL');
  final envProjectGeneratorUrl = getEnv('STUDYU_PROJECT_GENERATOR_URL');

  // TODO Remove this after migration phase is over
  await SecureStorage.migrateSharedPreferencesToSecureStorage();

  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseAnonKey!,
    authOptions: FlutterAuthClientOptions(
      localStorage: SupabaseStorage(),
    ),
    debug: true,
  );
  env.setEnv(
    supabaseUrl,
    supabaseAnonKey,
    envAppUrl: envAppUrl,
    envDesignerUrl: envDesignerUrl,
    envProjectGeneratorUrl: envProjectGeneratorUrl,
    supabaseClient: Supabase.instance.client,
  );
}
