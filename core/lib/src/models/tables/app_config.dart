// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import '../../../core.dart';
import '../../util/supabase_object.dart';
import '../contact.dart';

part 'app_config.g.dart';

@JsonSerializable()
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

  AppConfig(
      this.id,
      {required this.contact,
      required this.app_privacy,
      required this.app_terms,
      required this.designer_privacy,
      required this.designer_terms,
      required this.imprint});

  factory AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  static Future<AppConfig> getAppConfig() async => SupabaseQuery.getById<AppConfig>('prod');

  static Future<Contact> getAppContact() async {
    return (await getAppConfig()).contact;
  }
}
