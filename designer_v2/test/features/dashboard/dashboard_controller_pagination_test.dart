// Pagination controller tests must run on the browser platform: the
// dashboard controller transitively imports `lib/features/account/study_import.dart`
// (via study_repository.dart's action callbacks) which uses `dart:js_interop`.
// Run with: `flutter test --platform chrome test/features/dashboard/dashboard_controller_pagination_test.dart`.
@TestOn('browser')
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_navigation.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_to_postgrest.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'dashboard_controller_pagination_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<StudyRepository>(),
  MockSpec<AuthRepository>(),
  MockSpec<UserRepository>(),
  MockSpec<sb.User>(),
])
Study _study(String id, {String? title}) {
  return Study.withId(id)
    ..id = id
    ..title = title ?? 'Study $id'
    ..status = StudyStatus.draft
    ..participation = Participation.invite
    ..resultSharing = ResultSharing.private
    ..registryPublished = false
    ..participantCount = 0
    ..activeSubjectCount = 0
    ..endedCount = 0;
}

class _Harness {
  _Harness({
    Set<String> pinnedIds = const {},
    StudiesPage? initialPage,
    List<Study> initialPinned = const [],
    ({String? sortColumn, bool? sortAscending}) activeSort = (
      sortColumn: null,
      sortAscending: null,
    ),
    StudiesFilter? initialFilter,
  }) {
    studyRepo = MockStudyRepository();
    authRepo = MockAuthRepository();
    userRepo = MockUserRepository();
    user = MockUser();
    when(user.id).thenReturn('me');
    when(user.email).thenReturn('me@x.test');
    studyUUser = StudyUUser(
      id: 'me',
      email: 'me@x.test',
      preferences: Preferences(pinnedStudies: pinnedIds),
    );

    when(authRepo.currentUser).thenReturn(user);
    when(userRepo.fetchUser()).thenAnswer((_) async => studyUUser);
    when(userRepo.user).thenReturn(studyUUser);
    when(userRepo.getCustomPresets()).thenReturn(const []);
    when(
      userRepo.getActiveFilter(any),
    ).thenReturn((presetId: null, filterGroup: null));
    when(userRepo.getActiveSort(any)).thenReturn(activeSort);

    final defaultPage =
        initialPage ?? const StudiesPage(studies: [], totalCount: 0);
    when(
      studyRepo.fetchPage(
        offset: anyNamed('offset'),
        limit: anyNamed('limit'),
        sortBy: anyNamed('sortBy'),
        ascending: anyNamed('ascending'),
        preset: anyNamed('preset'),
        currentUser: anyNamed('currentUser'),
        searchQuery: anyNamed('searchQuery'),
        advancedFilter: anyNamed('advancedFilter'),
        excludeIds: anyNamed('excludeIds'),
      ),
    ).thenAnswer((_) async => defaultPage);

    when(studyRepo.fetchPinned(any)).thenAnswer((_) async => initialPinned);

    container = ProviderContainer(
      overrides: [
        studyRepositoryProvider.overrideWithValue(studyRepo),
        authRepositoryProvider.overrideWithValue(authRepo),
        userRepositoryProvider.overrideWithValue(userRepo),
        dashboardDispatchProvider.overrideWithValue((_) {}),
      ],
    );
    addTearDown(container.dispose);

    container.listen(
      dashboardControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    // Mirror DashboardScreen.initState — the widget always kicks off a
    // setStudiesFilter call (with widget.filter, possibly null) after build.
    // The controller itself no longer drives an initial fetch from build();
    // setStudiesFilter is the single load path.
    // ignore: unawaited_futures
    container
        .read(dashboardControllerProvider.notifier)
        .setStudiesFilter(initialFilter);
  }

  late final MockStudyRepository studyRepo;
  late final MockAuthRepository authRepo;
  late final MockUserRepository userRepo;
  late final MockUser user;
  late final StudyUUser studyUUser;
  late final ProviderContainer container;

  DashboardController get controller =>
      container.read(dashboardControllerProvider.notifier);

  DashboardState get state => container.read(dashboardControllerProvider);

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

void main() {
  group('DashboardController pagination', () {
    test('initial fetch requests page 0 with default params', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(25, (i) => _study('s$i')),
          totalCount: 60,
        ),
      );
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: 0,
          limit: DashboardState.pageSize,
          sortBy: StudiesTableColumn.createdAt,
          ascending: false,
          preset: StudiesFilter.owned,
          currentUser: h.user,
          searchQuery: '',
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(greaterThanOrEqualTo(1));

      expect(h.state.loadedStudies, hasLength(25));
      expect(h.state.totalCount, 60);
      expect(h.state.hasMore, isTrue);
      expect(h.state.isLoadingInitial, isFalse);
    });

    test('keeps the initial count loading until the total is known', () async {
      final h = _Harness();
      final pageCompleter = Completer<StudiesPage>();
      final totalCompleter = Completer<StudiesPage>();
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((invocation) {
        final limit = invocation.namedArguments[#limit] as int;
        return limit == 1 ? totalCompleter.future : pageCompleter.future;
      });

      await Future<void>.delayed(Duration.zero);
      pageCompleter.complete(
        StudiesPage(studies: [_study('s1')], totalCount: 4),
      );
      await h.settle();

      expect(h.state.loadedStudies, hasLength(1));
      expect(h.state.isLoadingInitial, isTrue);

      totalCompleter.complete(const StudiesPage(studies: [], totalCount: 4));
      await h.settle();

      expect(h.state.isLoadingInitial, isFalse);
      expect(h.state.displayTotalStudyCount, 4);
    });

    test('hasMore is false when total <= loaded', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(10, (i) => _study('s$i')),
          totalCount: 10,
        ),
      );
      await h.settle();
      expect(h.state.hasMore, isFalse);
    });

    test('loadMore appends next page with offset', () async {
      final h = _Harness();
      // First call: full page.
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer(
        (inv) async => StudiesPage(
          studies: List.generate(
            25,
            (i) => _study('s${(inv.namedArguments[#offset] as int) + i}'),
          ),
          totalCount: 60,
        ),
      );
      await h.settle();
      expect(h.state.loadedStudies.first.id, 's0');

      await h.controller.loadMore();
      await h.settle();

      expect(h.state.loadedStudies, hasLength(50));
      expect(h.state.loadedStudies[25].id, 's25');
      expect(h.state.hasMore, isTrue);
    });

    test('loadMore is a no-op when hasMore is false', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(5, (i) => _study('s$i')),
          totalCount: 5,
        ),
      );
      await h.settle();
      clearInteractions(h.studyRepo);

      await h.controller.loadMore();
      await h.settle();

      verifyNever(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      );
    });

    test('loadMore is a no-op while a load is in flight', () async {
      final h = _Harness();
      final firstPage = StudiesPage(
        studies: List.generate(25, (i) => _study('s$i')),
        totalCount: 100,
      );
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) async => firstPage);
      await h.settle();
      clearInteractions(h.studyRepo);

      // Hold the next page open via a manual completer.
      final completer = Completer<StudiesPage>();
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) => completer.future);

      // Two rapid loadMore calls — only the first should hit the repo.
      // ignore: unawaited_futures
      h.controller.loadMore();
      // ignore: unawaited_futures
      h.controller.loadMore();
      await Future<void>.delayed(Duration.zero);

      verify(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(1);

      completer.complete(
        StudiesPage(
          studies: List.generate(25, (i) => _study('p${i + 25}')),
          totalCount: 100,
        ),
      );
    });

    test('setSorting resets pagination and reloads with new sort', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(25, (i) => _study('s$i')),
          totalCount: 100,
        ),
      );
      await h.settle();
      clearInteractions(h.studyRepo);

      h.controller.setSorting(StudiesTableColumn.title, true);
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: 0,
          limit: DashboardState.pageSize,
          sortBy: StudiesTableColumn.title,
          ascending: true,
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(1);
      expect(h.state.sortByColumn, StudiesTableColumn.title);
      expect(h.state.sortAscending, isTrue);
    });

    test(
      'setStudiesFilter resets pagination and reloads with new preset',
      () async {
        final h = _Harness();
        await h.settle();
        clearInteractions(h.studyRepo);

        await h.controller.setStudiesFilter(StudiesFilter.public);
        await h.settle();

        verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: DashboardState.pageSize,
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: StudiesFilter.public,
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(1);
        expect(h.state.studiesFilter, StudiesFilter.public);
      },
    );

    test('search query change is debounced before triggering reload', () async {
      final h = _Harness();
      await h.settle();
      clearInteractions(h.studyRepo);

      await h.controller.filterStudies('foo');
      // Just after triggering, no fetch should have fired yet.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      verifyNever(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 350));
      verify(
        h.studyRepo.fetchPage(
          offset: 0,
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: 'foo',
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(1);
    });

    test(
      'rapid keystrokes only trigger one fetch (debounce coalesces)',
      () async {
        final h = _Harness();
        await h.settle();
        clearInteractions(h.studyRepo);

        await h.controller.filterStudies('f');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await h.controller.filterStudies('fo');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await h.controller.filterStudies('foo');
        await Future<void>.delayed(const Duration(milliseconds: 400));

        verify(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: 'foo',
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(1);
      },
    );

    test('stale fetch responses are discarded by token mechanism', () async {
      final h = _Harness();
      await h.settle();
      clearInteractions(h.studyRepo);

      // First reload (filter=public) — will be intentionally slow.
      final slowCompleter = Completer<StudiesPage>();
      // Second reload (filter=all) — fast.
      final fastPage = StudiesPage(
        studies: [_study('fast1'), _study('fast2')],
        totalCount: 2,
      );

      var callIndex = 0;
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) {
        callIndex++;
        if (callIndex == 1) return slowCompleter.future;
        return Future.value(fastPage);
      });

      // Kick off the slow reload.
      // ignore: unawaited_futures
      h.controller.setStudiesFilter(StudiesFilter.public);
      await Future<void>.delayed(Duration.zero);

      // Trigger the second reload while the first is still pending.
      // ignore: unawaited_futures
      h.controller.setStudiesFilter(StudiesFilter.all);
      await h.settle();

      expect(h.state.loadedStudies.map((s) => s.id), ['fast1', 'fast2']);

      // Now resolve the slow first call — its result must NOT overwrite state.
      slowCompleter.complete(
        StudiesPage(studies: [_study('slow1'), _study('slow2')], totalCount: 2),
      );
      await h.settle();
      expect(h.state.loadedStudies.map((s) => s.id), ['fast1', 'fast2']);
    });

    test(
      'UnsupportedFilterException flips advancedFilterUnsupported',
      () async {
        final h = _Harness();
        await h.settle();
        clearInteractions(h.studyRepo);

        when(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).thenAnswer(
          (_) async => throw const UnsupportedFilterException('missedDays'),
        );

        await h.controller.updateFilter(
          FilterGroup(
            children: [
              FilterCondition(
                property: StudyProperty.missedDays,
                operator: FilterOperator.greaterThan,
                value: 5,
              ),
            ],
          ),
        );
        await h.settle();

        expect(h.state.advancedFilterUnsupported, isTrue);
        expect(h.state.loadedStudies, isEmpty);
        expect(h.state.hasMore, isFalse);
      },
    );

    test('pinStudy moves a loaded study locally without reloading', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: [_study('a'), _study('b'), _study('c')],
          totalCount: 3,
        ),
      );
      await h.settle();

      final updatedUser = StudyUUser(
        id: 'me',
        email: 'me@x.test',
        preferences: Preferences(pinnedStudies: {'b'}),
      );
      when(h.userRepo.updatePreferences(any, any)).thenAnswer((_) async {
        when(h.userRepo.user).thenReturn(updatedUser);
        return updatedUser;
      });
      clearInteractions(h.studyRepo);

      await h.controller.pinStudy('b');

      expect(h.state.loadedStudies.map((s) => s.id), ['a', 'c']);
      expect(h.state.pinnedStudiesList.map((s) => s.id), ['b']);
      expect(h.state.totalCount, 2);
      expect(h.state.pageTotalCount, 2);
      expect(h.state.hasMore, isFalse);
      verifyNever(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      );
      verifyNever(h.studyRepo.fetchPinned(any));
    });

    test('pinStudy reloads when the study is not loaded', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: [_study('a'), _study('b')],
          totalCount: 2,
        ),
      );
      await h.settle();

      final updatedUser = StudyUUser(
        id: 'me',
        email: 'me@x.test',
        preferences: Preferences(pinnedStudies: {'missing'}),
      );
      when(h.userRepo.updatePreferences(any, any)).thenAnswer((_) async {
        when(h.userRepo.user).thenReturn(updatedUser);
        return updatedUser;
      });
      when(
        h.studyRepo.fetchPinned(any),
      ).thenAnswer((_) async => [_study('missing')]);
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer(
        (_) async =>
            StudiesPage(studies: [_study('a'), _study('b')], totalCount: 2),
      );
      clearInteractions(h.studyRepo);

      await h.controller.pinStudy('missing');
      await h.settle();

      verify(h.studyRepo.fetchPinned(any)).called(1);
      verify(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(greaterThanOrEqualTo(1));
      expect(h.state.pinnedStudiesList.map((s) => s.id), ['missing']);
    });

    test('pinOffStudy keeps the full reload behavior', () async {
      final h = _Harness(
        pinnedIds: {'p'},
        initialPage: StudiesPage(studies: [_study('a')], totalCount: 1),
        initialPinned: [_study('p')],
      );
      await h.settle();

      final updatedUser = StudyUUser(
        id: 'me',
        email: 'me@x.test',
        preferences: Preferences(),
      );
      when(h.userRepo.updatePreferences(any, any)).thenAnswer((_) async {
        when(h.userRepo.user).thenReturn(updatedUser);
        return updatedUser;
      });
      when(h.studyRepo.fetchPinned(any)).thenAnswer((_) async => const []);
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer(
        (_) async =>
            StudiesPage(studies: [_study('p'), _study('a')], totalCount: 2),
      );
      clearInteractions(h.studyRepo);

      await h.controller.pinOffStudy('p');
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(greaterThanOrEqualTo(1));
      expect(h.state.pinnedStudiesList, isEmpty);
      expect(h.state.loadedStudies.map((s) => s.id), ['p', 'a']);
    });

    test(
      'initial fetch excludes pinned ids from the paginated query',
      () async {
        final h = _Harness(
          pinnedIds: {'pinA', 'pinB'},
          initialPinned: [_study('pinA'), _study('pinB')],
        );
        await h.settle();

        final captured = verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: captureAnyNamed('excludeIds'),
          ),
        ).captured;
        final excludeIds = captured.last as List<String>;
        expect(excludeIds, containsAll(<String>['pinA', 'pinB']));
        expect(h.state.pinnedStudiesList.map((s) => s.id), ['pinA', 'pinB']);
      },
    );

    test('setSorting persists sort to user preferences', () async {
      final h = _Harness();
      when(
        h.userRepo.saveActiveSort(
          page: anyNamed('page'),
          sortColumn: anyNamed('sortColumn'),
          sortAscending: anyNamed('sortAscending'),
        ),
      ).thenAnswer((_) async => h.studyUUser);
      await h.settle();

      h.controller.setSorting(StudiesTableColumn.title, true);
      await h.settle();

      verify(
        h.userRepo.saveActiveSort(
          page: 'my_studies',
          sortColumn: 'title',
          sortAscending: true,
        ),
      ).called(1);
    });

    test(
      'initial load restores persisted sort and uses it for fetch',
      () async {
        final h = _Harness(
          activeSort: (sortColumn: 'title', sortAscending: true),
        );
        await h.settle();

        expect(h.state.sortByColumn, StudiesTableColumn.title);
        expect(h.state.sortAscending, isTrue);
        verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: anyNamed('limit'),
            sortBy: StudiesTableColumn.title,
            ascending: true,
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    test('unknown persisted sort column falls back to default', () async {
      final h = _Harness(
        activeSort: (sortColumn: 'someRemovedColumn', sortAscending: true),
      );
      await h.settle();

      expect(h.state.sortByColumn, StudiesTableColumn.createdAt);
      expect(h.state.sortAscending, isFalse);
    });

    test('controller does not double-fetch on first build (no race with '
        'setStudiesFilter)', () async {
      // Regression: previously, build() -> _loadInitial -> _resetAndReload
      // raced against initState's setStudiesFilter(widget.filter), firing
      // two HTTP fetches per navigation. The fix routes the single load
      // through setStudiesFilter only.
      final h = _Harness();
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(2);
    });
  });
}
