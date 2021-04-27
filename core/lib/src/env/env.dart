import 'package:supabase/supabase.dart';

// load env from envs/.env or from the filename specified in the ENV runtime-variable
String envFilePath() {
  const env = String.fromEnvironment('ENV');
  return env.isNotEmpty ? 'envs/$env' : 'envs/.env';
}

final dotEnv = <String, String>{};

void loadEnv(Map<String, String> env) {
  dotEnv.addAll(env);
}

const designerDeepLink = 'https://studyu-designer.codemagic.app';

// GoTrue redirectTo strips /#/ from URL, therefore we need to use the default set in supabase
String? authRedirectToUrl({bool isWeb = false}) =>
    isWeb ? null : designerDeepLink;

final projectGeneratorUrl = dotEnv['PROJECT_GENERATOR_URL']!;
final _supabaseUrl = dotEnv['SUPABASE_URL']!;
final _supabaseAnonKey = dotEnv['SUPABASE_PUBLIC_ANON_KEY']!;
final client = SupabaseClient(_supabaseUrl, _supabaseAnonKey);
