import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('applyFoodTemplate isolates mutable food data', () async {
    final prototype = _foodEntry(
      id: 'food-prototype',
      originalValues: {
        'source': 'saved',
        'details': {'verified': true, 'note': null},
        'tags': ['fresh', null],
      },
    );
    final viewModel = await _viewModel();

    final applied = viewModel.applyFoodTemplate(
      _template(id: 'food-template', prototype: prototype),
    );

    expect(applied.id, isNot(prototype.id));
    expect(applied.templateId, 'food-template');
    expect(applied.nutrition, isNot(same(prototype.nutrition)));
    expect(applied.nutrition.micros, isNot(same(prototype.nutrition.micros)));
    expect(applied.originalValues, isNot(same(prototype.originalValues)));
    final appliedDetails =
        applied.originalValues['details'] as Map<String, dynamic>;
    final prototypeDetails =
        prototype.originalValues['details'] as Map<String, dynamic>;
    final appliedTags = applied.originalValues['tags'] as List<dynamic>;
    final prototypeTags = prototype.originalValues['tags'] as List<dynamic>;
    expect(appliedDetails, isNot(same(prototypeDetails)));
    expect(appliedTags, isNot(same(prototypeTags)));
    expect(appliedDetails['note'], isNull);
    expect(appliedTags[1], isNull);

    applied.nutrition.energyKcal = 999;
    applied.nutrition.micros['iron'] = 999;
    applied.originalValues['source'] = 'applied';
    appliedDetails['verified'] = false;
    appliedTags.add('applied');

    expect(prototype.id, 'food-prototype');
    expect(prototype.templateId, isNull);
    expect(prototype.nutrition.energyKcal, 100);
    expect(prototype.nutrition.micros['iron'], 2);
    expect(prototype.originalValues['source'], 'saved');
    expect(prototypeDetails, {'verified': true, 'note': null});
    expect(prototypeTags, ['fresh', null]);
  });

  test('applyFoodTemplate reparents independent recipe compositions', () async {
    final prototype = _foodEntry(
      id: 'recipe-prototype',
      entryType: FoodEntryType.recipe,
      originalValues: {'source': 'recipe-template'},
      recipeMetadata: RecipeMetadata(
        rawWeight: 500,
        cookedWeight: 400,
        yieldFactor: 0.8,
        preparationMethod: 'baked',
        retentionFactors: {'vitaminC': 0.7},
      ),
      recipeIngredients: [
        RecipeComposition(
          id: 'prototype-composition',
          recipeId: 'recipe-prototype',
          ingredientId: 'ingredient-1',
          amount: 2,
          unit: 'cup',
          sortOrder: 3,
        ),
      ],
    );
    final viewModel = await _viewModel();

    final applied = viewModel.applyFoodTemplate(
      _template(id: 'recipe-template', prototype: prototype),
    );
    final appliedComposition = applied.recipeIngredients!.single;
    final prototypeComposition = prototype.recipeIngredients!.single;

    expect(applied.id, isNot(prototype.id));
    expect(applied.templateId, 'recipe-template');
    expect(applied.recipeMetadata, isNot(same(prototype.recipeMetadata)));
    expect(
      applied.recipeMetadata!.retentionFactors,
      isNot(same(prototype.recipeMetadata!.retentionFactors)),
    );
    expect(applied.recipeIngredients, isNot(same(prototype.recipeIngredients)));
    expect(appliedComposition, isNot(same(prototypeComposition)));
    expect(appliedComposition.id, isNot(prototypeComposition.id));
    expect(appliedComposition.recipeId, applied.id);
    expect(appliedComposition.ingredientId, prototypeComposition.ingredientId);
    expect(appliedComposition.amount, prototypeComposition.amount);
    expect(appliedComposition.unit, prototypeComposition.unit);
    expect(appliedComposition.sortOrder, prototypeComposition.sortOrder);

    applied.recipeMetadata!.retentionFactors['vitaminC'] = 0.1;
    appliedComposition.amount = 99;
    applied.recipeIngredients!.add(
      RecipeComposition.withId(
        recipeId: applied.id,
        ingredientId: 'ingredient-2',
        amount: 1,
        unit: 'g',
      ),
    );

    expect(prototype.id, 'recipe-prototype');
    expect(prototype.templateId, isNull);
    expect(prototype.recipeMetadata!.retentionFactors['vitaminC'], 0.7);
    expect(prototype.recipeIngredients, hasLength(1));
    expect(prototypeComposition.id, 'prototype-composition');
    expect(prototypeComposition.recipeId, 'recipe-prototype');
    expect(prototypeComposition.amount, 2);
  });
}

Future<TemplateViewModel> _viewModel() async {
  final viewModel = TemplateViewModel(userId: 'test-user');
  while (viewModel.isLoading) {
    await Future<void>.delayed(Duration.zero);
  }
  return viewModel;
}

SavedFoodTemplate _template({
  required String id,
  required FoodEntry prototype,
}) => SavedFoodTemplate(
  id: id,
  userId: 'test-user',
  name: 'Template',
  isPublic: false,
  createdAt: DateTime.utc(2025),
  prototype: prototype,
);

FoodEntry _foodEntry({
  required String id,
  FoodEntryType entryType = FoodEntryType.singleIngredient,
  required Map<String, dynamic> originalValues,
  RecipeMetadata? recipeMetadata,
  List<RecipeComposition>? recipeIngredients,
}) => FoodEntry(
  id: id,
  entryType: entryType,
  name: 'Food',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.unknown,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 5,
    carbs: 10,
    fat: 2,
    sugars: 3,
    fiber: 4,
    saturatedFat: 1,
    transFat: 0,
    cholesterol: 0,
    sodium: 10,
    waterContent: 70,
    micros: {'iron': 2},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2025),
  originalValues: originalValues,
  recipeMetadata: recipeMetadata,
  recipeIngredients: recipeIngredients,
);
