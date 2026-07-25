import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

enum FoodQuantityAction { existingMeal, addToSelection, updateSelection }

class FoodQuantitySheet extends StatefulWidget {
  final FoodEntry food;
  final String? mealLabel;
  final FoodQuantityAction action;

  const FoodQuantitySheet({
    required this.food,
    this.mealLabel,
    this.action = FoodQuantityAction.existingMeal,
    super.key,
  });

  static Future<FoodEntry?> show(
    BuildContext context, {
    required FoodEntry food,
    String? mealLabel,
    FoodQuantityAction action = FoodQuantityAction.existingMeal,
  }) => showModalBottomSheet<FoodEntry>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        FoodQuantitySheet(food: food, mealLabel: mealLabel, action: action),
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
      text: _formatNumber(widget.food.amount),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final food = _scaledFood ?? widget.food;
    final serving = widget.food.portionReference?.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            Text(widget.food.name, style: theme.textTheme.headlineSmall),
            if (widget.food.brandName case final brand?) ...[
              const SizedBox(height: 4),
              Text(brand, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 24),
            Text(l10n.food_quantity_amount, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: (_scaledFood?.amount ?? widget.food.amount) > 1
                      ? () => _changeAmount(-1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                    ],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _scaledFood == null
                          ? l10n.food_quantity_invalid_amount
                          : null,
                      suffixText: widget.food.unit,
                    ),
                    onChanged: _updateAmount,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () => _changeAmount(1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.food_quantity_serving,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              serving != null && serving.isNotEmpty
                  ? serving
                  : l10n.food_quantity_serving_value(
                      _formatNumber(widget.food.servingSizeGrams),
                      widget.food.unit,
                    ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _NutrientValue(
                  label: l10n.food_quantity_energy,
                  value: l10n.kcal_value(
                    food.nutrition.energyKcal.toStringAsFixed(0),
                  ),
                ),
                _NutrientValue(
                  label: l10n.food_quantity_protein,
                  value: '${food.nutrition.protein.toStringAsFixed(1)} g',
                ),
                _NutrientValue(
                  label: l10n.food_quantity_carbs,
                  value: '${food.nutrition.carbs.toStringAsFixed(1)} g',
                ),
                _NutrientValue(
                  label: l10n.food_quantity_fat,
                  value: '${food.nutrition.fat.toStringAsFixed(1)} g',
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _scaledFood == null
                  ? null
                  : () => Navigator.pop(context, _scaledFood),
              child: Text(switch (widget.action) {
                FoodQuantityAction.addToSelection =>
                  l10n.food_quantity_add_to_selection,
                FoodQuantityAction.updateSelection =>
                  l10n.food_quantity_update_selection,
                FoodQuantityAction.existingMeal =>
                  widget.mealLabel == null
                      ? l10n.add_food
                      : l10n.food_quantity_add_to_meal(widget.mealLabel!),
              }),
            ),
          ],
        ),
      ),
    );
  }
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
