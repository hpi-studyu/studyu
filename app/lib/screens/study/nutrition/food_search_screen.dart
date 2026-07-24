import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_history.dart';
import 'package:studyu_app/screens/study/nutrition/my_templates_screen.dart';
import 'package:studyu_app/screens/study/nutrition/recipe_builder_screen.dart';
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

String _formatGrams(double grams) => grams == grams.roundToDouble()
    ? grams.round().toString()
    : grams.toStringAsFixed(1);

final class FoodSearchSelection {
  final List<studyu.FoodEntry> foods;

  FoodSearchSelection(Iterable<studyu.FoodEntry> foods)
    : foods = List.unmodifiable(foods);

  FoodSearchSelection.single(studyu.FoodEntry food)
    : foods = List.unmodifiable([food]);
}

enum _FoodSearchSection { recent, myItems }

enum _FoodSearchFilter { all, myItems, database }

class FoodSearchScreen extends StatelessWidget {
  final bool allowRecipes;
  final bool allowMealTemplates;
  final String? mealLabel;
  final OpenFoodFactsSearch? openFoodFactsSearch;
  final UsdaFoodSearch? usdaFoodSearch;

  const FoodSearchScreen({
    this.allowRecipes = true,
    this.allowMealTemplates = false,
    this.mealLabel,
    this.openFoodFactsSearch,
    this.usdaFoodSearch,
    super.key,
  });

  static MaterialPageRoute<studyu.FoodEntry> route({
    bool allowRecipes = true,
  }) => MaterialPageRoute(
    builder: (_) => FoodSearchScreen(allowRecipes: allowRecipes),
  );

  static Future<FoodSearchSelection?> show(
    BuildContext context, {
    required String mealLabel,
    bool allowRecipes = true,
    OpenFoodFactsSearch? openFoodFactsSearch,
    UsdaFoodSearch? usdaFoodSearch,
  }) => showModalBottomSheet<FoodSearchSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.96,
      child: FoodSearchScreen(
        allowRecipes: allowRecipes,
        allowMealTemplates: true,
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
        allowRecipes: allowRecipes,
        allowMealTemplates: allowMealTemplates,
        mealLabel: mealLabel,
        openFoodFactsSearch: openFoodFactsSearch,
        usdaFoodSearch: usdaFoodSearch,
        history: history,
      ),
    );
  }
}

class _FoodSearchScreenContent extends StatefulWidget {
  final bool allowRecipes;
  final bool allowMealTemplates;
  final String? mealLabel;
  final OpenFoodFactsSearch? openFoodFactsSearch;
  final UsdaFoodSearch? usdaFoodSearch;
  final FoodSearchHistory history;

  const _FoodSearchScreenContent({
    this.allowRecipes = true,
    this.allowMealTemplates = false,
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

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'StudyU',
      version: '1.0',
      system: 'Flutter',
      url: 'https://studyu.health',
    );
    OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH];

    _scrollController.addListener(_onScroll);

    // Auto-focus search field on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
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
          calories: food.energyKcal100g,
          calorieBasisGrams: 100,
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

  void _selectHistoryItem(FoodSearchHistoryItem item) {
    _showQuantity(item.createSelection());
  }

  void _selectResult(UnifiedFoodResult result) {
    final foodEntry = result.source == studyu.FoodSource.openfoodfacts
        ? _convertToFoodEntry(result.originalData as Product)
        : _convertUsdaToFoodEntry(result.originalData as UsdaFoodItem);
    if (widget.mealLabel == null) {
      _navigateToEdit(foodEntry);
    } else {
      _showQuantity(foodEntry);
    }
  }

  void _selectFoodTemplate(studyu.SavedFoodTemplate template) {
    final templateViewModel = Provider.of<TemplateViewModel>(
      context,
      listen: false,
    );
    final foodEntry = templateViewModel.applyFoodTemplate(template);
    if (widget.allowMealTemplates) {
      _showQuantity(foodEntry);
    } else {
      Navigator.pop(context, foodEntry);
    }
  }

  void _selectMealTemplate(studyu.SavedMealTemplate template) {
    final templateViewModel = Provider.of<TemplateViewModel>(
      context,
      listen: false,
    );
    final meal = templateViewModel.applyMealTemplate(template);
    Navigator.pop(context, FoodSearchSelection(meal.foods));
  }

  Future<void> _showQuantity(studyu.FoodEntry foodEntry) async {
    final result = await FoodQuantitySheet.show(
      context,
      food: foodEntry,
      mealLabel: widget.mealLabel,
    );
    if (result != null && mounted) {
      _completeSingleSelection(result);
    }
  }

  void _completeSingleSelection(studyu.FoodEntry foodEntry) {
    if (widget.allowMealTemplates) {
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
        _completeSingleSelection(result);
      }
    });
  }

  void _createRecipe() {
    Navigator.push(context, RecipeBuilderScreen.route()).then((result) {
      if (result != null && mounted) {
        _completeSingleSelection(result);
      }
    });
  }

  Future<void> _manageSavedItems(TemplateViewModel templateViewModel) async {
    await Navigator.push(context, MyTemplatesScreen.route());
    if (mounted) await templateViewModel.loadAllTemplates();
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
      await _showQuantity(result);
    }
  }

  bool _isAllowedTemplate(dynamic template) {
    if (template is studyu.SavedMealTemplate) return widget.allowMealTemplates;
    if (template is studyu.SavedFoodTemplate) {
      return widget.allowRecipes ||
          template.prototype.entryType != studyu.FoodEntryType.recipe;
    }
    return false;
  }

  int _personalResultCount(TemplateViewModel templateViewModel) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return 0;
    return [
      ...templateViewModel.mealTemplates,
      ...templateViewModel.foodTemplates,
    ].where((template) {
      if (template is studyu.SavedMealTemplate) {
        return _isAllowedTemplate(template) &&
            template.name.toLowerCase().contains(query);
      }
      if (template is studyu.SavedFoodTemplate) {
        return _isAllowedTemplate(template) &&
            template.name.toLowerCase().contains(query);
      }
      return false;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final templateViewModel = Provider.of<TemplateViewModel>(context);
    final rankedResults = rankFoodSearchResults(_combinedResults, _activeQuery);
    final personalResultCount = _personalResultCount(templateViewModel);
    final totalResultCount = personalResultCount + _combinedResults.length;
    String? searchStatus;
    if (_isInitialLoading || _isLoadingMore) {
      searchStatus = l10n.searching_databases;
    } else if (_errorMessage != null) {
      searchStatus = _errorMessage;
    } else if (_hasSearched &&
        totalResultCount == 0 &&
        _offSearched &&
        _usdaSearched) {
      searchStatus = l10n.no_results_found;
    } else if (_hasSearched && totalResultCount > 0) {
      searchStatus = l10n.food_search_results_count(totalResultCount);
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.mealLabel == null ? null : const CloseButton(),
        title: Text(
          widget.mealLabel == null
              ? l10n.add_food_title
              : l10n.add_food_to_meal(widget.mealLabel!),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          _SearchBarHeader(
            controller: _searchController,
            focusNode: _searchFocusNode,
            l10n: l10n,
            onChanged: (val) => _onSearchChanged(val, templateViewModel),
            onClear: () {
              _searchController.clear();
              _onSearchChanged('', templateViewModel);
            },
            onScanBarcode: _scanBarcode,
          ),
          if (_searchController.text.trim().isEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 2),
                child: TextButton.icon(
                  onPressed: _addManually,
                  icon: const Icon(Icons.edit_note_outlined, size: 18),
                  label: Text(l10n.add_manually),
                ),
              ),
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
              onSelectFoodTemplate: _selectFoodTemplate,
              onSelectMealTemplate: _selectMealTemplate,
              onManageSavedItems: () => _manageSavedItems(templateViewModel),
              onSelectResult: _selectResult,
              onAddManually: _addManually,
              onCreateRecipe: _createRecipe,
              onRetry: () => _retrySearch(templateViewModel),
              allowRecipes: widget.allowRecipes,
              allowMealTemplates: widget.allowMealTemplates,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _SearchBarHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onScanBarcode;

  const _SearchBarHeader({
    required this.controller,
    required this.focusNode,
    required this.l10n,
    required this.onChanged,
    required this.onClear,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.search_food_hint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : IconButton(
                  tooltip: l10n.scan_barcode,
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  onPressed: onScanBarcode,
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) => focusNode.unfocus(),
        onChanged: onChanged,
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

  String _label(_FoodSearchSection section) {
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
        tabs: [for (final section in sections) Tab(text: _label(section))],
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

class _TemplateCard extends StatelessWidget {
  final Object template;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mealTemplate = template is studyu.SavedMealTemplate
        ? template as studyu.SavedMealTemplate
        : null;
    final foodTemplate = template is studyu.SavedFoodTemplate
        ? template as studyu.SavedFoodTemplate
        : null;
    final isRecipe =
        foodTemplate?.prototype.entryType == studyu.FoodEntryType.recipe;
    final name = mealTemplate?.name ?? foodTemplate!.name;

    final foodBasis =
        foodTemplate != null &&
            foodTemplate.prototype.source != studyu.FoodSource.manual &&
            foodTemplate.prototype.unit.trim().isNotEmpty
        ? ' / ${foodTemplate.prototype.unit.trim()}'
        : '';
    final metadata = mealTemplate != null
        ? '${l10n.template_type_meal} • ${l10n.items_count(mealTemplate.prototypes.length)}'
        : isRecipe
        ? [
            l10n.template_type_recipe,
            l10n.servings_value(
              foodTemplate!.prototype.amount.toStringAsFixed(0),
            ),
            l10n.kcal_per_serving(
              foodTemplate.prototype.nutrition.energyKcal.round().toString(),
            ),
          ].join(' • ')
        : [
            l10n.template_type_food,
            if (foodTemplate!.prototype.source == studyu.FoodSource.manual)
              l10n.custom
            else
              l10n.database,
            '${l10n.kcal_value(foodTemplate.prototype.nutrition.energyKcal.round().toString())}$foodBasis',
          ].join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isRecipe
                ? Colors.orange.withValues(alpha: 0.12)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            mealTemplate != null
                ? Icons.restaurant_menu_outlined
                : isRecipe
                ? Icons.menu_book_outlined
                : Icons.fastfood_outlined,
            size: 22,
            color: isRecipe
                ? Colors.orange.shade700
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          metadata,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _HistoryFoodCard extends StatelessWidget {
  final FoodSearchHistoryItem item;
  final VoidCallback onTap;
  final ThemeData theme;

  const _HistoryFoodCard({
    required this.item,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final food = item.food;
    final l10n = AppLocalizations.of(context)!;
    final brand = food.brandName?.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          Icons.fastfood_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(food.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            if (brand != null && brand.isNotEmpty) brand,
            l10n.kcal_value(food.nutrition.energyKcal.round().toString()),
          ].join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _FoodResultCard extends StatelessWidget {
  final UnifiedFoodResult result;
  final VoidCallback onTap;
  final ThemeData theme;

  const _FoodResultCard({
    required this.result,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image or fallback icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: result.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          result.imageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return _buildFallbackIcon();
                          },
                        ),
                      )
                    : _buildFallbackIcon(),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _SourceBadge(
                          source: result.source,
                          hasBrand: result.brand?.trim().isNotEmpty ?? false,
                        ),
                        if (result.brand != null &&
                            result.brand!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.brand!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Calories
              if (result.calories != null)
                Column(
                  children: [
                    Text(
                      '${result.calories!.round()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    if (result.calorieBasisGrams != null)
                      Text(
                        result.calorieBasisGrams == 100
                            ? l10n.calorie_basis_100g
                            : l10n.calorie_basis_grams(
                                _formatGrams(result.calorieBasisGrams!),
                              ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return const Center(child: Icon(Icons.fastfood_outlined, size: 24));
  }
}

class _SourceBadge extends StatelessWidget {
  final studyu.FoodSource source;
  final bool hasBrand;

  const _SourceBadge({required this.source, required this.hasBrand});

  @override
  Widget build(BuildContext context) {
    final isOff = source == studyu.FoodSource.openfoodfacts;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOff
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        hasBrand
            ? AppLocalizations.of(context)!.brand
            : AppLocalizations.of(context)!.database,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOff ? Colors.green.shade700 : Colors.orange.shade700,
          letterSpacing: 0.3,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: Text(l10n.try_again)),
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
  final VoidCallback onAddManually;
  final VoidCallback onCreateRecipe;
  final bool allowRecipes;

  const _NoResultsState({
    required this.query,
    required this.onAddManually,
    required this.onCreateRecipe,
    required this.allowRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(l10n.no_results_found, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onAddManually,
            icon: const Icon(Icons.edit_note_outlined),
            label: Text(l10n.create_food_from_search(query)),
          ),
          if (allowRecipes) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onCreateRecipe,
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(l10n.create_recipe),
            ),
          ],
        ],
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
  final void Function(studyu.SavedFoodTemplate) onSelectFoodTemplate;
  final void Function(studyu.SavedMealTemplate) onSelectMealTemplate;
  final VoidCallback onManageSavedItems;
  final void Function(UnifiedFoodResult) onSelectResult;
  final VoidCallback onAddManually;
  final VoidCallback onCreateRecipe;
  final VoidCallback onRetry;
  final bool allowRecipes;
  final bool allowMealTemplates;

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
    required this.onSelectFoodTemplate,
    required this.onSelectMealTemplate,
    required this.onManageSavedItems,
    required this.onSelectResult,
    required this.onAddManually,
    required this.onCreateRecipe,
    required this.onRetry,
    this.allowRecipes = true,
    this.allowMealTemplates = false,
  });

  bool _isAllowedTemplate(dynamic template) {
    if (template is studyu.SavedMealTemplate) return allowMealTemplates;
    if (template is studyu.SavedFoodTemplate) {
      return allowRecipes ||
          template.prototype.entryType != studyu.FoodEntryType.recipe;
    }
    return false;
  }

  List<Object> _personalMatches() {
    final query = searchController.text.trim().toLowerCase();
    return [
      ...templateViewModel.mealTemplates,
      ...templateViewModel.foodTemplates,
    ].where((template) {
      if (template is studyu.SavedMealTemplate) {
        return _isAllowedTemplate(template) &&
            template.name.toLowerCase().contains(query);
      }
      if (template is studyu.SavedFoodTemplate) {
        return _isAllowedTemplate(template) &&
            template.name.toLowerCase().contains(query);
      }
      return false;
    }).toList();
  }

  List<FoodSearchHistoryItem> _recentItems() {
    return [...history.frequentlyUsed, ...history.recent]..sort((left, right) {
      final dateComparison = right.lastUsedAt.compareTo(left.lastUsedAt);
      if (dateComparison != 0) return dateComparison;
      final countComparison = right.useCount.compareTo(left.useCount);
      return countComparison != 0
          ? countComparison
          : left.identity.compareTo(right.identity);
    });
  }

  Widget _templateCard(Object template) {
    return _TemplateCard(
      template: template,
      onTap: () {
        if (template is studyu.SavedMealTemplate) {
          onSelectMealTemplate(template);
        } else if (template is studyu.SavedFoodTemplate) {
          onSelectFoodTemplate(template);
        }
      },
      theme: theme,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim();
    final children = <Widget>[const SizedBox(height: 8)];
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
      children.add(const SizedBox(height: 12));
      if (selectedSection == _FoodSearchSection.recent) {
        final recentItems = _recentItems();
        if (recentItems.isEmpty) {
          children.add(_EmptySectionMessage(message: l10n.no_recent_items));
        } else {
          children.addAll(
            recentItems.map(
              (item) => _HistoryFoodCard(
                item: item,
                onTap: () => onSelectHistory(item),
                theme: theme,
              ),
            ),
          );
        }
      } else {
        final filteredTemplates = templateViewModel.filteredTemplates
            .where(_isAllowedTemplate)
            .cast<Object>()
            .toList();
        children.add(
          _MyItemsToolbar(
            viewModel: templateViewModel,
            l10n: l10n,
            onManage: onManageSavedItems,
          ),
        );
        children.add(const SizedBox(height: 8));
        if (filteredTemplates.isEmpty) {
          children.add(_EmptySectionMessage(message: l10n.no_templates_saved));
        } else {
          children.addAll(filteredTemplates.map(_templateCard));
        }
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

    final personalMatches = _personalMatches();
    final showPersonal = selectedFilter != _FoodSearchFilter.database;
    final showDatabase = selectedFilter != _FoodSearchFilter.myItems;
    final databaseComplete = offSearched && usdaSearched;

    if (showPersonal && personalMatches.isNotEmpty) {
      children.add(
        _SectionHeader(
          icon: Icons.bookmark_outline,
          title: l10n.my_saved_items,
          iconColor: theme.colorScheme.primary,
        ),
      );
      children.add(const SizedBox(height: 8));
      children.addAll(personalMatches.map(_templateCard));
    }

    if (showDatabase) {
      children.add(
        _SectionHeader(
          icon: Icons.public,
          title: l10n.global_database,
          iconColor: Colors.grey.shade700,
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
      } else if (errorMessage != null && combinedResults.isEmpty) {
        children.add(_ErrorMessage(message: errorMessage!, onRetry: onRetry));
      } else if (combinedResults.isNotEmpty) {
        children.addAll(
          combinedResults.map(
            (result) => _FoodResultCard(
              result: result,
              onTap: () => onSelectResult(result),
              theme: theme,
            ),
          ),
        );
      } else if (databaseComplete) {
        children.add(_EmptySectionMessage(message: l10n.no_results_found));
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

    final noVisibleResults =
        databaseComplete &&
        !(showPersonal && personalMatches.isNotEmpty) &&
        !(showDatabase && combinedResults.isNotEmpty);
    if (hasSearched && noVisibleResults) {
      children.add(
        _NoResultsState(
          query: query,
          onAddManually: onAddManually,
          onCreateRecipe: onCreateRecipe,
          allowRecipes: allowRecipes,
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
}

class _MyItemsToolbar extends StatelessWidget {
  final TemplateViewModel viewModel;
  final AppLocalizations l10n;
  final VoidCallback onManage;

  const _MyItemsToolbar({
    required this.viewModel,
    required this.l10n,
    required this.onManage,
  });

  String _label(TemplateFilter filter) => switch (filter) {
    TemplateFilter.all => l10n.filter_all,
    TemplateFilter.foods => l10n.filter_foods,
    TemplateFilter.meals => l10n.filter_meals,
    TemplateFilter.recipes => l10n.filter_recipes,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in TemplateFilter.values) ...[
                  FilterChip(
                    selected: viewModel.currentFilter == filter,
                    label: Text(_label(filter)),
                    onSelected: (_) => viewModel.setFilter(filter),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: onManage,
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          child: Text(l10n.manage_saved_items),
        ),
      ],
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

  String _label(_FoodSearchFilter filter) => switch (filter) {
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
              label: Text(_label(filter)),
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
