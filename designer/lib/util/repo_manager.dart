import 'package:http/http.dart' as http;
import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> generateRepo(String studyId) async {
  await http.get(
    Uri.parse('${env.projectGeneratorUrl}/generate'),
    headers: {
      'x-session': Supabase.instance.client.auth.session().persistSessionString,
      'x-study-id': studyId,
    },
  );
}

Future<void> updateRepo(String studyId, String projectId) async {
  await http.get(
    Uri.parse('${env.projectGeneratorUrl}/update'),
    headers: {
      'x-session': Supabase.instance.client.auth.session().persistSessionString,
      'x-study-id': studyId,
      'x-project-id': projectId,
    },
  );
}
