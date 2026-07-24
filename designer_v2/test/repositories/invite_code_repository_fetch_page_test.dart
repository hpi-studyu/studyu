import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetchPage marks fetched invites as persisted', () {
    final packageRootFile = File(
      'lib/repositories/invite_code_repository.dart',
    );
    final repoRootFile = File(
      'designer_v2/lib/repositories/invite_code_repository.dart',
    );
    final source = packageRootFile.existsSync()
        ? packageRootFile.readAsStringSync()
        : repoRootFile.readAsStringSync();

    final classStart = source.indexOf('class InviteCodeRepository');
    final fetchPageStart = source.indexOf(
      'Future<List<StudyInvite>> fetchPage',
      classStart,
    );
    final fetchPageEnd = source.indexOf('\n  @override', fetchPageStart + 1);

    expect(fetchPageStart, isNonNegative);
    expect(fetchPageEnd, isNonNegative);

    final fetchPageSource = source.substring(fetchPageStart, fetchPageEnd);

    expect(fetchPageSource, contains('wrappedInvite.markAsFetched();'));
  });
}
