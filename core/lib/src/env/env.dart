import 'package:supabase/supabase.dart';

late final SupabaseClient client;
late final String supabaseUrl;
late final String supabaseAnonKey;
late final String? appUrl;
late final String? designerUrl;
late final String? projectGeneratorUrl;
late final String? authRedirectToUrl;

void setEnv(
  String envSupabaseUrl,
  String envSupabaseAnonKey, {
  String? envAppUrl,
  String? envDesignerUrl,
  String? envProjectGeneratorUrl,
  SupabaseClient? supabaseClient,
}) {
  supabaseUrl = envSupabaseUrl;
  supabaseAnonKey = envSupabaseAnonKey;
  projectGeneratorUrl = envProjectGeneratorUrl;
  appUrl = envAppUrl;
  designerUrl = envDesignerUrl;
  client = supabaseClient ?? SupabaseClient(supabaseUrl, supabaseAnonKey);
  authRedirectToUrl = designerUrl;
}
