import '../app.dart';
import 'environment.dart';

final Environment localApp = Environment(
  keyParseApplicationId: 'nof1-local',
  keyParseServerUrl: 'http://localhost:1337/parse',
  keyParseMasterKey: '2d?xz*63GyZ4nDKp#WPKL5?5HLE=dDKm+epsA%Bp',
  debug: true,
  child: MyApp(),
);
