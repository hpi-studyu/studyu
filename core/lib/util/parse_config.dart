import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/study/contact.dart';

Future<ParseStudyUConfig> getParseConfig() async {
  final configs = await ParseConfig().getConfigs();
  return ParseStudyUConfig.fromJson(configs.result as Map<String, dynamic>);
}

Future<Contact> getParseConfigContact() async {
  return (await getParseConfig()).contact;
}
