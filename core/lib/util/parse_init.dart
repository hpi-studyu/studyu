import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

class ParseInit extends StatefulWidget {
  final Widget child;

  const ParseInit({Key key, this.child}) : super(key: key);

  @override
  _ParseInitState createState() => _ParseInitState();
}

class _ParseInitState extends State<ParseInit> {
  Future<ParseResponse> _initParseFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initParseFuture = initParse();
  }

  @override
  Widget build(BuildContext context) {
    return ParseListFutureBuilder<bool>(
      queryFunction: () => _initParseFuture,
      builder: (context, _) => widget.child,
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
      assert(parseAppId != null && parseAppId.isNotEmpty, "Parse App ID is null or empty");
      assert(serverUrl != null && serverUrl.isNotEmpty, "Parse Server URL is null or empty");
      await Parse().initialize(
        parseAppId,
        serverUrl,
        debug: DotEnv().env['FLUTTER_PARSE_DEBUG'] == 'true',
        coreStore: await CoreStoreSharedPrefsImp.getInstance(),
      );
    }
    return Parse().healthCheck();
  }
}
