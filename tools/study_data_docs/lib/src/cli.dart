/// Core CLI logic: orchestrates scanning, writing, and drift checking.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:study_data_docs/src/doc_metadata.dart';
import 'package:study_data_docs/src/generated_block.dart';
import 'package:study_data_docs/src/link_checker.dart';
import 'package:study_data_docs/src/markdown_writer.dart';
import 'package:study_data_docs/src/model_scanner.dart';
import 'package:study_data_docs/src/page_scope.dart';

const String _kDefaultMetadataFile = 'core/docs/study-data/_metadata.yaml';
const String _kDefaultDocsDir = 'core/docs/study-data';
const String _kModelsDir = 'core/lib/src/models';

/// Resolves the repo root using `git rev-parse --show-toplevel`.
Future<String> resolveRepoRoot() async {
  final result = await Process.run('git', ['rev-parse', '--show-toplevel']);
  if (result.exitCode != 0) {
    throw StateError('Cannot resolve repo root: ${result.stderr}');
  }
  return (result.stdout as String).trim();
}

/// Runs `--write`: generates/updates the full docs tree.
Future<void> runWrite({
  required String repoRoot,
  String? metadataPathOverride,
  String? docsDirOverride,
}) async {
  final metadataPath = p.join(
    repoRoot,
    metadataPathOverride ?? _kDefaultMetadataFile,
  );
  final docsDir = p.join(repoRoot, docsDirOverride ?? _kDefaultDocsDir);
  final modelsDir = p.join(repoRoot, _kModelsDir);

  stdout.writeln('[write] Scanning models from $modelsDir …');
  final scannedClasses = await scanModels(
    modelsDir: modelsDir,
    repoRoot: repoRoot,
  );

  final meta = DocMetadata.load(metadataPath);

  var written = 0;
  for (final pagePath in allPagePaths) {
    final pageMeta = meta.page(pagePath);
    if (pageMeta == null) {
      stderr.writeln(
        '[write] WARNING: No metadata for page $pagePath — skipping.',
      );
      continue;
    }

    final entries = entriesForPage(pagePath);
    final classes = entries
        .map((e) => scannedClasses[e.className])
        .whereType<ScannedClass>()
        .toList();

    writePage(
      docsDir: docsDir,
      pagePath: pagePath,
      meta: pageMeta,
      classes: classes,
    );
    written++;
  }

  _writeIndexPage(docsDir: docsDir, meta: meta);

  stdout.writeln('[write] Done — $written pages written.');
}

/// Runs `--check`: exits non-zero if docs drift from what `--write` would produce.
Future<void> runCheck({
  required String repoRoot,
  String? metadataPathOverride,
  String? docsDirOverride,
}) async {
  final metadataPath = p.join(
    repoRoot,
    metadataPathOverride ?? _kDefaultMetadataFile,
  );
  final docsDir = p.join(repoRoot, docsDirOverride ?? _kDefaultDocsDir);
  final modelsDir = p.join(repoRoot, _kModelsDir);

  final errors = <String>[];

  if (!File(metadataPath).existsSync()) {
    stderr.writeln('[check] FAIL: Metadata file not found: $metadataPath');
    exit(1);
  }

  final meta = DocMetadata.load(metadataPath);

  stdout.writeln('[check] Scanning models …');
  final scannedClasses = await scanModels(
    modelsDir: modelsDir,
    repoRoot: repoRoot,
  );

  // 1. Every canonical page must have a metadata entry.
  for (final pagePath in allPagePaths) {
    if (meta.page(pagePath) == null) {
      errors.add('Missing metadata entry for page: $pagePath');
    }
  }

  // 2. Every metadata page must be in the canonical scope.
  for (final pagePath in meta.allPagePaths) {
    if (!allPagePaths.contains(pagePath)) {
      errors.add(
        'Metadata has page "$pagePath" not in canonical scope. '
        'Remove it or add it to page_scope.dart.',
      );
    }
  }

  // 3. Check drift in generated blocks.
  for (final pagePath in allPagePaths) {
    final pageMeta = meta.page(pagePath);
    if (pageMeta == null) continue;

    final absPath = p.join(docsDir, pagePath);
    final file = File(absPath);

    if (!file.existsSync()) {
      errors.add('Docs page missing: $pagePath — run --write to generate it.');
      continue;
    }

    final existing = file.readAsStringSync();
    final entries = entriesForPage(pagePath);
    final classes = entries
        .map((e) => scannedClasses[e.className])
        .whereType<ScannedClass>()
        .toList();

    // Check FIELDS block drift.
    if (pageMeta.generatedFields && entries.any((e) => e.generatedFields)) {
      final expectedRows = _buildExpectedFieldRows(classes, pageMeta);
      final expectedContent = buildFieldsTable(expectedRows);
      final currentContent = extractBlock(existing, 'FIELDS');

      if (currentContent == null) {
        errors.add('$pagePath: missing GENERATED:FIELDS block.');
      } else if (currentContent.trim() != expectedContent.trim()) {
        errors.add(
          '$pagePath: GENERATED:FIELDS block is out of date. Run --write.',
        );
      }

      // Check that every serialisable field has a description.
      for (final cls in classes) {
        for (final field in cls.fields) {
          if (!field.includeInJson) continue;
          if (pageMeta.ignoredFields.contains(field.name) ||
              pageMeta.ignoredFields.contains(field.jsonKey)) {
            continue;
          }
          final hasMeta =
              pageMeta.fields.containsKey(field.name) ||
              pageMeta.fields.containsKey(field.jsonKey);
          if (!hasMeta) {
            errors.add(
              '$pagePath: field "${field.name}" (json: "${field.jsonKey}") '
              'has no description in _metadata.yaml and is not in ignoredFields.',
            );
          }
        }
      }
    }

    // Check DISCRIMINATORS block drift.
    final discriminators = <String, String>{};
    for (final cls in classes) {
      discriminators.addAll(cls.discriminatorValues);
    }
    if (discriminators.isNotEmpty) {
      final expectedContent = buildDiscriminatorsBlock(discriminators);
      final currentContent = extractBlock(existing, 'DISCRIMINATORS');
      if (currentContent == null) {
        errors.add('$pagePath: missing GENERATED:DISCRIMINATORS block.');
      } else if (currentContent.trim() != expectedContent.trim()) {
        errors.add(
          '$pagePath: GENERATED:DISCRIMINATORS block is out of date. Run --write.',
        );
      }
    }

    // Check page title matches metadata.
    final firstHeadingMatch = RegExp(
      r'^#\s+(.+)$',
      multiLine: true,
    ).firstMatch(existing);
    if (firstHeadingMatch != null) {
      final heading = firstHeadingMatch.group(1)!.trim();
      if (heading != pageMeta.title) {
        errors.add(
          '$pagePath: first heading "$heading" does not match '
          'metadata title "${pageMeta.title}".',
        );
      }
    }

    // Check LINKS block drift.
    if (pageMeta.links.isNotEmpty) {
      final linkEntries = _buildExpectedLinkEntries(pageMeta.links, pagePath);
      final expectedContent = buildLinksBlock(linkEntries);
      final currentContent = extractBlock(existing, 'LINKS');
      if (currentContent == null) {
        errors.add('$pagePath: missing GENERATED:LINKS block.');
      } else if (currentContent.trim() != expectedContent.trim()) {
        errors.add(
          '$pagePath: GENERATED:LINKS block is out of date. Run --write.',
        );
      }
    }
  }

  // 4. Check no orphaned pages exist in the docs tree.
  final docsDirectory = Directory(docsDir);
  if (docsDirectory.existsSync()) {
    for (final entity in docsDirectory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.md')) continue;
      final rel = p.relative(entity.path, from: docsDir);
      if (rel == 'index.md') continue;
      if (!allPagePaths.contains(rel)) {
        errors.add(
          'Orphaned page in docs tree: $rel — '
          'add to page_scope.dart or delete the file.',
        );
      }
    }
  }

  // 5. Check relative links.
  final brokenLinks = checkLinks(docsDir);
  for (final link in brokenLinks) {
    errors.add(link.toString());
  }

  if (errors.isEmpty) {
    stdout.writeln('[check] OK — no drift detected.');
    exit(0);
  } else {
    stderr.writeln('[check] FAIL — ${errors.length} issue(s):');
    for (final e in errors) {
      stderr.writeln('  • $e');
    }
    exit(1);
  }
}

void _writeIndexPage({required String docsDir, required DocMetadata meta}) {
  final absPath = p.join(docsDir, 'index.md');
  final file = File(absPath);
  if (file.existsSync()) return;

  final buf = StringBuffer();
  buf.writeln('# Study Data Reference');
  buf.writeln();
  buf.writeln(
    'This directory documents the JSON-serialisable data models in '
    '`studyu_core`. Generated field tables come from source; prose sections '
    'are written by hand.',
  );
  buf.writeln();
  buf.writeln('## Pages');
  buf.writeln();

  final sections = <String, List<String>>{};
  for (final pagePath in allPagePaths) {
    final dir = p.posix.dirname(pagePath);
    sections.putIfAbsent(dir, () => []).add(pagePath);
  }

  for (final section in sections.keys.toList()..sort()) {
    buf.writeln('### $section');
    for (final path in sections[section]!) {
      final label = _pageLabelFromPath(path);
      buf.writeln('- [$label]($path)');
    }
    buf.writeln();
  }

  file.writeAsStringSync(buf.toString());
}

List<FieldRow> _buildExpectedFieldRows(
  List<ScannedClass> classes,
  PageMeta meta,
) {
  final rows = <FieldRow>[];
  final seen = <String>{};

  for (final cls in classes) {
    for (final field in cls.fields) {
      if (!field.includeInJson) continue;
      if (seen.contains(field.jsonKey)) continue;
      if (meta.ignoredFields.contains(field.name) ||
          meta.ignoredFields.contains(field.jsonKey)) {
        continue;
      }
      seen.add(field.jsonKey);

      final fieldMeta = meta.fields[field.name] ?? meta.fields[field.jsonKey];
      final description = fieldMeta?.description ?? '';

      rows.add(
        FieldRow(
          jsonKey: field.jsonKey,
          dartType: field.dartType,
          required: field.required,
          description: description,
        ),
      );
    }
  }

  for (final fieldMeta in meta.fields.values) {
    if (fieldMeta.virtual && !seen.contains(fieldMeta.name)) {
      rows.add(
        FieldRow(
          jsonKey: fieldMeta.name,
          dartType: fieldMeta.type ?? 'unknown',
          required: fieldMeta.required,
          description: fieldMeta.description,
        ),
      );
    }
  }

  return rows;
}

List<LinkEntry> _buildExpectedLinkEntries(
  List<String> targetPaths,
  String currentPagePath,
) {
  return targetPaths.map((target) {
    final relHref = _relativeLink(currentPagePath, target);
    final label = _pageLabelFromPath(target);
    return LinkEntry(label: label, href: relHref);
  }).toList();
}

String _relativeLink(String from, String to) {
  final fromDir = p.dirname(from);
  return p.posix.relative(to, from: fromDir);
}

String _pageLabelFromPath(String pagePath) {
  final name = p.basenameWithoutExtension(pagePath);
  return name
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
