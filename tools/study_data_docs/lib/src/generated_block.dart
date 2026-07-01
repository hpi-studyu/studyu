/// Manages GENERATED:* block markers inside markdown files.
///
/// Block format:
///   <!-- GENERATED:FIELDS START -->
///   ...content...
///   <!-- GENERATED:FIELDS END -->
///
/// Content between markers is replaced on every `--write` run. Content
/// outside the markers is preserved unchanged.
library;

/// Returns the start marker for [kind].
String startMarker(String kind) => '<!-- GENERATED:$kind START -->';

/// Returns the end marker for [kind].
String endMarker(String kind) => '<!-- GENERATED:$kind END -->';

/// Replaces the content of a named generated block inside [existing] markdown.
///
/// If the block does not exist, it is appended at the end.
/// Returns the updated markdown string.
String replaceBlock({
  required String existing,
  required String kind,
  required String newContent,
}) {
  final start = startMarker(kind);
  final end = endMarker(kind);

  final startIdx = existing.indexOf(start);
  final endIdx = existing.indexOf(end);

  if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
    // Replace content between markers.
    final before = existing.substring(0, startIdx + start.length);
    final after = existing.substring(endIdx);
    return '$before\n$newContent\n$after';
  }

  // Block absent: append it.
  final trimmed = existing.trimRight();
  return '$trimmed\n\n$start\n$newContent\n$end\n';
}

/// Extracts the raw content between markers for [kind] in [markdown].
///
/// Returns null if the block is absent.
String? extractBlock(String markdown, String kind) {
  final start = startMarker(kind);
  final end = endMarker(kind);

  final startIdx = markdown.indexOf(start);
  final endIdx = markdown.indexOf(end);

  if (startIdx == -1 || endIdx == -1 || endIdx <= startIdx) return null;
  return markdown.substring(startIdx + start.length, endIdx).trim();
}

/// Checks that [markdown] contains all required generated blocks for a page
/// that expects [kinds].
List<String> missingBlocks(String markdown, Iterable<String> kinds) {
  return kinds.where((k) => !markdown.contains(startMarker(k))).toList();
}

/// Builds a GENERATED:FIELDS block body for the given field rows.
///
/// [rows] is a list of `(jsonKey, dartType, required, description)` tuples.
String buildFieldsTable(List<FieldRow> rows) {
  if (rows.isEmpty) {
    return '_No JSON-serialisable fields._';
  }

  final buf = StringBuffer();
  buf.writeln('| Field | Type | Required | Description |');
  buf.writeln('|-------|------|----------|-------------|');
  for (final row in rows) {
    final req = row.required ? 'Yes' : 'No';
    buf.write('| `${row.jsonKey}` ');
    buf.write('| `${_escapeType(row.dartType)}` ');
    buf.write('| $req ');
    buf.writeln('| ${row.description} |');
  }
  return buf.toString().trimRight();
}

/// Builds a GENERATED:DISCRIMINATORS block body.
///
/// [entries] maps discriminator field name → wire value.
String buildDiscriminatorsBlock(Map<String, String> entries) {
  if (entries.isEmpty) return '_No discriminator fields._';

  final buf = StringBuffer();
  buf.writeln('| Field | Value |');
  buf.writeln('|-------|-------|');
  for (final entry in entries.entries) {
    buf.writeln('| `${entry.key}` | `${entry.value}` |');
  }
  return buf.toString().trimRight();
}

/// Builds a GENERATED:LINKS block body.
///
/// [links] maps link label → relative markdown href.
String buildLinksBlock(List<LinkEntry> links) {
  if (links.isEmpty) return '_No cross-references._';

  final buf = StringBuffer();
  for (final link in links) {
    buf.writeln('- [${link.label}](${link.href})');
  }
  return buf.toString().trimRight();
}

class FieldRow {
  final String jsonKey;
  final String dartType;
  final bool required;
  final String description;

  const FieldRow({
    required this.jsonKey,
    required this.dartType,
    required this.required,
    required this.description,
  });
}

class LinkEntry {
  final String label;
  final String href;

  const LinkEntry({required this.label, required this.href});
}

String _escapeType(String type) => type.replaceAll('|', '\\|');
