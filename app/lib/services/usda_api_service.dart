import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:studyu_flutter_common/src/utils/env_loader.dart';

/// Service for interacting with USDA FoodData Central API
/// Documentation: https://fdc.nal.usda.gov/api-guide.html
class UsdaApiService {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  
  /// Get USDA API key from environment
  static String? get _apiKey {
    // Try to get from environment file first
    final envKey = getEnv('USDA_API_KEY', optional: true);
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    // Fallback to dart-define
    try {
      const dartDefineKey = String.fromEnvironment('USDA_API_KEY');
      if (dartDefineKey.isNotEmpty) {
        return dartDefineKey;
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  /// Search for foods in USDA database by barcode/GTIN
  /// 
  /// [barcode] - Barcode/GTIN/UPC code (e.g., "041303016022")
  /// 
  /// Returns a list of food items matching the barcode
  static Future<UsdaSearchResponse> searchByBarcode(String barcode) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('USDA API key not configured. Please set USDA_API_KEY in environment.');
    }

    // USDA API supports searching by GTIN/UPC
    final url = Uri.parse('$_baseUrl/foods/search')
        .replace(queryParameters: {
      'api_key': apiKey,
      'query': barcode,
      'pageSize': '10',
      'dataType': 'Foundation,SR Legacy,Branded', // Include Branded products for barcodes
    });

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final searchResponse = UsdaSearchResponse.fromJson(jsonData);
        
        // Filter to exact barcode matches
        final exactMatches = searchResponse.foods.where((food) {
          return food.gtinUpc != null && 
                 food.gtinUpc!.replaceAll(RegExp('[^0-9]'), '') == 
                 barcode.replaceAll(RegExp('[^0-9]'), '');
        }).toList();
        
        return UsdaSearchResponse(
          totalHits: exactMatches.length,
          currentPage: 1,
          totalPages: 1,
          foods: exactMatches,
        );
      } else if (response.statusCode == 403) {
        throw Exception('USDA API key is invalid or expired. Please check your API key.');
      } else if (response.statusCode == 429) {
        throw Exception('USDA API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('USDA API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to search USDA database by barcode: $e');
    }
  }

  /// Search for foods in USDA database
  /// 
  /// [query] - Search term (e.g., "apple", "chicken breast")
  /// [pageSize] - Number of results per page (default: 50, max: 200)
  /// [pageNumber] - Page number (default: 1)
  /// 
  /// Returns a list of food items matching the search query
  static Future<UsdaSearchResponse> searchFoods({
    required String query,
    int pageSize = 50,
    int pageNumber = 1,
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('USDA API key not configured. Please set USDA_API_KEY in environment.');
    }

    final url = Uri.parse('$_baseUrl/foods/search')
        .replace(queryParameters: {
      'api_key': apiKey,
      'query': query,
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
      'dataType': 'Foundation,SR Legacy', // Foundation foods + Standard Reference Legacy
    });

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UsdaSearchResponse.fromJson(jsonData);
      } else if (response.statusCode == 403) {
        throw Exception('USDA API key is invalid or expired. Please check your API key.');
      } else if (response.statusCode == 429) {
        throw Exception('USDA API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('USDA API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to search USDA database: $e');
    }
  }

  /// Get detailed food information by FDC ID
  /// 
  /// [fdcId] - FoodData Central ID
  /// [nutrients] - Optional list of nutrient IDs to include (default: all)
  static Future<UsdaFoodItem> getFoodDetails(int fdcId, {List<int>? nutrients}) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('USDA API key not configured. Please set USDA_API_KEY in environment.');
    }

    final url = Uri.parse('$_baseUrl/food/$fdcId')
        .replace(queryParameters: {
      'api_key': apiKey,
      if (nutrients != null && nutrients.isNotEmpty)
        'nutrients': nutrients.join(','),
    });

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UsdaFoodItem.fromJson(jsonData);
      } else if (response.statusCode == 403) {
        throw Exception('USDA API key is invalid or expired.');
      } else if (response.statusCode == 404) {
        throw Exception('Food not found in USDA database.');
      } else {
        throw Exception('USDA API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch food details: $e');
    }
  }
}

/// USDA Search Response Model
class UsdaSearchResponse {
  final int totalHits;
  final int currentPage;
  final int totalPages;
  final List<UsdaFoodItem> foods;

  UsdaSearchResponse({
    required this.totalHits,
    required this.currentPage,
    required this.totalPages,
    required this.foods,
  });

  factory UsdaSearchResponse.fromJson(Map<String, dynamic> json) {
    return UsdaSearchResponse(
      totalHits: json['totalHits'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      foods: (json['foods'] as List<dynamic>? ?? [])
          .map((food) => UsdaFoodItem.fromJson(food as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// USDA Food Item Model
class UsdaFoodItem {
  final int fdcId;
  final String? description;
  final String? dataType; // Foundation, SR Legacy, etc.
  final String? brandOwner;
  final String? brandName;
  final String? gtinUpc;
  final String? ingredients;
  final double? servingSize;
  final String? servingSizeUnit;
  final String? householdServingFullText;
  final List<UsdaFoodNutrient> foodNutrients;
  final List<UsdaFoodPortion>? foodPortions;

  UsdaFoodItem({
    required this.fdcId,
    this.description,
    this.dataType,
    this.brandOwner,
    this.brandName,
    this.gtinUpc,
    this.ingredients,
    this.servingSize,
    this.servingSizeUnit,
    this.householdServingFullText,
    required this.foodNutrients,
    this.foodPortions,
  });

  factory UsdaFoodItem.fromJson(Map<String, dynamic> json) {
    return UsdaFoodItem(
      fdcId: json['fdcId'] as int,
      description: json['description'] as String?,
      dataType: json['dataType'] as String?,
      brandOwner: json['brandOwner'] as String?,
      brandName: json['brandName'] as String?,
      gtinUpc: json['gtinUpc'] as String?,
      ingredients: json['ingredients'] as String?,
      servingSize: (json['servingSize'] as num?)?.toDouble(),
      servingSizeUnit: json['servingSizeUnit'] as String?,
      householdServingFullText: json['householdServingFullText'] as String?,
      foodNutrients: (json['foodNutrients'] as List<dynamic>? ?? [])
          .map((nutrient) => UsdaFoodNutrient.fromJson(nutrient as Map<String, dynamic>))
          .toList(),
      foodPortions: json['foodPortions'] != null
          ? (json['foodPortions'] as List<dynamic>)
              .map((portion) => UsdaFoodPortion.fromJson(portion as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Get nutrient value by nutrient ID
  /// Common IDs: 1008 (Energy/Calories), 1003 (Protein), 1005 (Carbs), 1004 (Fat)
  double? getNutrientValue(int nutrientId) {
    final nutrient = foodNutrients.firstWhere(
      (n) => n.nutrientId == nutrientId,
      orElse: () => UsdaFoodNutrient(nutrientId: nutrientId),
    );
    return nutrient.value;
  }

  /// Get energy in kcal per 100g
  double get energyKcal100g {
    return getNutrientValue(1008) ?? 0.0; // Energy (kcal)
  }

  /// Get protein in g per 100g
  double get protein100g {
    return getNutrientValue(1003) ?? 0.0; // Protein
  }

  /// Get carbohydrates in g per 100g
  double get carbohydrates100g {
    return getNutrientValue(1005) ?? 0.0; // Carbohydrate, by difference
  }

  /// Get total fat in g per 100g
  double get fat100g {
    return getNutrientValue(1004) ?? 0.0; // Total lipid (fat)
  }

  /// Get sugars in g per 100g
  double get sugars100g {
    return getNutrientValue(2000) ?? 0.0; // Sugars, total including NLEA
  }

  /// Get fiber in g per 100g
  double get fiber100g {
    return getNutrientValue(1079) ?? 0.0; // Fiber, total dietary
  }

  /// Get saturated fat in g per 100g
  double get saturatedFat100g {
    return getNutrientValue(1258) ?? 0.0; // Fatty acids, total saturated
  }

  /// Get sodium in mg per 100g
  double get sodium100g {
    return getNutrientValue(1093) ?? 0.0; // Sodium, Na
  }
}

/// USDA Food Nutrient Model
class UsdaFoodNutrient {
  final int nutrientId;
  final String? nutrientName;
  final String? nutrientNumber;
  final String? unitName;
  final double? value;
  final int? derivationId;
  final String? derivationDescription;

  UsdaFoodNutrient({
    required this.nutrientId,
    this.nutrientName,
    this.nutrientNumber,
    this.unitName,
    this.value,
    this.derivationId,
    this.derivationDescription,
  });

  factory UsdaFoodNutrient.fromJson(Map<String, dynamic> json) {
    return UsdaFoodNutrient(
      nutrientId: json['nutrientId'] as int? ?? json['nutrient']?['id'] as int? ?? 0,
      nutrientName: json['nutrientName'] as String? ?? json['nutrient']?['name'] as String?,
      nutrientNumber: json['nutrientNumber'] as String? ?? json['nutrient']?['number'] as String?,
      unitName: json['unitName'] as String? ?? json['nutrient']?['unitName'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      derivationId: json['derivationId'] as int? ?? json['derivation']?['id'] as int?,
      derivationDescription: json['derivationDescription'] as String? ?? json['derivation']?['description'] as String?,
    );
  }
}

/// USDA Food Portion Model
class UsdaFoodPortion {
  final int id;
  final double amount;
  final String? measureUnit;
  final String? portionDescription;
  final String? modifier;

  UsdaFoodPortion({
    required this.id,
    required this.amount,
    this.measureUnit,
    this.portionDescription,
    this.modifier,
  });

  factory UsdaFoodPortion.fromJson(Map<String, dynamic> json) {
    return UsdaFoodPortion(
      id: json['id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      measureUnit: json['measureUnit'] as String? ?? json['measureUnit']?['name'] as String?,
      portionDescription: json['portionDescription'] as String?,
      modifier: json['modifier'] as String?,
    );
  }
}

