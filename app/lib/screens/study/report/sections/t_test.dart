import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
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
  num calculateTStatistic(
      num meanA, num meanB, num varianceA, num varianceB, int nA, int nB) {
    final num numerator = meanA - meanB;
    final num denominator = sqrt((varianceA / nA) + (varianceB / nB));
    return numerator / denominator;
  }

  // Calculate degrees of freedom using Welch-Satterthwaite equation
  double calculateDegreesOfFreedom(
      num meanA, num meanB, num varianceA, num varianceB, int nA, int nB) {
    final num numerator = pow((varianceA / nA) + (varianceB / nB), 2);
    final num denominator = (pow(varianceA / nA, 2) / (nA - 1)) +
        (pow(varianceB / nB, 2) / (nB - 1));
    return numerator / denominator;
  }

  // Method to read CSV data from assets
  Future<List<List<dynamic>>> loadCsvData() async {
    final csvData =
        await rootBundle.loadString('assets/data/t_critical_values.csv');
    return const CsvToListConverter(eol: '\n').convert(csvData);
  }

  // Get t-critical value based on degrees of freedom
  Future<double> getTCritical(double degreesOfFreedom) async {
    final List<List<dynamic>> rows = await loadCsvData();
    // Default alpha/2 = 0.05/2 = 0.025
    int roundedDegreesOfFreedom = degreesOfFreedom.round();
    // Critical values of the t-test do not significantly change with large degrees of freedom.
    // Approximate the critical values for large degrees of freedom by using the value at df = 200.
    if (roundedDegreesOfFreedom > 200) {
      roundedDegreesOfFreedom = 200;
    }
    // Iterate over rows, skipping the header
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isNotEmpty) {
        final degreeOfFreedom = row[0] as int;
        final criticalValue = row[1] as double;
        if (degreeOfFreedom == roundedDegreesOfFreedom) {
          return criticalValue;
        }
      }
    }
    throw Exception(
        "Degrees of Freedom not found in CSV file.");
  }

  // Method to check if the result is significant based on alpha level 0.05
  Future<bool> isSignificantlyDifferent() async {
    final num meanA = sampleA.mean;
    final num meanB = sampleB.mean;
    final num varianceA = variance(sampleA);
    final num varianceB = variance(sampleB);
    final int nA = sampleA.length;
    final int nB = sampleB.length;
    final num tStatistic =
        calculateTStatistic(meanA, meanB, varianceA, varianceB, nA, nB);
    final double degreesOfFreedom =
        calculateDegreesOfFreedom(meanA, meanB, varianceA, varianceB, nA, nB);
    final double tCritical = await getTCritical(degreesOfFreedom);
    return tStatistic.abs() > tCritical;
  }
}
