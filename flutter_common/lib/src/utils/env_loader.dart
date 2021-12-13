import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';

const envsAssetPath = 'packages/studyu_flutter_common/envs';

// load env from envs/.env or from the filename specified in the ENV runtime-variable
String envFilePath() {
  const env = String.fromEnvironment('ENV');
  return env.isNotEmpty ? '$envsAssetPath/$env' : '$envsAssetPath/.env';
}

const designerDeepLink = 'https://designer.studyu.health';

// GoTrue redirectTo strips /#/ from URL, there fore we need to use the default set in supabase
String? authRedirectToUrl = kIsWeb ? null : designerDeepLink;

Future<void> loadEnv() async {
  await dotenv.load(fileName: envFilePath());
  final supabaseUrl = dotenv.env['STUDYU_SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['STUDYU_SUPABASE_PUBLIC_ANON_KEY'];
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authCallbackUrlHostname: kIsWeb ? null : 'designer.studyu.health', // optional
    debug: true, // optional
  );
  env.loadEnv(dotenv.env, supabaseClient: Supabase.instance.client);
}
