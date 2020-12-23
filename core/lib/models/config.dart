// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import 'study/contact.dart';

part 'config.g.dart';

@JsonSerializable()
class ParseStudyUConfig {

  Contact contact;
  Map<String, String> app_privacy;
  Map<String, String> app_terms;
  Map<String, String> designer_privacy;
  Map<String, String> designer_terms;
  Map<String, String> imprint;

  ParseStudyUConfig();

  factory ParseStudyUConfig.fromJson(Map<String, dynamic> json) => _$ParseStudyUConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ParseStudyUConfigToJson(this);
}

