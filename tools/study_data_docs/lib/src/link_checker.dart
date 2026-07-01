/// Validates relative markdown links inside a docs tree.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

/// A single broken link found during checking.
class BrokenLink {
  final String sourceFile; // relative path of the file containing the link
  final String href; // the raw href value
  final String resolvedPath; // absolute path that was checked

  const BrokenLink({
    required this.sourceFile,
    required this.href,
    required this.resolvedPath,
  });

  @override
  String toString() => '$sourceFile: broken link "$href" → $resolvedPath';
}

/// Checks all relative markdown links inside [docsDir].
///
/// Returns a list of broken links. An empty list means all links resolve.
List<BrokenLink> checkLinks(String docsDir) {
  final brokenLinks = <BrokenLink>[];
  final dir = Directory(docsDir);
  if (!dir.existsSync()) return brokenLinks;

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.md')) continue;

    final content = entity.readAsStringSync();
    final links = _extractMarkdownLinks(content);

    for (final href in links) {
      // Only check relative links.
      if (href.startsWith('http://') ||
          href.startsWith('https://') ||
          href.startsWith('#')) {
        continue;
      }

      // Strip anchor fragments.
      final bareHref = href.contains('#') ? href.split('#').first : href;
      if (bareHref.isEmpty) continue;

      final resolved = p.normalize(p.join(p.dirname(entity.path), bareHref));

      if (!File(resolved).existsSync() && !Directory(resolved).existsSync()) {
        brokenLinks.add(
          BrokenLink(
            sourceFile: entity.path,
            href: href,
            resolvedPath: resolved,
          ),
        );
      }
    }
  }

  return brokenLinks;
}

/// Extracts all href values from `[text](href)` patterns.
List<String> _extractMarkdownLinks(String markdown) {
  final pattern = RegExp(r'\[(?:[^\]]*)\]\(([^)]+)\)');
  return pattern.allMatches(markdown).map((m) => m.group(1)!).toList();
}
