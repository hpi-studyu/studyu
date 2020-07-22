import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:studyou_core/environment.dart';
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
    _initParseFuture = initParse(Environment.of(context));
  }

  @override
  Widget build(BuildContext context) {
    return ParseListFutureBuilder<bool>(
      queryFunction: () => _initParseFuture,
      builder: (context, _) => widget.child,
    );
  }

  Future<ParseResponse> initParse(Environment env) async {
    if (!Parse().hasParseBeenInitialized()) {
      await Parse().initialize(env.keyParseApplicationId, env.keyParseServerUrl,
          masterKey: env.keyParseMasterKey, debug: env.debug, coreStore: await CoreStoreSharedPrefsImp.getInstance());
    }
    return Parse().healthCheck();
  }
}
