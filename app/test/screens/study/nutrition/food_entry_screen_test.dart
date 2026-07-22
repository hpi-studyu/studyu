import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_core/core.dart';

Widget foodEntryApp({
  FoodEntry? existingFood,
  bool showSearchAction = true,
  ValueChanged<FoodEntry?>? onResult,
}) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: const Locale('en'),
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<FoodEntry>(
              FoodEntryScreen.route(
                existingFood: existingFood,
                showSearchAction: showSearchAction,
              ),
            );
            onResult?.call(result);
          },
          child: const Text('Open food'),
        ),
      ),
    ),
  ),
);

Future<void> openFoodEntry(
  WidgetTester tester, {
  FoodEntry? existingFood,
  bool showSearchAction = true,
  ValueChanged<FoodEntry?>? onResult,
}) async {
  await tester.pumpWidget(
    foodEntryApp(
      existingFood: existingFood,
      showSearchAction: showSearchAction,
      onResult: onResult,
    ),
  );
  await tester.tap(find.text('Open food'));
  await tester.pumpAndSettle();
}

FoodEntry existingOffFood(Map<String, dynamic> originalValues) {
  return FoodEntry(
    id: 'off-food',
    entryType: FoodEntryType.brandedProduct,
    name: 'Original product',
    brandName: 'Brand',
    description: 'Source description',
    amount: 1,
    unit: 'bar',
    servingSizeGrams: 42,
    portionReference: 'one bar',
    portionEstimationMethod: PortionEstimationMethod.standardUnit,
    portionState: PortionState.asServed,
    yieldFactor: 0.9,
    ediblePortion: 0.8,
    nutrition: NutritionProfile(
      energyKcal: 200,
      protein: 5,
      carbs: 20,
      fat: 10,
      sugars: 8,
      fiber: 3,
      saturatedFat: 4,
      transFat: 0.5,
      cholesterol: 7,
      sodium: 100,
      waterContent: 12,
      micros: {'iron': 2},
    ),
    foodCode: 'off-code',
    externalId: 'off-external-id',
    source: FoodSource.openfoodfacts,
    confidenceScore: 0.73,
    templateId: 'template-id',
    createdAt: DateTime.utc(2025, 1, 2, 3, 4),
    modifiedAt: DateTime.utc(2025, 2, 3),
    originalValues: originalValues,
    parentRecipeId: 'parent-recipe-id',
    recipeMetadata: RecipeMetadata(
      rawWeight: 100,
      cookedWeight: 80,
      yieldFactor: 0.8,
      preparationMethod: 'baked',
      retentionFactors: {'protein': 0.9},
    ),
    recipeIngredients: [
      RecipeComposition(
        id: 'composition-id',
        recipeId: 'recipe-id',
        ingredientId: 'ingredient-id',
        amount: 1,
        unit: 'piece',
      ),
    ],
  );
}

Finder inputWithLabel(String label) => find
    .ancestor(
      of: find.textContaining(label),
      matching: find.byType(TextFormField),
    )
    .first;

Finder decoratorWithLabel(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is InputDecorator &&
      widget.decoration.labelText?.contains(label) == true,
);

void main() {
  testWidgets('shows database search outside the search flow', (tester) async {
    await openFoodEntry(tester);

    expect(find.byTooltip('Search Food Database'), findsOneWidget);
  });

  testWidgets('does not open nested search from the search flow', (
    tester,
  ) async {
    await openFoodEntry(tester, showSearchAction: false);

    expect(find.byTooltip('Search Food Database'), findsNothing);
  });

  testWidgets('editing preserves food identity and source provenance', (
    tester,
  ) async {
    const imageUrl = 'https://images.openfoodfacts.org/product.jpg';
    final originalValues = <String, dynamic>{
      'image_front_small_url': imageUrl,
      'source_name': 'Open Food Facts',
    };
    final existingFood = existingOffFood(originalValues);
    FoodEntry? result;

    await openFoodEntry(
      tester,
      existingFood: existingFood,
      onResult: (value) => result = value,
    );

    await tester.enterText(inputWithLabel('Food Name'), 'Edited product');
    await tester.enterText(inputWithLabel('Amount'), '2');
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.name, 'Edited product');
    expect(result!.amount, 2);
    expect(result!.id, existingFood.id);
    expect(result!.createdAt, existingFood.createdAt);
    expect(result!.modifiedAt, isNotNull);
    expect(result!.modifiedAt, isNot(existingFood.modifiedAt));
    expect(result!.foodCode, existingFood.foodCode);
    expect(result!.externalId, existingFood.externalId);
    expect(result!.source, existingFood.source);
    expect(result!.confidenceScore, existingFood.confidenceScore);
    expect(result!.templateId, existingFood.templateId);
    expect(result!.originalValues, same(originalValues));
    expect(result!.parentRecipeId, existingFood.parentRecipeId);
    expect(result!.recipeMetadata, same(existingFood.recipeMetadata));
    expect(result!.recipeIngredients, same(existingFood.recipeIngredients));
    expect(result!.nutrition.transFat, existingFood.nutrition.transFat);
    expect(result!.nutrition.cholesterol, existingFood.nutrition.cholesterol);
    expect(result!.nutrition.waterContent, existingFood.nutrition.waterContent);
    expect(result!.nutrition.micros, same(existingFood.nutrition.micros));
  });

  testWidgets('missing or malformed image values render no product image', (
    tester,
  ) async {
    await openFoodEntry(tester, existingFood: existingOffFood(const {}));
    expect(find.byType(Image), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await openFoodEntry(
      tester,
      existingFood: existingOffFood(const {'image_front_small_url': 42}),
    );
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('failed product image leaves no empty space', (tester) async {
    await openFoodEntry(
      tester,
      existingFood: existingOffFood(const {
        'image_front_small_url': 'https://example.invalid/image.jpg',
      }),
    );
    final failedImageCardTop = tester.getTopLeft(find.byType(Card).first).dy;

    await tester.pageBack();
    await tester.pumpAndSettle();
    await openFoodEntry(tester, existingFood: existingOffFood(const {}));
    final absentImageCardTop = tester.getTopLeft(find.byType(Card).first).dy;

    expect(failedImageCardTop, absentImageCardTop);
  });

  testWidgets('uses themed cards and unfilled field decorations', (
    tester,
  ) async {
    await openFoodEntry(tester, existingFood: existingOffFood(const {}));

    final cards = tester.widgetList<Card>(find.byType(Card));
    expect(cards, hasLength(3));
    for (final card in cards) {
      expect(card.color, isNull);
      expect(card.elevation, isNull);
    }

    expect(
      tester
          .widget<InputDecorator>(decoratorWithLabel('Food Name'))
          .decoration
          .filled,
      isNot(true),
    );

    await tester.tap(find.text('Detailed Nutrition'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<InputDecorator>(decoratorWithLabel('Fiber'))
          .decoration
          .filled,
      isNot(true),
    );

    await tester.scrollUntilVisible(
      find.text('Advanced Options'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Advanced Options'));
    await tester.pumpAndSettle();
    final entryType = tester.widget<InputDecorator>(
      decoratorWithLabel('Entry Type'),
    );
    expect(entryType.decoration.filled, isNot(true));
  });
}
