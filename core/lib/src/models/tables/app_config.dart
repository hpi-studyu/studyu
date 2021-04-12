// ignore_for_file: non_constant_identifier_names
import '../../../core.dart';
import '../../util/supabase_object.dart';
import '../contact.dart';

class AppConfig extends SupabaseObjectFunctions<AppConfig> {
  static const String tableName = 'app_config';

  @override
  String id;

  Contact contact;
  Map<String, String> app_privacy;
  Map<String, String> app_terms;
  Map<String, String> designer_privacy;
  Map<String, String> designer_terms;
  Map<String, String> imprint;

  AppConfig();

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig()
    ..contact = Contact.fromJson(json['contact'] as Map<String, dynamic>)
    ..app_privacy = Map<String, String>.from(json['app_privacy'] as Map)
    ..app_terms = Map<String, String>.from(json['app_terms'] as Map)
    ..designer_privacy = Map<String, String>.from(json['designer_privacy'] as Map)
    ..designer_terms = Map<String, String>.from(json['designer_terms'] as Map)
    ..imprint = Map<String, String>.from(json['imprint'] as Map);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'contact': contact.toJson(),
        'app_privacy': app_privacy,
        'app_terms': app_terms,
        'designer_privacy': designer_privacy,
        'designer_terms': designer_terms,
        'imprint': imprint,
      };

  static Future<AppConfig> getAppConfig() async => SupabaseQuery.getById<AppConfig>('prod');

  static Future<Contact> getAppContact() async {
    return (await getAppConfig()).contact;
  }
}
