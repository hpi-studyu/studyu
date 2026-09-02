import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deleteStudy removes child rows before deleting the study', () {
    final source = File('lib/repositories/api_client.dart').readAsStringSync();
    final deleteStart = source.indexOf(
      'Future<void> deleteStudy(Study study) async',
    );
    final deleteEnd = source.indexOf('\n  }', deleteStart);

    expect(deleteStart, isNonNegative);
    expect(deleteEnd, isNonNegative);

    final deleteSource = source.substring(deleteStart, deleteEnd);

    expect(deleteSource, contains('_deleteStudyDependents(study.id)'));
    expect(deleteSource, contains('study.delete()'));
    expect(
      deleteSource.indexOf('_deleteStudyDependents(study.id)'),
      lessThan(deleteSource.indexOf('study.delete()')),
      reason:
          'Study deletion must remove dependent rows first so databases without '
          'ON DELETE CASCADE do not reject deletion via study_invite_studyId_fkey.',
    );
  });

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
}
