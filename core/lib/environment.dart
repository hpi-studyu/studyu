import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Environment extends InheritedWidget {
  final String keyParseApplicationId;
  final String keyParseServerUrl;
  final String keyParseMasterKey;
  final bool debug;

  const Environment({
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

  const Environment.development({@required Widget child})
      : keyParseApplicationId = 'nof1',
        keyParseServerUrl = 'https://nof1.herokuapp.com/parse',
        keyParseMasterKey = '2d?xz*63GyZ4nDKp#WPKL5?5HLE=dDKm+epsA%Bp',
        debug = true,
        super(child: child);

  // Same as development. Change when production server available, e.g. for user testing
  const Environment.production({@required Widget child})
      : keyParseApplicationId = 'nof1',
        keyParseServerUrl = 'https://nof1.herokuapp.com/parse',
        keyParseMasterKey = '2d?xz*63GyZ4nDKp#WPKL5?5HLE=dDKm+epsA%Bp',
        debug = true,
        super(child: child);

  const Environment.local({@required Widget child})
      : keyParseApplicationId = 'nof1-local',
        keyParseServerUrl = 'http://localhost:1337/parse',
        keyParseMasterKey = 'nof1-local',
        debug = true,
        super(child: child);

  // Android Emulator access the machine's localhost via 10.0.2.2
  const Environment.localAndroidEmulator({@required Widget child})
      : keyParseApplicationId = 'nof1-local',
        keyParseServerUrl = 'http://10.0.2.2:1337/parse',
        keyParseMasterKey = 'nof1-local',
        debug = true,
        super(child: child);
}
