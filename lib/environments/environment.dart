import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class Environment extends InheritedWidget {
  final String keyParseApplicationId;
  final String keyParseServerUrl;
  final String keyParseMasterKey;
  final bool debug;

  Environment({
    @required this.keyParseApplicationId,
    @required this.keyParseServerUrl,
    @required this.keyParseMasterKey,
    @required this.debug,
    @required Widget child,
  }) : super(child: child);

  static Environment of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Environment>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
