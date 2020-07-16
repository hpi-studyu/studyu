import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:studyou_core/environment.dart';

class ParseInit extends StatefulWidget {
  final Widget child;

  const ParseInit({Key key, this.child}) : super(key: key);

  @override
  _ParseInitState createState() => _ParseInitState();
}

class _ParseInitState extends State<ParseInit> {
  Future<bool> _initParseFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initParseFuture = initParse(Environment.of(context));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initParseFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError || (snapshot.hasData && !snapshot.data))
          return Scaffold(body: Center(child: Text('Server connection failed')));
        if (!snapshot.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));

        return widget.child;
      },
    );
  }

  Future<bool> initParse(Environment env) async {
    if (!Parse().hasParseBeenInitialized()) {
      await Parse().initialize(env.keyParseApplicationId, env.keyParseServerUrl,
          masterKey: env.keyParseMasterKey, debug: env.debug, coreStore: await CoreStoreSharedPrefsImp.getInstance());
    }
    final response = await Parse().healthCheck();
    if (response.success) {
      print('Connection to Parse server successful');
      return true;
    } else {
      print('Failed establishing connection to Parse server');
      return false;
    }
  }
}
