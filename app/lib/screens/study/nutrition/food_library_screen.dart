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
  const FoodLibraryScreen({super.key});

  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (_) => const FoodLibraryScreen());

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId),
      child: const _FoodLibraryScreenContent(),
    );
  }
}

class _FoodLibraryScreenContent extends StatelessWidget {
  const _FoodLibraryScreenContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<TemplateViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.food_library),
        actions: [
          PopupMenuButton<_NewItemType>(
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
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fastfood),
                  title: Text(l10n.filter_foods),
                ),
              ),
              PopupMenuItem(
                value: _NewItemType.meal,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restaurant_menu_outlined),
                  title: Text(l10n.create_meal),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 4),
                  Text(l10n.new_item),
                ],
              ),
            ),
          ),
        ],
      ),
      body: const FoodLibrary(),
    );
  }

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
