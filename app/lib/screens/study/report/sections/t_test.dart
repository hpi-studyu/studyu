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
  num calculateDegreesOfFreedom(
      num meanA, num meanB, num varianceA, num varianceB, int nA, int nB) {
    final num numerator = pow((varianceA / nA) + (varianceB / nB), 2);
    final num denominator = (pow(varianceA / nA, 2) / (nA - 1)) +
        (pow(varianceB / nB, 2) / (nB - 1));
    return numerator / denominator;
  }

  // Function to approximate the Gamma function using Lanczos approximation
  num gamma(num x) {
    const List<num> p = [
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7
    ];

    if (x < 0.5) {
      return pi / (sin(pi * x) * gamma(1 - x));
    } else {
      x -= 1;
      num a = 0.99999999999980993;
      num t = x + 7.5;

      for (int i = 0; i < p.length; i++) {
        a += p[i] / (x + i + 1);
      }

      return sqrt(2 * pi) * pow(t, x + 0.5) * exp(-t) * a;
    }
  }

  // Function to calculate the PDF of the t-distribution
  num tDistributionPDF(num t, num v) {
    num gammaHalfVPlus1 = gamma((v + 1) / 2);
    num gammaHalfV = gamma(v / 2);
    num sqrtVPI = sqrt(v * pi);

    num numerator = gammaHalfVPlus1;
    num denominator =
        sqrtVPI * gammaHalfV * pow(1 + (t * t) / v, (v + 1) / 2);

    return numerator / denominator;
  }

  // Calculate p-value for two-tailed t-test
  double calculatePValue() {
    final num meanA = sampleA.mean;
    final num meanB = sampleB.mean;
    final num varianceA = variance(sampleA);
    final num varianceB = variance(sampleB);
    final int nA = sampleA.length;
    final int nB = sampleB.length;
    final num tStatistic =
    calculateTStatistic(meanA, meanB, varianceA, varianceB, nA, nB);
    final num degreesOfFreedom =
    calculateDegreesOfFreedom(meanA, meanB, varianceA, varianceB, nA, nB);

    final double positiveTailProbability =
    integratePDF(tStatistic.abs(), degreesOfFreedom);
    print(positiveTailProbability.toDouble().toStringAsFixed(20));
    print("positiveTailProbability");
    return 2 * positiveTailProbability; // Two-tailed p-value
  }

  // Numerical integration using the trapezoidal rule to approximate the CDF
  double integratePDF(num tStatistic, num degreesOfFreedom) {
    const double stepSize = 0.001; // Step size for the integration
    double sum = 0.0;

    for (double t = tStatistic.toDouble(); t < 10; t += stepSize) {
      sum += tDistributionPDF(t, degreesOfFreedom) * stepSize;
    }

    return sum;
  }

// Method to check if the result is significant based on alpha level 0.05
  Future<bool> isSignificantlyDifferent() async {
    final double pValue = calculatePValue();
    return pValue < 0.05;
  }
}
