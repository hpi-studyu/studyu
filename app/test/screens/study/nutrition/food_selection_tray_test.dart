import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_core/core.dart' as studyu;

import 'fake_nutrition_food_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('new result opens details, then add reveals compact tray', (
    tester,
  ) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);
    expect(
      tester
          .widget<FoodQuantitySheet>(find.byType(FoodQuantitySheet))
          .food
          .portionReference,
      '1 medium apple',
    );
    expect(find.textContaining('1 medium apple'), findsOneWidget);
    expect(find.text('serving'), findsOneWidget);
    expect(find.text('0 items selected'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.text('1 item selected'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Add 1 item to Lunch'),
      findsOneWidget,
    );
  });

  testWidgets('canceling empty details hides tray but keeps it ready', (
    tester,
  ) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(FoodQuantitySheet),
        matching: find.byTooltip('Close'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.text('0 items selected'), findsNothing);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);
  });

  testWidgets('selected item details and surface expansion stay in one route', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester);

    await _addExternalApple(tester);

    final searchRouteCount = find.byType(FoodSearchScreen).evaluate().length;
    await tester.tap(find.text('1 item selected'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);
    expect(find.byType(FoodSearchScreen), findsNWidgets(searchRouteCount));

    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Update item'), findsOneWidget);
    expect(find.textContaining('1 medium apple'), findsOneWidget);
    expect(find.textContaining('150 g per serving'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(FoodQuantitySheet),
        matching: find.byTooltip('Close'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);

    await tester.tap(find.text('1 item selected'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsNothing);
  });

  testWidgets('detail servings normalize into quantity before increment', (
    tester,
  ) async {
    FoodSearchSelection? selection;
    await _pumpSearch(tester, onResult: (value) => selection = value);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    await tester.enterText(_amountField(), '2');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 servings'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('selection-tray')),
        matching: find.byTooltip('Increase External Apple'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('3 servings'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add 1 item to Lunch'));
    await tester.pumpAndSettle();

    final food = selection!.foods.single;
    expect(food.amount, 3);
    expect(food.servingSizeGrams, 150);
    expect(food.nutrition.energyKcal, 234);
  });

  testWidgets('details stay bounded and confirmable above keyboard', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester);

    await tester.tap(find.text('External Apple'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.tap(_amountField());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.widgetWithText(FilledButton, 'Add item').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('custom weight fits narrow rows and resets to source baseline', (
    tester,
  ) async {
    _setSurfaceSize(tester);
    await _pumpSearch(tester, textScaler: const TextScaler.linear(1.5));

    await _addExternalApple(tester);
    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    await tester.enterText(_weightField(), '120');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Update item'));
    await tester.pumpAndSettle();

    expect(find.text('120 g'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('1 item selected'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    final reset = find.text('Use default weight (150 g)');
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.tap(find.widgetWithText(FilledButton, 'Update item'));
    await tester.pumpAndSettle();

    expect(find.text('150 g'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting final expanded item hides selection surface', (
    tester,
  ) async {
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    await tester.tap(find.text('1 item selected'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete External Apple'));
    await tester.pumpAndSettle();

    expect(find.text('1 item selected'), findsNothing);
    expect(find.byTooltip('Delete External Apple'), findsNothing);
    expect(
      find.widgetWithText(FilledButton, 'Add 0 items to Lunch'),
      findsNothing,
    );
    expect(find.byType(FoodQuantitySheet), findsNothing);
  });

  testWidgets('system back returns details to expanded then compact', (
    tester,
  ) async {
    await _pumpSearch(tester);
    await _addExternalApple(tester);

    await tester.tap(find.text('1 item selected'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('External Apple').last);
    await tester.pumpAndSettle();
    expect(find.byType(FoodQuantitySheet), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.byTooltip('Delete External Apple'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete External Apple'), findsNothing);
    expect(find.text('1 item selected'), findsOneWidget);
  });

  testWidgets('confirmation returns final FoodSearchSelection route result', (
    tester,
  ) async {
    FoodSearchSelection? selection;
    await _pumpSearch(tester, onResult: (value) => selection = value);

    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add 1 item to Lunch'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodSearchScreen), findsNothing);
    expect(selection?.foods.single.name, 'External Apple');
    expect(selection?.foods.single.amount, 1);
  });

  testWidgets('My library item uses unified details and selection surface', (
    tester,
  ) async {
    final repository = FakeNutritionFoodRepository([_libraryTemplate()]);
    await _pumpSearch(tester, repository: repository, query: null);

    await tester.tap(find.text('My library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library Pear'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Add item'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodQuantitySheet), findsNothing);
    expect(find.text('1 item selected'), findsOneWidget);
    expect(repository.loadCalls, 1);
  });
}

Finder _amountField() => find
    .descendant(
      of: find.byType(FoodQuantitySheet),
      matching: find.byType(TextField),
    )
    .first;

Finder _weightField() =>
    find.byKey(const ValueKey('food-quantity-weight-field'));

void _setSurfaceSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _addExternalApple(WidgetTester tester) async {
  await tester.tap(find.text('External Apple'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
  await tester.pumpAndSettle();
}

Future<void> _pumpSearch(
  WidgetTester tester, {
  String? query = 'apple',
  TextScaler? textScaler,
  FakeNutritionFoodRepository? repository,
  ValueChanged<FoodSearchSelection?>? onResult,
}) async {
  Future<SearchResult> openFoodFactsSearch({
    required String query,
    required int page,
    required int pageSize,
  }) async => const SearchResult(products: []);
  Future<UsdaSearchResponse> usdaFoodSearch({
    required String query,
    required int page,
    required int pageSize,
  }) async => UsdaSearchResponse(
    totalHits: 1,
    currentPage: page,
    totalPages: 1,
    foods: [_externalFood()],
  );

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        builder: textScaler == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                final result = await FoodSearchScreen.show(
                  context,
                  mealLabel: 'Lunch',
                  usdaFoodSearch: usdaFoodSearch,
                  openFoodFactsSearch: openFoodFactsSearch,
                  repository: repository ?? FakeNutritionFoodRepository(),
                );
                onResult?.call(result);
              },
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open search'));
  await tester.pumpAndSettle();
  if (query case final query?) {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }
}

UsdaFoodItem _externalFood() => UsdaFoodItem(
  fdcId: 101,
  description: 'External Apple',
  brandOwner: 'Example Foods',
  gtinUpc: '012345678901',
  servingSize: 150,
  servingSizeUnit: 'g',
  householdServingFullText: '1 medium apple',
  foodNutrients: [UsdaFoodNutrient(nutrientId: 1008, value: 52)],
);

studyu.SavedFoodTemplate _libraryTemplate() => studyu.SavedFoodTemplate(
  id: 'library-pear-template',
  userId: 'anonymous',
  name: 'Library Pear',
  isPublic: false,
  createdAt: DateTime.utc(2024),
  prototype: studyu.FoodEntry.withId(
    entryType: studyu.FoodEntryType.singleIngredient,
    name: 'Library Pear',
    amount: 1,
    unit: 'serving',
    servingSizeGrams: 120,
    portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
    portionState: studyu.PortionState.asServed,
    nutrition: studyu.NutritionProfile(
      energyKcal: 80,
      protein: 1,
      carbs: 20,
      fat: 0,
      sugars: 12,
      fiber: 4,
      saturatedFat: 0,
      transFat: 0,
      cholesterol: 0,
      sodium: 0,
      waterContent: 0,
      micros: const {},
    ),
    source: studyu.FoodSource.manual,
    confidenceScore: 1,
    originalValues: const {},
  ),
);
