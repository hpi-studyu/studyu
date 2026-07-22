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

  testWidgets('search live region reports loading and the result count', (
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
    usdaCompleter.complete(usdaResult());
    await tester.pump();

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
