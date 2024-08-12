import 'dart:math';

import 'package:csv/csv.dart';
import 'package:statistics/statistics.dart';

// This class implements the Welch's two sample t-test according to https://en.wikipedia.org/wiki/Student%27s_t-test
// Assuming two populations are normally distributed
// Size and variance of the samples from the populations can differ
class TTest {
  final List<num> sampleA;
  final List<num> sampleB;

  TTest(this.sampleA, this.sampleB);

  // Return variance
  num variance(List<num> sample) {
    return pow(sample.standardDeviation, 2);
  }

  // Calculate t-statistic using Welch's formula for two sample t-test
  num calculateTStatistic(num meanA, num meanB, num varianceA, num varianceB, int nA, int nB) {
    final num numerator = meanA - meanB;
    final num denominator = sqrt((varianceA / nA) + (varianceB / nB));
    return numerator / denominator;
  }

  // Calculate degrees of freedom using Welch-Satterthwaite equation
  double calculateDegreesOfFreedom(num meanA, num meanB, num varianceA, num varianceB, int nA, int nB) {
    final num numerator = pow((varianceA / nA) + (varianceB / nB), 2);
    final num denominator = (pow(varianceA / nA, 2) / (nA - 1)) + (pow(varianceB / nB, 2) / (nB - 1));
    return numerator / denominator;
  }

  double getTCriticalFromCsv(double degreesOfFreedom, String filePath) {
    final List<List<double>> rows = const CsvToListConverter().convert(filePath);
    for (final row in rows) {
      if (row[0] == degreesOfFreedom) {
        return row[1];
      }
    }
    throw Exception("Degrees of Freedom not found in CSV, study too long, reduce number of days");
  }

  double getTCritical(double degreesOfFreedom) {
    const String csvFilePath = 'assets/data/t_critical_values.csv';
    // Default alpha/2 = 0.05/2 = 0.025
    final double tCritical = getTCriticalFromCsv(degreesOfFreedom, csvFilePath);
    return tCritical;
  }

  // Method to check if the result is significant based on alpha level 0.05
  bool isSignificantlyDifferent() {
    final num meanA = sampleA.mean;
    final num meanB = sampleB.mean;
    final num varianceA = variance(sampleA);
    final num varianceB = variance(sampleB);
    final int nA = sampleA.length;
    final int nB = sampleB.length;
    final num tStatistic = calculateTStatistic(meanA, meanB, varianceA, varianceB, nA, nB);
    final double degreesOfFreedom = calculateDegreesOfFreedom(meanA, meanB, varianceA, varianceB, nA, nB);
    final double tCritical = getTCritical(degreesOfFreedom);
    return tStatistic.abs() > tCritical;
  }

}
