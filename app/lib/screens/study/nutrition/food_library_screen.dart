import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

enum _NewItemType { food, meal }

class FoodLibraryScreen extends StatelessWidget {
  final bool embedded;

  const FoodLibraryScreen({this.embedded = false, super.key});

  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (_) => const FoodLibraryScreen());

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';
    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId),
      child: _FoodLibraryScreenContent(embedded: embedded),
    );
  }
}

class _FoodLibraryScreenContent extends StatelessWidget {
  final bool embedded;

  const _FoodLibraryScreenContent({required this.embedded});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<TemplateViewModel>();
    const library = FoodLibrary();
    final newItemButton = _newItemButton(context, viewModel, l10n);

    if (!embedded) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.food_library),
          actions: [newItemButton],
        ),
        body: library,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.food_library,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              newItemButton,
            ],
          ),
        ),
        const Expanded(child: library),
      ],
    );
  }

  Widget _newItemButton(
    BuildContext context,
    TemplateViewModel viewModel,
    AppLocalizations l10n,
  ) => PopupMenuButton<_NewItemType>(
    tooltip: l10n.new_item,
    onSelected: (type) {
      switch (type) {
        case _NewItemType.food:
          _createFood(context, viewModel);
        case _NewItemType.meal:
          _createMeal(context, viewModel);
      }
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: _NewItemType.food,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_outlined),
            const SizedBox(width: 12),
            Text(l10n.add_food_action),
          ],
        ),
      ),
      PopupMenuItem(
        value: _NewItemType.meal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu_outlined),
            const SizedBox(width: 12),
            Text(l10n.add_meal_action),
          ],
        ),
      ),
    ],
    icon: const Icon(Icons.add),
  );

  Future<void> _createMeal(
    BuildContext context,
    TemplateViewModel viewModel,
  ) async {
    final meal = await Navigator.push<FoodEntry>(
      context,
      MealCreatorScreen.route(),
    );
    if (meal == null || !context.mounted) return;
    await viewModel.saveFoodAsTemplate(name: meal.name, food: meal);
  }

  Future<void> _createFood(
    BuildContext context,
    TemplateViewModel viewModel,
  ) async {
    final food = await Navigator.push<FoodEntry>(
      context,
      FoodEntryScreen.route(showSearchAction: false),
    );
    if (food == null || !context.mounted) return;
    await viewModel.saveFoodAsTemplate(name: food.name, food: food);
  }
}
