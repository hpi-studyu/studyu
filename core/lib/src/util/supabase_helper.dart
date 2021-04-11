import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:supabase/supabase.dart';

Future<SupabaseClient> initSupabaseFromEnv() async {
  const env = String.fromEnvironment('ENV');
  final envFileName = env.isNotEmpty ? 'envs/$env' : 'envs/.env';
  await dot_env.load(fileName: envFileName);
  final supabaseUrl = dot_env.env['SUPABASE_URL'];
  final supabaseAnonKey = dot_env.env['SUPABASE_PUBLIC_ANON_KEY'];

  return SupabaseClient(supabaseUrl, supabaseAnonKey);
}
