import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_bar.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart' as studyu;

export 'package:studyu_app/screens/study/nutrition/food_item_components.dart'
    show SelectionFeedbackCard, SelectionQuantityButton, SelectionQuantityText;

enum _FoodLibraryAction { add, edit, duplicate, delete }

typedef FoodLibrarySelectionAction =
    void Function(studyu.SavedFoodTemplate template, Offset? source);

class FoodLibrary extends StatefulWidget {
  final bool allowMeals;
  final bool showSearch;
  final ScrollController? scrollController;
  final Widget? header;
  final Widget? listHeader;
  final ValueChanged<studyu.SavedFoodTemplate>? onTap;
  final FoodLibrarySelectionAction? onAdd;
  final bool Function(studyu.SavedFoodTemplate)? isSelected;
  final int Function(studyu.SavedFoodTemplate)? selectedQuantity;
  final FoodLibrarySelectionAction? onIncrement;
  final ValueChanged<studyu.SavedFoodTemplate>? onDecrement;
  final bool showManagementActions;

  const FoodLibrary({
    this.allowMeals = true,
    this.showSearch = true,
    this.scrollController,
    this.header,
    this.listHeader,
    this.onTap,
    this.onAdd,
    this.isSelected,
    this.selectedQuantity,
    this.onIncrement,
    this.onDecrement,
    this.showManagementActions = true,
    super.key,
  });

  @override
  State<FoodLibrary> createState() => _FoodLibraryState();
}

class _FoodLibraryState extends State<FoodLibrary> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<TemplateViewModel>();
    final templates = viewModel.filteredTemplates
        .where(
          (template) =>
              widget.allowMeals ||
              template.prototype.entryType != studyu.FoodEntryType.meal,
        )
        .toList();

    return Column(
      children: [
        if (widget.showSearch)
          FoodSearchBar(
            controller: _searchController,
            hintText: l10n.search_templates,
            onChanged: viewModel.setSearchQuery,
          ),
        if (widget.header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity, child: widget.header),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _FoodLibraryToolbar(viewModel: viewModel, l10n: l10n),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : templates.isEmpty
              ? _FoodLibraryEmptyState(
                  message: viewModel.searchQuery.isEmpty
                      ? l10n.no_templates_saved
                      : l10n.no_matching_templates,
                )
              : ListView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (widget.listHeader != null) widget.listHeader!,
                    for (final template in templates)
                      FoodLibraryItemCard(
                        template: template,
                        onTap: widget.onTap,
                        onAdd: widget.onAdd,
                        isSelected: widget.isSelected?.call(template) ?? false,
                        selectedQuantity:
                            widget.selectedQuantity?.call(template) ?? 1,
                        onIncrement: widget.onIncrement == null
                            ? null
                            : (source) => widget.onIncrement!(template, source),
                        onDecrement: widget.onDecrement == null
                            ? null
                            : () => widget.onDecrement!(template),
                        showManagementActions: widget.showManagementActions,
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ],
    );
  }
}

class FoodLibraryItemCard extends StatelessWidget {
  final studyu.SavedFoodTemplate template;
  final ValueChanged<studyu.SavedFoodTemplate>? onTap;
  final FoodLibrarySelectionAction? onAdd;
  final bool isSelected;
  final int selectedQuantity;
  final ValueChanged<Offset?>? onIncrement;
  final VoidCallback? onDecrement;
  final bool showManagementActions;

  const FoodLibraryItemCard({
    required this.template,
    this.onTap,
    this.onAdd,
    this.isSelected = false,
    this.selectedQuantity = 1,
    this.onIncrement,
    this.onDecrement,
    this.showManagementActions = true,
    super.key,
  });

  bool get _isMeal => template.prototype.entryType == studyu.FoodEntryType.meal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final icon = _isMeal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final imageUrl = foodImageUrl(template.prototype);
    final quantity = isSelected ? selectedQuantity : 1;
    final metadata = _isMeal
        ? '${l10n.template_type_meal} · '
              '${l10n.items_count(template.prototype.componentFoods?.length ?? 0)} · '
              '${l10n.kcal_value((template.prototype.nutrition.energyKcal * template.prototype.amount * quantity).round().toString())}'
        : selectedFoodServingMetadata(l10n, template.prototype, quantity);

    return SelectionFeedbackCard(
      selected: isSelected,
      child: InkWell(
        onTap: () {
          if (onTap case final onTap?) {
            onTap(template);
          } else {
            _edit(context);
          }
        },
        borderRadius: BorderRadius.circular(12),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: imageUrl == null
                      ? fallbackFoodIcon(theme, icon)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                fallbackFoodIcon(theme, icon),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: selectionAnimationDuration(context),
                        child: Text(
                          metadata,
                          key: ValueKey(metadata),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected && onIncrement != null && onDecrement != null)
                  SelectionQuantityControl(
                    name: template.name,
                    quantity: selectedQuantity,
                    onIncrement: onIncrement!,
                    onDecrement: onDecrement!,
                  )
                else if (onAdd != null)
                  Builder(
                    builder: (buttonContext) => TextButton(
                      onPressed: () =>
                          onAdd!(template, globalCenter(buttonContext)),
                      child: Text(l10n.add),
                    ),
                  ),
                if (showManagementActions)
                  PopupMenuButton<_FoodLibraryAction>(
                    onSelected: (action) => _handleAction(context, action),
                    itemBuilder: (_) => [
                      if (onAdd != null && !isSelected)
                        PopupMenuItem(
                          value: _FoodLibraryAction.add,
                          child: _menuItem(Icons.add, l10n.add),
                        ),
                      PopupMenuItem(
                        value: _FoodLibraryAction.edit,
                        child: _menuItem(Icons.edit_outlined, l10n.edit),
                      ),
                      PopupMenuItem(
                        value: _FoodLibraryAction.duplicate,
                        child: _menuItem(Icons.copy_outlined, l10n.duplicate),
                      ),
                      PopupMenuItem(
                        value: _FoodLibraryAction.delete,
                        child: _menuItem(Icons.delete_outline, l10n.delete),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _FoodLibraryAction action,
  ) async {
    final viewModel = context.read<TemplateViewModel>();
    switch (action) {
      case _FoodLibraryAction.add:
        onAdd?.call(template, null);
      case _FoodLibraryAction.edit:
        await _edit(context);
      case _FoodLibraryAction.duplicate:
        await viewModel.duplicateFoodTemplate(template.id);
      case _FoodLibraryAction.delete:
        await _delete(context, viewModel);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final prototype = studyu.FoodEntry.fromJson(template.prototype.toJson());
    final edited = await Navigator.push<studyu.FoodEntry>(
      context,
      _isMeal
          ? MealCreatorScreen.route(existingMeal: prototype)
          : FoodEntryScreen.route(
              existingFood: prototype,
              showSearchAction: false,
            ),
    );
    if (edited == null || !context.mounted) return;
    await context.read<TemplateViewModel>().updateFoodTemplatePrototype(
      template.id,
      edited,
    );
  }

  Future<void> _delete(
    BuildContext context,
    TemplateViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete_template),
        content: Text(l10n.delete_template_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.deleteFoodTemplate(template.id);
  }

  Widget _menuItem(IconData icon, String label) =>
      Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]);
}

class _FoodLibraryToolbar extends StatelessWidget {
  final TemplateViewModel viewModel;
  final AppLocalizations l10n;

  const _FoodLibraryToolbar({required this.viewModel, required this.l10n});

  String _label(TemplateFilter filter) => switch (filter) {
    TemplateFilter.all => l10n.filter_all,
    TemplateFilter.foods => l10n.filter_foods,
    TemplateFilter.meals => l10n.filter_meals,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in TemplateFilter.values) ...[
            FilterChip(
              selected: viewModel.currentFilter == filter,
              label: Text(_label(filter)),
              onSelected: (_) => viewModel.setFilter(filter),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _FoodLibraryEmptyState extends StatelessWidget {
  final String message;

  const _FoodLibraryEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
