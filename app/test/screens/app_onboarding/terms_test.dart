import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('pops terms when a selected study has a previous route', () {
    final state = AppState()..selectedStudy = Study('study-1', 'owner-1');

    expect(routeAfterTerms(state, canPop: true), isNull);
  });

  test('opens study overview when selected study terms cannot pop', () {
    final state = AppState()..selectedStudy = Study('study-1', 'owner-1');

    expect(
      routeAfterTerms(state, canPop: false),
      '/${RouteNames.studyOverview}',
    );
  });

  test('opens study selection without a selected study', () {
    expect(
      routeAfterTerms(AppState(), canPop: false),
      '/${RouteNames.studySelection}',
    );
  });
}
