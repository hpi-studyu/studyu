import 'package:http/http.dart' as http;
import 'package:studyou_core/env.dart' as env;

Future<void> generateRepo(String studyId) async {
  await http.get(Uri.parse('${env.projectGeneratorUrl}/generate'), headers: {
    'x-session': env.client.auth.session().persistSessionString,
    'x-study-id': studyId,
  });
}

Future<void> updateRepo(String studyId, String projectId) async {
  await http.get(Uri.parse('${env.projectGeneratorUrl}/update'), headers: {
    'x-session': env.client.auth.session().persistSessionString,
    'x-study-id': studyId,
    'x-project-id': projectId,
  });
}
