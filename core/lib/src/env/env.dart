import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Load environment variables from envs/.env or from the filename specified in the ENV runtime-variable
Future<void> loadEnv() async {
  const env = String.fromEnvironment('ENV');
  final envFileName = env.isNotEmpty ? 'envs/$env' : 'envs/.env';
  await dot_env.load(fileName: envFileName);
}

const designerDeepLink = 'https://studyu-designer.codemagic.app';

// GoTrue redirectTo strips /#/ from URL, therefore we need to use the default set in supabase
const String? authRedirectToUrl = kIsWeb ? null : designerDeepLink;

final projectGeneratorUrl = dot_env.env['PROJECT_GENERATOR_URL']!;
final _supabaseUrl = dot_env.env['SUPABASE_URL']!;
final _supabaseAnonKey = dot_env.env['SUPABASE_PUBLIC_ANON_KEY']!;
final client = SupabaseClient(_supabaseUrl, _supabaseAnonKey);
