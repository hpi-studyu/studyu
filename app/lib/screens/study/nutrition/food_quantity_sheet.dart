import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

enum FoodQuantityAction {
  /// Legacy actions retained for source compatibility.
  existingMeal,
  addToSelection,
  addMealToSelection,
  updateSelection,
  addToMeal,
  update,
}

class FoodQuantitySheet extends StatefulWidget {
  final FoodEntry food;
  final String? mealLabel;
  final FoodQuantityAction action;
  final double? initialAmount;
  final bool caloriesKnown;
  final bool gramsKnown;

  const FoodQuantitySheet({
    required this.food,
    this.mealLabel,
    this.action = FoodQuantityAction.existingMeal,
    this.initialAmount,
    this.caloriesKnown = true,
    this.gramsKnown = true,
    super.key,
  });

  static Future<FoodEntry?> show(
    BuildContext context, {
    required FoodEntry food,
    String? mealLabel,
    FoodQuantityAction action = FoodQuantityAction.existingMeal,
    double? initialAmount,
    bool caloriesKnown = true,
    bool gramsKnown = true,
  }) => showModalBottomSheet<FoodEntry>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FoodQuantitySheet(
      food: food,
      mealLabel: mealLabel,
      action: action,
      initialAmount: initialAmount,
      caloriesKnown: caloriesKnown,
      gramsKnown: gramsKnown,
    ),
  );

  @override
  State<FoodQuantitySheet> createState() => _FoodQuantitySheetState();
}

class _FoodQuantitySheetState extends State<FoodQuantitySheet> {
  late final TextEditingController _amountController;
  FoodEntry? _scaledFood;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _formatNumber(widget.initialAmount ?? widget.food.amount),
    );
    _updateAmount(_amountController.text);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  static String _formatNumber(double value) => value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  void _updateAmount(String value) {
    final amount = double.tryParse(value.replaceFirst(',', '.'));
    final sourceAmount = widget.food.amount;
    setState(() {
      _scaledFood =
          amount != null &&
              amount.isFinite &&
              amount > 0 &&
              sourceAmount.isFinite &&
              sourceAmount > 0
          ? rescaleFoodAmount(widget.food, amount)
          : null;
    });
  }

  void _changeAmount(double delta) {
    final current = _scaledFood?.amount ?? widget.food.amount;
    final next = current + delta;
    if (!next.isFinite || next <= 0) return;
    _amountController.text = _formatNumber(next);
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
    _updateAmount(_amountController.text);
  }

  String _servingDescription(AppLocalizations l10n) {
    final portionReference = widget.food.portionReference?.trim();
    if (!widget.gramsKnown) {
      return portionReference == null || portionReference.isEmpty
          ? l10n.serving_amount(1)
          : portionReference;
    }
    final servingWeight = l10n.grams_per_serving(
      _formatNumber(widget.food.servingSizeGrams),
    );
    if (portionReference != null && portionReference.isNotEmpty) {
      return '$portionReference · $servingWeight';
    }
    return servingWeight;
  }

  String _amountUnit(AppLocalizations l10n, double amount) {
    final unit = widget.food.unit.trim();
    return unit.isEmpty || unit.toLowerCase() == 'serving'
        ? l10n.food_quantity_serving_unit(amount)
        : unit;
  }

  String? _foodImageUrl() {
    for (final key in [
      'image_front_small_url',
      'image_front_url',
      'image_url',
      'imageUrl',
    ]) {
      final value = widget.food.originalValues[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final food = _scaledFood ?? widget.food;
    final amount = food.amount;
    final servings = amount / widget.food.amount;
    final unavailable = widget.food.nutrition.unavailableNutrients;
    final caloriesKnown =
        widget.caloriesKnown && !unavailable.contains('energyKcal');
    final nutritionUnavailable =
        !caloriesKnown ||
        const {'protein', 'carbs', 'fat'}.any(unavailable.contains);
    final brand = widget.food.brandName?.trim();
    final imageUrl = _foodImageUrl();
    final subtitle = [
      if (brand != null && brand.isNotEmpty) brand,
      _servingDescription(l10n),
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: imageUrl == null
                            ? _FoodImageFallback(
                                theme: theme,
                                semanticLabel: widget.food.name,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  semanticLabel: widget.food.name,
                                  errorBuilder: (_, _, _) => _FoodImageFallback(
                                    theme: theme,
                                    semanticLabel: widget.food.name,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.food.name,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: l10n.close,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            l10n.food_quantity_amount,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: amount > 1
                                    ? () => _changeAmount(-1)
                                    : null,
                                tooltip: l10n.food_selection_decrement(
                                  widget.food.name,
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp('[0-9.,]'),
                                    ),
                                  ],
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    suffixText: _amountUnit(l10n, amount),
                                  ),
                                  onChanged: _updateAmount,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _changeAmount(1),
                                tooltip: l10n.food_selection_increment(
                                  widget.food.name,
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_scaledFood == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.food_quantity_invalid_amount,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    l10n.food_quantity_selection_total,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caloriesKnown
                        ? l10n.kcal_value(
                            food.nutrition.energyKcal.toStringAsFixed(0),
                          )
                        : '— kcal',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (caloriesKnown &&
                      servings > 1 &&
                      widget.food.nutrition.energyKcal != 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.food_quantity_per_serving(
                        l10n.kcal_value(
                          widget.food.nutrition.energyKcal.toStringAsFixed(0),
                        ),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (nutritionUnavailable) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.food_quantity_nutrition_unavailable,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _NutrientGrid(
                    nutrients: [
                      (
                        l10n.food_quantity_protein,
                        unavailable.contains('protein')
                            ? '—'
                            : '${food.nutrition.protein.toStringAsFixed(1)} g',
                      ),
                      (
                        l10n.food_quantity_carbs,
                        unavailable.contains('carbs')
                            ? '—'
                            : '${food.nutrition.carbs.toStringAsFixed(1)} g',
                      ),
                      (
                        l10n.food_quantity_fat,
                        unavailable.contains('fat')
                            ? '—'
                            : '${food.nutrition.fat.toStringAsFixed(1)} g',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _scaledFood == null
                  ? null
                  : () => Navigator.pop(context, _scaledFood),
              child: Text(switch (widget.action) {
                FoodQuantityAction.addToSelection =>
                  widget.mealLabel == null
                      ? l10n.add_food
                      : l10n.food_quantity_add_to_meal(widget.mealLabel!),
                FoodQuantityAction.addMealToSelection =>
                  widget.mealLabel == null
                      ? l10n.add_food
                      : l10n.food_quantity_add_to_meal(widget.mealLabel!),
                FoodQuantityAction.addToMeal =>
                  widget.mealLabel == null
                      ? l10n.add_food
                      : l10n.food_quantity_add_to_meal(widget.mealLabel!),
                FoodQuantityAction.update => l10n.update,
                FoodQuantityAction.updateSelection => l10n.update,
                FoodQuantityAction.existingMeal => l10n.update,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodImageFallback extends StatelessWidget {
  final ThemeData theme;
  final String semanticLabel;

  const _FoodImageFallback({required this.theme, required this.semanticLabel});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      Icons.restaurant_outlined,
      color: theme.colorScheme.onSurfaceVariant,
      semanticLabel: semanticLabel,
    ),
  );
}

class _NutrientGrid extends StatelessWidget {
  final List<(String, String)> nutrients;

  const _NutrientGrid({required this.nutrients});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
      final columns = constraints.maxWidth < 360 || largeText ? 2 : 3;
      const spacing = 16.0;
      final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: 16,
        children: [
          for (final nutrient in nutrients)
            SizedBox(
              width: width,
              child: _NutrientValue(label: nutrient.$1, value: nutrient.$2),
            ),
        ],
      );
    },
  );
}

class _NutrientValue extends StatelessWidget {
  final String label;
  final String value;

  const _NutrientValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}
