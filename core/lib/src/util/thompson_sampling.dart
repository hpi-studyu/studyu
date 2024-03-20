import 'dart:math';
import 'package:data/data.dart';

// TODO: Implement the Thompson Sampling algorithm form notebook

class UnknownMeanUnknownVariance {
  double _alpha;
  double _beta;

  int _n;
  List<double> _x;

  double _mu0;
  double _v0;

  UnknownMeanUnknownVariance({double alpha = 1, double beta = 1})
      : _alpha = alpha,
        _beta = beta,
        _n = 0,
        _x = [],
        _mu0 = 1,
        _v0 = beta / (alpha + 1);

  void update(double x) {
    const int n = 1;
    final int v = _n;

    _alpha = _alpha + n / 2;
    _beta = _beta + ((n * v / (v + n)) * (pow(x - _mu0, 2) / 2));

    _v0 = _beta / (_alpha + 1);

    _x.add(x);
    _n++;
    _mu0 = _calculateMean(_x);
  }

  double _calculateMean(List<double> values) {
    final double sum = values.fold(
      0,
      (previousValue, currentValue) => previousValue + currentValue,
    );
    return sum / values.length;
  }

  double sample() {
    double precision = GammaDistribution(_alpha, 1 / _beta).sample();

    if (precision == 0 || _n == 0) {
      precision = 0.001;
    }

    final double estimatedVariance = 1 / precision;
    return NormalDistribution(_mu0, sqrt(estimatedVariance)).sample();
  }
}

class ThompsonSamplingAlgo {
  final List<double> means;
  final List<double> variances;

  ThompsonSamplingAlgo(List<double> initialMeans, List<double> initialVariances)
      : means = List.from(initialMeans),
        variances = List.from(initialVariances);

  void updateObservations(int armIndex, double newObservation) {
    // Update mean and variance based on new observation
    final double oldMean = means[armIndex];
    final double oldVariance = variances[armIndex];

    // Update mean and variance using online update formulas
    final double newMean = (oldMean + newObservation) / 2;
    final double newVariance =
        (oldVariance + pow(newObservation - oldMean, 2)) / 2;

    means[armIndex] = newMean;
    variances[armIndex] = newVariance;
  }

  int selectArm() {
    // Number of arms (options)
    final int numArms = means.length;

    // Perform Thompson Sampling for each arm
    final List<double> samples = List.generate(numArms, (index) {
      // Generate a random sample for each arm using the Normal distribution
      final double sample = Random().nextDouble();

      // Calculate the sampled value from the Normal distribution
      return means[index] + sqrt(variances[index]) * cos(2 * pi * sample);
    });

    // Choose the arm with the highest sampled value
    final int selectedArm = samples.indexOf(samples.reduce(max));

    return selectedArm;
  }
}
