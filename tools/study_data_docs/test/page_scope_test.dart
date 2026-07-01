import 'package:study_data_docs/src/page_scope.dart';
import 'package:test/test.dart';

void main() {
  group('scopeFor', () {
    test('returns entry for in-scope class', () {
      final entry = scopeFor('Study');
      expect(entry, isNotNull);
      expect(entry!.pagePath, equals('study/index.md'));
    });

    test('returns null for excluded class', () {
      expect(scopeFor('Task'), isNull);
      expect(scopeFor('TaskInstance'), isNull);
    });

    test('returns null for unknown class', () {
      expect(scopeFor('SomeRandomClass'), isNull);
    });
  });

  group('entriesForPage', () {
    test('returns all entries for a multi-class page', () {
      final entries = entriesForPage('shared/expressions.md');
      expect(entries.length, greaterThan(3));
      final names = entries.map((e) => e.className).toSet();
      expect(names, contains('Expression'));
      expect(names, contains('BooleanExpression'));
      expect(names, contains('CompositeExpression'));
    });

    test('returns single entry for single-class page', () {
      final entries = entriesForPage('study/index.md');
      expect(entries.length, equals(1));
      expect(entries.first.className, equals('Study'));
    });
  });

  group('allPagePaths', () {
    test('contains expected paths', () {
      final paths = allPagePaths;
      expect(paths, contains('study/index.md'));
      expect(paths, contains('questionnaire/question-types/scale.md'));
      expect(paths, contains('reports/sections/average.md'));
      expect(paths, contains('shared/expressions.md'));
    });

    test('does not contain excluded class pages', () {
      final paths = allPagePaths;
      for (final path in paths) {
        expect(path, isNot(contains('task_instance')));
      }
    });
  });

  group('PageScopeEntry flags', () {
    test('StudyUQuestionnaire has generatedFields: false', () {
      final entry = scopeFor('StudyUQuestionnaire');
      expect(entry, isNotNull);
      expect(entry!.generatedFields, isFalse);
    });

    test('CompositeExpression has a note', () {
      final entry = scopeFor('CompositeExpression');
      expect(entry, isNotNull);
      expect(entry!.note, isNotNull);
      expect(entry.note, contains('Expression.fromJson'));
    });

    test('StudySubject has a runtime-only note', () {
      final entry = scopeFor('StudySubject');
      expect(entry, isNotNull);
      expect(entry!.note, contains('Supabase join rows'));
    });

    test('Question has dispatcherField set to type', () {
      final entry = scopeFor('Question');
      expect(entry, isNotNull);
      expect(entry!.dispatcherField, 'type');
    });

    test('Expression has dispatcherField set to type', () {
      final entry = scopeFor('Expression');
      expect(entry, isNotNull);
      expect(entry!.dispatcherField, 'type');
    });

    test('BooleanQuestion has no dispatcherField', () {
      final entry = scopeFor('BooleanQuestion');
      expect(entry, isNotNull);
      expect(entry!.dispatcherField, isNull);
    });
  });
}
