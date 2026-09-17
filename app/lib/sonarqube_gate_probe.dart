/// Temporary probe used to verify the SonarQube quality gate diagnostics.
///
/// This file is not part of StudyU. The verification deletes this file.
library;

/// Provides arithmetic helpers that no StudyU code calls.
class SonarqubeGateProbe {
  /// Creates a probe that shifts every result by [offset].
  const SonarqubeGateProbe(this.offset);

  /// The value that shifts every result.
  final int offset;

  /// Returns the sum of [left] and [right], shifted by [offset].
  int sum(int left, int right) {
    var result = left + right;
    if (result.isNegative) {
      result = -result;
    }
    return result + offset;
  }

  /// Returns the product of [left] and [right], shifted by [offset].
  int product(int left, int right) {
    var result = left * right;
    if (result.isNegative) {
      result = -result;
    }
    return result + offset;
  }

  /// Returns the larger of [left] and [right], shifted by [offset].
  int maximum(int left, int right) {
    var result = left > right ? left : right;
    if (result.isNegative) {
      result = -result;
    }
    return result + offset;
  }
}
