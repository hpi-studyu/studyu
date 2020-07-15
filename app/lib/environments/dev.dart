import '../app.dart';
import 'environment.dart';

final Environment devApp = Environment(
  keyParseApplicationId: 'nof1',
  keyParseServerUrl: 'https://nof1.herokuapp.com/parse',
  keyParseMasterKey: '2d?xz*63GyZ4nDKp#WPKL5?5HLE=dDKm+epsA%Bp',
  debug: true,
  child: MyApp(),
);
