import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/design/interventions/schedule_creator/model/intervention.dart';
import 'package:studyu_designer_v2/features/design/interventions/schedule_creator/model/study_schedule.dart';

// Simple test example
void main() {
  test("test algo", () {
    // Example usage
    final List<double> initialMeans = [
      1.0,
      1.0,
      1.0,
    ]; // Initial mean for each arm
    final List<double> initialVariances = [
      2.0,
      2.0,
      2.0,
    ]; // Initial variance for each arm

    // Create Thompson Sampling instance
    final ThompsonSamplingAlgo thompsonSampling =
        ThompsonSamplingAlgo(initialMeans, initialVariances);

    // // Simulate new observations (adjust to new data)
    thompsonSampling.updateObservations(0, 11.0);
    thompsonSampling.updateObservations(1, 10.0);
    // thompsonSampling.updateObservations(2, 3.0);

    var arms = [];

    for (var i = 0; i < 50; i++) {
      arms.add(thompsonSampling.selectArm());
    }

    print(arms);

    // sum how much each arm was used
    List<int> amounts = [0, 0, 0];
    amounts = initialMeans.map((e) => 0).toList();

    for (final a in arms) {
      amounts[a] += 1;
    }

    print(amounts);
  });
}
