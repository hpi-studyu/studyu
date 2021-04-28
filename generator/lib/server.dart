import 'dart:io';

import 'package:args/args.dart';
import 'package:generator/utils/generator.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:studyou_core/env.dart' as env;

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

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
  switch (request.url.pathSegments[0]) {
    case 'generate':
      final session = request.headers['x-session'];
      final studyId = request.headers['x-study-id'];
      if (session == null) {
        return shelf.Response(400, body: 'Bad Request. X-Session header is missing.');
      }
      if (studyId == null) {
        return shelf.Response(400, body: 'Bad Request. X-Study-Id header is missing.');
      }

      final res = await env.client.auth.recoverSession(session);
      if (res.error != null) {
        print(res.error?.message);
        return shelf.Response.forbidden('Could not authenticate with X-Session. Error: ${res.error!.message}');
      }

      print(env.client.auth.session()!.providerToken);

      await generateRepo(studyId);

      return shelf.Response.ok('OK');
    default:
      return shelf.Response.ok('Request for "${request.url}" did not match any know routes.');
  }
}
