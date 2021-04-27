import 'dart:convert';

import 'package:http/http.dart' as http;

class GitlabClient {
  late final String token;
  final String baseUrl;

  late Map<String, String> headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json'
  };

  GitlabClient(this.token, {this.baseUrl = 'https://gitlab.com/api/v4'});

  Future<http.Response> _httpPostRequest(
    String body,
    String resourcePath,
  ) async =>
      http.post(Uri.parse('$baseUrl/$resourcePath'),
          headers: headers, body: body);

  Future<int?> createProject(String name) async {
    final response = await _httpPostRequest(
        jsonEncode({'name': name, 'visibility': 'public'}), 'projects');

    if (httpSuccess(response.statusCode)) {
      final json = jsonDecode(response.body);
      return json['id'] as int;
    } else {
      print(
          'Creating project failed. Statuscode: ${response.statusCode} Reason: ${response.reasonPhrase}');
    }
  }

  static bool httpSuccess(int statusCode) =>
      statusCode ~/ 200 == 1 && statusCode % 200 < 100;

  Future<Map<String, dynamic>?> makeCommit({
    required int projectId,
    required String message,
    required List<Map<String, String>> actions,
    String branch = 'master',
  }) async {
    final body = {
      'branch': branch,
      'commit_message': message,
      'actions': actions
    };
    final response = await _httpPostRequest(jsonEncode(body),
        'projects/${projectId.toString()}/repository/commits');

    if (httpSuccess(response.statusCode)) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print(
          'Making commit failed. Statuscode: ${response.statusCode} Reason: ${response.reasonPhrase}');
    }
  }

  Map<String, String> commitAction({
    required String filePath,
    required String content,
    String action = 'create',
  }) {
    return {'action': action, 'file_path': filePath, 'content': content};
  }
}
