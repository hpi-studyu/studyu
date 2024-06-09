import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig extends SupabaseObjectFunctions<AppConfig> {
  static const String tableName = 'app_config';

  @override
  Map<String, Object> get primaryKeys => {'id': id};

  String id;
  @JsonKey(name: 'app_min_version')
  String appMinVersion;
  @JsonKey(name: 'app_privacy')
  Map<String, String> appPrivacy;
  @JsonKey(name: 'app_terms')
  Map<String, String> appTerms;
  @JsonKey(name: 'designer_privacy')
  Map<String, String> designerPrivacy;
  @JsonKey(name: 'designer_terms')
  Map<String, String> designerTerms;
  Map<String, String> imprint;
  Contact contact;
  StudyUAnalytics? analytics;

  AppConfig(
    this.id, {
    required this.appMinVersion,
    required this.appPrivacy,
    required this.appTerms,
    required this.designerPrivacy,
    required this.designerTerms,
    required this.contact,
    required this.imprint,
    required this.analytics,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  static Future<AppConfig> getAppConfig() async {
    try {
      return await SupabaseQuery.getById<AppConfig>('prod');
    } catch (error) {
      throw Exception("Could not load app config. Check if the database is "
          "running and app_config table is properly set up.");
    }
  }

  static Future<Contact> getAppContact() async {
    return (await getAppConfig()).contact;
  }
}
