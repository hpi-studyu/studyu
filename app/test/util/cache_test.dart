import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  group('Cache', () {
    late Map<String, String> storage;

    setUp(() {
      storage = {};
      Cache.debugContainsKeyForTesting = (key) =>
          Future.value(storage.containsKey(key));
      Cache.debugReadValueForTesting = (key) => Future.value(storage[key]);
      Cache.debugWriteValueForTesting = (key, value) async {
        storage[key] = value;
      };
      Cache.debugDeleteValueForTesting = (key) async {
        storage.remove(key);
      };
      Cache.debugReadAllValuesForTesting = () =>
          Future.value(Map<String, String>.from(storage));
      Cache.debugCurrentUserIdGetterForTesting = () => 'user-1';
      Cache.debugActiveSubjectIdGetterForTesting = () =>
          Future.value('subject-1');
    });

    tearDown(Cache.debugResetTestingOverrides);

    test('correct user and subject cache is accepted', () async {
      final subject = _subject('subject-1', 'user-1');
      storage['cache_subject_user-1_subject-1'] = jsonEncode(
        _cachedSubjectJson(subject),
      );

      final loaded = await Cache.loadSubject(backupSubject: subject);

      expect(loaded.id, 'subject-1');
      expect(loaded.userId, 'user-1');
    });

    test('different user cache is rejected', () {
      storage['cache_subject_user-1_subject-1'] = jsonEncode(
        _cachedSubjectJson(_subject('subject-1', 'user-2')),
      );

      expect(
        () => Cache.loadSubject(backupSubject: _subject('subject-1', 'user-1')),
        throwsException,
      );
    });

    test('same user but different subject cache is rejected', () {
      storage['cache_subject_user-1_subject-1'] = jsonEncode(
        _cachedSubjectJson(_subject('subject-2', 'user-1')),
      );

      expect(
        () => Cache.loadSubject(backupSubject: _subject('subject-1', 'user-1')),
        throwsException,
      );
    });

    test('matching legacy cache is migrated to scoped key', () async {
      final subject = _subject('subject-1', 'user-1');
      storage[cacheSubjectKey] = jsonEncode(_cachedSubjectJson(subject));

      final loaded = await Cache.loadSubject(backupSubject: subject);

      expect(loaded.id, 'subject-1');
      expect(storage.containsKey(cacheSubjectKey), isFalse);
      expect(storage.containsKey('cache_subject_user-1_subject-1'), isTrue);
    });

    test(
      'mismatched legacy cache is never merged into remote subject',
      () async {
        final remoteSubject = _subject('subject-1', 'user-1');
        remoteSubject.progress = [_progress('subject-1', 1)];
        final cachedSubject = _subject('subject-2', 'user-1');
        cachedSubject.progress = [_progress('subject-2', 2)];
        storage[cacheSubjectKey] = jsonEncode(
          _cachedSubjectJson(cachedSubject),
        );

        final synchronized = await Cache.synchronize(remoteSubject);

        expect(synchronized.progress, hasLength(1));
        expect(storage.containsKey(cacheSubjectKey), isFalse);
      },
    );

    test('parsed mismatched cache is rejected', () {
      storage[cacheSubjectKey] = jsonEncode(
        _cachedSubjectJson(_subject('subject-2', 'user-1')),
      );

      expect(
        () => Cache.loadSubject(backupSubject: _subject('subject-1', 'user-1')),
        throwsException,
      );
    });
  });
}

StudySubject _subject(String subjectId, String userId) {
  final subject = StudySubject(subjectId, 'study-1', userId, const []);
  subject.startedAt = DateTime.utc(2026);
  subject.study = Study('study-1', 'owner-1');
  return subject;
}

SubjectProgress _progress(String subjectId, int day) {
  return SubjectProgress(
    subjectId: subjectId,
    interventionId: 'intervention-1',
    taskId: 'task-1',
    resultType: 'bool',
    result: Result<bool>('bool')..result = true,
  )..completedAt = DateTime.utc(2026, 1, day);
}

Map<String, dynamic> _cachedSubjectJson(StudySubject subject) {
  return subject.toFullJson();
}
