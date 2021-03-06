import 'package:extended_math/extended_math.dart';
import 'package:grizzly_distuv/grizzly_distuv.dart';
import 'package:grizzly_distuv/math.dart';

class Range<T> {
  final T min;
  final T max;

  Range(this.min, this.max);
}

class LinearRegressionResult<T> {
  final T intercept;
  final List<T> variables;

  const LinearRegressionResult(this.intercept, this.variables);
}

class LinearRegression {
  Matrix designMatrix;
  Vector dependentValues;
  Vector _estimatedCoefficients;
  StudentT _coefficientDistribution;

  LinearRegression(Iterable<MapEntry<List<num>, num>> samples) {
    final numVariables = samples.first.key.length;
    designMatrix = Matrix(samples.map((sample) {
      if (sample.key.length != numVariables) throw ArgumentError('Not all samples have the same number of variables.');
      return [1, ...sample.key];
    }).toList());
    dependentValues = Vector(samples.map((e) => e.value).toList());
    _coefficientDistribution = StudentT(_getDegreesOfFreedom().toDouble());
  }

  Vector _getEstimatedCoefficientVector() {
    if (_estimatedCoefficients != null) return _estimatedCoefficients;
    if (designMatrix.rows != dependentValues.itemsCount) {
      throw MatrixException('Dimensionality of design matrix and dependent variable vector do not agree.');
    }

    final aggregatedScore =
        (designMatrix.transpose().matrixProduct(dependentValues.toMatrixColumn())).columnAsVector(1);

    return _estimatedCoefficients = _getCrossMatrix().eliminate(aggregatedScore.toList());
  }

  LinearRegressionResult<num> getEstimatedCoefficients() {
    final coefficients = _getEstimatedCoefficientVector().toList();
    return LinearRegressionResult(coefficients.first, coefficients.sublist(1));
  }

  int _getDegreesOfFreedom() => designMatrix.rows - designMatrix.columns;

  SquareMatrix _getCrossMatrix() => designMatrix.transpose().matrixProduct(designMatrix).toSquareMatrix();
  SquareMatrix _getVarCoVarMatrix() => (_getCrossMatrix().inverse() * _squaredStandardError()).toSquareMatrix();

  Vector _getPredictedValues() =>
      designMatrix.matrixProduct(_getEstimatedCoefficientVector().toMatrixColumn()).columnAsVector(1);
  Vector _getResiduals() => dependentValues - _getPredictedValues();
  Vector _getStandardErrors() => _getVarCoVarMatrix().mainDiagonal().map(sqrt);

  Vector _getTValues({Vector mu0}) {
    mu0 ??= Vector.generate(designMatrix.columns, (_) => 0);
    return (_getEstimatedCoefficientVector() - mu0).hadamard(_getStandardErrors().map((x) => 1 / x));
  }

  LinearRegressionResult<num> getTValues() {
    final tValues = _getTValues().toList();
    return LinearRegressionResult(tValues.first, tValues.sublist(1));
  }

  double _getStudentTCDF(double t) {
    final df = _coefficientDistribution.df;
    final halfDf = df / 2;
    final x = df / (t * t + df);
    return 1 - (0.5 * ibetaReg(halfDf, 0.5, x));
  }

  Vector _getPValues({Vector mu0}) {
    final tValues = _getTValues(mu0: mu0);
    return tValues.map((t) => (1 - _getStudentTCDF(t.abs() as double)) * 2);
  }

  LinearRegressionResult<num> getPValues() {
    final tValues = _getPValues().toList();
    return LinearRegressionResult(tValues.first, tValues.sublist(1));
  }

  num _getTConfidenceInterval(double alpha) => _coefficientDistribution.ppf(1 - (alpha / 2));

  Vector _getConfidenceRadius(double alpha) {
    return _getStandardErrors() * _getTConfidenceInterval(alpha);
  }

  LinearRegressionResult<Range<num>> getConfidenceIntervals(double alpha) {
    final coeffecients = _getEstimatedCoefficientVector();
    final radius = _getConfidenceRadius(alpha);
    final lower = (coeffecients - radius).toList();
    final upper = (coeffecients + radius).toList();
    return LinearRegressionResult(Range(lower.first, upper.first),
        Iterable<int>.generate(designMatrix.columns - 1).map((e) => Range(lower[e + 1], upper[e + 1])).toList());
  }

  num _squaredStandardError() => _getResiduals().dot(_getResiduals()) / _getDegreesOfFreedom();
}
