import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:study_data_docs/src/doc_metadata.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('doc_metadata_test_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  String writeMeta(String yaml) {
    final file = File(p.join(tmp.path, '_metadata.yaml'));
    file.writeAsStringSync(yaml);
    return file.path;
  }

  group('DocMetadata.empty', () {
    test('has no pages', () {
      final meta = DocMetadata.empty();
      expect(meta.allPagePaths, isEmpty);
    });
  });

  group('DocMetadata.load', () {
    test('returns empty when file missing', () {
      final meta = DocMetadata.load(p.join(tmp.path, 'nonexistent.yaml'));
      expect(meta.allPagePaths, isEmpty);
    });

    test('parses pages, titles, and fields', () {
      final path = writeMeta('''
pages:
  study/index.md:
    title: Study
    classes: [Study]
    fields:
      id: Unique identifier.
      title: Display title.
''');
      final meta = DocMetadata.load(path);
      expect(meta.allPagePaths, contains('study/index.md'));
      final page = meta.page('study/index.md')!;
      expect(page.title, 'Study');
      expect(page.fields['id']!.description, 'Unique identifier.');
      expect(page.fields['title']!.description, 'Display title.');
    });

    test('parses generatedFields: false', () {
      final path = writeMeta('''
pages:
  questionnaire/index.md:
    title: Questionnaire
    classes: [StudyUQuestionnaire]
    generated_fields: false
    fields: {}
''');
      final meta = DocMetadata.load(path);
      expect(meta.page('questionnaire/index.md')!.generatedFields, isFalse);
    });

    test('parses ignoredFields', () {
      final path = writeMeta('''
pages:
  study/index.md:
    title: Study
    classes: [Study]
    ignored_fields: [published, createdAt]
    fields: {}
''');
      final meta = DocMetadata.load(path);
      expect(
        meta.page('study/index.md')!.ignoredFields,
        containsAll(['published', 'createdAt']),
      );
    });

    test('parses links', () {
      final path = writeMeta('''
pages:
  study/index.md:
    title: Study
    classes: [Study]
    links:
      - study/contact.md
    fields: {}
''');
      final meta = DocMetadata.load(path);
      expect(meta.page('study/index.md')!.links, contains('study/contact.md'));
    });

    test('parses virtual fields', () {
      final path = writeMeta('''
pages:
  shared/data-reference.md:
    title: Data Reference
    classes: [DataReference]
    fields:
      task: Task ID.
      extra:
        description: Extra virtual field.
        virtual: true
        type: String
''');
      final meta = DocMetadata.load(path);
      final fields = meta.page('shared/data-reference.md')!.fields;
      expect(fields['task']!.virtual, isFalse);
      expect(fields['extra']!.virtual, isTrue);
      expect(fields['extra']!.type, 'String');
    });
  });
}
