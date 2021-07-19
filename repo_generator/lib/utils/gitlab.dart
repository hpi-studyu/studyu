import 'dart:convert';

import 'package:http/http.dart' as http;

class GitlabClient {
  late final String token;
  final String baseUrl;

  late Map<String, String> headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

  GitlabClient(this.token, {this.baseUrl = 'https://gitlab.com/api/v4'});

  Future<http.Response> _httpPostRequest(
    String body,
    String resourcePath,
  ) async =>
      http.post(Uri.parse('$baseUrl/$resourcePath'), headers: headers, body: body);

  Future<http.Response> _httpPutRequest(
    String body,
    String resourcePath,
  ) async =>
      http.put(Uri.parse('$baseUrl/$resourcePath'), headers: headers, body: body);

  Future<Map<String, dynamic>?> createProject(String name) async {
    final response = await _httpPostRequest(jsonEncode({'name': name, 'visibility': 'public'}), 'projects');

    if (httpSuccess(response.statusCode)) {
      final json = jsonDecode(response.body);
      return json;
    } else {
      print('Creating project failed. Statuscode: ${response.statusCode} Reason: ${response.reasonPhrase}');
    }
  }

  static bool httpSuccess(int statusCode) => statusCode ~/ 200 == 1 && statusCode % 200 < 100;

  Future<Map<String, dynamic>?> addDeployKey({
    required String projectId,
    required String title,
    required String key,
    bool canPush = false,
  }) async {
    final body = {'title': title, 'key': key, 'can_push': canPush};
    final response = await _httpPostRequest(jsonEncode(body), 'projects/$projectId/deploy_keys');

    if (httpSuccess(response.statusCode)) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print(response.body);
      print('Adding deploy key $title failed. Statuscode: ${response.statusCode} Reason: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>?> makeCommit({
    required String projectId,
    required String message,
    required List<Map<String, String>> actions,
    String branch = 'master',
  }) async {
    final body = {'branch': branch, 'commit_message': message, 'actions': actions};
    final response = await _httpPostRequest(jsonEncode(body), 'projects/$projectId/repository/commits');

    if (httpSuccess(response.statusCode)) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print(response.body);
      print('Making commit failed. Statuscode: ${response.statusCode} Reason: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>?> createProjectVariable({
    required String projectId,
    required String key,
    required String value,
    bool masked = false,
  }) async {
    final body = {'key': key, 'value': value, 'masked': masked};
    final response = await _httpPostRequest(jsonEncode(body), 'projects/$projectId/variables');

    if (httpSuccess(response.statusCode)) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print(response.body);
      print('Creating variable $key failed. Statuscode: ${response.statusCode} Reason: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>?> updateProjectVariable({
    required String projectId,
    required String key,
    required String value,
  }) async {
    final body = {'value': value};
    final response = await _httpPutRequest(jsonEncode(body), 'projects/$projectId/variables/$key');

    if (httpSuccess(response.statusCode)) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print(response.body);
      print('Updating variable failed. Statuscode: ${response.statusCode} Reason: ${response.reasonPhrase}');
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
