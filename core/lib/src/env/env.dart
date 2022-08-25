import 'package:supabase/supabase.dart';

late final SupabaseClient client;
late final String supabaseUrl;
late final String supabaseAnonKey;
late final String? appUrl;
late final String? projectGeneratorUrl;
late final String appDeepLink;
late final String designerDeepLink;
late final String authRedirectToUrl;

void setEnv(
  String envSupabaseUrl,
  String envSupabaseAnonKey, {
  String? envAppUrl,
  String? envProjectGeneratorUrl,
  SupabaseClient? supabaseClient,
  String? envAppDeepLink,
  String? envDesignerDeepLink,
}) {
  supabaseUrl = envSupabaseUrl;
  supabaseAnonKey = envSupabaseAnonKey;
  projectGeneratorUrl = envProjectGeneratorUrl;
  appUrl = envAppUrl;
  client = supabaseClient ?? SupabaseClient(supabaseUrl, supabaseAnonKey);
  appDeepLink = envAppDeepLink ?? '';
  designerDeepLink = envDesignerDeepLink ?? '';
  authRedirectToUrl = designerDeepLink;
}
