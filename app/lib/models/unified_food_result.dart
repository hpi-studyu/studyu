import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_core/core.dart';

/// Unified search result that can hold data from any source
/// This is a View Model for the App UI, not a Core domain model.
class UnifiedFoodResult {
  final String id;
  final String name;
  final String? brand;
  final String? imageUrl;
  final double? calories;
  final FoodSource source;

  /// Holds [Product] (from OpenFoodFacts) or [UsdaFoodItem] (from App)
  final dynamic originalData;

  UnifiedFoodResult({
    required this.id,
    required this.name,
    this.brand,
    this.imageUrl,
    this.calories,
    required this.source,
    required this.originalData,
  });
}
