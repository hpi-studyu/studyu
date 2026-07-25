import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

enum TemplateFilter { all, foods, meals }

class TemplateViewModel extends ChangeNotifier {
  final TemplateStorageManager _storageManager = TemplateStorageManager();
  final String userId;

  List<SavedFoodTemplate> _foodTemplates = [];

  bool _isLoading = false;
  String? _error;
  TemplateFilter _currentFilter = TemplateFilter.all;
  String _searchQuery = '';

  TemplateViewModel({required this.userId}) {
    loadAllTemplates();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  TemplateFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  List<SavedFoodTemplate> get foodTemplates => _foodTemplates;
  List<SavedFoodTemplate> get mealTemplates => _foodTemplates
      .where((template) => template.prototype.entryType == FoodEntryType.meal)
      .toList();
  List<SavedFoodTemplate> get foodOnlyTemplates => _foodTemplates
      .where((template) => template.prototype.entryType != FoodEntryType.meal)
      .toList();

  List<SavedFoodTemplate> get filteredTemplates {
    final templates = switch (_currentFilter) {
      TemplateFilter.all => _foodTemplates,
      TemplateFilter.foods => foodOnlyTemplates,
      TemplateFilter.meals => mealTemplates,
    };

    if (_searchQuery.isEmpty) return templates;
    final lowerQuery = _searchQuery.toLowerCase();
    return templates
        .where((template) => template.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<void> loadAllTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foodTemplates = await _storageManager.loadFoodTemplates(userId);
    } catch (e) {
      _error = e.toString();
      StudyULogger.error('Failed to load templates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveMealAsTemplate({
    required String name,
    required MealLog meal,
    List<String>? tags,
  }) async {
    await saveFoodAsTemplate(
      name: name,
      food: _buildMealEntry(name: name, foods: meal.foods),
      tags: tags,
    );
  }

  Future<String> saveFoodAsTemplate({
    required String name,
    required FoodEntry food,
    List<String>? tags,
  }) async {
    final template = SavedFoodTemplate.withId(
      userId: userId,
      name: name,
      tags: tags,
      isPublic: false,
      prototype: _cloneFoodEntry(food),
    );

    await _storageManager.saveFoodTemplate(template);
    await loadAllTemplates();
    return template.id;
  }

  Future<void> renameFoodTemplate(String templateId, String newName) async {
    final templates = await _storageManager.loadFoodTemplates(userId);
    final index = templates.indexWhere((t) => t.id == templateId);
    if (index >= 0) {
      templates[index].name = newName;
      templates[index].updatedAt = DateTime.now();
      await _storageManager.saveFoodTemplate(templates[index]);
      await loadAllTemplates();
    }
  }

  Future<void> updateFoodTemplatePrototype(
    String templateId,
    FoodEntry prototype,
  ) async {
    final templates = await _storageManager.loadFoodTemplates(userId);
    final index = templates.indexWhere((template) => template.id == templateId);
    if (index < 0) return;

    templates[index].prototype = _cloneFoodEntry(prototype);
    templates[index].updatedAt = DateTime.now();
    await _storageManager.saveFoodTemplate(templates[index]);
    await loadAllTemplates();
  }

  Future<void> duplicateFoodTemplate(String templateId) async {
    final templates = await _storageManager.loadFoodTemplates(userId);
    final source = templates.firstWhere(
      (template) => template.id == templateId,
    );
    await _storageManager.saveFoodTemplate(
      SavedFoodTemplate.withId(
        userId: userId,
        name: source.name,
        tags: source.tags == null ? null : List<String>.from(source.tags!),
        isPublic: source.isPublic,
        prototype: _cloneFoodEntry(source.prototype),
      ),
    );
    await loadAllTemplates();
  }

  Future<void> deleteFoodTemplate(String templateId) async {
    await _storageManager.deleteFoodTemplate(userId, templateId);
    await loadAllTemplates();
  }

  FoodEntry applyFoodTemplate(SavedFoodTemplate template) {
    return _createFoodFromPrototype(template.prototype, template.id);
  }

  void setFilter(TemplateFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  FoodEntry _cloneFoodEntry(FoodEntry original) {
    return FoodEntry.fromJson(original.toJson());
  }

  FoodEntry _createFoodFromPrototype(FoodEntry prototype, String templateId) {
    final food = _cloneFoodEntry(prototype)
      ..id = const Uuid().v4()
      ..originalValues =
          jsonDecode(jsonEncode(prototype.originalValues))
              as Map<String, dynamic>
      ..templateId = templateId
      ..createdAt = DateTime.now()
      ..modifiedAt = null
      ..parentEntryId = null;
    food.componentFoods = food.componentFoods
        ?.map(
          (composition) => FoodComposition.withId(
            parentEntryId: food.id,
            foodId: composition.foodId,
            amount: composition.amount,
            unit: composition.unit,
            sortOrder: composition.sortOrder,
          ),
        )
        .toList();
    return food;
  }

  FoodEntry _buildMealEntry({
    required String name,
    required List<FoodEntry> foods,
  }) {
    final nutrition = _sumNutrition(foods);
    final meal = FoodEntry.withId(
      entryType: FoodEntryType.meal,
      name: name,
      amount: 1,
      unit: 'serving',
      servingSizeGrams: foods.fold(
        0,
        (total, food) => total + food.servingSizeGrams,
      ),
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.asServed,
      nutrition: nutrition,
      source: FoodSource.manual,
      confidenceScore: 0.9,
      originalValues: {},
      componentFoods: [],
    );
    meal.componentFoods = foods
        .map(
          (food) => FoodComposition.withId(
            parentEntryId: meal.id,
            foodId: food.id,
            amount: food.amount,
            unit: food.unit,
          ),
        )
        .toList();
    return meal;
  }

  NutritionProfile _sumNutrition(List<FoodEntry> foods) {
    final micros = <String, double>{};
    var energy = 0.0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    var sugars = 0.0;
    var fiber = 0.0;
    var saturatedFat = 0.0;
    var transFat = 0.0;
    var cholesterol = 0.0;
    var sodium = 0.0;
    var waterContent = 0.0;

    for (final food in foods) {
      final nutrition = food.nutrition;
      energy += nutrition.energyKcal;
      protein += nutrition.protein;
      carbs += nutrition.carbs;
      fat += nutrition.fat;
      sugars += nutrition.sugars;
      fiber += nutrition.fiber;
      saturatedFat += nutrition.saturatedFat;
      transFat += nutrition.transFat;
      cholesterol += nutrition.cholesterol;
      sodium += nutrition.sodium;
      waterContent += nutrition.waterContent;
      nutrition.micros.forEach((key, value) {
        micros[key] = (micros[key] ?? 0) + value;
      });
    }

    return NutritionProfile(
      energyKcal: energy,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sugars: sugars,
      fiber: fiber,
      saturatedFat: saturatedFat,
      transFat: transFat,
      cholesterol: cholesterol,
      sodium: sodium,
      waterContent: waterContent,
      micros: micros,
    );
  }
}
