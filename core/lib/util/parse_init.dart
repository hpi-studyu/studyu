import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

class ParseInit extends StatelessWidget {
  final Widget child;

  const ParseInit({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ParseListFutureBuilder<bool>(
          queryFunction: () => initParse(),
          builder: (context, _) => child,
        ),
      ),
    );
  }

  Future<ParseResponse> initParse() async {
    if (!Parse().hasParseBeenInitialized()) {
      // Configuration filename inside envs/ folder set by env var, e.g. ".env.local".
      // Determined via flutter build/run android/web/... --dart-define=ENV=.env.dev/.env.prod/.env.local/...
      const env = const String.fromEnvironment('ENV');
      final envFileName = env.isNotEmpty ? 'envs/$env' : 'envs/.env';
      await DotEnv().load('$envFileName');
      final parseAppId = DotEnv().env['FLUTTER_PARSE_APP_ID'];
      final serverUrl = DotEnv().env['FLUTTER_PARSE_SERVER_URL'];
      final masterKey = DotEnv().env['FLUTTER_PARSE_MASTER_KEY'];
      final clientKey = DotEnv().env['FLUTTER_PARSE_CLIENT_KEY'];
      assert(parseAppId != null && parseAppId.isNotEmpty, "Parse App ID is null or empty");
      assert(serverUrl != null && serverUrl.isNotEmpty, "Parse Server URL is null or empty");
      await Parse().initialize(
        parseAppId,
        serverUrl,
        masterKey: masterKey,
        clientKey: clientKey,
        debug: DotEnv().env['FLUTTER_PARSE_DEBUG'] == 'true',
        coreStore: await CoreStoreSharedPrefsImp.getInstance(),
        // Dio is better, but slower on the web. Thus use http for web
        // https://github.com/parse-community/Parse-SDK-Flutter/tree/development/packages/flutter#network-client
        clientCreator: ({sendSessionId, securityContext}) => kIsWeb
            ? ParseHTTPClient(sendSessionId: sendSessionId, securityContext: securityContext)
            : ParseDioClient(sendSessionId: sendSessionId, securityContext: securityContext),
      );
    }
    return Parse().healthCheck();
  }
}
