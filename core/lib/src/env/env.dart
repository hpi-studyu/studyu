import 'package:supabase/supabase.dart';

final dotEnv = <String, String>{};

late SupabaseClient client;
late String supabaseUrl;
late String supabaseAnonKey;
late String? appUrl;
late String? projectGeneratorUrl;

void loadEnv(Map<String, String> env, {SupabaseClient? supabaseClient}) {
  dotEnv.addAll(env);
  projectGeneratorUrl = dotEnv['STUDYU_PROJECT_GENERATOR_URL'];
  appUrl = dotEnv['STUDYU_APP_URL'];
  supabaseUrl = dotEnv['STUDYU_SUPABASE_URL']!;
  supabaseAnonKey = dotEnv['STUDYU_SUPABASE_PUBLIC_ANON_KEY']!;
  client = supabaseClient ?? SupabaseClient(supabaseUrl, supabaseAnonKey);
}
