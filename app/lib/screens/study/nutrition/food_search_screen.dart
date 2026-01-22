import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/models/app_state.dart';
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

enum FoodApiSource { openFoodFacts, usda }

class _FoodSearchScreenContentState extends State<_FoodSearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _openFoodFactsResults = [];
  List<UsdaFoodItem> _usdaResults = [];
  FoodApiSource _selectedApi = FoodApiSource.openFoodFacts;
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(TemplateViewModel templateViewModel) async {
    final query = _searchController.text.trim();

    // Update local template search
    templateViewModel.setSearchQuery(query);

    if (query.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _openFoodFactsResults = [];
      _usdaResults = [];
    });

    try {
      if (_selectedApi == FoodApiSource.openFoodFacts) {
        await _searchOpenFoodFacts();
      } else {
        await _searchUsda();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error searching: $e';
      });
    }
  }

  Future<void> _searchOpenFoodFacts() async {
    try {
      final searchResult = await OpenFoodAPIClient.searchProducts(
        null,
        ProductSearchQueryConfiguration(
          parametersList: [
            SearchTerms(terms: [_searchController.text.trim()]),
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

      setState(() {
        _isLoading = false;
        if (searchResult.products != null &&
            searchResult.products!.isNotEmpty) {
          _openFoodFactsResults = searchResult.products!;
        } else {
          // Don't show error if we just found no remote results,
          // as we might have local templates
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'OpenFoodFacts error: $e';
      });
    }
  }

  Future<void> _searchUsda() async {
    try {
      final searchResult = await UsdaApiService.searchFoods(
        query: _searchController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        if (searchResult.foods.isNotEmpty) {
          _usdaResults = List.from(searchResult.foods);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'USDA API error: $e';
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

  void _selectProduct(Product product) {
    final foodEntry = _convertToFoodEntry(product);
    _navigateToEdit(foodEntry);
  }

  void _selectUsdaFood(UsdaFoodItem food) {
    final foodEntry = _convertUsdaToFoodEntry(food);
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
      if (result != null) {
        Navigator.pop(context, result);
      }
    });
  }

  void _addManually() {
    Navigator.push(context, FoodEntryScreen.route()).then((result) {
      if (result != null) {
        Navigator.pop(context, result);
      }
    });
  }

  void _createRecipe() {
    Navigator.push(context, RecipeBuilderScreen.route()).then((result) {
      if (result != null) {
        Navigator.pop(context, result);
      }
    });
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
                          _searchController.clear();
                          templateViewModel.setSearchQuery('');
                          setState(() {
                            _openFoodFactsResults = [];
                            _usdaResults = [];
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
              onChanged: (val) {
                // Live filter templates
                templateViewModel.setSearchQuery(val);
                setState(() {}); // Rebuild to show/hide clear button
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // API Toggle
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Global Search:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('OpenFoodFacts'),
                  selected: _selectedApi == FoodApiSource.openFoodFacts,
                  onSelected: (selected) {
                    if (selected)
                      setState(
                        () => _selectedApi = FoodApiSource.openFoodFacts,
                      );
                    if (_hasSearched) _searchFood(templateViewModel);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('USDA'),
                  selected: _selectedApi == FoodApiSource.usda,
                  onSelected: (selected) {
                    if (selected)
                      setState(() => _selectedApi = FoodApiSource.usda);
                    if (_hasSearched) _searchFood(templateViewModel);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. My Templates Section (Foods + Recipes)
                if (templateViewModel.foodTemplates.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
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

                // 2. Remote Results Section
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

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
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
                      'Type above to search global databases',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else if ((_selectedApi == FoodApiSource.openFoodFacts
                        ? _openFoodFactsResults.isEmpty
                        : _usdaResults.isEmpty) &&
                    _hasSearched)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No results found in database',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                if (_selectedApi == FoodApiSource.openFoodFacts)
                  ..._openFoodFactsResults.map(
                    (product) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: product.imageFrontSmallUrl != null
                            ? Image.network(
                                product.imageFrontSmallUrl!,
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.fastfood),
                              )
                            : const Icon(Icons.fastfood),
                        title: Text(product.productName ?? 'Unknown'),
                        subtitle: Text(product.brands ?? ''),
                        onTap: () => _selectProduct(product),
                      ),
                    ),
                  )
                else
                  ..._usdaResults.map(
                    (food) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.agriculture,
                          color: Colors.orange,
                        ),
                        title: Text(food.description ?? 'Unknown'),
                        subtitle: Text(food.brandOwner ?? ''),
                        onTap: () => _selectUsdaFood(food),
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
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.orange.shade700,
                      ),
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
                      child: Icon(
                        Icons.edit_note,
                        color: Colors.purple.shade700,
                      ),
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
          ),
        ],
      ),
    );
  }
}
