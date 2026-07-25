import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart' as studyu;

enum _FoodLibraryAction { add, edit, duplicate, delete }

class FoodLibrary extends StatefulWidget {
  final bool allowMeals;
  final bool showSearch;
  final ScrollController? scrollController;
  final Widget? header;
  final Widget? listHeader;
  final ValueChanged<studyu.SavedFoodTemplate>? onTap;
  final ValueChanged<studyu.SavedFoodTemplate>? onAdd;

  const FoodLibrary({
    this.allowMeals = true,
    this.showSearch = true,
    this.scrollController,
    this.header,
    this.listHeader,
    this.onTap,
    this.onAdd,
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
  final ValueChanged<studyu.SavedFoodTemplate>? onAdd;

  const FoodLibraryItemCard({
    required this.template,
    this.onTap,
    this.onAdd,
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
    final imageUrl = _foodImageUrl(template.prototype);
    final metadata = _isMeal
        ? '${l10n.template_type_meal} · ${l10n.items_count(template.prototype.componentFoods?.length ?? 0)}'
        : _foodServingMetadata(l10n, template.prototype);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                      ? _fallbackItemIcon(theme, icon)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _fallbackItemIcon(theme, icon),
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
                      Text(
                        metadata,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_FoodLibraryAction>(
                  onSelected: (action) => _handleAction(context, action),
                  itemBuilder: (_) => [
                    if (onAdd != null)
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
        onAdd?.call(template);
      case _FoodLibraryAction.edit:
        await _edit(context);
      case _FoodLibraryAction.duplicate:
        await viewModel.duplicateFoodTemplate(template.id);
      case _FoodLibraryAction.delete:
        await _delete(context, viewModel);
    }
  }

  Future<void> _edit(BuildContext context) async {
    if (_isMeal) {
      await _rename(context);
      return;
    }

    final prototype = studyu.FoodEntry.fromJson(template.prototype.toJson());
    final edited = await Navigator.push<studyu.FoodEntry>(
      context,
      FoodEntryScreen.route(existingFood: prototype, showSearchAction: false),
    );
    if (edited == null || !context.mounted) return;
    await context.read<TemplateViewModel>().updateFoodTemplatePrototype(
      template.id,
      edited,
    );
  }

  Future<void> _rename(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: template.name);
    final name = await showDialog<String>(
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
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(dialogContext, name);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name == template.name || !context.mounted) return;
    await context.read<TemplateViewModel>().renameFoodTemplate(
      template.id,
      name,
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

String _formatNumber(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toStringAsFixed(1);

String _foodServingMetadata(AppLocalizations l10n, studyu.FoodEntry food) {
  final unit = food.unit.trim();
  final serving = unit.isEmpty || unit.toLowerCase() == 'serving'
      ? l10n.serving_amount(food.amount)
      : '${_formatNumber(food.amount)} $unit';
  return '$serving · ${l10n.kcal_value(food.nutrition.energyKcal.round().toString())}';
}

String? _foodImageUrl(studyu.FoodEntry food) {
  for (final key in [
    'image_front_small_url',
    'image_front_url',
    'image_url',
    'imageUrl',
  ]) {
    final value = food.originalValues[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}

Widget _fallbackItemIcon(ThemeData theme, IconData icon) => Container(
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: theme.colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
);
