import 'package:studyu_core/src/util/thompson_sampling.dart';
import 'package:test/test.dart';

void main() {
  group(
    "thompson sampling test",
    () => {
      // test

      test("test creation", () {
        final ts = ThompsonSampling(3);

        print(ts.selectArm());

        ts.updateObservations(1, 0);
        ts.updateObservations(1, 0);
        ts.updateObservations(1, 0);
        ts.updateObservations(1, 0);
        ts.updateObservations(1, 0);

        print(ts.selectArm());
      }),
    },
  );
}
