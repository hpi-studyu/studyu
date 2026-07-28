import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_history_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('opens a legacy history record as read-only', (tester) async {
    final now = DateTime.now();
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = now.subtract(const Duration(days: 3));
    final currentStudyDay = subject.getDayOfStudyFor(now);
    final recall = DailyRecall(
      id: 'legacy-recall',
      date: now.subtract(const Duration(days: 2)),
      recallMode: RecallMode.realtimeRecord,
      entryStartedAt: now.subtract(const Duration(days: 2)),
      meals: [],
      studyDaySnapshot: currentStudyDay - 2,
    );
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        interventionId: 'intervention',
        taskId: 'task',
        resultType: 'DailyRecall',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: null,
          result: recall,
        ),
      )..completedAt = now.subtract(const Duration(days: 2)),
    );
    final task = NutritionTask.withId()..id = 'task';
    NutritionRecallRecord? opened;
    bool? editable;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: NutritionHistoryScreen(
          subject: subject,
          task: task,
          onOpenRecall: (record, canEdit) {
            opened = record;
            editable = canEdit;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final date = MaterialLocalizations.of(
      tester.element(find.byType(NutritionHistoryScreen)),
    ).formatMediumDate(recall.date);
    await tester.tap(find.text(date));

    expect(opened?.recall.id, recall.id);
    expect(editable, isFalse);
  });
}
