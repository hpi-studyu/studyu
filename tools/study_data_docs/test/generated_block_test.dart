import 'package:study_data_docs/src/generated_block.dart';
import 'package:test/test.dart';

void main() {
  group('replaceBlock', () {
    test('replaces content between existing markers', () {
      final existing = [
        '# Title',
        '',
        '<!-- GENERATED:FIELDS START -->',
        'old content',
        '<!-- GENERATED:FIELDS END -->',
        '',
        'Some prose.',
        '',
      ].join('\n');

      final result = replaceBlock(
        existing: existing,
        kind: 'FIELDS',
        newContent: 'new content',
      );

      expect(result, contains('new content'));
      expect(result, isNot(contains('old content')));
      expect(result, contains('Some prose.'));
    });

    test('appends block when absent', () {
      const existing = '# Title\n\nSome prose.\n';
      final result = replaceBlock(
        existing: existing,
        kind: 'FIELDS',
        newContent: 'new content',
      );

      expect(result, contains('<!-- GENERATED:FIELDS START -->'));
      expect(result, contains('<!-- GENERATED:FIELDS END -->'));
      expect(result, contains('new content'));
      expect(result, contains('Some prose.'));
    });
  });

  group('extractBlock', () {
    test('extracts content between markers', () {
      final markdown = [
        '# Title',
        '',
        '<!-- GENERATED:FIELDS START -->',
        '| Field | Type |',
        '|-------|------|',
        '| id | String |',
        '<!-- GENERATED:FIELDS END -->',
        '',
      ].join('\n');

      final content = extractBlock(markdown, 'FIELDS');
      expect(content, isNotNull);
      expect(content, contains('| id | String |'));
    });

    test('returns null when block absent', () {
      const markdown = '# Title\n\nNo blocks here.\n';
      expect(extractBlock(markdown, 'FIELDS'), isNull);
    });
  });

  group('buildFieldsTable', () {
    test('emits markdown table rows', () {
      final rows = [
        const FieldRow(
          dartName: 'id',
          jsonKey: 'id',
          dartType: 'String',
          required: true,
          description: 'Unique identifier.',
        ),
        const FieldRow(
          dartName: 'title',
          jsonKey: 'title',
          dartType: 'String?',
          required: false,
          description: 'Display title.',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(table, contains('| `id` |'));
      expect(table, contains('| `title` |'));
      expect(table, contains('Yes'));
      expect(table, contains('No'));
    });

    test('links type labels when type href is present', () {
      const rows = [
        FieldRow(
          dartName: 'conditional',
          jsonKey: 'conditional',
          dartType: 'QuestionConditional<V>?',
          required: false,
          description: 'Optional display condition.',
          typeHref: '../shared/question-conditional.md',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(
        table,
        contains(
          '[`QuestionConditional<V>?`](../shared/question-conditional.md)',
        ),
      );
    });

    test('returns placeholder for empty rows', () {
      final table = buildFieldsTable([]);
      expect(table, contains('No JSON-serialisable fields'));
    });
  });

  group('FieldRow.fieldLabel', () {
    test('shows dart name only when names match', () {
      const row = FieldRow(
        dartName: 'userId',
        jsonKey: 'userId',
        dartType: 'String',
        required: true,
        description: '',
      );
      expect(row.fieldLabel, 'userId');
    });

    test('shows dart name and json key when they differ', () {
      const row = FieldRow(
        dartName: 'userId',
        jsonKey: 'user_id',
        dartType: 'String',
        required: true,
        description: '',
      );
      expect(row.fieldLabel, 'userId (user_id)');
    });
  });

  group('buildFieldsTable with defaults', () {
    test('includes Default column when any row has a default', () {
      final rows = [
        const FieldRow(
          dartName: 'count',
          jsonKey: 'count',
          dartType: 'int',
          required: false,
          description: 'Item count.',
          defaultValue: '0',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(table, contains('Default'));
      expect(table, contains('`0`'));
    });

    test('omits Default column when no row has a default', () {
      final rows = [
        const FieldRow(
          dartName: 'id',
          jsonKey: 'id',
          dartType: 'String',
          required: true,
          description: 'ID.',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(table, isNot(contains('Default')));
    });
  });

  group('buildDiscriminatorsBlock', () {
    test('emits discriminator table for concrete class', () {
      final block = buildDiscriminatorsBlock({'type': 'boolean'});
      expect(block, contains('| `type` | `boolean` |'));
    });

    test('emits sorted multi-value row for dispatcher page', () {
      final block = buildDiscriminatorsBlock({
        'type': {'scale', 'boolean', 'choice'},
      });
      expect(block, contains('`boolean`'));
      expect(block, contains('`choice`'));
      expect(block, contains('`scale`'));
      // Values appear in sorted order.
      final boolIdx = block.indexOf('`boolean`');
      final choiceIdx = block.indexOf('`choice`');
      final scaleIdx = block.indexOf('`scale`');
      expect(boolIdx, lessThan(choiceIdx));
      expect(choiceIdx, lessThan(scaleIdx));
    });

    test('returns placeholder for empty map', () {
      final block = buildDiscriminatorsBlock({});
      expect(block, contains('No discriminator'));
    });
  });

  group('buildLinksBlock', () {
    test('emits list of links', () {
      final block = buildLinksBlock([
        const LinkEntry(label: 'Study', href: '../study/index.md'),
      ]);
      expect(block, contains('[Study](../study/index.md)'));
    });

    test('returns placeholder for empty list', () {
      final block = buildLinksBlock([]);
      expect(block, contains('No cross-references'));
    });
  });
}
