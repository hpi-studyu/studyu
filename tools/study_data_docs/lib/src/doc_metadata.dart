/// Parses and writes `_metadata.yaml` files that describe each doc page.
///
/// The metadata file lives at `core/docs/study-data/_metadata.yaml` and
/// drives field descriptions, ignored fields, virtual fields, and the link
/// graph between pages.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// A field entry inside a page's `fields:` map.
class FieldMeta {
  final String name;
  final String description;
  final bool virtual; // true = exists in docs but not in source
  final String? type;
  final bool required;

  const FieldMeta({
    required this.name,
    required this.description,
    this.virtual = false,
    this.type,
    this.required = false,
  });

  Map<String, dynamic> toYaml() => {
    if (type case final t?) 'type': t,
    'description': description,
    if (virtual) 'virtual': true,
    if (required) 'required': true,
  };
}

/// A single page entry inside the metadata file.
class PageMeta {
  final String path; // relative to core/docs/study-data/
  final String title;
  final List<String> classes;
  final Map<String, FieldMeta> fields;
  final List<String> ignoredFields;
  final List<String> links; // canonical page paths this page links to
  final bool generatedFields;
  final String? note;

  const PageMeta({
    required this.path,
    required this.title,
    required this.classes,
    this.fields = const {},
    this.ignoredFields = const [],
    this.links = const [],
    this.generatedFields = true,
    this.note,
  });
}

/// Loads and parses the `_metadata.yaml` file.
class DocMetadata {
  final Map<String, PageMeta> _pages; // keyed by page path

  DocMetadata.empty() : _pages = {};

  /// Loads the metadata file from [metadataPath].
  DocMetadata.load(String metadataPath) : _pages = _parseFile(metadataPath);

  static Map<String, PageMeta> _parseFile(String metadataPath) {
    final file = File(metadataPath);
    if (!file.existsSync()) return {};

    final raw = loadYaml(file.readAsStringSync());
    if (raw is! YamlMap) return {};

    final pages = <String, PageMeta>{};
    final pagesNode = raw['pages'];
    if (pagesNode is! YamlMap) return {};

    for (final entry in pagesNode.entries) {
      final pagePath = entry.key as String;
      final data = entry.value as YamlMap;

      final title = data['title'] as String? ?? '';
      final classes = _stringList(data['classes']);
      final ignoredFields = _stringList(data['ignored_fields']);
      final links = _stringList(data['links']);
      final generatedFields = data['generated_fields'] as bool? ?? true;
      final note = data['note'] as String?;

      final fields = <String, FieldMeta>{};
      final fieldsNode = data['fields'];
      if (fieldsNode is YamlMap) {
        for (final fieldEntry in fieldsNode.entries) {
          final fieldName = fieldEntry.key as String;
          final fieldData = fieldEntry.value;
          if (fieldData == null) continue;

          if (fieldData is String) {
            fields[fieldName] = FieldMeta(
              name: fieldName,
              description: fieldData,
            );
          } else if (fieldData is YamlMap) {
            fields[fieldName] = FieldMeta(
              name: fieldName,
              description: fieldData['description'] as String? ?? '',
              virtual: fieldData['virtual'] as bool? ?? false,
              type: fieldData['type'] as String?,
              required: fieldData['required'] as bool? ?? false,
            );
          }
        }
      }

      pages[pagePath] = PageMeta(
        path: pagePath,
        title: title,
        classes: classes,
        fields: fields,
        ignoredFields: ignoredFields,
        links: links,
        generatedFields: generatedFields,
        note: note,
      );
    }

    return pages;
  }

  PageMeta? page(String pagePath) => _pages[pagePath];
  Iterable<PageMeta> get allPages => _pages.values;
  Set<String> get allPagePaths => _pages.keys.toSet();

  static List<String> _stringList(dynamic value) {
    if (value == null) return [];
    if (value is YamlList) return value.map((e) => e as String).toList();
    return [];
  }
}

/// Writes a stub `_metadata.yaml` seeded with the given pages.
///
/// Preserves any existing entries; only adds missing page paths.
void writeMetadataStubs({
  required String metadataPath,
  required List<PageMeta> stubs,
}) {
  final existing = DocMetadata.load(metadataPath);

  final buf = StringBuffer();
  buf.writeln('# Auto-generated stubs — fill in descriptions.');
  buf.writeln('# Do not remove pages or fields present in the source.');
  buf.writeln('pages:');

  final allPaths = {...existing.allPagePaths, ...stubs.map((s) => s.path)};

  for (final path in allPaths) {
    final existingPage = existing.page(path);
    final stub = stubs.where((s) => s.path == path).firstOrNull;
    final page = existingPage ?? stub!;

    buf.writeln('  ${p.posix.normalize(path)}:');
    buf.writeln('    title: ${_yamlString(page.title)}');
    if (page.classes.isNotEmpty) {
      buf.writeln('    classes: [${page.classes.join(', ')}]');
    }
    if (!page.generatedFields) {
      buf.writeln('    generated_fields: false');
    }
    if (page.note != null) {
      buf.writeln('    note: ${_yamlString(page.note!)}');
    }
    if (page.ignoredFields.isNotEmpty) {
      buf.writeln('    ignored_fields: [${page.ignoredFields.join(', ')}]');
    }
    if (page.links.isNotEmpty) {
      buf.writeln('    links:');
      for (final link in page.links) {
        buf.writeln('      - $link');
      }
    }
    buf.writeln('    fields:');
    for (final field in page.fields.values) {
      buf.writeln('      ${field.name}: ${_yamlString(field.description)}');
    }
  }

  File(metadataPath).writeAsStringSync(buf.toString());
}

String _yamlString(String value) {
  if (value.contains('\n') || value.contains("'")) {
    return '"${value.replaceAll('"', '\\"')}"';
  }
  if (value.isEmpty) return "''";
  return "'$value'";
}
