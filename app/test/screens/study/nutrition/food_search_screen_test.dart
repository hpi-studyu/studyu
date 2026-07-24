import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsData;
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
import 'package:studyu_core/core.dart' as studyu;

typedef SearchRequest = ({String source, String query, int page, int pageSize});

Widget foodSearchApp(
  Locale locale, {
  OpenFoodFactsSearch? openFoodFactsSearch,
  UsdaFoodSearch? usdaFoodSearch,
}) => ChangeNotifierProvider(
  create: (_) => AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: locale,
    home: FoodSearchScreen(
      openFoodFactsSearch: openFoodFactsSearch,
      usdaFoodSearch: usdaFoodSearch,
    ),
  ),
);

Widget foodSearchModalApp({
  required String mealLabel,
  OpenFoodFactsSearch? openFoodFactsSearch,
  UsdaFoodSearch? usdaFoodSearch,
  ValueChanged<studyu.FoodEntry?>? onResult,
}) => ChangeNotifierProvider(
  create: (_) => AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () async {
              final result = await FoodSearchScreen.show(
                context,
                mealLabel: mealLabel,
                openFoodFactsSearch: openFoodFactsSearch,
                usdaFoodSearch: usdaFoodSearch,
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

SearchResult offResult([List<Product> products = const []]) =>
    SearchResult(products: products);

Product offFood(String name, [String? barcode]) =>
    Product(productName: name, barcode: barcode ?? name);

UsdaSearchResponse usdaResult([List<UsdaFoodItem> foods = const []]) =>
    UsdaSearchResponse(
      totalHits: foods.length,
      currentPage: 1,
      totalPages: foods.isEmpty ? 0 : 1,
      foods: foods,
    );

UsdaFoodItem usdaFood(String name, [int id = 1]) =>
    UsdaFoodItem(fdcId: id, description: name, foodNutrients: const []);

Future<void> enterSearch(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> scrollToBottom(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, 4000));
  await tester.pump();
  await tester.drag(find.byType(ListView), const Offset(0, -4000));
  await tester.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows English search examples without a quick recipe action', (
    tester,
  ) async {
    await tester.pumpWidget(foodSearchApp(const Locale('en')));
    await tester.pump();

    expect(
      find.text('Try “apple”, “oat milk”, or a brand name.'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(find.text('Add Manually'), findsOneWidget);
    expect(find.text('Create Recipe'), findsNothing);
  });

  testWidgets('shows localized German search examples', (tester) async {
    await tester.pumpWidget(foodSearchApp(const Locale('de')));
    await tester.pump();

    expect(
      find.text('Zum Beispiel „Apfel“, „Hafermilch“ oder einen Markennamen.'),
      findsOneWidget,
    );
  });

  testWidgets('modal keeps contextual search state across quantity cancel', (
    tester,
  ) async {
    final requests = <SearchRequest>[];
    await tester.pumpWidget(
      foodSearchModalApp(
        mealLabel: 'Snack',
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'off',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return offResult([offFood('Apple')]);
            },
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'usda',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return usdaResult();
            },
      ),
    );

    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Add food to Snack'), findsOneWidget);
    expect(
      tester.getSize(find.byType(FoodSearchScreen)).height,
      greaterThan(500),
    );

    await enterSearch(tester, 'apple');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(find.text('Add to Snack'), findsOneWidget);
    expect(find.text('Apple'), findsWidgets);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Add food to Snack'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'apple',
    );
    expect(requests, [
      (source: 'off', query: 'apple', page: 1, pageSize: 20),
      (source: 'usda', query: 'apple', page: 1, pageSize: 20),
    ]);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.text('Open search'), findsOneWidget);
    expect(find.byType(FoodSearchScreen), findsNothing);
  });

  testWidgets('modal scales provider serving and selected amount once', (
    tester,
  ) async {
    final nutriments = Nutriments.empty()
      ..setValue(Nutrient.energyKCal, PerSize.oneHundredGrams, 100)
      ..setValue(Nutrient.proteins, PerSize.oneHundredGrams, 10);
    studyu.FoodEntry? selectedFood;

    await tester.pumpWidget(
      foodSearchModalApp(
        mealLabel: 'Snack',
        onResult: (food) => selectedFood = food,
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) async =>
                offResult([
                  Product(
                    productName: 'Apple',
                    servingSize: '50 g',
                    nutriments: nutriments,
                  ),
                ]),
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async =>
                usdaResult(),
      ),
    );

    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    await enterSearch(tester, 'apple');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(find.text('50 kcal'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('100 kcal'), findsOneWidget);

    await tester.tap(find.text('Add to Snack'));
    await tester.pumpAndSettle();

    expect(selectedFood, isNotNull);
    expect(selectedFood!.amount, 2);
    expect(selectedFood!.servingSizeGrams, 50);
    expect(selectedFood!.nutrition.energyKcal, 100);
    expect(selectedFood!.nutrition.protein, 10);
  });

  testWidgets('German USDA outage stays localized and retries Apfel', (
    tester,
  ) async {
    final requests = <SearchRequest>[];

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('de'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) {
              requests.add((
                source: 'off',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return Future.value(offResult());
            },
        usdaFoodSearch: ({required query, required page, required pageSize}) {
          requests.add((
            source: 'usda',
            query: query,
            page: page,
            pageSize: pageSize,
          ));
          throw Exception('offline');
        },
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'Apfel');
    await tester.pump();

    expect(requests, [
      (source: 'off', query: 'Apfel', page: 1, pageSize: 20),
      (source: 'usda', query: 'Apfel', page: 1, pageSize: 20),
    ]);
    expect(
      find.text(
        'Die Lebensmittelsuche ist nicht verfügbar. Bitte versuchen Sie es erneut.',
      ),
      findsOneWidget,
    );
    expect(find.text('Erneut versuchen'), findsOneWidget);
    expect(
      find.text('Food search is unavailable. Please try again.'),
      findsNothing,
    );
    expect(
      find.text('No results found. Try different keywords.'),
      findsNothing,
    );

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pump();
    await tester.pump();

    expect(requests, [
      (source: 'off', query: 'Apfel', page: 1, pageSize: 20),
      (source: 'usda', query: 'Apfel', page: 1, pageSize: 20),
      (source: 'off', query: 'Apfel', page: 1, pageSize: 20),
      (source: 'usda', query: 'Apfel', page: 1, pageSize: 20),
    ]);
    expect(
      find.text(
        'Die Lebensmittelsuche ist nicht verfügbar. Bitte versuchen Sie es erneut.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('clear button exposes the native localized semantics tooltip', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(foodSearchApp(const Locale('de')));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Apfel');
    await tester.pump();

    final tooltip = MaterialLocalizations.of(
      tester.element(find.byType(TextField)),
    ).clearButtonTooltip;
    final clearButton = find.widgetWithIcon(IconButton, Icons.clear);

    expect(clearButton, findsOneWidget);
    expect(find.byTooltip(tooltip), findsOneWidget);
    expect(
      tester.getSemantics(clearButton).getSemanticsData().tooltip,
      tooltip,
    );

    semantics.dispose();
  });

  testWidgets('debounce searches only the latest text', (tester) async {
    final requests = <SearchRequest>[];

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) {
              requests.add((
                source: 'off',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return Future.value(offResult());
            },
        usdaFoodSearch: ({required query, required page, required pageSize}) {
          requests.add((
            source: 'usda',
            query: query,
            page: page,
            pageSize: pageSize,
          ));
          return Future.value(usdaResult());
        },
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'app');
    await tester.pump(const Duration(milliseconds: 399));
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(const Duration(milliseconds: 399));

    expect(requests, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));

    expect(requests, [
      (source: 'off', query: 'apple', page: 1, pageSize: 20),
      (source: 'usda', query: 'apple', page: 1, pageSize: 20),
    ]);
  });

  testWidgets('changed text removes stale results before debounce', (
    tester,
  ) async {
    final requests = <SearchRequest>[];

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) {
              requests.add((
                source: 'off',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return Future.value(
                offResult([
                  offFood(query == 'apple' ? 'Stale Apple' : 'Fresh Banana'),
                ]),
              );
            },
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'usda',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return usdaResult();
            },
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');
    await tester.pump();
    expect(find.text('Stale Apple'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'banana');
    await tester.pump(const Duration(milliseconds: 399));

    expect(find.text('Stale Apple'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(requests.where((request) => request.query == 'banana'), isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('Fresh Banana'), findsOneWidget);
  });

  testWidgets('search renders results while a provider is pending', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final offCompleter = Completer<SearchResult>();
    final usdaCompleter = Completer<UsdaSearchResponse>();

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) =>
                offCompleter.future,
        usdaFoodSearch: ({required query, required page, required pageSize}) =>
            usdaCompleter.future,
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');

    final status = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.liveRegion == true,
      description: 'search status live region',
    );
    expect(status, findsOneWidget);
    expect(
      tester.getSemantics(status).getSemanticsData(),
      isA<SemanticsData>()
          .having(
            (data) => data.flagsCollection.isLiveRegion,
            'live region',
            isTrue,
          )
          .having((data) => data.label, 'label', 'Searching databases...'),
    );

    offCompleter.complete(offResult([offFood('Apple'), offFood('Apple Pie')]));
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Apple Pie'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.text('Food search is unavailable. Please try again.'),
      findsNothing,
    );
    expect(
      find.text('No results found. Try different keywords.'),
      findsNothing,
    );
    expect(find.text('End of results'), findsNothing);
    expect(
      tester.getSemantics(status).getSemanticsData(),
      isA<SemanticsData>()
          .having(
            (data) => data.flagsCollection.isLiveRegion,
            'live region',
            isTrue,
          )
          .having((data) => data.label, 'label', 'Searching databases...'),
    );

    usdaCompleter.complete(usdaResult());
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Apple Pie'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('End of results'), findsOneWidget);
    expect(
      tester.getSemantics(status).getSemanticsData(),
      isA<SemanticsData>()
          .having(
            (data) => data.flagsCollection.isLiveRegion,
            'live region',
            isTrue,
          )
          .having((data) => data.label, 'label', '2 results found'),
    );

    semantics.dispose();
  });

  testWidgets('branded result details preserve query and scroll on back', (
    tester,
  ) async {
    final requests = <SearchRequest>[];

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'off',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return offResult(
                List.generate(
                  12,
                  (index) => Product(
                    productName: 'Apple $index',
                    barcode: 'apple-$index',
                    brands: 'Orchard Co',
                  ),
                ),
              );
            },
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'usda',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return usdaResult();
            },
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');
    await tester.pump();

    expect(find.text('Orchard Co'), findsWidgets);
    await tester.dragUntilVisible(
      find.text('Apple 8'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    final scrollable = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    );
    final offsetBeforeDetails = tester
        .state<ScrollableState>(scrollable)
        .position
        .pixels;
    expect(offsetBeforeDetails, greaterThan(0));

    await tester.tap(find.text('Apple 8'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Food'), findsOneWidget);
    expect(find.byTooltip('Search Food Database'), findsNothing);

    await tester.tap(find.text('Advanced Options'));
    await tester.pumpAndSettle();
    final brandField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Brand Name',
      ),
    );
    expect(brandField.controller!.text, 'Orchard Co');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'apple',
    );
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      closeTo(offsetBeforeDetails, 0.1),
    );
    expect(requests, [
      (source: 'off', query: 'apple', page: 1, pageSize: 20),
      (source: 'usda', query: 'apple', page: 1, pageSize: 20),
    ]);
  });

  testWidgets('older initial responses cannot overwrite the current search', (
    tester,
  ) async {
    final offRequests = <String, Completer<SearchResult>>{};
    final usdaRequests = <String, Completer<UsdaSearchResponse>>{};

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) {
              return (offRequests[query] = Completer<SearchResult>()).future;
            },
        usdaFoodSearch: ({required query, required page, required pageSize}) {
          return (usdaRequests[query] = Completer<UsdaSearchResponse>()).future;
        },
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');
    await enterSearch(tester, 'banana');

    offRequests['apple']!.complete(offResult([offFood('Apple')]));
    usdaRequests['apple']!.complete(usdaResult());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    offRequests['banana']!.complete(offResult([offFood('Banana')]));
    usdaRequests['banana']!.complete(usdaResult());
    await tester.pump();

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('clearing invalidates in-flight work', (tester) async {
    final offCompleter = Completer<SearchResult>();
    final usdaCompleter = Completer<UsdaSearchResponse>();

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) =>
                offCompleter.future,
        usdaFoodSearch: ({required query, required page, required pageSize}) =>
            usdaCompleter.future,
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    offCompleter.complete(offResult([offFood('Late Apple')]));
    usdaCompleter.complete(usdaResult([usdaFood('Late USDA')]));
    await tester.pump();

    expect(find.text('Search for Food'), findsOneWidget);
    expect(find.text('Late Apple'), findsNothing);
    expect(find.text('Late USDA'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('pagination stays bound to the active query', (tester) async {
    final requests = <SearchRequest>[];
    final oldPagination = Completer<SearchResult>();

    Future<SearchResult> searchOff({
      required String query,
      required int page,
      required int pageSize,
    }) {
      requests.add((
        source: 'off',
        query: query,
        page: page,
        pageSize: pageSize,
      ));
      if (query == 'apple' && page == 1) {
        return Future.value(
          offResult(List.generate(20, (index) => offFood('Apple $index'))),
        );
      }
      if (query == 'apple' && page == 2) return oldPagination.future;
      if (query == 'banana' && page == 1) {
        return Future.value(
          offResult(List.generate(20, (index) => offFood('Banana $index'))),
        );
      }
      if (query == 'banana' && page == 2) {
        return Future.value(offResult([offFood('Banana page 2')]));
      }
      throw StateError('Unexpected OFF request: $query page $page');
    }

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch: searchOff,
        usdaFoodSearch: ({required query, required page, required pageSize}) {
          requests.add((
            source: 'usda',
            query: query,
            page: page,
            pageSize: pageSize,
          ));
          return Future.value(usdaResult());
        },
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');
    await tester.pump();
    await scrollToBottom(tester);

    expect(
      requests,
      contains((source: 'off', query: 'apple', page: 2, pageSize: 20)),
    );

    await tester.enterText(find.byType(TextField), 'banana');
    await tester.pump(const Duration(milliseconds: 399));
    await scrollToBottom(tester);

    expect(requests.where((request) => request.query == 'banana'), isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    await tester.pump();
    await scrollToBottom(tester);

    expect(
      requests.where(
        (request) => request.source == 'off' && request.query == 'banana',
      ),
      [
        (source: 'off', query: 'banana', page: 1, pageSize: 20),
        (source: 'off', query: 'banana', page: 2, pageSize: 20),
      ],
    );

    oldPagination.complete(offResult([offFood('Stale Apple page 2')]));
    await tester.pump();
    await scrollToBottom(tester);

    expect(find.text('Banana page 2'), findsOneWidget);
    expect(find.text('Stale Apple page 2'), findsNothing);
    expect(
      requests.where(
        (request) => request.query == 'banana' && request.page == 3,
      ),
      isEmpty,
    );
  });

  testWidgets('trim-equivalent edits invalidate pagination during debounce', (
    tester,
  ) async {
    final requests = <SearchRequest>[];
    final refreshedSearch = Completer<SearchResult>();
    var initialSearchComplete = false;

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) {
              requests.add((
                source: 'off',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              if (page == 1 && !initialSearchComplete) {
                initialSearchComplete = true;
                return Future.value(
                  offResult(
                    List.generate(20, (index) => offFood('Apple $index')),
                  ),
                );
              }
              if (page == 1) return refreshedSearch.future;
              return Future.value(offResult([offFood('Unexpected page 2')]));
            },
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'usda',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return usdaResult();
            },
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');
    await tester.pump();

    await tester.enterText(find.byType(TextField), ' apple ');
    await tester.pump(const Duration(milliseconds: 399));
    await scrollToBottom(tester);

    expect(requests.where((request) => request.page == 2), isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    expect(
      requests.where(
        (request) => request.source == 'off' && request.query == 'apple',
      ),
      [
        (source: 'off', query: 'apple', page: 1, pageSize: 20),
        (source: 'off', query: 'apple', page: 1, pageSize: 20),
      ],
    );

    refreshedSearch.complete(offResult());
    await tester.pump();
  });

  testWidgets('successful empty searches show no-result actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) async =>
                offResult(),
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async =>
                usdaResult(),
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'nothing');
    await tester.pump();

    expect(
      find.text('No results found. Try different keywords.'),
      findsOneWidget,
    );
    expect(find.text('Add Food Manually'), findsOneWidget);
    expect(find.text('Create Recipe'), findsOneWidget);
    expect(
      find.text('Food search is unavailable. Please try again.'),
      findsNothing,
    );

    final status = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.liveRegion == true,
    );
    expect(
      tester.getSemantics(status).getSemanticsData(),
      isA<SemanticsData>()
          .having(
            (data) => data.flagsCollection.isLiveRegion,
            'live region',
            isTrue,
          )
          .having(
            (data) => data.label,
            'label',
            'No results found. Try different keywords.',
          ),
    );

    semantics.dispose();
  });

  testWidgets('provider outage shows an error and retry keeps the query', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final requests = <SearchRequest>[];
    var offAttempts = 0;

    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'off',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              if (offAttempts++ == 0) throw Exception('offline');
              return offResult([offFood('Recovered Apple')]);
            },
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async {
              requests.add((
                source: 'usda',
                query: query,
                page: page,
                pageSize: pageSize,
              ));
              return usdaResult();
            },
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'apple');
    await tester.pump();

    expect(
      find.text('Food search is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(
      find.text('No results found. Try different keywords.'),
      findsNothing,
    );

    final status = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.liveRegion == true,
    );
    expect(
      tester.getSemantics(status).getSemanticsData(),
      isA<SemanticsData>()
          .having(
            (data) => data.flagsCollection.isLiveRegion,
            'live region',
            isTrue,
          )
          .having(
            (data) => data.label,
            'label',
            'Food search is unavailable. Please try again.',
          ),
    );

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Recovered Apple'), findsOneWidget);
    expect(
      find.text('Food search is unavailable. Please try again.'),
      findsNothing,
    );
    expect(requests, [
      (source: 'off', query: 'apple', page: 1, pageSize: 20),
      (source: 'usda', query: 'apple', page: 1, pageSize: 20),
      (source: 'off', query: 'apple', page: 1, pageSize: 20),
      (source: 'usda', query: 'apple', page: 1, pageSize: 20),
    ]);

    semantics.dispose();
  });

  testWidgets('saved food selection applies a fresh template entry', (
    tester,
  ) async {
    final prototype = studyu.FoodEntry(
      id: 'prototype-food-id',
      entryType: studyu.FoodEntryType.manualCustom,
      name: 'Template Apple',
      brandName: 'Saved Orchard',
      description: 'Immutable prototype',
      amount: 2,
      unit: 'slice',
      servingSizeGrams: 40,
      portionReference: '2 slices',
      portionEstimationMethod: studyu.PortionEstimationMethod.householdMeasure,
      portionState: studyu.PortionState.asServed,
      yieldFactor: 0.9,
      ediblePortion: 0.8,
      nutrition: studyu.NutritionProfile(
        energyKcal: 52,
        protein: 0.3,
        carbs: 14,
        fat: 0.2,
        sugars: 10,
        fiber: 2.4,
        saturatedFat: 0,
        transFat: 0,
        cholesterol: 0,
        sodium: 1,
        waterContent: 34,
        micros: const {'vitaminC': 4.6},
      ),
      foodCode: 'saved-code',
      externalId: 'saved-external-id',
      source: studyu.FoodSource.manual,
      confidenceScore: 0.8,
      createdAt: DateTime.utc(2025),
      originalValues: const {'origin': 'saved-template'},
    );
    final template = studyu.SavedFoodTemplate(
      id: 'saved-template-id',
      userId: 'anonymous',
      name: 'Saved Apple Template',
      tags: const ['fruit'],
      isPublic: false,
      createdAt: DateTime.utc(2025, 1, 2),
      prototype: prototype,
    );
    await TemplateStorageManager().saveFoodTemplate(template);
    studyu.FoodEntry? selectedFood;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selectedFood = await FoodSearchScreen.show(
                    context,
                    mealLabel: 'Snack',
                    openFoodFactsSearch:
                        ({
                          required query,
                          required page,
                          required pageSize,
                        }) async => offResult(),
                    usdaFoodSearch:
                        ({
                          required query,
                          required page,
                          required pageSize,
                        }) async => usdaResult(),
                  );
                },
                child: const Text('Open food search'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open food search'));
    await tester.pumpAndSettle();
    expect(find.text('Add food to Snack'), findsOneWidget);
    await tester.tap(find.text('Saved Apple Template'));
    await tester.pumpAndSettle();
    expect(find.text('Add to Snack'), findsOneWidget);
    await tester.tap(find.text('Add to Snack'));
    await tester.pumpAndSettle();

    expect(selectedFood, isNotNull);
    expect(selectedFood!.id, isNot(prototype.id));
    expect(selectedFood!.templateId, template.id);
    expect(selectedFood!.name, prototype.name);
    expect(selectedFood!.brandName, prototype.brandName);
    expect(selectedFood!.description, prototype.description);
    expect(selectedFood!.amount, prototype.amount);
    expect(selectedFood!.unit, prototype.unit);
    expect(selectedFood!.servingSizeGrams, prototype.servingSizeGrams);
    expect(selectedFood!.nutrition.toJson(), prototype.nutrition.toJson());
    expect(selectedFood!.foodCode, prototype.foodCode);
    expect(selectedFood!.externalId, prototype.externalId);
    expect(selectedFood!.source, prototype.source);
    expect(selectedFood!.confidenceScore, prototype.confidenceScore);
    expect(selectedFood!.originalValues, prototype.originalValues);
    expect(prototype.id, 'prototype-food-id');
    expect(prototype.templateId, isNull);
  });

  testWidgets('partial provider success keeps useful results', (tester) async {
    await tester.pumpWidget(
      foodSearchApp(
        const Locale('en'),
        openFoodFactsSearch:
            ({required query, required page, required pageSize}) {
              throw Exception('offline');
            },
        usdaFoodSearch:
            ({required query, required page, required pageSize}) async =>
                usdaResult([usdaFood('USDA Banana')]),
      ),
    );
    await tester.pump();

    await enterSearch(tester, 'banana');
    await tester.pump();

    expect(find.text('USDA Banana'), findsOneWidget);
    expect(
      find.text('Food search is unavailable. Please try again.'),
      findsNothing,
    );
    expect(
      find.text('No results found. Try different keywords.'),
      findsNothing,
    );
  });
}
