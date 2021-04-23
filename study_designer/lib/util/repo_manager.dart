import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:studyou_core/env.dart' as env;

Future<void> generateRepo(String studyId) async{
  await http.get(Uri.parse(env.projectGeneratorUrl), headers: {
    'X-Session': json.encode(env.client.auth.session().toJson()),
    'X-Study-Id': studyId,
    'X-User-Id': env.client.auth.user().id,
  });
}

Future<void> updateRepo(String studyId, String projectId) async{
  await http.get(Uri.parse('${env.projectGeneratorUrl}/repo/update'), headers: {
    'X-Session': json.encode(env.client.auth.session().toJson()),
    'X-Study-Id': studyId,
    'X-Project-Id': projectId,
  });
}