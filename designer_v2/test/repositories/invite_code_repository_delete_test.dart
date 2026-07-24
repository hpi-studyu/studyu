import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('invite delete waits for backend completion', () {
    final packageRootFile = File(
      'lib/repositories/invite_code_repository.dart',
    );
    final repoRootFile = File(
      'designer_v2/lib/repositories/invite_code_repository.dart',
    );
    final source = packageRootFile.existsSync()
        ? packageRootFile.readAsStringSync()
        : repoRootFile.readAsStringSync();

    final deleteStart = source.indexOf(
      'Future<void> delete(StudyInvite model)',
    );
    final deleteEnd = source.indexOf('\n  @override', deleteStart);

    expect(deleteStart, isNonNegative);
    expect(deleteEnd, isNonNegative);

    final deleteSource = source.substring(deleteStart, deleteEnd);

    expect(
      deleteSource,
      contains('completeFutureOptimistically: false'),
      reason:
          'Invite delete must await backend completion before showing success '
          'or refreshing the recruit table.',
    );
  });
}
