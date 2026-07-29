import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

void main() {
  testWidgets('saved meal edit updates name and ordered composition', (
    tester,
  ) async {
    final component = _food('component', 'Apple');
    final meal = _food('meal', 'Fruit bowl')
      ..entryType = FoodEntryType.meal
      ..componentFoods = [
        FoodComposition(
          id: 'composition',
          parentEntryId: 'meal-entry',
          foodId: component.foodId,
          amount: 1,
          unit: 'serving',
          sortOrder: 0,
        ),
      ]
      ..componentSnapshots = [component];
    final template = SavedFoodTemplate(
      id: meal.foodId,
      userId: 'subject',
      name: meal.name,
      isPublic: false,
      createdAt: DateTime.utc(2026, 7, 15),
      prototype: meal,
    );
    final repository = _LibraryRepository(template);
    final viewModel = TemplateViewModel(
      userId: 'subject',
      repository: repository,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: Scaffold(body: FoodLibraryItemCard(template: template)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fruit bowl'));
    await tester.pumpAndSettle();

    expect(find.byType(MealCreatorScreen), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Meal Name *'),
      'Updated bowl',
    );
    await tester.tap(find.byTooltip('Edit amount'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '2');
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(repository.saved, isNotNull);
    expect(repository.saved!.foodId, 'meal-definition');
    expect(repository.saved!.name, 'Updated bowl');
    expect(repository.saved!.componentFoods!.single.amount, 2);
    expect(repository.saved!.componentFoods!.single.sortOrder, 0);
    expect(
      repository.saved!.componentSnapshots!.single.foodId,
      'component-definition',
    );
    expect(repository.saved!.componentSnapshots!.single.amount, 2);
    expect(repository.expectedVersionId, 'meal-version');
  });
}

class _LibraryRepository extends NutritionFoodRepository {
  _LibraryRepository(this.template);

  final SavedFoodTemplate template;
  FoodEntry? saved;
  String? expectedVersionId;

  @override
  Future<List<SavedFoodTemplate>> loadTemplates(String subjectId) async => [
    template,
  ];

  @override
  Future<SavedFoodTemplate> saveTemplate({
    required String subjectId,
    required String name,
    required FoodEntry food,
    List<String>? tags,
    String? expectedVersionId,
  }) async {
    saved = FoodEntry.fromJson(food.toJson());
    this.expectedVersionId = expectedVersionId;
    return SavedFoodTemplate(
      id: food.foodId,
      userId: subjectId,
      name: name,
      isPublic: false,
      createdAt: template.createdAt,
      prototype: saved!,
    );
  }
}

FoodEntry _food(String id, String name) => FoodEntry(
  id: '$id-entry',
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 1,
    carbs: 1,
    fat: 1,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {},
);
