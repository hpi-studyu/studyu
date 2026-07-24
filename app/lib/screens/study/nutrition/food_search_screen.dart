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

final class FoodSearchSelection {
  final List<studyu.FoodEntry> foods;

  FoodSearchSelection(Iterable<studyu.FoodEntry> foods)
    : foods = List.unmodifiable(foods);

  FoodSearchSelection.single(studyu.FoodEntry food)
    : foods = List.unmodifiable([food]);
}

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
    final userId = appState.activeSubject?.id ?? 'anonymous';

    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId),
      child: _FoodSearchScreenContent(
        allowRecipes: allowRecipes,
        allowMealTemplates: allowMealTemplates,
        mealLabel: mealLabel,
        openFoodFactsSearch: openFoodFactsSearch,
        usdaFoodSearch: usdaFoodSearch,
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

  const _FoodSearchScreenContent({
    this.allowRecipes = true,
    this.allowMealTemplates = false,
    this.mealLabel,
    this.openFoodFactsSearch,
    this.usdaFoodSearch,
  });

  @override
  State<_FoodSearchScreenContent> createState() =>
      _FoodSearchScreenContentState();
}

class _FoodSearchScreenContentState extends State<_FoodSearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();
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
        final calories = nutriments?.getValue(
          Nutrient.energyKCal,
          PerSize.oneHundredGrams,
        );

        return UnifiedFoodResult(
          id: product.barcode ?? '',
          name: product.productName ?? 'Unknown',
          brand: product.brands,
          imageUrl: product.imageFrontSmallUrl,
          calories: calories,
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
      FoodEntryScreen.route(showSearchAction: false),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final templateViewModel = Provider.of<TemplateViewModel>(context);
    String? searchStatus;
    if (_isInitialLoading || _isLoadingMore) {
      searchStatus = l10n.searching_databases;
    } else if (_errorMessage != null) {
      searchStatus = _errorMessage;
    } else if (_hasSearched &&
        _combinedResults.isEmpty &&
        _offSearched &&
        _usdaSearched) {
      searchStatus = l10n.no_results_found;
    } else if (_hasSearched && _combinedResults.isNotEmpty) {
      searchStatus = l10n.food_search_results_count(_combinedResults.length);
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
              combinedResults: _combinedResults,
              onSelectFoodTemplate: _selectFoodTemplate,
              onSelectMealTemplate: _selectMealTemplate,
              onManageSavedItems: () => _manageSavedItems(templateViewModel),
              onSelectResult: _selectResult,
              onAddManually: _addManually,
              onCreateRecipe: _createRecipe,
              onScanBarcode: _scanBarcode,
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

  const _SearchBarHeader({
    required this.controller,
    required this.focusNode,
    required this.l10n,
    required this.onChanged,
    required this.onClear,
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
              : null,
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ?trailing,
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
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          mealTemplate != null
              ? l10n.items_count(mealTemplate.prototypes.length)
              : '${isRecipe ? "Recipe • " : ""}${foodTemplate!.prototype.nutrition.energyKcal.round()} kcal',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.add_circle_outline,
          color: theme.colorScheme.primary,
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
                        _SourceBadge(source: result.source),
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
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    final isOff = result.source == studyu.FoodSource.openfoodfacts;
    return Center(
      child: Icon(
        isOff ? Icons.eco_outlined : Icons.agriculture_outlined,
        size: 24,
        color: isOff ? Colors.green.shade600 : Colors.orange.shade600,
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final studyu.FoodSource source;

  const _SourceBadge({required this.source});

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
        isOff ? 'OFF' : 'USDA',
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

class _LoadingState extends StatelessWidget {
  final ThemeData theme;

  const _LoadingState({required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.searching_databases,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
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
  final VoidCallback onAddManually;
  final VoidCallback onCreateRecipe;
  final bool allowRecipes;

  const _NoResultsState({
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
            label: Text(l10n.add_food_manually),
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

class _InitialPrompt extends StatelessWidget {
  final ThemeData theme;

  const _InitialPrompt({required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.search_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.search_for_food,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.search_food_description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final VoidCallback onManualTap;
  final VoidCallback onScanTap;
  final ThemeData theme;

  const _QuickActionsCard({
    required this.onManualTap,
    required this.onScanTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        children: [
          _QuickActionTile(
            icon: Icons.edit_note_outlined,
            iconColor: Colors.purple,
            title: l10n.add_manually,
            subtitle: l10n.add_manually_subtitle,
            onTap: onManualTap,
            theme: theme,
          ),
          const Divider(height: 1, indent: 68),
          _QuickActionTile(
            icon: Icons.qr_code_scanner_outlined,
            iconColor: Colors.green,
            title: l10n.scan_barcode,
            subtitle: l10n.scan_barcode_subtitle,
            onTap: onScanTap,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ThemeData theme;

  const _QuickActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Optimized ListView.builder for food search results.
/// Uses lazy loading for better performance with large result sets.
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
  final void Function(studyu.SavedFoodTemplate) onSelectFoodTemplate;
  final void Function(studyu.SavedMealTemplate) onSelectMealTemplate;
  final VoidCallback onManageSavedItems;
  final void Function(UnifiedFoodResult) onSelectResult;
  final VoidCallback onAddManually;
  final VoidCallback onCreateRecipe;
  final VoidCallback onScanBarcode;
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
    required this.onSelectFoodTemplate,
    required this.onSelectMealTemplate,
    required this.onManageSavedItems,
    required this.onSelectResult,
    required this.onAddManually,
    required this.onCreateRecipe,
    required this.onScanBarcode,
    required this.onRetry,
    this.allowRecipes = true,
    this.allowMealTemplates = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isAllowedTemplate(dynamic template) {
      if (template is studyu.SavedMealTemplate) return allowMealTemplates;
      if (template is studyu.SavedFoodTemplate) {
        return allowRecipes ||
            template.prototype.entryType != studyu.FoodEntryType.recipe;
      }
      return false;
    }

    final filteredTemplates = templateViewModel.filteredTemplates
        .where(isAllowedTemplate)
        .cast<Object>()
        .toList();
    final hasTemplates = <Object>[
      ...templateViewModel.mealTemplates,
      ...templateViewModel.foodTemplates,
    ].any(isAllowedTemplate);
    final showTemplates = hasTemplates && filteredTemplates.isNotEmpty;
    final showNoMatchingTemplates =
        hasTemplates &&
        filteredTemplates.isEmpty &&
        searchController.text.isNotEmpty;
    final showManageOnly = allowMealTemplates && !hasTemplates;

    // Calculate section offsets for itemBuilder
    // Structure: [padding, templatesHeader, templatesList, globalHeader, content, quickActionsHeader, quickActions, bottomPadding]
    const int paddingItem = 1;
    final int templatesHeaderItems = hasTemplates
        ? 2
        : showManageOnly
        ? 1
        : 0;
    final int templatesListItems = showTemplates ? filteredTemplates.length : 0;
    final int noMatchingTemplateItem = showNoMatchingTemplates ? 1 : 0;
    final int templatesSpacing = hasTemplates
        ? 1
        : 0; // SizedBox after templates
    const int globalHeaderItems = 2; // header + spacing
    final int contentItems = _getContentItemCount();
    final int loadingIndicatorItem =
        (isLoadingMore || (isInitialLoading && combinedResults.isNotEmpty))
        ? 1
        : 0;
    final int endOfResultsItem =
        (hasSearched &&
            combinedResults.isNotEmpty &&
            !offHasMore &&
            !usdaHasMore &&
            !isInitialLoading &&
            !isLoadingMore)
        ? 1
        : 0;
    const int quickActionsHeaderItems = 2; // header + spacing
    const int quickActionsItem = 1;
    const int bottomPadding = 1;

    final totalItems =
        paddingItem +
        templatesHeaderItems +
        templatesListItems +
        noMatchingTemplateItem +
        templatesSpacing +
        globalHeaderItems +
        contentItems +
        loadingIndicatorItem +
        endOfResultsItem +
        quickActionsHeaderItems +
        quickActionsItem +
        bottomPadding;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        return _buildItem(
          context,
          index,
          filteredTemplates,
          hasTemplates,
          showTemplates,
          showNoMatchingTemplates,
          showManageOnly,
        );
      },
    );
  }

  int _getContentItemCount() {
    if (isInitialLoading && combinedResults.isEmpty) return 1;
    if (errorMessage != null) return 1;
    if (!hasSearched && searchController.text.isEmpty) return 1;
    if (combinedResults.isEmpty && hasSearched && offSearched && usdaSearched) {
      return 1;
    }
    return combinedResults.length;
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    List<Object> filteredTemplates,
    bool hasTemplates,
    bool showTemplates,
    bool showNoMatchingTemplates,
    bool showManageOnly,
  ) {
    var currentIndex = 0;

    // Initial padding
    if (index == currentIndex++) {
      return const SizedBox(height: 8);
    }

    if (showManageOnly && index == currentIndex++) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: onManageSavedItems,
          child: Text(l10n.manage_saved_items),
        ),
      );
    }

    // Templates section header
    if (hasTemplates) {
      if (index == currentIndex++) {
        return _SectionHeader(
          icon: Icons.bookmark_outline,
          title: l10n.my_saved_items,
          iconColor: theme.colorScheme.primary,
          trailing: allowMealTemplates
              ? TextButton(
                  onPressed: onManageSavedItems,
                  child: Text(l10n.manage_saved_items),
                )
              : null,
        );
      }
      if (index == currentIndex++) {
        return const SizedBox(height: 8);
      }

      // Templates list or empty message
      if (showNoMatchingTemplates) {
        if (index == currentIndex++) {
          return _EmptySectionMessage(message: l10n.no_matching_templates);
        }
      } else if (showTemplates) {
        final templateIndex = index - currentIndex;
        if (templateIndex >= 0 && templateIndex < filteredTemplates.length) {
          final template = filteredTemplates[templateIndex];
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
        currentIndex += filteredTemplates.length;
      }

      // Spacing after templates
      if (index == currentIndex++) {
        return const SizedBox(height: 16);
      }
    }

    // Global database section header
    if (index == currentIndex++) {
      return _SectionHeader(
        icon: Icons.public,
        title: l10n.global_database,
        iconColor: Colors.grey.shade700,
      );
    }
    if (index == currentIndex++) {
      return const SizedBox(height: 8);
    }

    // Content section
    final contentItemCount = _getContentItemCount();
    if (contentItemCount > 0) {
      final contentIndex = index - currentIndex;
      if (contentIndex >= 0 && contentIndex < contentItemCount) {
        return _buildContentItem(contentIndex);
      }
      currentIndex += contentItemCount;
    }

    // Loading indicator
    if ((isLoadingMore || (isInitialLoading && combinedResults.isNotEmpty)) &&
        index == currentIndex++) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // End of results message
    if (hasSearched &&
        combinedResults.isNotEmpty &&
        !offHasMore &&
        !usdaHasMore &&
        !isInitialLoading &&
        !isLoadingMore &&
        index == currentIndex++) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            l10n.end_of_results,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    // Quick actions section
    if (index == currentIndex++) {
      return const SizedBox(height: 16);
    }
    if (index == currentIndex++) {
      return _SectionHeader(
        icon: Icons.add_circle_outline,
        title: l10n.quick_actions,
        iconColor: theme.colorScheme.secondary,
      );
    }
    if (index == currentIndex++) {
      return const SizedBox(height: 8);
    }
    if (index == currentIndex++) {
      return _QuickActionsCard(
        onManualTap: onAddManually,
        onScanTap: onScanBarcode,
        theme: theme,
      );
    }
    if (index == currentIndex++) {
      return const SizedBox(height: 24);
    }

    return const SizedBox.shrink();
  }

  Widget _buildContentItem(int contentIndex) {
    if (isInitialLoading && combinedResults.isEmpty) {
      return _LoadingState(theme: theme);
    }
    if (errorMessage != null) {
      return _ErrorMessage(message: errorMessage!, onRetry: onRetry);
    }
    if (!hasSearched && searchController.text.isEmpty) {
      return _InitialPrompt(theme: theme);
    }
    if (combinedResults.isEmpty && hasSearched && offSearched && usdaSearched) {
      return _NoResultsState(
        onAddManually: onAddManually,
        onCreateRecipe: onCreateRecipe,
        allowRecipes: allowRecipes,
      );
    }

    // Results
    if (contentIndex < combinedResults.length) {
      return _FoodResultCard(
        result: combinedResults[contentIndex],
        onTap: () => onSelectResult(combinedResults[contentIndex]),
        theme: theme,
      );
    }

    return const SizedBox.shrink();
  }
}
