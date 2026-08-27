import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard page fetch marks loaded studies as fetched', () {
    final source = File(
      'lib/repositories/study_repository.dart',
    ).readAsStringSync();

    final fetchPageStart = source.indexOf('Future<StudiesPage> fetchPage({');
    final fetchPageEnd = source.indexOf(
      '\n  @override\n  Future<List<Study>> fetchPinned',
      fetchPageStart,
    );

    expect(fetchPageStart, isNonNegative);
    expect(fetchPageEnd, isNonNegative);

    final fetchPageSource = source.substring(fetchPageStart, fetchPageEnd);

    expect(
      fetchPageSource,
      contains('final wrappedStudies = upsertAllLocally(page.studies);'),
    );
    expect(fetchPageSource, contains('wrappedStudy.markAsFetched();'));
  });

  test('pinned studies fetch marks loaded studies as fetched', () {
    final source = File(
      'lib/repositories/study_repository.dart',
    ).readAsStringSync();

    final fetchPinnedStart = source.indexOf(
      'Future<List<Study>> fetchPinned(Set<String> pinnedIds) async {',
    );
    final fetchPinnedEnd = source.indexOf(
      '\n  @override\n  List<ModelAction> availableActions',
      fetchPinnedStart,
    );

    expect(fetchPinnedStart, isNonNegative);
    expect(fetchPinnedEnd, isNonNegative);

    final fetchPinnedSource = source.substring(
      fetchPinnedStart,
      fetchPinnedEnd,
    );

    expect(
      fetchPinnedSource,
      contains('final wrappedStudies = upsertAllLocally(studies);'),
    );
    expect(fetchPinnedSource, contains('wrappedStudy.markAsFetched();'));
  });

  test('dashboard duplicate actions do not redirect back to studies', () {
    final source = File(
      'lib/repositories/study_repository.dart',
    ).readAsStringSync();

    final duplicateDraftStart = source.indexOf(
      'type: StudyActionType.duplicateDraft,',
    );
    final duplicateStart = source.indexOf('type: StudyActionType.duplicate,');
    final exportDefinitionStart = source.indexOf(
      'type: StudyActionType.exportDefinition,',
    );

    expect(duplicateDraftStart, isNonNegative);
    expect(duplicateStart, isNonNegative);
    expect(exportDefinitionStart, isNonNegative);

    final duplicateActionsSource = source.substring(
      duplicateDraftStart,
      exportDefinitionStart,
    );

    expect(
      duplicateActionsSource,
      contains('onExecute: () => duplicateAndSave(model),'),
    );
    expect(
      duplicateActionsSource,
      isNot(contains('dispatch(RoutingIntents.studies)')),
    );
  });

  test('duplicateAndSave waits for backend persistence before returning', () {
    final source = File(
      'lib/repositories/study_repository.dart',
    ).readAsStringSync();

    final duplicateStart = source.indexOf(
      'Future<void> duplicateAndSave(Study model) async {',
    );
    final duplicateEnd = source.indexOf(
      '\n  @override\n  Future<void> close(Study study)',
      duplicateStart,
    );

    expect(duplicateStart, isNonNegative);
    expect(duplicateEnd, isNonNegative);

    final duplicateSource = source.substring(duplicateStart, duplicateEnd);

    expect(
      duplicateSource,
      contains('await save(duplicate, runOptimistically: false);'),
    );
  });
}
