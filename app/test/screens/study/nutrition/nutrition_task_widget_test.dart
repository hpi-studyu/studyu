import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_core/core.dart';

Widget nutritionTaskApp(NutritionTask task) => ChangeNotifierProvider(
  create: (_) => AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: NutritionTaskWidget(
      task: task,
      completionPeriod: CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      ),
    ),
  ),
);

NutritionTask nutritionTask({String? instructions, int? minimumMeals}) =>
    NutritionTask.withId()
      ..title = 'Nutrition'
      ..instructions = instructions
      ..minimumMealsRequired = minimumMeals;

void main() {
  testWidgets('hides blank nutrition instructions', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(instructions: '   ')),
    );
    await tester.pump();

    expect(find.text('Instructions'), findsNothing);
  });

  testWidgets('shows nutrition instructions without a collapsed section', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(instructions: 'Record every meal.')),
    );
    await tester.pump();

    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Record every meal.'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
  });

  testWidgets(
    'shows the minimum meal requirement without custom instructions',
    (tester) async {
      await tester.pumpWidget(nutritionTaskApp(nutritionTask(minimumMeals: 2)));
      await tester.pump();

      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Please record at least 2 meal(s)'), findsOneWidget);
    },
  );
}
