import 'package:extended_math/extended_math.dart';

class LinearRegressionCoefficients {
  final num intercept;
  final List<num> variables;

  const LinearRegressionCoefficients(this.intercept, this.variables);
}

class LinearRegression {
  Matrix designMatrix;
  Vector dependentValues;

  LinearRegression(Iterable<MapEntry<List<num>, num>> samples) {
    final numVariables = samples.first.key.length;
    designMatrix = Matrix(samples.map((sample) {
      if (sample.key.length != numVariables) throw ArgumentError('Not all samples have the same number of variables.');
      return [1, ...sample.key];
    }).toList());
    dependentValues = Vector(samples.map((e) => e.value).toList());
  }

  LinearRegressionCoefficients getEstimatedCoefficients() {
    if (designMatrix.rows != dependentValues.itemsCount) {
      throw MatrixException('Dimensionality of design matrix and dependent variable vector do not agree.');
    }

    final crossMatrix = (designMatrix.transpose().matrixProduct(designMatrix)).toSquareMatrix();
    final aggregatedScore =
        (designMatrix.transpose().matrixProduct(dependentValues.toMatrixColumn())).columnAsVector(1);

    final coefficients = crossMatrix.eliminate(aggregatedScore.toList()).toList();
    return LinearRegressionCoefficients(coefficients.first, coefficients.sublist(1));
  }
}
