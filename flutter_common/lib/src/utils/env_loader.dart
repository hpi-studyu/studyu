import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';

const envsAssetPath = 'packages/studyu_flutter_common/envs';

// load env from envs/.env.productive or from the filename specified in the STUDYU_ENV runtime-variable
String envFilePath() {
  const env = String.fromEnvironment('STUDYU_ENV');
  return env.isNotEmpty ? '$envsAssetPath/$env' : '$envsAssetPath/.env.productive';
}

Future<void> loadEnv() async {
  await dotenv.load(fileName: envFilePath());
  final supabaseUrl = dotenv.env['STUDYU_SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['STUDYU_SUPABASE_PUBLIC_ANON_KEY']!;
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authCallbackUrlHostname: kIsWeb ? null : 'designer.studyu.health', // optional
    debug: true,
    // optional
  );
  env.setEnv(
    dotenv.env['STUDYU_SUPABASE_URL']!,
    dotenv.env['STUDYU_SUPABASE_PUBLIC_ANON_KEY']!,
    envAppUrl: dotenv.env['STUDYU_APP_URL'],
    envDesignerUrl: dotenv.env['STUDYU_DESIGNER_URL'],
    envProjectGeneratorUrl: dotenv.env['STUDYU_PROJECT_GENERATOR_URL'],
    supabaseClient: Supabase.instance.client,
  );
}
