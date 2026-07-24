import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delete waits for backend completion before resolving', () {
    final source = File(
      'lib/repositories/model_repository.dart',
    ).readAsStringSync();
    final deleteStart = source.indexOf(
      'Future<void> delete(ModelID modelId, {bool runOptimistically = true})',
    );
    final deleteEnd = source.indexOf('\n  @override', deleteStart);

    expect(deleteStart, isNonNegative);
    expect(deleteEnd, isNonNegative);

    final deleteSource = source.substring(deleteStart, deleteEnd);

    expect(deleteSource, contains('completeFutureOptimistically: false'));
    expect(
      deleteSource,
      isNot(contains('completeFutureOptimistically: runOptimistically')),
    );
  });
}
