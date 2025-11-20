import 'package:supabase/supabase.dart';

late final SupabaseClient client;
late final String supabaseUrl;
late final String supabaseAnonKey;
late final String? appUrl;
late final String? designerUrl;
late final String? projectGeneratorUrl;
late final String? playStoreUrl;
late final String? appstoreUrl;
late final String? developerEmail;
late final String? sttWebSocketUrl;

void setEnv(
  String envSupabaseUrl,
  String envSupabaseAnonKey, {
  required SupabaseClient supabaseClient,
  String? envAppUrl,
  String? envDesignerUrl,
  String? envProjectGeneratorUrl,
  String? envPlayStoreUrl,
  String? envAppstoreUrl,
  String? envDeveloperEmail,
  String? envSttWebSocketUrl,
}) {
  supabaseUrl = envSupabaseUrl;
  supabaseAnonKey = envSupabaseAnonKey;
  client = supabaseClient;
  // Remove trailing slashes to prevent double slashes when concatenating path
  if (envAppUrl != null && envAppUrl.endsWith('/')) {
    appUrl = envAppUrl.substring(0, envAppUrl.length - 1);
  } else {
    appUrl = envAppUrl;
  }
  if (envDesignerUrl != null && envDesignerUrl.endsWith('/')) {
    designerUrl = envDesignerUrl.substring(0, envDesignerUrl.length - 1);
  } else {
    designerUrl = envDesignerUrl;
  }
  if (envProjectGeneratorUrl != null && envProjectGeneratorUrl.endsWith('/')) {
    projectGeneratorUrl = envProjectGeneratorUrl.substring(
      0,
      envProjectGeneratorUrl.length - 1,
    );
  } else {
    projectGeneratorUrl = envProjectGeneratorUrl;
  }

  playStoreUrl = envPlayStoreUrl;
  appstoreUrl = envAppstoreUrl;
  developerEmail = envDeveloperEmail;
  sttWebSocketUrl = envSttWebSocketUrl;
}
