import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_library_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_bar.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_history.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_core/core.dart' as studyu;

typedef OpenFoodFactsSearch =
    Future<SearchResult> Function({
      required String query,
      required int page,
      required int pageSize,
    });
typedef UsdaFoodSearch =
    Future<UsdaSearchResponse> Function({
      required String query,
      required int page,
      required int pageSize,
    });

List<UnifiedFoodResult> rankFoodSearchResults(
  Iterable<UnifiedFoodResult> results,
  String query,
) {
  final normalizedQuery = _normalizeSearchText(query);
  final indexed = results.indexed.toList();
  if (normalizedQuery.isEmpty) {
    return indexed.map((entry) => entry.$2).toList(growable: false);
  }

  indexed.sort((left, right) {
    final scoreComparison = _foodSearchScore(
      left.$2,
      normalizedQuery,
    ).compareTo(_foodSearchScore(right.$2, normalizedQuery));
    return scoreComparison != 0 ? scoreComparison : left.$1.compareTo(right.$1);
  });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}

int _foodSearchScore(UnifiedFoodResult result, String normalizedQuery) {
  final name = _normalizeSearchText(result.name);
  final queryTokens = normalizedQuery.split(' ');
  final nameTokens = name.split(' ');
  final isExact = name == normalizedQuery;
  final isPrefixOrToken =
      name.startsWith(normalizedQuery) ||
      queryTokens.every(
        (queryToken) =>
            nameTokens.any((nameToken) => nameToken.startsWith(queryToken)),
      );
  final matchTier = isExact
      ? 0
      : isPrefixOrToken
      ? 1
      : 2;
  final isBranded = result.brand?.trim().isNotEmpty ?? false;
  return matchTier * 2 + (isBranded ? 1 : 0);
}

String _normalizeSearchText(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

double? _gramsFromMetadata(String? value) {
  if (value == null) return null;
  final match = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*g(?:rams?)?\b',
    caseSensitive: false,
  ).firstMatch(value);
  return match == null
      ? null
      : double.tryParse(match.group(1)!.replaceAll(',', '.'));
}

String _formatNumber(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toStringAsFixed(1);

num _servingAmount(double value) =>
    value == value.roundToDouble() ? value.round() : value;

String _foodServingMetadata(AppLocalizations l10n, studyu.FoodEntry food) {
  return _selectedFoodServingMetadata(l10n, food, 1, caloriesKnown: true);
}

String _selectedFoodServingMetadata(
  AppLocalizations l10n,
  studyu.FoodEntry food,
  int quantity, {
  required bool caloriesKnown,
}) {
  final unit = food.unit.trim();
  final baseServing = unit.isEmpty || unit.toLowerCase() == 'serving'
      ? l10n.serving_amount(_servingAmount(food.amount))
      : '${_formatNumber(food.amount)} $unit';
  final serving = quantity == 1
      ? baseServing
      : unit.isEmpty || unit.toLowerCase() == 'serving'
      ? l10n.serving_amount(_servingAmount(food.amount * quantity))
      : '$quantity × $baseServing';
  final calories = caloriesKnown
      ? l10n.kcal_value(
          (food.nutrition.energyKcal * quantity).round().toString(),
        )
      : '— kcal';
  return '$serving · $calories';
}

double? _resultCalories(UnifiedFoodResult result) {
  return switch (result.originalData) {
    final UsdaFoodItem food when food.getNutrientValue(1008) != null =>
      food.energyKcal100g * (food.servingSize ?? 100) / 100,
    final UsdaFoodItem _ => null,
    _ => result.calories,
  };
}

bool _resultCaloriesKnown(UnifiedFoodResult result) {
  return switch (result.originalData) {
    final UsdaFoodItem food => food.getNutrientValue(1008) != null,
    final Product product =>
      product.nutriments?.getValue(
            Nutrient.energyKCal,
            PerSize.oneHundredGrams,
          ) !=
          null,
    _ => result.calories != null,
  };
}

String _selectionCaloriesSummary(
  AppLocalizations l10n,
  FoodSelectionStore store,
) {
  final known = store.knownCalories().round();
  return store.unknownCaloriesCount == 0
      ? l10n.kcal_value(known.toString())
      : known == 0
      ? l10n.food_selection_unknown_calories(store.unknownCaloriesCount)
      : l10n.food_selection_known_calories(
          known.toString(),
          store.unknownCaloriesCount,
        );
}

String? _foodImageUrl(studyu.FoodEntry food) {
  for (final key in [
    'image_front_small_url',
    'image_front_url',
    'image_url',
    'imageUrl',
  ]) {
    final value = food.originalValues[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}

Widget _fallbackItemIcon(ThemeData theme, IconData icon, {double size = 22}) =>
    Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: size, color: theme.colorScheme.onSurfaceVariant),
    );

final class FoodSearchSelection {
  final List<studyu.FoodEntry> foods;

  FoodSearchSelection(Iterable<studyu.FoodEntry> foods)
    : foods = List.unmodifiable(foods);

  FoodSearchSelection.single(studyu.FoodEntry food)
    : foods = List.unmodifiable([food]);
}

final class FoodSelectionItem {
  final String key;
  studyu.FoodEntry baseFood;
  int quantity;
  bool caloriesKnown;

  FoodSelectionItem({
    required this.key,
    required this.baseFood,
    this.quantity = 1,
    this.caloriesKnown = true,
  });

  String get name => baseFood.name;
}

/// Temporary, route-scoped state for the multi-select Add items flow.
final class FoodSelectionStore extends ChangeNotifier {
  final LinkedHashMap<String, FoodSelectionItem> _items = LinkedHashMap();
  final List<String> _recentKeys = [];

  Iterable<FoodSelectionItem> get items => _items.values;
  Iterable<FoodSelectionItem> get recentItems => _recentKeys.reversed
      .map((key) => _items[key])
      .whereType<FoodSelectionItem>();
  int get itemCount => _items.length;
  int get servingCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  int get unknownCaloriesCount =>
      _items.values.where((item) => !item.caloriesKnown).length;
  bool get isEmpty => _items.isEmpty;

  FoodSelectionItem? itemFor(String key) => _items[key];

  void addOrIncrement(
    String key,
    studyu.FoodEntry food, {
    bool caloriesKnown = true,
  }) {
    final existing = _items[key];
    if (existing == null) {
      _items[key] = FoodSelectionItem(
        key: key,
        baseFood: cloneFoodEntry(food),
        caloriesKnown: caloriesKnown,
      );
    } else {
      existing.quantity++;
    }
    _recentKeys
      ..remove(key)
      ..add(key);
    notifyListeners();
  }

  void increment(String key) {
    final item = _items[key];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
  }

  void decrement(String key) {
    final item = _items[key];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(key);
      _recentKeys.remove(key);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void delete(String key) {
    if (_items.remove(key) == null) return;
    _recentKeys.remove(key);
    notifyListeners();
  }

  void replaceBase(
    String key,
    studyu.FoodEntry food, {
    required bool caloriesKnown,
  }) {
    final item = _items[key];
    if (item == null) return;
    final servings = food.amount / item.baseFood.amount;
    final roundedServings = servings.round();
    if (servings.isFinite &&
        roundedServings > 0 &&
        (servings - roundedServings).abs() < 0.000001) {
      item.quantity = roundedServings;
    } else {
      item
        ..baseFood = cloneFoodEntry(food)
        ..quantity = 1;
    }
    item.caloriesKnown = caloriesKnown;
    notifyListeners();
  }

  double knownCalories() => _items.values
      .where((item) => item.caloriesKnown)
      .fold(
        0,
        (sum, item) => sum + item.baseFood.nutrition.energyKcal * item.quantity,
      );

  List<studyu.FoodEntry> materialize() {
    final result = <studyu.FoodEntry>[];
    for (final item in _items.values) {
      final amount = item.baseFood.amount * item.quantity;
      if (!amount.isFinite || amount <= 0) {
        throw ArgumentError.value(amount, 'amount', 'Must be positive');
      }
      result.add(rescaleFoodAmount(item.baseFood, amount));
    }
    return result;
  }
}

String canonicalFoodSelectionKey(studyu.FoodEntry food) {
  if (food.templateId case final templateId? when templateId.isNotEmpty) {
    return 'template:$templateId';
  }
  final source = food.source.name;
  final externalId = food.externalId?.trim();
  if (externalId != null && externalId.isNotEmpty) {
    return '$source:id:$externalId';
  }
  final barcode = food.foodCode?.trim();
  if (barcode != null && barcode.isNotEmpty) {
    return '$source:barcode:$barcode';
  }
  if (food.source == studyu.FoodSource.manual) return 'manual:${food.id}';
  return [
    source,
    _normalizeSearchText(food.name),
    _normalizeSearchText(food.brandName ?? ''),
    _normalizeSearchText(food.unit),
    food.amount.toString(),
    food.servingSizeGrams.toString(),
  ].join('|');
}

enum _FoodSearchSection { recent, myItems }

enum _FoodSearchFilter { all, myItems, database }

enum _FoodSearchAction { food, meal, foodLibrary }

class FoodSearchScreen extends StatelessWidget {
  final bool allowMeals;
  final String? mealLabel;
  final OpenFoodFactsSearch? openFoodFactsSearch;
  final UsdaFoodSearch? usdaFoodSearch;

  const FoodSearchScreen({
    this.allowMeals = true,
    this.mealLabel,
    this.openFoodFactsSearch,
    this.usdaFoodSearch,
    super.key,
  });

  static MaterialPageRoute<studyu.FoodEntry> route({bool allowMeals = true}) =>
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(allowMeals: allowMeals),
      );

  static Future<FoodSearchSelection?> show(
    BuildContext context, {
    required String mealLabel,
    bool allowMeals = true,
    OpenFoodFactsSearch? openFoodFactsSearch,
    UsdaFoodSearch? usdaFoodSearch,
  }) => Navigator.of(context).push(
    MaterialPageRoute<FoodSearchSelection>(
      fullscreenDialog: true,
      builder: (_) => FoodSearchScreen(
        allowMeals: allowMeals,
        mealLabel: mealLabel,
        openFoodFactsSearch: openFoodFactsSearch,
        usdaFoodSearch: usdaFoodSearch,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final activeSubject = appState.activeSubject;
    final userId = activeSubject?.id ?? 'anonymous';
    final history = activeSubject == null
        ? FoodSearchHistory.empty
        : buildFoodSearchHistory(
            activeSubject.progress,
            subjectId: activeSubject.id,
          );

    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId),
      child: _FoodSearchScreenContent(
        allowMeals: allowMeals,
        mealLabel: mealLabel,
        openFoodFactsSearch: openFoodFactsSearch,
        usdaFoodSearch: usdaFoodSearch,
        history: history,
      ),
    );
  }
}

class _FoodSearchScreenContent extends StatefulWidget {
  final bool allowMeals;
  final String? mealLabel;
  final OpenFoodFactsSearch? openFoodFactsSearch;
  final UsdaFoodSearch? usdaFoodSearch;
  final FoodSearchHistory history;

  const _FoodSearchScreenContent({
    this.allowMeals = true,
    this.mealLabel,
    this.openFoodFactsSearch,
    this.usdaFoodSearch,
    required this.history,
  });

  @override
  State<_FoodSearchScreenContent> createState() =>
      _FoodSearchScreenContentState();
}

class _FoodSearchScreenContentState extends State<_FoodSearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  late final FoodSelectionStore? _selectionStore = widget.mealLabel == null
      ? null
      : FoodSelectionStore();
  _FoodSearchSection _selectedSection = _FoodSearchSection.recent;
  _FoodSearchFilter _selectedFilter = _FoodSearchFilter.all;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // Debounce timer for live search
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 400);

  // Combined results from all sources
  List<UnifiedFoodResult> _combinedResults = [];

  // Pagination state per source
  int _offPage = 1;
  int _usdaPage = 1;
  bool _offHasMore = true;
  bool _usdaHasMore = true;

  // Loading states
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  String? _errorMessage;

  // Search identity and provider state
  int _searchGeneration = 0;
  String _activeQuery = '';
  bool _offSearched = false;
  bool _usdaSearched = false;
  bool _offFailed = false;
  bool _usdaFailed = false;
  bool _showServingHint = true;
  bool _isConfirming = false;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _selectionStore?.addListener(_onSelectionChanged);
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'StudyU',
      version: '1.0',
      system: 'Flutter',
      url: 'https://studyu.health',
    );
    OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH];

    _scrollController.addListener(_onScroll);
  }

  void _onSelectionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _selectionStore?.removeListener(_onSelectionChanged);
    _selectionStore?.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// Debounced search - triggers after user stops typing
  void _onSearchChanged(String value, TemplateViewModel templateViewModel) {
    templateViewModel.setSearchQuery(value);
    _debounceTimer?.cancel();

    final query = value.trim();
    final generation = ++_searchGeneration;

    if (!mounted) return;
    _resetSearchState();
    if (query.isEmpty) return;

    _debounceTimer = Timer(
      _debounceDuration,
      () => _searchFood(templateViewModel, query, generation),
    );
  }

  void _resetSearchState() {
    setState(() {
      _combinedResults = [];
      _offPage = 1;
      _usdaPage = 1;
      _offHasMore = true;
      _usdaHasMore = true;
      _isInitialLoading = false;
      _isLoadingMore = false;
      _hasSearched = false;
      _errorMessage = null;
      _activeQuery = '';
      _offSearched = false;
      _usdaSearched = false;
      _offFailed = false;
      _usdaFailed = false;
    });
  }

  Future<void> _searchFood(
    TemplateViewModel templateViewModel,
    String query,
    int generation,
  ) async {
    if (!mounted || generation != _searchGeneration) return;
    templateViewModel.setSearchQuery(query);

    setState(() {
      _activeQuery = query;
      _offPage = 1;
      _usdaPage = 1;
      _offHasMore = true;
      _usdaHasMore = true;
      _offSearched = false;
      _usdaSearched = false;
      _offFailed = false;
      _usdaFailed = false;
      _isInitialLoading = true;
      _isLoadingMore = false;
      _hasSearched = true;
      _errorMessage = null;
      _combinedResults = [];
    });

    await Future.wait([
      _searchOpenFoodFacts(query, page: 1, generation: generation),
      _searchUsda(query, page: 1, generation: generation),
    ]);

    if (!mounted || generation != _searchGeneration) return;
    setState(() {
      _isInitialLoading = false;
      if (_combinedResults.isEmpty && (_offFailed || _usdaFailed)) {
        _errorMessage = AppLocalizations.of(context)!.food_search_error;
      }
    });
  }

  void _retrySearch(TemplateViewModel templateViewModel) {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final generation = ++_searchGeneration;
    _searchFood(templateViewModel, query, generation);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isInitialLoading) return;
    if (!_offHasMore && !_usdaHasMore) return;

    final query = _activeQuery;
    if (query.isEmpty || query != _searchController.text.trim()) return;

    final generation = _searchGeneration;
    final offPage = _offPage;
    final usdaPage = _usdaPage;

    if (!mounted) return;
    setState(() {
      _isLoadingMore = true;
    });

    final futures = <Future<void>>[];
    if (_offHasMore) {
      futures.add(
        _searchOpenFoodFacts(query, page: offPage, generation: generation),
      );
    }
    if (_usdaHasMore) {
      futures.add(_searchUsda(query, page: usdaPage, generation: generation));
    }

    await Future.wait(futures);

    if (!mounted || generation != _searchGeneration) return;
    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<SearchResult> _fetchOpenFoodFacts({
    required String query,
    required int page,
  }) {
    final search = widget.openFoodFactsSearch;
    if (search != null) {
      return search(query: query, page: page, pageSize: _pageSize);
    }

    return OpenFoodAPIClient.searchProducts(
      null,
      ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]),
          PageNumber(page: page),
          const PageSize(size: _pageSize),
        ],
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: [
          ProductField.NAME,
          ProductField.BRANDS,
          ProductField.BARCODE,
          ProductField.NUTRIMENTS,
          ProductField.SERVING_SIZE,
          ProductField.QUANTITY,
          ProductField.IMAGE_FRONT_SMALL_URL,
        ],
        version: ProductQueryVersion.v3,
      ),
    );
  }

  Future<UsdaSearchResponse> _fetchUsda({
    required String query,
    required int page,
  }) {
    final search = widget.usdaFoodSearch;
    if (search != null) {
      return search(query: query, page: page, pageSize: _pageSize);
    }

    return UsdaApiService.searchFoods(
      query: query,
      pageSize: _pageSize,
      pageNumber: page,
    );
  }

  Future<void> _searchOpenFoodFacts(
    String query, {
    required int page,
    required int generation,
  }) async {
    try {
      final searchResult = await _fetchOpenFoodFacts(query: query, page: page);
      if (!mounted || generation != _searchGeneration) return;

      final products = searchResult.products ?? const <Product>[];
      final newResults = products.map((product) {
        final nutriments = product.nutriments;
        final caloriesPer100g = nutriments?.getValue(
          Nutrient.energyKCal,
          PerSize.oneHundredGrams,
        );
        final calorieBasisGrams =
            _gramsFromMetadata(product.servingSize) ??
            _gramsFromMetadata(product.quantity) ??
            100.0;

        return UnifiedFoodResult(
          id: product.barcode ?? '',
          name: product.productName ?? 'Unknown',
          brand: product.brands,
          imageUrl: product.imageFrontSmallUrl,
          calories: caloriesPer100g == null
              ? null
              : caloriesPer100g * calorieBasisGrams / 100,
          calorieBasisGrams: caloriesPer100g == null ? null : calorieBasisGrams,
          source: studyu.FoodSource.openfoodfacts,
          originalData: product,
        );
      }).toList();

      setState(() {
        _offSearched = true;
        _offFailed = false;
        _combinedResults.addAll(newResults);
        _offPage = page + 1;
        _offHasMore = products.length >= _pageSize;
      });
    } catch (error) {
      if (!mounted || generation != _searchGeneration) return;
      debugPrint('OpenFoodFacts error: $error');
      setState(() {
        _offSearched = true;
        _offFailed = true;
        _offHasMore = false;
      });
    }
  }

  Future<void> _searchUsda(
    String query, {
    required int page,
    required int generation,
  }) async {
    try {
      final searchResult = await _fetchUsda(query: query, page: page);
      if (!mounted || generation != _searchGeneration) return;

      final newResults = searchResult.foods.map((food) {
        return UnifiedFoodResult(
          id: food.fdcId.toString(),
          name: food.description ?? 'Unknown',
          brand: food.brandOwner ?? food.brandName,
          calories: food.getNutrientValue(1008),
          calorieBasisGrams: food.getNutrientValue(1008) == null ? null : 100,
          source: studyu.FoodSource.usda,
          originalData: food,
        );
      }).toList();

      setState(() {
        _usdaSearched = true;
        _usdaFailed = false;
        _combinedResults.addAll(newResults);
        _usdaPage = page + 1;
        _usdaHasMore = searchResult.foods.length >= _pageSize;
      });
    } catch (error) {
      if (!mounted || generation != _searchGeneration) return;
      debugPrint('USDA error: $error');
      setState(() {
        _usdaSearched = true;
        _usdaFailed = true;
        _usdaHasMore = false;
      });
    }
  }

  studyu.FoodEntry _convertUsdaToFoodEntry(UsdaFoodItem food) {
    final servingSizeGrams = food.servingSize ?? 100.0;
    final servingSizeUnit = food.servingSizeUnit ?? 'g';
    final scale = servingSizeGrams / 100.0;

    return studyu.FoodEntry.withId(
      entryType: studyu.FoodEntryType.brandedProduct,
      name: food.description ?? 'Unknown Food',
      brandName: food.brandOwner ?? food.brandName,
      description: food.ingredients,
      amount: 1,
      unit: servingSizeUnit,
      servingSizeGrams: servingSizeGrams,
      portionReference: food.householdServingFullText,
      portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
      portionState: studyu.PortionState.asServed,
      yieldFactor: 1.0,
      nutrition: studyu.NutritionProfile(
        energyKcal: (food.energyKcal100g * scale).roundToDouble(),
        protein: food.protein100g * scale,
        carbs: food.carbohydrates100g * scale,
        fat: food.fat100g * scale,
        sugars: food.sugars100g * scale,
        fiber: food.fiber100g * scale,
        saturatedFat: food.saturatedFat100g * scale,
        transFat: 0,
        cholesterol: 0,
        sodium: food.sodium100g * scale,
        waterContent: 0,
        micros: {},
      ),
      foodCode: food.gtinUpc,
      externalId: food.fdcId.toString(),
      source: studyu.FoodSource.usda,
      confidenceScore: 1.0,
      originalValues: {
        'fdcId': food.fdcId,
        'dataType': food.dataType,
        'description': food.description,
      },
    );
  }

  studyu.FoodEntry _convertToFoodEntry(Product product) {
    final nutriments = product.nutriments;
    final energyKcal =
        nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
    final protein =
        nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0;
    final carbs =
        nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
        0;
    final fat =
        nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0;
    final sugars =
        nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0;
    final fiber =
        nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0;
    final saturatedFat =
        nutriments?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams) ??
        0;
    final sodium =
        (nutriments?.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0) *
        1000;
    double servingSizeGrams = 100.0;
    if (product.servingSize != null) {
      final match = RegExp(
        r'(\d+(?:\.\d+)?)\s*g',
      ).firstMatch(product.servingSize!);
      if (match != null) {
        servingSizeGrams = double.tryParse(match.group(1)!) ?? 100.0;
      }
    }

    return studyu.FoodEntry.withId(
      entryType: studyu.FoodEntryType.brandedProduct,
      name: product.productName ?? 'Unknown Product',
      brandName: product.brands,
      description: product.genericName,
      amount: 1,
      unit: 'serving',
      servingSizeGrams: servingSizeGrams,
      portionReference: product.servingSize,
      portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
      portionState: studyu.PortionState.asServed,
      yieldFactor: 1.0,
      nutrition: studyu.NutritionProfile(
        energyKcal: energyKcal * servingSizeGrams / 100,
        protein: protein * servingSizeGrams / 100,
        carbs: carbs * servingSizeGrams / 100,
        fat: fat * servingSizeGrams / 100,
        sugars: sugars * servingSizeGrams / 100,
        fiber: fiber * servingSizeGrams / 100,
        saturatedFat: saturatedFat * servingSizeGrams / 100,
        transFat: 0,
        cholesterol: 0,
        sodium: sodium * servingSizeGrams / 100,
        waterContent: 0,
        micros: {},
      ),
      foodCode: product.barcode,
      externalId: product.barcode,
      source: studyu.FoodSource.openfoodfacts,
      confidenceScore: 1.0,
      originalValues: product.toJson(),
    );
  }

  bool _isAllowedFood(studyu.FoodEntry food) {
    return widget.allowMeals || food.entryType != studyu.FoodEntryType.meal;
  }

  void _selectHistoryItem(FoodSearchHistoryItem item) {
    if (!_isAllowedFood(item.food)) return;
    final food = item.createSelection();
    if (_selectionStore == null) {
      _showQuantity(food);
      return;
    }
    final key = canonicalFoodSelectionKey(food);
    final selected = _selectionStore.itemFor(key);
    _showQuantity(
      selected?.baseFood ?? food,
      key: key,
      action: selected == null
          ? FoodQuantityAction.addToSelection
          : FoodQuantityAction.updateSelection,
    );
  }

  void _addHistoryItem(FoodSearchHistoryItem item) {
    if (!_isAllowedFood(item.food)) return;
    final food = item.createSelection();
    _addToSelection(food, key: canonicalFoodSelectionKey(food));
  }

  studyu.FoodEntry _foodEntryForResult(UnifiedFoodResult result) {
    return result.source == studyu.FoodSource.openfoodfacts
        ? _convertToFoodEntry(result.originalData as Product)
        : _convertUsdaToFoodEntry(result.originalData as UsdaFoodItem);
  }

  void _selectResult(UnifiedFoodResult result) {
    final foodEntry = _foodEntryForResult(result);
    if (widget.mealLabel == null) {
      _navigateToEdit(foodEntry);
      return;
    }
    final key = canonicalFoodSelectionKey(foodEntry);
    final selected = _selectionStore!.itemFor(key);
    _showQuantity(
      selected?.baseFood ?? foodEntry,
      key: key,
      action: selected == null
          ? FoodQuantityAction.addToSelection
          : FoodQuantityAction.updateSelection,
      caloriesKnown: _resultCaloriesKnown(result),
    );
  }

  void _addResult(UnifiedFoodResult result) {
    final food = _foodEntryForResult(result);
    _addToSelection(
      food,
      key: canonicalFoodSelectionKey(food),
      caloriesKnown: _resultCaloriesKnown(result),
    );
  }

  studyu.FoodEntry _foodEntryForTemplate(studyu.SavedFoodTemplate template) {
    return Provider.of<TemplateViewModel>(
      context,
      listen: false,
    ).applyFoodTemplate(template);
  }

  void _selectFoodTemplate(studyu.SavedFoodTemplate template) {
    if (!_isAllowedFood(template.prototype)) return;
    final foodEntry = _foodEntryForTemplate(template);
    if (widget.mealLabel == null) {
      _completeSingleSelection(foodEntry);
      return;
    }
    final key = canonicalFoodSelectionKey(foodEntry);
    final selected = _selectionStore!.itemFor(key);
    _showQuantity(
      selected?.baseFood ?? foodEntry,
      key: key,
      action: selected == null
          ? FoodQuantityAction.addToSelection
          : FoodQuantityAction.updateSelection,
    );
  }

  void _addFoodTemplate(studyu.SavedFoodTemplate template) {
    if (!_isAllowedFood(template.prototype)) return;
    final food = _foodEntryForTemplate(template);
    _addToSelection(food, key: canonicalFoodSelectionKey(food));
  }

  Future<void> _showQuantity(
    studyu.FoodEntry foodEntry, {
    String? key,
    FoodQuantityAction action = FoodQuantityAction.existingMeal,
    bool caloriesKnown = true,
  }) async {
    if (_showServingHint) {
      setState(() => _showServingHint = false);
    }
    final selected = key == null ? null : _selectionStore?.itemFor(key);
    final result = await FoodQuantitySheet.show(
      context,
      food: foodEntry,
      mealLabel: widget.mealLabel,
      action: action,
      initialAmount: selected == null
          ? null
          : selected.baseFood.amount * selected.quantity,
    );
    if (result == null || !mounted) return;
    if (action == FoodQuantityAction.updateSelection && key != null) {
      _selectionStore!.replaceBase(
        key,
        result,
        caloriesKnown:
            _selectionStore.itemFor(key)?.caloriesKnown ?? caloriesKnown,
      );
    } else if (action == FoodQuantityAction.addToSelection) {
      _addToSelection(
        result,
        key: key ?? canonicalFoodSelectionKey(result),
        caloriesKnown: caloriesKnown,
      );
    } else {
      _completeSingleSelection(result);
    }
  }

  Future<void> _showReviewSheet(FoodSelectionStore store) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          _SelectionReviewSheet(store: store, mealLabel: widget.mealLabel!),
    );
    if (confirmed == true && mounted) _confirmSelection(store);
  }

  void _confirmSelection(FoodSelectionStore store) {
    if (_isConfirming || store.isEmpty) return;
    setState(() => _isConfirming = true);
    final foods = store.materialize();
    if (mounted) Navigator.pop(context, FoodSearchSelection(foods));
  }

  void _addToSelection(
    studyu.FoodEntry food, {
    required String key,
    bool caloriesKnown = true,
  }) {
    if (_selectionStore == null) {
      _completeSingleSelection(food);
      return;
    }
    _selectionStore.addOrIncrement(key, food, caloriesKnown: caloriesKnown);
  }

  void _completeSingleSelection(studyu.FoodEntry foodEntry) {
    if (widget.mealLabel != null) {
      Navigator.pop(context, FoodSearchSelection.single(foodEntry));
    } else {
      Navigator.pop(context, foodEntry);
    }
  }

  void _navigateToEdit(studyu.FoodEntry foodEntry) {
    Navigator.push(
      context,
      FoodEntryScreen.route(existingFood: foodEntry, showSearchAction: false),
    ).then((result) {
      if (result != null && mounted) {
        _completeSingleSelection(result);
      }
    });
  }

  void _addManually() {
    Navigator.push(
      context,
      FoodEntryScreen.route(
        showSearchAction: false,
        mealLabel: widget.mealLabel,
      ),
    ).then((result) {
      if (result != null && mounted) {
        if (_selectionStore == null) {
          _completeSingleSelection(result);
        } else {
          _addToSelection(result, key: canonicalFoodSelectionKey(result));
        }
      }
    });
  }

  void _createMeal() {
    Navigator.push<studyu.FoodEntry>(context, MealCreatorScreen.route()).then((
      result,
    ) {
      if (result != null && mounted) {
        if (_selectionStore == null) {
          _completeSingleSelection(result);
        } else {
          _addToSelection(result, key: canonicalFoodSelectionKey(result));
        }
      }
    });
  }

  void _openFoodLibrary() {
    Navigator.push(context, FoodLibraryScreen.route());
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<studyu.FoodEntry>(
      context,
      BarcodeScannerScreen.route(),
    );
    if (result == null || !mounted) return;
    if (widget.mealLabel == null) {
      _navigateToEdit(result);
    } else {
      final key = canonicalFoodSelectionKey(result);
      final selected = _selectionStore!.itemFor(key);
      await _showQuantity(
        selected?.baseFood ?? result,
        key: key,
        action: selected == null
            ? FoodQuantityAction.addToSelection
            : FoodQuantityAction.updateSelection,
      );
    }
  }

  bool _isAllowedTemplate(studyu.SavedFoodTemplate template) {
    return widget.allowMeals ||
        template.prototype.entryType != studyu.FoodEntryType.meal;
  }

  int _personalResultCount(TemplateViewModel templateViewModel) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return 0;
    return templateViewModel.foodTemplates
        .where(
          (template) =>
              _isAllowedTemplate(template) &&
              template.name.toLowerCase().contains(query),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final templateViewModel = Provider.of<TemplateViewModel>(context);
    final query = _searchController.text.trim();
    final rankedResults = rankFoodSearchResults(_combinedResults, _activeQuery);
    final personalResultCount = _personalResultCount(templateViewModel);
    final visibleResultCount = switch (_selectedFilter) {
      _FoodSearchFilter.all => personalResultCount + _combinedResults.length,
      _FoodSearchFilter.myItems => personalResultCount,
      _FoodSearchFilter.database => _combinedResults.length,
    };
    final databaseComplete = _offSearched && _usdaSearched;
    final searchComplete =
        _hasSearched &&
        !_isInitialLoading &&
        (_selectedFilter == _FoodSearchFilter.myItems || databaseComplete);
    final showSearchFallback =
        query.isNotEmpty &&
        searchComplete &&
        visibleResultCount == 0 &&
        (_selectedFilter == _FoodSearchFilter.myItems || _errorMessage == null);
    String? searchStatus;
    if ((_isInitialLoading || _isLoadingMore) &&
        _selectedFilter != _FoodSearchFilter.myItems) {
      searchStatus = l10n.searching_databases;
    } else if (_errorMessage != null &&
        _selectedFilter != _FoodSearchFilter.myItems) {
      searchStatus = _errorMessage;
    } else if (searchComplete && visibleResultCount == 0) {
      searchStatus = l10n.no_results_for_query(query);
    } else if (_hasSearched && visibleResultCount > 0) {
      searchStatus = l10n.food_search_results_count(visibleResultCount);
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.mealLabel == null ? null : const CloseButton(),
        centerTitle: true,
        title: Text(
          widget.mealLabel == null
              ? l10n.add_food_title
              : l10n.add_items_to_meal(widget.mealLabel!.toLowerCase()),
        ),
        actions: [
          PopupMenuButton<_FoodSearchAction>(
            tooltip: l10n.create,
            onSelected: (action) {
              switch (action) {
                case _FoodSearchAction.food:
                  _addManually();
                case _FoodSearchAction.meal:
                  _createMeal();
                case _FoodSearchAction.foodLibrary:
                  _openFoodLibrary();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _FoodSearchAction.food,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant_outlined),
                    const SizedBox(width: 12),
                    Text(l10n.add_food_action),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _FoodSearchAction.meal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant_menu_outlined),
                    const SizedBox(width: 12),
                    Text(l10n.add_meal_action),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _FoodSearchAction.foodLibrary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_outline),
                    const SizedBox(width: 12),
                    Text(l10n.food_library),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          FoodSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            hintText: l10n.search_food_hint,
            onChanged: (val) => _onSearchChanged(val, templateViewModel),
            onScanBarcode: _scanBarcode,
            barcodeTooltip: l10n.scan_barcode,
          ),
          Semantics(
            liveRegion: true,
            label: searchStatus,
            child: const SizedBox.shrink(),
          ),

          // Content
          Expanded(
            child: _FoodSearchListView(
              scrollController: _scrollController,
              l10n: l10n,
              theme: theme,
              templateViewModel: templateViewModel,
              searchController: _searchController,
              isInitialLoading: _isInitialLoading,
              isLoadingMore: _isLoadingMore,
              hasSearched: _hasSearched,
              offSearched: _offSearched,
              usdaSearched: _usdaSearched,
              offHasMore: _offHasMore,
              usdaHasMore: _usdaHasMore,
              errorMessage: _errorMessage,
              combinedResults: rankedResults,
              history: widget.history,
              selectedSection: _selectedSection,
              selectedFilter: _selectedFilter,
              onSectionChanged: (section) {
                setState(() {
                  _selectedSection = section;
                });
              },
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              onSelectHistory: _selectHistoryItem,
              onAddHistory: _addHistoryItem,
              onSelectFoodTemplate: _selectFoodTemplate,
              onAddFoodTemplate: _addFoodTemplate,
              onSelectResult: _selectResult,
              onAddResult: _addResult,
              onRetry: () => _retrySearch(templateViewModel),
              allowMeals: widget.allowMeals,
              showServingHint: _showServingHint && widget.mealLabel != null,
              selectionStore: _selectionStore,
              selectionKeyForResult: (result) =>
                  canonicalFoodSelectionKey(_foodEntryForResult(result)),
            ),
          ),
          if (showSearchFallback)
            _SearchFallback(query: query, onAddManually: _addManually),
          if (_selectionStore case final store? when !store.isEmpty)
            _SelectionPeekTray(
              store: store,
              mealLabel: widget.mealLabel!,
              isConfirming: _isConfirming,
              onReview: () => _showReviewSheet(store),
              onConfirm: () => _confirmSelection(store),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _SelectionQuantityControl extends StatelessWidget {
  final String name;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _SelectionQuantityControl({
    required this.name,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      selected: true,
      label: l10n.food_selection_selected(name, quantity),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.food_selection_decrement(name),
            onPressed: onDecrement,
            icon: const Icon(Icons.remove),
            visualDensity: VisualDensity.compact,
          ),
          Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            tooltip: l10n.food_selection_increment(name),
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _SelectionPeekTray extends StatelessWidget {
  final FoodSelectionStore store;
  final String mealLabel;
  final bool isConfirming;
  final VoidCallback onReview;
  final VoidCallback onConfirm;

  const _SelectionPeekTray({
    required this.store,
    required this.mealLabel,
    required this.isConfirming,
    required this.onReview,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final keyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final largeText = mediaQuery.textScaler.scale(1) > 1.3;
    final previewLimit = keyboardOpen ? 0 : (largeText ? 1 : 2);
    final previewItems = store.recentItems.take(previewLimit).toList();
    final hiddenItemCount = store.itemCount - previewItems.length;
    final showViewMore = !keyboardOpen && hiddenItemCount > 0;
    final calorieText = _selectionCaloriesSummary(l10n, store);
    final totals = '${l10n.serving_amount(store.servingCount)} · $calorieText';
    final unavailable = store.unknownCaloriesCount == 0
        ? ''
        : ', ${l10n.food_selection_calories_unavailable(store.unknownCaloriesCount)}';
    final totalsSemantics =
        '${l10n.items_count(store.itemCount)}, '
        '${l10n.serving_amount(store.servingCount)}, $calorieText$unavailable';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -200) onReview();
      },
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: onReview,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.food_selection_selected_count(store.itemCount),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.food_selection_selected_items,
                          onPressed: onReview,
                          icon: const Icon(Icons.expand_less),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),
                if (previewItems.isNotEmpty)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    child: Column(
                      children: [
                        for (final item in previewItems)
                          AnimatedSwitcher(
                            key: ValueKey(item.key),
                            duration: const Duration(milliseconds: 180),
                            child: _SelectionPreviewRow(
                              key: ValueKey('${item.key}:${item.quantity}'),
                              item: item,
                              store: store,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (showViewMore)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onReview,
                      child: Text(
                        l10n.food_selection_view_more(hiddenItemCount),
                      ),
                    ),
                  ),
                Semantics(
                  label: totalsSemantics,
                  child: ExcludeSemantics(
                    child: Text(
                      totals,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: isConfirming ? null : onConfirm,
                  child: Text(
                    l10n.food_selection_confirm(store.itemCount, mealLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionPreviewRow extends StatelessWidget {
  final FoodSelectionItem item;
  final FoodSelectionStore store;

  const _SelectionPreviewRow({
    required this.item,
    required this.store,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        _SelectionQuantityControl(
          name: item.name,
          quantity: item.quantity,
          onDecrement: () => store.decrement(item.key),
          onIncrement: () => store.increment(item.key),
        ),
      ],
    );
  }
}

class _SelectionReviewSheet extends StatefulWidget {
  final FoodSelectionStore store;
  final String mealLabel;

  const _SelectionReviewSheet({required this.store, required this.mealLabel});

  @override
  State<_SelectionReviewSheet> createState() => _SelectionReviewSheetState();
}

class _SelectionReviewSheetState extends State<_SelectionReviewSheet> {
  bool _isConfirming = false;

  FoodSelectionStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    store.addListener(onStoreChanged);
  }

  @override
  void dispose() {
    store.removeListener(onStoreChanged);
    super.dispose();
  }

  void onStoreChanged() {
    if (mounted && store.isEmpty) Navigator.pop(context);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final summary = _selectionCaloriesSummary(l10n, store);
    return FractionallySizedBox(
      heightFactor: 0.65,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.food_selection_selected_count(store.itemCount),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: store.items.length,
                itemBuilder: (context, index) {
                  final item = store.items.elementAt(index);
                  final kcal = item.caloriesKnown
                      ? l10n.kcal_value(
                          (item.baseFood.nutrition.energyKcal * item.quantity)
                              .round()
                              .toString(),
                        )
                      : '— kcal';
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      '${l10n.serving_amount(item.quantity)} · $kcal',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.food_selection_decrement(item.name),
                          onPressed: () => store.decrement(item.key),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          tooltip: l10n.food_selection_increment(item.name),
                          onPressed: () => store.increment(item.key),
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          tooltip: l10n.food_selection_delete(item.name),
                          onPressed: () => store.delete(item.key),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${l10n.serving_amount(store.servingCount)} · $summary',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: store.isEmpty || _isConfirming
                        ? null
                        : () {
                            setState(() => _isConfirming = true);
                            Navigator.pop(context, true);
                          },
                    child: Text(
                      l10n.food_selection_confirm(
                        store.itemCount,
                        widget.mealLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSectionTabs extends StatelessWidget {
  final List<_FoodSearchSection> sections;
  final _FoodSearchSection selectedSection;
  final ValueChanged<_FoodSearchSection> onChanged;
  final AppLocalizations l10n;

  const _QuickSectionTabs({
    required this.sections,
    required this.selectedSection,
    required this.onChanged,
    required this.l10n,
  });

  String label(_FoodSearchSection section) {
    return switch (section) {
      _FoodSearchSection.recent => l10n.recent_foods,
      _FoodSearchSection.myItems => l10n.my_saved_items,
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = sections.indexOf(selectedSection);
    return DefaultTabController(
      key: ValueKey(Object.hashAll(sections)),
      length: sections.length,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      child: TabBar(
        isScrollable: true,
        onTap: (index) => onChanged(sections[index]),
        tabs: [for (final section in sections) Tab(text: label(section))],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryFoodCard extends StatelessWidget {
  final FoodSearchHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final ThemeData theme;
  final FoodSelectionStore? selectionStore;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const _HistoryFoodCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
    required this.theme,
    this.selectionStore,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final food = item.food;
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = _foodImageUrl(food);
    final selected = selectionStore?.itemFor(canonicalFoodSelectionKey(food));
    return Semantics(
      selected: selected != null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: selected == null
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: imageUrl == null
                        ? _fallbackItemIcon(theme, Icons.restaurant_outlined)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _fallbackItemIcon(
                                theme,
                                Icons.restaurant_outlined,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              ListTileTheme.of(context).titleTextStyle ??
                              theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selected == null
                              ? _foodServingMetadata(l10n, food)
                              : _selectedFoodServingMetadata(
                                  l10n,
                                  selected.baseFood,
                                  selected.quantity,
                                  caloriesKnown: selected.caloriesKnown,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected == null)
                    TextButton(
                      onPressed: onAdd,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(l10n.add),
                    )
                  else
                    _SelectionQuantityControl(
                      name: food.name,
                      quantity: selected.quantity,
                      onIncrement: onIncrement!,
                      onDecrement: onDecrement!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodResultCard extends StatelessWidget {
  final UnifiedFoodResult result;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final ThemeData theme;
  final FoodSelectionStore? selectionStore;
  final String? selectionKey;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const _FoodResultCard({
    required this.result,
    required this.onTap,
    required this.onAdd,
    required this.theme,
    this.selectionStore,
    this.selectionKey,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calories = _resultCalories(result);
    final selected = selectionKey == null
        ? null
        : selectionStore?.itemFor(selectionKey!);
    final metadata = selected == null
        ? [
            l10n.serving_amount(1),
            if (calories == null)
              '— kcal'
            else
              l10n.kcal_value(calories.round().toString()),
          ].join(' · ')
        : _selectedFoodServingMetadata(
            l10n,
            selected.baseFood,
            selected.quantity,
            caloriesKnown: selected.caloriesKnown,
          );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: selected == null
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: result.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          result.imageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackItemIcon(
                            theme,
                            Icons.restaurant_outlined,
                            size: 24,
                          ),
                        ),
                      )
                    : _fallbackItemIcon(
                        theme,
                        Icons.restaurant_outlined,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metadata,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected == null)
                TextButton(
                  onPressed: onAdd,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.add),
                )
              else
                _SelectionQuantityControl(
                  name: result.name,
                  quantity: selected.quantity,
                  onIncrement: onIncrement!,
                  onDecrement: onDecrement!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.try_again)),
        ],
      ),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  final String message;

  const _EmptySectionMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;

  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        AppLocalizations.of(context)!.no_results_for_query(query),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SearchFallback extends StatelessWidget {
  final String query;
  final VoidCallback onAddManually;

  const _SearchFallback({required this.query, required this.onAddManually});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.cant_find_it,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            FilledButton.tonalIcon(
              onPressed: onAddManually,
              icon: const Icon(Icons.note_add_outlined),
              label: Text(
                AppLocalizations.of(context)!.create_food_from_search(query),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServingHint extends StatelessWidget {
  final AppLocalizations l10n;

  const _ServingHint({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        l10n.tap_item_to_choose_serving,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FoodSearchListView extends StatelessWidget {
  final ScrollController scrollController;
  final AppLocalizations l10n;
  final ThemeData theme;
  final TemplateViewModel templateViewModel;
  final TextEditingController searchController;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasSearched;
  final bool offSearched;
  final bool usdaSearched;
  final bool offHasMore;
  final bool usdaHasMore;
  final String? errorMessage;
  final List<UnifiedFoodResult> combinedResults;
  final FoodSearchHistory history;
  final _FoodSearchSection selectedSection;
  final ValueChanged<_FoodSearchSection> onSectionChanged;
  final _FoodSearchFilter selectedFilter;
  final ValueChanged<_FoodSearchFilter> onFilterChanged;
  final void Function(FoodSearchHistoryItem) onSelectHistory;
  final void Function(FoodSearchHistoryItem) onAddHistory;
  final void Function(studyu.SavedFoodTemplate) onSelectFoodTemplate;
  final void Function(studyu.SavedFoodTemplate) onAddFoodTemplate;
  final void Function(UnifiedFoodResult) onSelectResult;
  final void Function(UnifiedFoodResult) onAddResult;
  final VoidCallback onRetry;
  final bool allowMeals;
  final bool showServingHint;
  final FoodSelectionStore? selectionStore;
  final String Function(UnifiedFoodResult)? selectionKeyForResult;

  const _FoodSearchListView({
    required this.scrollController,
    required this.l10n,
    required this.theme,
    required this.templateViewModel,
    required this.searchController,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasSearched,
    required this.offSearched,
    required this.usdaSearched,
    required this.offHasMore,
    required this.usdaHasMore,
    required this.errorMessage,
    required this.combinedResults,
    required this.history,
    required this.selectedSection,
    required this.onSectionChanged,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSelectHistory,
    required this.onAddHistory,
    required this.onSelectFoodTemplate,
    required this.onAddFoodTemplate,
    required this.onSelectResult,
    required this.onAddResult,
    required this.onRetry,
    this.allowMeals = true,
    required this.showServingHint,
    this.selectionStore,
    this.selectionKeyForResult,
  });

  bool isAllowedTemplate(studyu.SavedFoodTemplate template) {
    return allowMeals ||
        template.prototype.entryType != studyu.FoodEntryType.meal;
  }

  List<studyu.SavedFoodTemplate> personalMatches0() {
    final query = searchController.text.trim().toLowerCase();
    return templateViewModel.foodTemplates
        .where(
          (template) =>
              isAllowedTemplate(template) &&
              template.name.toLowerCase().contains(query),
        )
        .toList();
  }

  List<FoodSearchHistoryItem> recentItems0() {
    final items = [...history.frequentlyUsed, ...history.recent]
        .where(
          (item) =>
              allowMeals || item.food.entryType != studyu.FoodEntryType.meal,
        )
        .toList();
    return items..sort((left, right) {
      final dateComparison = right.lastUsedAt.compareTo(left.lastUsedAt);
      if (dateComparison != 0) return dateComparison;
      final countComparison = right.useCount.compareTo(left.useCount);
      return countComparison != 0
          ? countComparison
          : left.identity.compareTo(right.identity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim();
    if (query.isEmpty && selectedSection == _FoodSearchSection.myItems) {
      return FoodLibrary(
        allowMeals: allowMeals,
        showSearch: false,
        scrollController: scrollController,
        header: _QuickSectionTabs(
          sections: const [
            _FoodSearchSection.recent,
            _FoodSearchSection.myItems,
          ],
          selectedSection: selectedSection,
          onChanged: onSectionChanged,
          l10n: l10n,
        ),
        listHeader: showServingHint ? _ServingHint(l10n: l10n) : null,
        onTap: onSelectFoodTemplate,
        onAdd: onAddFoodTemplate,
        isSelected: (template) {
          final food = templateViewModel.applyFoodTemplate(template);
          return selectionStore?.itemFor(canonicalFoodSelectionKey(food)) !=
              null;
        },
        selectedQuantity: (template) {
          final food = templateViewModel.applyFoodTemplate(template);
          return selectionStore
                  ?.itemFor(canonicalFoodSelectionKey(food))
                  ?.quantity ??
              1;
        },
        onIncrement: onAddFoodTemplate,
        onDecrement: (template) {
          final food = templateViewModel.applyFoodTemplate(template);
          selectionStore?.decrement(canonicalFoodSelectionKey(food));
        },
        showManagementActions: false,
      );
    }

    final children = <Widget>[];
    if (query.isEmpty) {
      children.add(
        _QuickSectionTabs(
          sections: const [
            _FoodSearchSection.recent,
            _FoodSearchSection.myItems,
          ],
          selectedSection: selectedSection,
          onChanged: onSectionChanged,
          l10n: l10n,
        ),
      );
      children.add(const SizedBox(height: 4));
      final recentItems = recentItems0();
      if (recentItems.isEmpty) {
        children.add(_EmptySectionMessage(message: l10n.no_recent_items));
      } else {
        if (showServingHint) children.add(_ServingHint(l10n: l10n));
        children.addAll(
          recentItems.map(
            (item) => _HistoryFoodCard(
              item: item,
              onTap: () => onSelectHistory(item),
              onAdd: () => onAddHistory(item),
              theme: theme,
              selectionStore: selectionStore,
              onIncrement: () => onAddHistory(item),
              onDecrement: () => selectionStore?.decrement(
                canonicalFoodSelectionKey(item.food),
              ),
            ),
          ),
        );
      }
      children.add(const SizedBox(height: 24));
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: children,
      );
    }

    children.add(
      _SearchFilterChips(
        selectedFilter: selectedFilter,
        onChanged: onFilterChanged,
        l10n: l10n,
      ),
    );
    children.add(const SizedBox(height: 12));

    final personalMatches = personalMatches0();
    final showPersonal = selectedFilter != _FoodSearchFilter.database;
    final showDatabase = selectedFilter != _FoodSearchFilter.myItems;
    final databaseComplete = offSearched && usdaSearched;
    final selectedSearchComplete =
        hasSearched &&
        !isInitialLoading &&
        (selectedFilter == _FoodSearchFilter.myItems || databaseComplete);
    final noVisibleResults =
        !(showPersonal && personalMatches.isNotEmpty) &&
        !(showDatabase && combinedResults.isNotEmpty);
    final showGlobalNoResults = selectedSearchComplete && noVisibleResults;
    if (showServingHint &&
        ((showDatabase && combinedResults.isNotEmpty) ||
            (showPersonal && personalMatches.isNotEmpty))) {
      children.add(_ServingHint(l10n: l10n));
    }

    if (showGlobalNoResults) {
      children.add(_NoResultsState(query: query));
    } else {
      if (showPersonal) {
        children.add(
          _SectionHeader(
            icon: Icons.bookmark_outline,
            title: l10n.my_saved_items,
            iconColor: theme.colorScheme.primary,
          ),
        );
        children.add(const SizedBox(height: 8));
        if (personalMatches.isEmpty) {
          children.add(
            _EmptySectionMessage(message: l10n.no_matching_templates),
          );
        } else {
          children.addAll(
            personalMatches.map(
              (template) => FoodLibraryItemCard(
                template: template,
                onTap: onSelectFoodTemplate,
                onAdd: onAddFoodTemplate,
                isSelected:
                    selectionStore?.itemFor(
                      canonicalFoodSelectionKey(
                        templateViewModel.applyFoodTemplate(template),
                      ),
                    ) !=
                    null,
                selectedQuantity:
                    selectionStore
                        ?.itemFor(
                          canonicalFoodSelectionKey(
                            templateViewModel.applyFoodTemplate(template),
                          ),
                        )
                        ?.quantity ??
                    1,
                onIncrement: () => onAddFoodTemplate(template),
                onDecrement: () => selectionStore?.decrement(
                  canonicalFoodSelectionKey(
                    templateViewModel.applyFoodTemplate(template),
                  ),
                ),
                showManagementActions: false,
              ),
            ),
          );
        }
      }

      if (showDatabase) {
        if (showPersonal) children.add(const SizedBox(height: 12));
        children.add(
          _SectionHeader(
            icon: Icons.public,
            title: l10n.global_database,
            iconColor: theme.colorScheme.onSurfaceVariant,
          ),
        );
        children.add(const SizedBox(height: 8));
        if (isInitialLoading && combinedResults.isEmpty) {
          children.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          if (combinedResults.isNotEmpty) {
            children.addAll(
              combinedResults.map(
                (result) => _FoodResultCard(
                  result: result,
                  onTap: () => onSelectResult(result),
                  onAdd: () => onAddResult(result),
                  theme: theme,
                  selectionStore: selectionStore,
                  selectionKey: selectionKeyForResult?.call(result),
                  onIncrement: () => onAddResult(result),
                  onDecrement: () => selectionStore?.decrement(
                    selectionKeyForResult?.call(result) ?? result.id,
                  ),
                ),
              ),
            );
          }
          if (errorMessage != null) {
            children.add(
              _ErrorMessage(message: errorMessage!, onRetry: onRetry),
            );
          } else if (databaseComplete && combinedResults.isEmpty) {
            children.add(
              _EmptySectionMessage(message: l10n.no_matching_templates),
            );
          }
        }
        if (isLoadingMore || (isInitialLoading && combinedResults.isNotEmpty)) {
          children.add(
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (hasSearched &&
            combinedResults.isNotEmpty &&
            !offHasMore &&
            !usdaHasMore &&
            !isInitialLoading &&
            !isLoadingMore) {
          children.add(
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  l10n.end_of_results,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
          );
        }
      }
    }

    children.add(const SizedBox(height: 24));
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: children,
    );
  }
}

class _SearchFilterChips extends StatelessWidget {
  final _FoodSearchFilter selectedFilter;
  final ValueChanged<_FoodSearchFilter> onChanged;
  final AppLocalizations l10n;

  const _SearchFilterChips({
    required this.selectedFilter,
    required this.onChanged,
    required this.l10n,
  });

  String label(_FoodSearchFilter filter) => switch (filter) {
    _FoodSearchFilter.all => l10n.filter_all,
    _FoodSearchFilter.myItems => l10n.my_saved_items,
    _FoodSearchFilter.database => l10n.database,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _FoodSearchFilter.values) ...[
            FilterChip(
              selected: selectedFilter == filter,
              label: Text(label(filter)),
              onSelected: (_) => onChanged(filter),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}
