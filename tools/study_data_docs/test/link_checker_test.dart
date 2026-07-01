import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:study_data_docs/src/link_checker.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('link_checker_test_');
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  test('returns no broken links when all targets exist', () {
    File(p.join(tmp.path, 'a.md')).writeAsStringSync('# A\n\n[B](b.md)\n');
    File(p.join(tmp.path, 'b.md')).writeAsStringSync('# B\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('finds broken relative links', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[Missing](missing.md)\n');

    final broken = checkLinks(tmp.path);
    expect(broken.length, equals(1));
    expect(broken.first.href, equals('missing.md'));
  });

  test('ignores http(s) links', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[External](https://example.com)\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('ignores anchor-only links', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[Heading](#section)\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('strips anchors before resolving', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[B](b.md#section)\n');
    File(p.join(tmp.path, 'b.md')).writeAsStringSync('# B\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });
}
