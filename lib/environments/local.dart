import '../app.dart';
import 'environment.dart';

final Environment localApp = Environment(
  keyParseApplicationId: 'nof1-local',
  keyParseServerUrl: 'http://localhost:1337/parse',
  keyParseMasterKey: 'nof1-local',
  debug: true,
  child: MyApp(),
);
