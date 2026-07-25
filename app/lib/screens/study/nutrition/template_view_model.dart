import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

enum TemplateFilter { all, foods, meals, createdMeals }

class TemplateViewModel extends ChangeNotifier {
  final TemplateStorageManager _storageManager = TemplateStorageManager();
  final String userId;

  List<SavedMealTemplate> _mealTemplates = [];
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

  List<SavedMealTemplate> get mealTemplates => _mealTemplates;
  List<SavedFoodTemplate> get foodTemplates => _foodTemplates;

  List<SavedFoodTemplate> get createdMealTemplates => _foodTemplates
      .where((t) => t.prototype.entryType == FoodEntryType.meal)
      .toList();

  List<SavedFoodTemplate> get foodOnlyTemplates => _foodTemplates
      .where((t) => t.prototype.entryType != FoodEntryType.meal)
      .toList();

  List<dynamic> get filteredTemplates {
    List<dynamic> results = [];

    switch (_currentFilter) {
      case TemplateFilter.all:
        results = [..._mealTemplates, ..._foodTemplates];
      case TemplateFilter.meals:
        results = _mealTemplates;
      case TemplateFilter.foods:
        results = foodOnlyTemplates;
      case TemplateFilter.createdMeals:
        results = createdMealTemplates;
    }

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      results = results.where((template) {
        if (template is SavedMealTemplate) {
          return template.name.toLowerCase().contains(lowerQuery);
        } else if (template is SavedFoodTemplate) {
          return template.name.toLowerCase().contains(lowerQuery);
        }
        return false;
      }).toList();
    }

    return results;
  }

  Future<void> loadAllTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mealTemplates = await _storageManager.loadMealTemplates(userId);
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
    final template = SavedMealTemplate.withId(
      userId: userId,
      name: name,
      mealType: meal.mealType,
      tags: tags,
      isPublic: false,
      prototypes: meal.foods.map(_cloneFoodEntry).toList(),
    );

    await _storageManager.saveMealTemplate(template);
    await loadAllTemplates();
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

  Future<void> updateMealTemplatePrototype(
    String templateId,
    List<FoodEntry> prototypes,
  ) async {
    final templates = await _storageManager.loadMealTemplates(userId);
    final index = templates.indexWhere((template) => template.id == templateId);
    if (index < 0) return;

    templates[index].prototypes = prototypes.map(_cloneFoodEntry).toList();
    templates[index].updatedAt = DateTime.now();
    await _storageManager.saveMealTemplate(templates[index]);
    await loadAllTemplates();
  }

  Future<void> duplicateMealTemplate(String templateId) async {
    final templates = await _storageManager.loadMealTemplates(userId);
    final source = templates.firstWhere(
      (template) => template.id == templateId,
    );
    await _storageManager.saveMealTemplate(
      SavedMealTemplate.withId(
        userId: userId,
        name: source.name,
        mealType: source.mealType,
        tags: source.tags == null ? null : List<String>.from(source.tags!),
        isPublic: source.isPublic,
        prototypes: source.prototypes.map(_cloneFoodEntry).toList(),
      ),
    );
    await loadAllTemplates();
  }

  Future<void> deleteMealTemplate(String templateId) async {
    await _storageManager.deleteMealTemplate(userId, templateId);
    await loadAllTemplates();
  }

  Future<void> renameMealTemplate(String templateId, String newName) async {
    final templates = await _storageManager.loadMealTemplates(userId);
    final index = templates.indexWhere((t) => t.id == templateId);
    if (index >= 0) {
      templates[index].name = newName;
      templates[index].updatedAt = DateTime.now();
      await _storageManager.saveMealTemplate(templates[index]);
      await loadAllTemplates();
    }
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

  MealLog applyMealTemplate(SavedMealTemplate template) {
    return MealLog.withId(
      mealType: template.mealType,
      mealContext: MealContext.home,
      timestamp: DateTime.now(),
      timezone: DateTime.now().timeZoneName,
      isSkipped: false,
      templateId: template.id,
      foods: template.prototypes
          .map((f) => _createFoodFromPrototype(f, template.id))
          .toList(),
    );
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
}
