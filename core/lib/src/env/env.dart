import 'package:supabase/supabase.dart';

late SupabaseClient client;
late String supabaseUrl;
late String supabaseAnonKey;
late String? appUrl;
late String? projectGeneratorUrl;

void setEnv(String envSupabaseUrl, String envSupabaseAnonKey, {String? envAppUrl, String? envProjectGeneratorUrl, SupabaseClient? supabaseClient}) {
  supabaseUrl = envSupabaseUrl;
  supabaseAnonKey = envSupabaseAnonKey;
  projectGeneratorUrl = envProjectGeneratorUrl;
  appUrl = envAppUrl;
  client = supabaseClient ?? SupabaseClient(supabaseUrl, supabaseAnonKey);
}
