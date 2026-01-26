import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/recipe_builder_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_core/core.dart' as studyu;

class FoodSearchScreen extends StatelessWidget {
  const FoodSearchScreen({super.key});

  static MaterialPageRoute<studyu.FoodEntry> route() =>
      MaterialPageRoute(builder: (_) => const FoodSearchScreen());

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId),
      child: const _FoodSearchScreenContent(),
    );
  }
}

class _FoodSearchScreenContent extends StatefulWidget {
  const _FoodSearchScreenContent();

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

  // Track which sources have been searched
  bool _offSearched = false;
  bool _usdaSearched = false;

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
    setState(() {});

    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _combinedResults = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      _searchFood(templateViewModel);
    });
  }

  Future<void> _searchFood(TemplateViewModel templateViewModel) async {
    final query = _searchController.text.trim();
    templateViewModel.setSearchQuery(query);

    if (query.isEmpty) {
      setState(() {
        _combinedResults = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    _offPage = 1;
    _usdaPage = 1;
    _offHasMore = true;
    _usdaHasMore = true;
    _offSearched = false;
    _usdaSearched = false;

    setState(() {
      _isInitialLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _combinedResults = [];
    });

    await Future.wait([
      _searchOpenFoodFacts(query, isInitial: true),
      _searchUsda(query, isInitial: true),
    ]);

    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isInitialLoading) return;
    if (!_offHasMore && !_usdaHasMore) return;

    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    final futures = <Future>[];

    if (_offHasMore) {
      futures.add(_searchOpenFoodFacts(query, isInitial: false));
    }
    if (_usdaHasMore) {
      futures.add(_searchUsda(query, isInitial: false));
    }

    await Future.wait(futures);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _searchOpenFoodFacts(
    String query, {
    required bool isInitial,
  }) async {
    try {
      final searchResult = await OpenFoodAPIClient.searchProducts(
        null,
        ProductSearchQueryConfiguration(
          parametersList: [
            SearchTerms(terms: [query]),
            PageNumber(page: _offPage),
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

      _offSearched = true;

      if (searchResult.products != null && searchResult.products!.isNotEmpty) {
        final newResults = searchResult.products!.map((product) {
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
          _combinedResults.addAll(newResults);
          _offPage++;
          _offHasMore = searchResult.products!.length >= _pageSize;
        });
      } else {
        setState(() {
          _offHasMore = false;
        });
      }
    } catch (e) {
      _offSearched = true;
      debugPrint('OpenFoodFacts error: $e');
    }
  }

  Future<void> _searchUsda(String query, {required bool isInitial}) async {
    try {
      final searchResult = await UsdaApiService.searchFoods(
        query: query,
        pageSize: _pageSize,
        pageNumber: _usdaPage,
      );

      _usdaSearched = true;

      if (searchResult.foods.isNotEmpty) {
        final newResults = searchResult.foods.map((food) {
          return UnifiedFoodResult(
            id: food.fdcId.toString(),
            name: food.description ?? 'Unknown',
            brand: food.brandOwner ?? food.brandName,
            imageUrl: null,
            calories: food.energyKcal100g,
            source: studyu.FoodSource.usda,
            originalData: food,
          );
        }).toList();

        setState(() {
          _combinedResults.addAll(newResults);
          _usdaPage++;
          _usdaHasMore = searchResult.foods.length >= _pageSize;
        });
      } else {
        setState(() {
          _usdaHasMore = false;
        });
      }
    } catch (e) {
      _usdaSearched = true;
      debugPrint('USDA error: $e');
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
        energyKcal: energyKcal,
        protein: protein,
        carbs: carbs,
        fat: fat,
        sugars: sugars,
        fiber: fiber,
        saturatedFat: saturatedFat,
        transFat: 0,
        cholesterol: 0,
        sodium: sodium,
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
    studyu.FoodEntry foodEntry;
    if (result.source == studyu.FoodSource.openfoodfacts) {
      foodEntry = _convertToFoodEntry(result.originalData as Product);
    } else {
      foodEntry = _convertUsdaToFoodEntry(result.originalData as UsdaFoodItem);
    }
    _navigateToEdit(foodEntry);
  }

  void _selectTemplate(
    studyu.SavedFoodTemplate template,
  ) {
    Navigator.pop(context, template.prototype);
  }

  void _navigateToEdit(studyu.FoodEntry foodEntry) {
    Navigator.push(
      context,
      FoodEntryScreen.route(existingFood: foodEntry),
    ).then((result) {
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  void _addManually() {
    Navigator.push(context, FoodEntryScreen.route()).then((result) {
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  void _createRecipe() {
    Navigator.push(context, RecipeBuilderScreen.route()).then((result) {
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      BarcodeScannerScreen.route(),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templateViewModel = Provider.of<TemplateViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: Column(
        children: [
          // Search Bar
          _SearchBarHeader(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (val) => _onSearchChanged(val, templateViewModel),
            onClear: () {
              _debounceTimer?.cancel();
              _searchController.clear();
              templateViewModel.setSearchQuery('');
              setState(() {
                _combinedResults = [];
                _hasSearched = false;
                _errorMessage = null;
              });
            },
          ),

          // Content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),

                // My Templates Section
                if (templateViewModel.foodTemplates.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.bookmark_outline,
                    title: 'My Saved Items',
                    iconColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  if (templateViewModel.filteredTemplates
                          .whereType<studyu.SavedFoodTemplate>()
                          .isEmpty &&
                      _searchController.text.isNotEmpty)
                    _EmptySectionMessage(message: 'No matching templates')
                  else
                    ...templateViewModel.filteredTemplates
                        .whereType<studyu.SavedFoodTemplate>()
                        .map((template) => _TemplateCard(
                              template: template,
                              onTap: () => _selectTemplate(template),
                              theme: theme,
                            )),
                  const SizedBox(height: 16),
                ],

                // Database Results Section
                _SectionHeader(
                  icon: Icons.public,
                  title: 'Global Database',
                  iconColor: Colors.grey.shade700,
                ),
                const SizedBox(height: 8),

                // Loading / Empty States
                if (_isInitialLoading)
                  _LoadingState(theme: theme)
                else if (_errorMessage != null)
                  _ErrorMessage(message: _errorMessage!)
                else if (!_hasSearched && _searchController.text.isEmpty)
                  _InitialPrompt(
                    onManualTap: _addManually,
                    onRecipeTap: _createRecipe,
                    onScanTap: _scanBarcode,
                    theme: theme,
                  )
                else if (_combinedResults.isEmpty &&
                    _hasSearched &&
                    _offSearched &&
                    _usdaSearched)
                  _EmptySectionMessage(message: 'No results found. Try different keywords.'),

                // Results
                ..._combinedResults.map((result) => _FoodResultCard(
                      result: result,
                      onTap: () => _selectResult(result),
                      theme: theme,
                    )),

                // Loading more
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // End of results
                if (_hasSearched &&
                    _combinedResults.isNotEmpty &&
                    !_offHasMore &&
                    !_usdaHasMore &&
                    !_isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'End of results',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),

                // Quick Actions (always visible at bottom)
                const SizedBox(height: 16),
                _SectionHeader(
                  icon: Icons.add_circle_outline,
                  title: 'Quick Actions',
                  iconColor: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 8),
                _QuickActionsCard(
                  onManualTap: _addManually,
                  onRecipeTap: _createRecipe,
                  onScanTap: _scanBarcode,
                  theme: theme,
                ),
                const SizedBox(height: 24),
              ],
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
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBarHeader({
    required this.controller,
    required this.focusNode,
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
          hintText: 'Search food (e.g., "apple", "chicken")',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final studyu.SavedFoodTemplate template;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isRecipe =
        template.prototype.entryType == studyu.FoodEntryType.recipe;

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
            isRecipe ? Icons.menu_book_outlined : Icons.fastfood_outlined,
            size: 22,
            color: isRecipe
                ? Colors.orange.shade700
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          template.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${isRecipe ? "Recipe • " : ""}${template.prototype.nutrition.energyKcal.round()} kcal',
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
                          errorBuilder: (_, __, ___) {
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
                        if (result.brand != null && result.brand!.isNotEmpty) ...[
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
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Searching databases...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
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
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _InitialPrompt extends StatelessWidget {
  final VoidCallback onManualTap;
  final VoidCallback onRecipeTap;
  final VoidCallback onScanTap;
  final ThemeData theme;

  const _InitialPrompt({
    required this.onManualTap,
    required this.onRecipeTap,
    required this.onScanTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
            'Search for Food',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type above to search global databases',
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
  final VoidCallback onRecipeTap;
  final VoidCallback onScanTap;
  final ThemeData theme;

  const _QuickActionsCard({
    required this.onManualTap,
    required this.onRecipeTap,
    required this.onScanTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        children: [
          _QuickActionTile(
            icon: Icons.menu_book_outlined,
            iconColor: Colors.orange,
            title: 'Create Recipe',
            subtitle: 'Build from multiple ingredients',
            onTap: onRecipeTap,
            theme: theme,
          ),
          const Divider(height: 1, indent: 68),
          _QuickActionTile(
            icon: Icons.edit_note_outlined,
            iconColor: Colors.purple,
            title: 'Add Manually',
            subtitle: 'Enter nutrition facts yourself',
            onTap: onManualTap,
            theme: theme,
          ),
          const Divider(height: 1, indent: 68),
          _QuickActionTile(
            icon: Icons.qr_code_scanner_outlined,
            iconColor: Colors.green,
            title: 'Scan Barcode',
            subtitle: 'Find packaged products quickly',
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
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
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
