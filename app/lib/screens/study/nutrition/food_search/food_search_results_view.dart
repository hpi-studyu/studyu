part of '../food_search_screen.dart';

class _QuickSectionTabs extends StatelessWidget {
  final List<_FoodSearchSection> sections;
  final _FoodSearchSection selectedSection;
  final ValueChanged<_FoodSearchSection> onChanged;
  final AppLocalizations l10n;

  const _QuickSectionTabs({
    required this.sections,
    required this.selectedSection,
    required this.onChanged,
    required this.l10n,
  });

  String label(_FoodSearchSection section) {
    return switch (section) {
      _FoodSearchSection.recent => l10n.recent_foods,
      _FoodSearchSection.myItems => l10n.my_saved_items,
    };
  }

  IconData icon(_FoodSearchSection section) {
    return switch (section) {
      _FoodSearchSection.recent => Icons.history,
      _FoodSearchSection.myItems => Icons.bookmark_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = sections.indexOf(selectedSection);
    return DefaultTabController(
      key: ValueKey(Object.hashAll(sections)),
      length: sections.length,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      child: TabBar(
        isScrollable: true,
        onTap: (index) => onChanged(sections[index]),
        tabs: [
          for (final section in sections)
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon(section), size: 18),
                  const SizedBox(width: 8),
                  Text(label(section)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryFoodCard extends StatelessWidget {
  final FoodSearchHistoryItem item;
  final VoidCallback onTap;
  final ValueChanged<Offset?> onAdd;
  final ThemeData theme;
  final FoodSelectionStore? selectionStore;
  final ValueChanged<Offset?>? onIncrement;
  final VoidCallback? onDecrement;

  const _HistoryFoodCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
    required this.theme,
    this.selectionStore,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final food = item.food;
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = foodImageUrl(food);
    final selected = selectionStore?.itemFor(canonicalFoodSelectionKey(food));
    final metadata = selected == null
        ? _foodServingMetadata(l10n, food)
        : _selectedFoodServingMetadata(
            l10n,
            selected.baselineFood,
            selected.quantity,
            caloriesKnown: selected.caloriesKnown,
            gramsKnown: selected.baselineGramsKnown,
          );
    return SelectionFeedbackCard(
      selected: selected != null,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: '${food.name}, ${l10n.details}',
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  overlayColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.pressed)
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: imageUrl == null
                                ? fallbackFoodIcon(theme, _foodIcon(food))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          fallbackFoodIcon(
                                            theme,
                                            _foodIcon(food),
                                          ),
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
                                  food.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      ListTileTheme.of(
                                        context,
                                      ).titleTextStyle ??
                                      theme.textTheme.bodyLarge,
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
                          FoodDetailsAffordance(
                            showLabel:
                                MediaQuery.sizeOf(context).width >= 400 &&
                                MediaQuery.textScalerOf(context).scale(1) < 1.3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (selected == null)
              Builder(
                builder: (buttonContext) => TextButton(
                  onPressed: () => onAdd(globalCenter(buttonContext)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.add),
                ),
              )
            else
              SelectionQuantityControl(
                name: food.name,
                quantity: selected.quantity,
                quantityStyle: theme.textTheme.titleMedium,
                onIncrement: onIncrement!,
                onDecrement: onDecrement!,
              ),
          ],
        ),
      ),
    );
  }
}

class _FoodResultCard extends StatelessWidget {
  final UnifiedFoodResult result;
  final VoidCallback onTap;
  final ValueChanged<Offset?> onAdd;
  final ThemeData theme;
  final FoodSelectionStore? selectionStore;
  final String? selectionKey;
  final ValueChanged<Offset?>? onIncrement;
  final VoidCallback? onDecrement;

  const _FoodResultCard({
    required this.result,
    required this.onTap,
    required this.onAdd,
    required this.theme,
    this.selectionStore,
    this.selectionKey,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calories = _resultCalories(result);
    final selected = selectionKey == null
        ? null
        : selectionStore?.itemFor(selectionKey!);
    final metadata = selected == null
        ? '${result.servingSizeGrams == null ? '—' : _formatNumber(result.servingSizeGrams!)} g · '
              '${calories == null ? '— kcal' : l10n.kcal_value(calories.round().toString())}'
        : _selectedFoodServingMetadata(
            l10n,
            selected.baselineFood,
            selected.quantity,
            caloriesKnown: selected.caloriesKnown,
            gramsKnown: selected.baselineGramsKnown,
          );

    return SelectionFeedbackCard(
      selected: selected != null,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: '${result.name}, ${l10n.details}',
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  overlayColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.pressed)
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: result.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    result.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => fallbackFoodIcon(
                                      theme,
                                      Icons.restaurant_outlined,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : fallbackFoodIcon(
                                  theme,
                                  Icons.restaurant_outlined,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        FoodDetailsAffordance(
                          showLabel:
                              MediaQuery.sizeOf(context).width >= 400 &&
                              MediaQuery.textScalerOf(context).scale(1) < 1.3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (selected == null)
              Builder(
                builder: (buttonContext) => TextButton(
                  onPressed: () => onAdd(globalCenter(buttonContext)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.add),
                ),
              )
            else
              SelectionQuantityControl(
                name: result.name,
                quantity: selected.quantity,
                quantityStyle: theme.textTheme.titleMedium,
                onIncrement: onIncrement!,
                onDecrement: onDecrement!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.try_again)),
        ],
      ),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  final String message;

  const _EmptySectionMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;

  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        AppLocalizations.of(context)!.no_results_for_query(query),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SearchFallback extends StatelessWidget {
  final String query;
  final VoidCallback onAddManually;

  const _SearchFallback({required this.query, required this.onAddManually});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.cant_find_it,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            FilledButton.tonalIcon(
              onPressed: onAddManually,
              icon: const Icon(Icons.note_add_outlined),
              label: Text(
                AppLocalizations.of(context)!.create_food_from_search(query),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServingHint extends StatelessWidget {
  final AppLocalizations l10n;

  const _ServingHint({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        l10n.tap_item_to_choose_serving,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FoodSearchListView extends StatelessWidget {
  final ScrollController scrollController;
  final AppLocalizations l10n;
  final ThemeData theme;
  final TemplateViewModel templateViewModel;
  final TextEditingController searchController;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasSearched;
  final bool offSearched;
  final bool usdaSearched;
  final bool offHasMore;
  final bool usdaHasMore;
  final String? errorMessage;
  final List<UnifiedFoodResult> combinedResults;
  final FoodSearchHistory history;
  final _FoodSearchSection selectedSection;
  final ValueChanged<_FoodSearchSection> onSectionChanged;
  final _FoodSearchFilter selectedFilter;
  final ValueChanged<_FoodSearchFilter> onFilterChanged;
  final void Function(FoodSearchHistoryItem) onSelectHistory;
  final void Function(FoodSearchHistoryItem, Offset? source) onAddHistory;
  final void Function(studyu.SavedFoodTemplate) onSelectFoodTemplate;
  final FoodLibrarySelectionAction onAddFoodTemplate;
  final void Function(UnifiedFoodResult) onSelectResult;
  final void Function(UnifiedFoodResult, Offset? source) onAddResult;
  final VoidCallback onRetry;
  final bool allowMeals;
  final bool showServingHint;
  final FoodSelectionStore? selectionStore;
  final String Function(UnifiedFoodResult)? selectionKeyForResult;
  final ValueChanged<String> onDecrementSelection;

  const _FoodSearchListView({
    required this.scrollController,
    required this.l10n,
    required this.theme,
    required this.templateViewModel,
    required this.searchController,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasSearched,
    required this.offSearched,
    required this.usdaSearched,
    required this.offHasMore,
    required this.usdaHasMore,
    required this.errorMessage,
    required this.combinedResults,
    required this.history,
    required this.selectedSection,
    required this.onSectionChanged,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSelectHistory,
    required this.onAddHistory,
    required this.onSelectFoodTemplate,
    required this.onAddFoodTemplate,
    required this.onSelectResult,
    required this.onAddResult,
    required this.onRetry,
    this.allowMeals = true,
    required this.showServingHint,
    this.selectionStore,
    this.selectionKeyForResult,
    required this.onDecrementSelection,
  });

  bool isAllowedTemplate(studyu.SavedFoodTemplate template) {
    return allowMeals ||
        template.prototype.entryType != studyu.FoodEntryType.meal;
  }

  List<studyu.SavedFoodTemplate> personalMatches0() {
    final query = searchController.text.trim().toLowerCase();
    return templateViewModel.foodTemplates
        .where(
          (template) =>
              isAllowedTemplate(template) &&
              template.name.toLowerCase().contains(query),
        )
        .toList();
  }

  List<FoodSearchHistoryItem> recentItems0() {
    final items = [...history.frequentlyUsed, ...history.recent]
        .where(
          (item) =>
              allowMeals || item.food.entryType != studyu.FoodEntryType.meal,
        )
        .toList();
    return items..sort((left, right) {
      final dateComparison = right.lastUsedAt.compareTo(left.lastUsedAt);
      if (dateComparison != 0) return dateComparison;
      final countComparison = right.useCount.compareTo(left.useCount);
      return countComparison != 0
          ? countComparison
          : left.identity.compareTo(right.identity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim();
    if (query.isEmpty && selectedSection == _FoodSearchSection.myItems) {
      return FoodLibrary(
        allowMeals: allowMeals,
        showSearch: false,
        scrollController: scrollController,
        header: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _QuickSectionTabs(
            sections: const [
              _FoodSearchSection.recent,
              _FoodSearchSection.myItems,
            ],
            selectedSection: selectedSection,
            onChanged: onSectionChanged,
            l10n: l10n,
          ),
        ),
        listHeader: showServingHint ? _ServingHint(l10n: l10n) : null,
        onTap: onSelectFoodTemplate,
        onAdd: onAddFoodTemplate,
        isSelected: (template) {
          final food = templateViewModel.applyFoodTemplate(template);
          return selectionStore?.itemFor(canonicalFoodSelectionKey(food)) !=
              null;
        },
        selectedQuantity: (template) {
          final food = templateViewModel.applyFoodTemplate(template);
          return selectionStore
                  ?.itemFor(canonicalFoodSelectionKey(food))
                  ?.quantity ??
              1;
        },
        onIncrement: onAddFoodTemplate,
        onDecrement: (template) {
          final food = templateViewModel.applyFoodTemplate(template);
          onDecrementSelection(canonicalFoodSelectionKey(food));
        },
        showManagementActions: false,
        showLibraryHeading: false,
      );
    }

    final children = <Widget>[];
    if (query.isEmpty) {
      children.add(
        _QuickSectionTabs(
          sections: const [
            _FoodSearchSection.recent,
            _FoodSearchSection.myItems,
          ],
          selectedSection: selectedSection,
          onChanged: onSectionChanged,
          l10n: l10n,
        ),
      );
      children.add(const SizedBox(height: 4));
      final recentItems = recentItems0();
      if (recentItems.isEmpty) {
        children.add(
          FoodLibraryEmptyState(
            icon: Icons.history_outlined,
            message: l10n.no_recent_items,
          ),
        );
      } else {
        if (showServingHint) children.add(_ServingHint(l10n: l10n));
        children.addAll(
          recentItems.map(
            (item) => _HistoryFoodCard(
              item: item,
              onTap: () => onSelectHistory(item),
              onAdd: (source) => onAddHistory(item, source),
              theme: theme,
              selectionStore: selectionStore,
              onIncrement: (source) => onAddHistory(item, source),
              onDecrement: () =>
                  onDecrementSelection(canonicalFoodSelectionKey(item.food)),
            ),
          ),
        );
      }
      children.add(const SizedBox(height: 24));
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: children,
      );
    }

    children.add(
      _SearchFilterChips(
        selectedFilter: selectedFilter,
        onChanged: onFilterChanged,
        l10n: l10n,
      ),
    );
    children.add(const SizedBox(height: 12));

    final personalMatches = personalMatches0();
    final showPersonal = selectedFilter != _FoodSearchFilter.database;
    final showDatabase = selectedFilter != _FoodSearchFilter.myItems;
    final databaseComplete = offSearched && usdaSearched;
    final selectedSearchComplete =
        hasSearched &&
        !isInitialLoading &&
        (selectedFilter == _FoodSearchFilter.myItems || databaseComplete);
    final noVisibleResults =
        !(showPersonal && personalMatches.isNotEmpty) &&
        !(showDatabase && combinedResults.isNotEmpty);
    final showGlobalNoResults = selectedSearchComplete && noVisibleResults;
    if (showServingHint &&
        ((showDatabase && combinedResults.isNotEmpty) ||
            (showPersonal && personalMatches.isNotEmpty))) {
      children.add(_ServingHint(l10n: l10n));
    }

    if (showGlobalNoResults) {
      children.add(_NoResultsState(query: query));
    } else {
      if (showPersonal) {
        children.add(
          _SectionHeader(
            icon: Icons.bookmark_outline,
            title: l10n.my_saved_items,
            iconColor: theme.colorScheme.onSurfaceVariant,
          ),
        );
        children.add(const SizedBox(height: 8));
        if (personalMatches.isEmpty) {
          children.add(
            _EmptySectionMessage(message: l10n.no_matching_templates),
          );
        } else {
          children.addAll(
            personalMatches.map(
              (template) => FoodLibraryItemCard(
                template: template,
                onTap: onSelectFoodTemplate,
                onAdd: onAddFoodTemplate,
                isSelected:
                    selectionStore?.itemFor(
                      canonicalFoodSelectionKey(
                        templateViewModel.applyFoodTemplate(template),
                      ),
                    ) !=
                    null,
                selectedQuantity:
                    selectionStore
                        ?.itemFor(
                          canonicalFoodSelectionKey(
                            templateViewModel.applyFoodTemplate(template),
                          ),
                        )
                        ?.quantity ??
                    1,
                onIncrement: (source) => onAddFoodTemplate(template, source),
                onDecrement: () => onDecrementSelection(
                  canonicalFoodSelectionKey(
                    templateViewModel.applyFoodTemplate(template),
                  ),
                ),
                showManagementActions: false,
              ),
            ),
          );
        }
      }

      if (showDatabase) {
        if (showPersonal) children.add(const SizedBox(height: 12));
        children.add(
          _SectionHeader(
            icon: Icons.public,
            title: l10n.global_database,
            iconColor: theme.colorScheme.onSurfaceVariant,
          ),
        );
        children.add(const SizedBox(height: 8));
        if (isInitialLoading && combinedResults.isEmpty) {
          children.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          if (combinedResults.isNotEmpty) {
            children.addAll(
              combinedResults.map(
                (result) => _FoodResultCard(
                  result: result,
                  onTap: () => onSelectResult(result),
                  onAdd: (source) => onAddResult(result, source),
                  theme: theme,
                  selectionStore: selectionStore,
                  selectionKey: selectionKeyForResult?.call(result),
                  onIncrement: (source) => onAddResult(result, source),
                  onDecrement: () => onDecrementSelection(
                    selectionKeyForResult?.call(result) ?? result.id,
                  ),
                ),
              ),
            );
            if (combinedResults.any(
              (result) => result.source == studyu.FoodSource.openfoodfacts,
            )) {
              children.add(const OpenFoodFactsAttribution());
            }
          }
          if (errorMessage != null) {
            children.add(
              _ErrorMessage(message: errorMessage!, onRetry: onRetry),
            );
          } else if (databaseComplete && combinedResults.isEmpty) {
            children.add(
              _EmptySectionMessage(message: l10n.no_matching_templates),
            );
          }
        }
        if (isLoadingMore || (isInitialLoading && combinedResults.isNotEmpty)) {
          children.add(
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (hasSearched &&
            combinedResults.isNotEmpty &&
            !offHasMore &&
            !usdaHasMore &&
            !isInitialLoading &&
            !isLoadingMore) {
          children.add(
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  l10n.end_of_results,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
          );
        }
      }
    }

    children.add(const SizedBox(height: 24));
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: children,
    );
  }
}

class _SearchFilterChips extends StatelessWidget {
  final _FoodSearchFilter selectedFilter;
  final ValueChanged<_FoodSearchFilter> onChanged;
  final AppLocalizations l10n;

  const _SearchFilterChips({
    required this.selectedFilter,
    required this.onChanged,
    required this.l10n,
  });

  String label(_FoodSearchFilter filter) => switch (filter) {
    _FoodSearchFilter.all => l10n.filter_all,
    _FoodSearchFilter.myItems => l10n.my_saved_items,
    _FoodSearchFilter.database => l10n.database,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _FoodSearchFilter.values) ...[
            FilterChip(
              selected: selectedFilter == filter,
              label: Text(label(filter)),
              onSelected: (_) => onChanged(filter),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

String _formatNumber(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toStringAsFixed(1);

String _foodServingMetadata(AppLocalizations l10n, studyu.FoodEntry food) =>
    foodTotalMetadata(
      l10n,
      food,
      1,
      caloriesKnown: !food.nutrition.unavailableNutrients.contains(
        'energyKcal',
      ),
    );

String _selectedFoodServingMetadata(
  AppLocalizations l10n,
  studyu.FoodEntry food,
  int quantity, {
  required bool caloriesKnown,
  required bool gramsKnown,
}) => foodTotalMetadata(
  l10n,
  food,
  quantity,
  gramsKnown: gramsKnown,
  caloriesKnown: caloriesKnown,
);

double? _resultCalories(UnifiedFoodResult result) => result.calories;

bool resultCaloriesKnown(UnifiedFoodResult result) {
  return switch (result.originalData) {
    final UsdaFoodItem food => food.getNutrientValue(1008) != null,
    final Product product =>
      product.nutriments?.getValue(
            Nutrient.energyKCal,
            PerSize.oneHundredGrams,
          ) !=
          null,
    _ => result.calories != null,
  };
}
