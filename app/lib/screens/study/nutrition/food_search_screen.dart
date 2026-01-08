import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_core/core.dart' as studyu;

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  static MaterialPageRoute<studyu.FoodEntry> route() => MaterialPageRoute(
        builder: (_) => const FoodSearchScreen(),
      );

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

enum FoodApiSource { openFoodFacts, usda }

class _FoodSearchScreenState extends State<FoodSearchScreen> {
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
    // Configure OpenFoodFacts
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

  Future<void> _searchFood() async {
    if (_searchController.text.trim().isEmpty) {
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
        if (searchResult.products != null && searchResult.products!.isNotEmpty) {
          _openFoodFactsResults = searchResult.products!;
        } else {
          _errorMessage = 'No results found in OpenFoodFacts';
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
          // Sort: Foundation first, then SR Legacy
          _usdaResults = List.from(searchResult.foods)
            ..sort((a, b) {
              // Foundation comes first (priority 0)
              // SR Legacy comes second (priority 1)
              // Other types come last (priority 2)
              int getPriority(String? dataType) {
                if (dataType == null) return 2;
                if (dataType.toLowerCase().contains('foundation')) return 0;
                if (dataType.toLowerCase().contains('sr legacy') || 
                    dataType.toLowerCase().contains('sr_legacy')) {
                  return 1;
                }
                return 2;
              }
              
              final priorityA = getPriority(a.dataType);
              final priorityB = getPriority(b.dataType);
              
              if (priorityA != priorityB) {
                return priorityA.compareTo(priorityB);
              }
              
              // If same priority, sort alphabetically by name
              return (a.description ?? '').compareTo(b.description ?? '');
            });
        } else {
          _errorMessage = 'No results found in USDA database';
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
    // USDA provides nutrients per 100g by default
    final servingSizeGrams = food.servingSize ?? 100.0;
    final servingSizeUnit = food.servingSizeUnit ?? 'g';
    
    // Scale nutrients to serving size
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
        sodium: food.sodium100g * scale, // Already in mg
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
    
    // Extract nutrition info with fallbacks
    final energyKcal = nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
    final protein = nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0;
    final carbs = nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0;
    final fat = nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0;
    final sugars = nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0;
    final fiber = nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0;
    final saturatedFat = nutriments?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams) ?? 0;
    final sodium = (nutriments?.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0) * 1000; // Convert g to mg

    // Parse serving size
    double servingSizeGrams = 100.0; // default
    if (product.servingSize != null) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*g').firstMatch(product.servingSize!);
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
    
    // Navigate to food entry screen for editing before saving
    Navigator.push(
      context,
      FoodEntryScreen.route(existingFood: foodEntry),
    ).then((result) {
      if (result != null) {
        // Return the edited food entry
        Navigator.pop(context, result);
      }
    });
  }

  void _selectUsdaFood(UsdaFoodItem food) {
    final foodEntry = _convertUsdaToFoodEntry(food);
    
    // Navigate to food entry screen for editing before saving
    Navigator.push(
      context,
      FoodEntryScreen.route(existingFood: foodEntry),
    ).then((result) {
      if (result != null) {
        // Return the edited food entry
        Navigator.pop(context, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Food Database'),
        actions: [
          // Only show barcode scanner for OpenFoodFacts
          if (_selectedApi == FoodApiSource.openFoodFacts)
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  BarcodeScannerScreen.route(),
                );
                if (result != null) {
                  // Barcode scan returned a food, pass it back
                  Navigator.pop(context, result);
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan Barcode',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for food (e.g., "apple", "coca cola")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
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
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _searchFood(),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // API Selector and Search
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                // API Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildApiButton(
                          FoodApiSource.openFoodFacts,
                          'OpenFoodFacts',
                          Icons.store,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildApiButton(
                          FoodApiSource.usda,
                          'USDA',
                          Icons.agriculture,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Info banner
                Row(
                  children: [
                    Icon(
                      _selectedApi == FoodApiSource.openFoodFacts
                          ? Icons.store
                          : Icons.agriculture,
                      color: _selectedApi == FoodApiSource.openFoodFacts
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedApi == FoodApiSource.openFoodFacts
                            ? "OpenFoodFacts - World's largest open food database"
                            : 'USDA FoodData Central - Official US nutrition database',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchFood,
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedApi == FoodApiSource.openFoodFacts
                            ? Colors.green
                            : Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Only show barcode scanner button for OpenFoodFacts
                if (_selectedApi == FoodApiSource.openFoodFacts) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        BarcodeScannerScreen.route(),
                      );
                      if (result != null && mounted) {
                        Navigator.pop(context, result);
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Barcode Instead'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Results
          Expanded(
            child: _buildResultsArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _selectedApi == FoodApiSource.openFoodFacts
                  ? 'Searching OpenFoodFacts database...'
                  : 'Searching USDA FoodData Central...',
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchFood,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 100,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'Search for Food',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a food name, brand, or barcode',
                style: TextStyle(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final hasResults = _selectedApi == FoodApiSource.openFoodFacts
        ? _openFoodFactsResults.isNotEmpty
        : _usdaResults.isNotEmpty;

    if (!hasResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedApi == FoodApiSource.openFoodFacts) {
      return ListView.builder(
        itemCount: _openFoodFactsResults.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final product = _openFoodFactsResults[index];
          return _buildProductCard(product);
        },
      );
    } else {
      return ListView.builder(
        itemCount: _usdaResults.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final food = _usdaResults[index];
          return _buildUsdaFoodCard(food);
        },
      );
    }
  }

  Widget _buildProductCard(Product product) {
    final nutriments = product.nutriments;
    final energyKcal = nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
    final protein = nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0;
    final carbs = nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0;
    final fat = nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _selectProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (product.imageFrontSmallUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageFrontSmallUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  ),
                )
              else
                _buildPlaceholderImage(),

              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.brands != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.brands!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNutrientChip('${energyKcal.toStringAsFixed(0)} kcal', Colors.orange),
                        const SizedBox(width: 4),
                        _buildNutrientChip('P: ${protein.toStringAsFixed(1)}g', Colors.blue),
                        const SizedBox(width: 4),
                        _buildNutrientChip('C: ${carbs.toStringAsFixed(1)}g', Colors.green),
                        const SizedBox(width: 4),
                        _buildNutrientChip('F: ${fat.toStringAsFixed(1)}g', Colors.purple),
                      ],
                    ),
                    if (product.servingSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Serving: ${product.servingSize}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.fastfood, color: Colors.grey.shade400, size: 30),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildApiButton(FoodApiSource api, String label, IconData icon, Color color) {
    final isSelected = _selectedApi == api;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedApi = api;
          _openFoodFactsResults = [];
          _usdaResults = [];
          _hasSearched = false;
          _errorMessage = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsdaFoodCard(UsdaFoodItem food) {
    final energyKcal = food.energyKcal100g;
    final protein = food.protein100g;
    final carbs = food.carbohydrates100g;
    final fat = food.fat100g;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _selectUsdaFood(food),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // USDA icon placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.agriculture,
                  color: Colors.orange.shade700,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),

              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.description ?? 'Unknown Food',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (food.brandOwner != null || food.brandName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        food.brandOwner ?? food.brandName ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (food.dataType != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          food.dataType!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNutrientChip('${energyKcal.toStringAsFixed(0)} kcal', Colors.orange),
                        const SizedBox(width: 4),
                        _buildNutrientChip('P: ${protein.toStringAsFixed(1)}g', Colors.blue),
                        const SizedBox(width: 4),
                        _buildNutrientChip('C: ${carbs.toStringAsFixed(1)}g', Colors.green),
                        const SizedBox(width: 4),
                        _buildNutrientChip('F: ${fat.toStringAsFixed(1)}g', Colors.purple),
                      ],
                    ),
                    if (food.householdServingFullText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Serving: ${food.householdServingFullText}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    if (food.gtinUpc != null && food.gtinUpc!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.qr_code, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Barcode: ${food.gtinUpc}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

