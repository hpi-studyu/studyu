import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:studyu_core/env.dart' as env;

import 'utils/generator.dart';
import 'utils/gitlab.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = '0.0.0.0';

Future<HttpServer> startServer(List<String> args) async {
  final parser = ArgParser()..addOption('port', abbr: 'p');
  final result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  final portStr = result['port'] as String? ?? Platform.environment['PORT'] ?? '8080';
  final port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    exit(1);
  }

  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  };
  shelf.Response? _options(shelf.Request request) =>
      (request.method == 'OPTIONS') ? shelf.Response.ok(null, headers: corsHeaders) : null;
  shelf.Response _cors(shelf.Response response) => response.change(headers: corsHeaders);
  final _fixCORS = shelf.createMiddleware(requestHandler: _options, responseHandler: _cors);

  final handler =
      const shelf.Pipeline().addMiddleware(_fixCORS).addMiddleware(shelf.logRequests()).addHandler(serverHandler);

  print('Starting server on $_hostname:$port');
  return io.serve(handler, _hostname, port);
}

Future<shelf.Response> serverHandler(shelf.Request request) async {
  final session = request.headers['x-session'];
  final studyId = request.headers['x-study-id'];
  if (session == null) {
    return shelf.Response(400, body: 'Bad Request. x-session header is missing.');
  }
  if (studyId == null) {
    return shelf.Response(400, body: 'Bad Request. x-study-id header is missing.');
  }

  print('Recovering Supabase session...');
  final res = await env.client.auth.recoverSession(session);
  print('Recovered Supabase session.');
  if (res.error != null) {
    print(res.error?.message);
    return shelf.Response.forbidden('Could not authenticate with X-Session. Error: ${res.error!.message}');
  }

  if (env.client.auth.session() == null) {
    return shelf.Response(500, body: 'Server Error. Session could not be established.');
  }

  if (env.client.auth.session()!.providerToken == null) {
    return shelf.Response(500, body: 'Server Error. GitLab token is not set.');
  }

  final gl = GitlabClient(env.client.auth.session()!.providerToken!);

  switch (request.url.pathSegments[0]) {
    case 'generate':
      await generateRepo(gl, studyId);
      return shelf.Response.ok('Generated repo');
    case 'update':
      final projectId = request.headers['x-project-id'];
      if (projectId == null) {
        return shelf.Response(400, body: 'Bad Request. x-project-id header is missing.');
      }
      await updateRepo(gl, projectId, studyId);
      return shelf.Response.ok('Updated repo');
    default:
      return shelf.Response.ok('Request for "${request.url}" did not match any know routes.');
  }
}
