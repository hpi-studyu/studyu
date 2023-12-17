import 'package:supabase/supabase.dart';

late final SupabaseClient client;
late final String supabaseUrl;
late final String supabaseAnonKey;
late final String? appUrl;
late final String? designerUrl;
late final String? projectGeneratorUrl;

void setEnv(
  String envSupabaseUrl,
  String envSupabaseAnonKey, {
  required SupabaseClient supabaseClient,
  String? envAppUrl,
  String? envDesignerUrl,
  String? envProjectGeneratorUrl,
}) {
  supabaseUrl = envSupabaseUrl;
  supabaseAnonKey = envSupabaseAnonKey;
  client = supabaseClient;
  appUrl = envAppUrl;
  designerUrl = envDesignerUrl;
  projectGeneratorUrl = envProjectGeneratorUrl;
}
