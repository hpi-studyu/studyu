import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'deleteStudy tries direct study delete before legacy cleanup fallback',
    () {
      final source = File(
        'lib/repositories/api_client.dart',
      ).readAsStringSync();
      final deleteStart = source.indexOf(
        'Future<void> deleteStudy(Study study) async',
      );
      final deleteEnd = source.indexOf('\n  }', deleteStart);

      expect(deleteStart, isNonNegative);
      expect(deleteEnd, isNonNegative);

      final deleteSource = source.substring(deleteStart, deleteEnd);

      expect(deleteSource, contains('study.delete()'));
      expect(deleteSource, contains('_deleteStudyDependents(study.id)'));
      expect(deleteSource, contains('_isMissingStudyCascade(error)'));
      expect(
        deleteSource.indexOf('await study.delete();'),
        lessThan(deleteSource.indexOf('_deleteStudyDependents(study.id)')),
        reason:
            'Study deletion should use database cascade first and only fall back '
            'to manual child cleanup for legacy foreign key setups.',
      );
    },
  );

  test('dependent cleanup includes invite codes and participant rows', () {
    final source = File('lib/repositories/api_client.dart').readAsStringSync();
    final cleanupStart = source.indexOf('Future<void> _deleteStudyDependents');
    final cleanupEnd = source.indexOf('\n  @override', cleanupStart);

    expect(cleanupStart, isNonNegative);
    expect(cleanupEnd, isNonNegative);

    final cleanupSource = source.substring(cleanupStart, cleanupEnd);

    expect(cleanupSource, contains('StudySubject.tableName'));
    expect(cleanupSource, contains('StudyInvite.tableName'));
    expect(cleanupSource, contains('StudyFitbitCredentials.tableName'));
    expect(cleanupSource, contains('Repo.tableName'));
    expect(cleanupSource, contains('SubjectProgress.tableName'));
    expect(cleanupSource, contains("eq('study_id', studyId)"));
  });

  test('legacy cleanup fallback only handles foreign key violations', () {
    final source = File('lib/repositories/api_client.dart').readAsStringSync();

    expect(source, contains("foreignKeyViolation = '23503'"));
    expect(
      source,
      contains('bool _isMissingStudyCascade(PostgrestException error)'),
    );
    expect(
      source,
      contains('error.code == PostgrestErrorCodes.foreignKeyViolation'),
    );
  });
}
