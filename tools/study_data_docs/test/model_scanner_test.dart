import 'package:study_data_docs/src/model_scanner.dart';
import 'package:test/test.dart';

void main() {
  group('buildDispatcherDiscriminators', () {
    final allClasses = {
      'BooleanQuestion': const ScannedClass(
        name: 'BooleanQuestion',
        sourceFile: 'core/lib/src/models/questionnaire/boolean_question.dart',
        fields: [],
        discriminatorValues: {'type': 'boolean'},
      ),
      'ChoiceQuestion': const ScannedClass(
        name: 'ChoiceQuestion',
        sourceFile: 'core/lib/src/models/questionnaire/choice_question.dart',
        fields: [],
        discriminatorValues: {'type': 'choice'},
      ),
      'ScaleQuestion': const ScannedClass(
        name: 'ScaleQuestion',
        sourceFile: 'core/lib/src/models/questionnaire/scale_question.dart',
        fields: [],
        discriminatorValues: {'type': 'scale'},
      ),
      'Unrelated': const ScannedClass(
        name: 'Unrelated',
        sourceFile: 'core/lib/src/models/other/unrelated.dart',
        fields: [],
      ),
    };

    test('collects all wire values for the given field', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'type',
        allClasses: allClasses,
      );
      expect(result, contains('type'));
      expect(result['type'], containsAll(['boolean', 'choice', 'scale']));
    });

    test('excludes classes with no discriminator for that field', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'type',
        allClasses: allClasses,
      );
      expect(result['type'], hasLength(3));
    });

    test('returns empty map when no classes have the field', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'nonexistent',
        allClasses: allClasses,
      );
      expect(result, isEmpty);
    });

    test('returns empty map for empty allClasses', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'type',
        allClasses: {},
      );
      expect(result, isEmpty);
    });
  });

  group('ScannedField', () {
    test('stores all fields', () {
      const f = ScannedField(
        name: 'id',
        dartType: 'String',
        jsonKey: 'id',
        required: true,
        nullable: false,
      );
      expect(f.name, 'id');
      expect(f.required, isTrue);
      expect(f.includeInJson, isTrue);
      expect(f.defaultValue, isNull);
    });

    test('includeInJson defaults to true', () {
      const f = ScannedField(
        name: 'x',
        dartType: 'int',
        jsonKey: 'x',
        required: false,
        nullable: false,
      );
      expect(f.includeInJson, isTrue);
    });
  });

  group('ScannedClass', () {
    test('discriminatorValues defaults to empty', () {
      const cls = ScannedClass(
        name: 'Foo',
        sourceFile: 'core/lib/src/models/foo.dart',
        fields: [],
      );
      expect(cls.discriminatorValues, isEmpty);
    });
  });
}
