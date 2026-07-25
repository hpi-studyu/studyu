import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

enum _NewItemType { food, createdMeal }

class MyTemplatesScreen extends StatelessWidget {
  const MyTemplatesScreen({super.key});

  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (_) => const MyTemplatesScreen());

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    return ChangeNotifierProvider(
      create: (_) => TemplateViewModel(userId: userId),
      child: const _MyTemplatesScreenContent(),
    );
  }
}

class _MyTemplatesScreenContent extends StatefulWidget {
  const _MyTemplatesScreenContent();

  @override
  State<_MyTemplatesScreenContent> createState() =>
      _MyTemplatesScreenContentState();
}

class _MyTemplatesScreenContentState extends State<_MyTemplatesScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getFilterLabel(AppLocalizations l10n, TemplateFilter filter) {
    return switch (filter) {
      TemplateFilter.all => l10n.filter_all,
      TemplateFilter.meals => l10n.filter_meals,
      TemplateFilter.foods => l10n.filter_foods,
      TemplateFilter.createdMeals => l10n.filter_created_meals,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<TemplateViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.my_templates),
            actions: [
              PopupMenuButton<_NewItemType>(
                tooltip: l10n.new_item,
                onSelected: (type) {
                  switch (type) {
                    case _NewItemType.food:
                      _createFood(context, viewModel);
                    case _NewItemType.createdMeal:
                      _createCreatedMeal(context, viewModel);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _NewItemType.food,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.fastfood),
                      title: Text(l10n.filter_foods),
                    ),
                  ),
                  PopupMenuItem(
                    value: _NewItemType.createdMeal,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.menu_book),
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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.search_templates,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: viewModel.setSearchQuery,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: TemplateFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: viewModel.currentFilter == filter,
                        label: Text(_getFilterLabel(l10n, filter)),
                        onSelected: (_) => viewModel.setFilter(filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.filteredTemplates.isEmpty
                    ? _buildEmptyState(l10n, theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final template = viewModel.filteredTemplates[index];
                          return _buildTemplateCard(
                            context,
                            template,
                            viewModel,
                            l10n,
                            theme,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(l10n.no_templates_saved, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.save_templates_hint,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createCreatedMeal(
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

  Future<void> _editFood(
    BuildContext context,
    TemplateViewModel viewModel,
    SavedFoodTemplate template,
  ) async {
    final food = await Navigator.push<FoodEntry>(
      context,
      FoodEntryScreen.route(
        existingFood: template.prototype,
        showSearchAction: false,
      ),
    );
    if (food == null || !context.mounted) return;
    await viewModel.updateFoodTemplatePrototype(template.id, food);
  }

  Widget _buildTemplateCard(
    BuildContext context,
    dynamic template,
    TemplateViewModel viewModel,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final isMeal = template is SavedMealTemplate;
    final foodTemplate = template is SavedFoodTemplate ? template : null;
    final isCreatedMeal =
        foodTemplate?.prototype.entryType == FoodEntryType.meal;
    final name = isMeal ? template.name : foodTemplate!.name;
    final metadata = isMeal
        ? '${l10n.template_type_meal} · ${l10n.items_count(template.prototypes.length)}'
        : isCreatedMeal
        ? [
            l10n.template_type_created_meal,
            l10n.servings_value(
              foodTemplate!.prototype.amount.toStringAsFixed(0),
            ),
            l10n.kcal_per_serving(
              foodTemplate.prototype.nutrition.energyKcal.round().toString(),
            ),
          ].join(' · ')
        : [
            l10n.template_type_food,
            if (foodTemplate!.prototype.source == FoodSource.manual)
              l10n.custom
            else
              l10n.database,
            l10n.kcal_value(
              foodTemplate.prototype.nutrition.energyKcal.round().toString(),
            ),
          ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isMeal
              ? Icons.restaurant_menu_outlined
              : isCreatedMeal
              ? Icons.menu_book_outlined
              : Icons.fastfood_outlined,
        ),
        title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(metadata, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: _templateMenu(context, viewModel, template, l10n),
        onTap: () {
          if (isMeal) {
            _showRenameDialog(context, viewModel, template, l10n);
          } else {
            _editFood(context, viewModel, foodTemplate!);
          }
        },
      ),
    );
  }

  PopupMenuButton<String> _templateMenu(
    BuildContext context,
    TemplateViewModel viewModel,
    dynamic template,
    AppLocalizations l10n,
  ) {
    final isMeal = template is SavedMealTemplate;
    return PopupMenuButton<String>(
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: _menuItem(Icons.edit_outlined, l10n.edit),
        ),
        PopupMenuItem(
          value: 'duplicate',
          child: _menuItem(Icons.copy_outlined, l10n.duplicate),
        ),
        PopupMenuItem(
          value: 'rename',
          child: _menuItem(
            Icons.drive_file_rename_outline,
            l10n.rename_template,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: _menuItem(Icons.delete_outline, l10n.delete),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            if (isMeal) {
              await _showRenameDialog(context, viewModel, template, l10n);
            } else {
              await _editFood(
                context,
                viewModel,
                template as SavedFoodTemplate,
              );
            }
          case 'duplicate':
            if (isMeal) {
              await viewModel.duplicateMealTemplate(template.id);
            } else {
              await viewModel.duplicateFoodTemplate(
                (template as SavedFoodTemplate).id,
              );
            }
          case 'rename':
            await _showRenameDialog(context, viewModel, template, l10n);
          case 'delete':
            await _confirmDelete(context, viewModel, template, l10n);
        }
      },
    );
  }

  Widget _menuItem(IconData icon, String label) {
    return Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TemplateViewModel viewModel,
    dynamic template,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.delete_template),
        content: Text(l10n.delete_template_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (template is SavedMealTemplate) {
      await viewModel.deleteMealTemplate(template.id);
    } else if (template is SavedFoodTemplate) {
      await viewModel.deleteFoodTemplate(template.id);
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    TemplateViewModel viewModel,
    dynamic template,
    AppLocalizations l10n,
  ) async {
    final currentName = template is SavedMealTemplate
        ? template.name
        : (template as SavedFoodTemplate).name;
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rename_template),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.new_name,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();
    if (newName == null || newName == currentName) return;
    if (template is SavedMealTemplate) {
      await viewModel.renameMealTemplate(template.id, newName);
    } else if (template is SavedFoodTemplate) {
      await viewModel.renameFoodTemplate(template.id, newName);
    }
  }
}
