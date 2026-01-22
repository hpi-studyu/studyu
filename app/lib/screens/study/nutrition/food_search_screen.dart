import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/models/usda_models.dart';
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
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
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
    // Always update local template filter immediately
    templateViewModel.setSearchQuery(value);
    setState(() {}); // Rebuild for clear button

    // Cancel previous timer
    _debounceTimer?.cancel();

    // If empty, clear results immediately
    if (value.trim().isEmpty) {
      setState(() {
        _combinedResults = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    // Debounce the API search
    _debounceTimer = Timer(_debounceDuration, () {
      _searchFood(templateViewModel);
    });
  }

  Future<void> _searchFood(TemplateViewModel templateViewModel) async {
    final query = _searchController.text.trim();

    // Update local template search
    templateViewModel.setSearchQuery(query);

    if (query.isEmpty) {
      setState(() {
        _combinedResults = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    // Reset pagination
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

    // Search both APIs simultaneously
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
            PageSize(size: _pageSize),
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
      // Don't show error - other source might work
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
      // Don't show error - other source might work
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
    TemplateViewModel viewModel,
  ) {
    final foodEntry = viewModel.applyFoodTemplate(template);
    Navigator.pop(context, foodEntry);
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

  Widget _buildSourceBadge(studyu.FoodSource source) {
    final isOff = source == studyu.FoodSource.openfoodfacts;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOff ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isOff ? 'OFF' : 'USDA',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isOff ? Colors.green.shade800 : Colors.orange.shade800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templateViewModel = Provider.of<TemplateViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search food (e.g., "apple")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _debounceTimer?.cancel();
                          _searchController.clear();
                          templateViewModel.setSearchQuery('');
                          setState(() {
                            _combinedResults = [];
                            _hasSearched = false;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (_) => _searchFood(templateViewModel),
              onChanged: (val) => _onSearchChanged(val, templateViewModel),
            ),
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // 1. My Templates Section (Foods + Recipes)
          if (templateViewModel.foodTemplates.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.bookmark, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'My Saved Items',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (templateViewModel.filteredTemplates
                    .whereType<studyu.SavedFoodTemplate>()
                    .isEmpty &&
                _searchController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No matching templates',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...templateViewModel.filteredTemplates
                  .whereType<studyu.SavedFoodTemplate>()
                  .map((template) {
                    final isRecipe =
                        template.prototype.entryType ==
                        studyu.FoodEntryType.recipe;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isRecipe
                              ? Colors.orange.shade100
                              : Colors.blue.shade100,
                          radius: 18,
                          child: Icon(
                            isRecipe ? Icons.menu_book : Icons.fastfood,
                            size: 18,
                            color: isRecipe
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                        title: Text(template.name),
                        subtitle: Text(
                          '${isRecipe ? "Recipe • " : ""}${template.prototype.nutrition.energyKcal.round()} kcal',
                        ),
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.blue,
                        ),
                        onTap: () =>
                            _selectTemplate(template, templateViewModel),
                      ),
                    );
                  }),
            const Divider(height: 32),
          ],

          // 2. Global Database Results Section
          Row(
            children: [
              Icon(Icons.public, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Global Database Results',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_isInitialLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
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
              ),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (!_hasSearched && _searchController.text.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Type above to search food databases',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else if (_combinedResults.isEmpty &&
              _hasSearched &&
              _offSearched &&
              _usdaSearched)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No results found. Try a different search term.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          // Combined Results
          ..._combinedResults.map((result) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: result.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          result.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildFallbackIcon(result.source),
                        ),
                      )
                    : _buildFallbackIcon(result.source),
                title: Text(
                  result.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    _buildSourceBadge(result.source),
                    if (result.brand != null && result.brand!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.brand!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: result.calories != null
                    ? Text(
                        '${result.calories!.round()} kcal',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      )
                    : null,
                onTap: () => _selectResult(result),
              ),
            );
          }),

          // Loading more indicator
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          // End of results indicator
          if (_hasSearched &&
              _combinedResults.isNotEmpty &&
              !_offHasMore &&
              !_usdaHasMore &&
              !_isLoadingMore)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'End of results',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),

          // 3. Quick Actions
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Or add by...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Create Recipe - prominent option
          Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Icon(Icons.menu_book, color: Colors.orange.shade700),
              ),
              title: const Text('Create a Recipe'),
              subtitle: const Text('Build from ingredients'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _createRecipe,
            ),
          ),
          const SizedBox(height: 8),

          // Manual Entry
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade50,
                child: Icon(Icons.edit_note, color: Colors.purple.shade700),
              ),
              title: const Text('Add Manually'),
              subtitle: const Text('Enter nutrition yourself'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _addManually,
            ),
          ),
          const SizedBox(height: 8),

          // Barcode Scanner
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.green.shade700,
                ),
              ),
              title: const Text('Scan Barcode'),
              subtitle: const Text('Find packaged products'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  BarcodeScannerScreen.route(),
                );
                if (result != null && context.mounted) {
                  Navigator.pop(context, result);
                }
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(studyu.FoodSource source) {
    return CircleAvatar(
      backgroundColor: source == studyu.FoodSource.openfoodfacts
          ? Colors.green.shade100
          : Colors.orange.shade100,
      radius: 20,
      child: Icon(
        source == studyu.FoodSource.openfoodfacts
            ? Icons.eco
            : Icons.agriculture,
        color: source == studyu.FoodSource.openfoodfacts
            ? Colors.green.shade700
            : Colors.orange.shade700,
        size: 20,
      ),
    );
  }
}
