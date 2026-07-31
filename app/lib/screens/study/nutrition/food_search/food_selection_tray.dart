part of '../food_search_screen.dart';

class _SelectionPeekTray extends StatelessWidget {
  final GlobalKey anchorKey;
  final GlobalKey headerAnchorKey;
  final GlobalKey Function(String key) rowAnchorFor;
  final GlobalKey Function(String key) quantityAnchorFor;
  final FoodSelectionStore store;
  final String mealLabel;
  final bool isConfirming;
  final VoidCallback onReview;
  final VoidCallback onConfirm;
  final ValueChanged<FoodSelectionItem> onSelect;
  final void Function(String key, Offset? source) onIncrement;
  final ValueChanged<String> onDecrement;

  const _SelectionPeekTray({
    required this.anchorKey,
    required this.headerAnchorKey,
    required this.rowAnchorFor,
    required this.quantityAnchorFor,
    required this.store,
    required this.mealLabel,
    required this.isConfirming,
    required this.onReview,
    required this.onConfirm,
    required this.onSelect,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final keyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final largeText = mediaQuery.textScaler.scale(1) > 1.3;
    final previewLimit = keyboardOpen ? 0 : (largeText ? 1 : 2);
    final previewItems = store.recentItems.take(previewLimit).toList();
    final hiddenItemCount = store.itemCount - previewItems.length;
    final showViewMore = !keyboardOpen && hiddenItemCount > 0;
    final calorieText = _selectionCaloriesSummary(l10n, store);
    final totals = '${l10n.serving_amount(store.servingCount)} · $calorieText';
    final unavailable = store.unknownCaloriesCount == 0
        ? ''
        : ', ${l10n.food_selection_calories_unavailable(store.unknownCaloriesCount)}';
    final totalsSemantics =
        '${l10n.items_count(store.itemCount)}, '
        '${l10n.serving_amount(store.servingCount)}, $calorieText$unavailable';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -200) onReview();
      },
      child: Material(
        key: anchorKey,
        elevation: 8,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Semantics(
                  button: true,
                  label: totalsSemantics,
                  child: ExcludeSemantics(
                    child: InkWell(
                      onTap: onReview,
                      child: Container(
                        key: headerAnchorKey,
                        constraints: const BoxConstraints(minHeight: 48),
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 2,
                            children: [
                              Text(
                                l10n.food_selection_selected_count(
                                  store.itemCount,
                                ),
                                style: theme.textTheme.titleSmall,
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 20,
                                ),
                                child: AnimatedSwitcher(
                                  duration: selectionAnimationDuration(context),
                                  child: Text(
                                    totals,
                                    key: ValueKey(totals),
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _SelectionPreviewRows(
                  items: previewItems,
                  rowAnchorFor: rowAnchorFor,
                  quantityAnchorFor: quantityAnchorFor,
                  onSelect: onSelect,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
                if (showViewMore)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onReview,
                      child: Text(
                        l10n.food_selection_view_more(hiddenItemCount),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: isConfirming ? null : onConfirm,
                  child: Text(
                    l10n.food_selection_confirm(store.itemCount, mealLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionPreviewRows extends StatefulWidget {
  final List<FoodSelectionItem> items;
  final GlobalKey Function(String key) rowAnchorFor;
  final GlobalKey Function(String key) quantityAnchorFor;
  final ValueChanged<FoodSelectionItem> onSelect;
  final void Function(String key, Offset? source) onIncrement;
  final ValueChanged<String> onDecrement;

  const _SelectionPreviewRows({
    required this.items,
    required this.rowAnchorFor,
    required this.quantityAnchorFor,
    required this.onSelect,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<_SelectionPreviewRows> createState() => _SelectionPreviewRowsState();
}

class _SelectionPreviewRowsState extends State<_SelectionPreviewRows> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<FoodSelectionItem> _items = List.of(widget.items);

  @override
  void didUpdateWidget(_SelectionPreviewRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    final listState = _listKey.currentState;
    if (listState == null) {
      _items = List.of(widget.items);
      return;
    }

    final nextKeys = widget.items.map((item) => item.key).toSet();
    for (var index = _items.length - 1; index >= 0; index--) {
      if (nextKeys.contains(_items[index].key)) continue;
      final removed = _items.removeAt(index);
      listState.removeItem(
        index,
        (_, animation) => _buildRow(removed, animation, outgoing: true),
        duration: selectionAnimationDuration(context),
      );
    }

    for (
      var targetIndex = 0;
      targetIndex < widget.items.length;
      targetIndex++
    ) {
      final item = widget.items[targetIndex];
      final currentIndex = _items.indexWhere((entry) => entry.key == item.key);
      if (currentIndex == -1) {
        _items.insert(targetIndex, item);
        listState.insertItem(
          targetIndex,
          duration: selectionAnimationDuration(context),
        );
      } else if (currentIndex != targetIndex) {
        final moved = _items.removeAt(currentIndex);
        listState.removeItem(
          currentIndex,
          (_, animation) => const SizedBox.shrink(),
          duration: Duration.zero,
        );
        _items.insert(targetIndex, moved);
        listState.insertItem(targetIndex, duration: Duration.zero);
      }
      _items[targetIndex] = item;
    }
  }

  Widget _buildRow(
    FoodSelectionItem item,
    Animation<double> animation, {
    bool outgoing = false,
  }) {
    final row = _SelectionPreviewRow(
      key: ValueKey(outgoing ? 'removing:${item.key}' : item.key),
      anchorKey: outgoing ? null : widget.rowAnchorFor(item.key),
      quantityAnchorKey: outgoing ? null : widget.quantityAnchorFor(item.key),
      item: item,
      onSelect: widget.onSelect,
      onIncrement: widget.onIncrement,
      onDecrement: widget.onDecrement,
    );
    if (!outgoing) {
      return FadeTransition(opacity: animation, child: row);
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.topCenter,
            child: row,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index, animation) =>
          _buildRow(_items[index], animation),
    );
  }
}

class _SelectionPreviewRow extends StatelessWidget {
  final GlobalKey? anchorKey;
  final GlobalKey? quantityAnchorKey;
  final FoodSelectionItem item;
  final ValueChanged<FoodSelectionItem> onSelect;
  final void Function(String key, Offset? source) onIncrement;
  final ValueChanged<String> onDecrement;

  const _SelectionPreviewRow({
    this.anchorKey,
    this.quantityAnchorKey,
    required this.item,
    required this.onSelect,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final overridden = item.servingWeightOverridden;
    final weightStyle = theme.textTheme.bodySmall?.copyWith(
      color: overridden
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant,
      fontWeight: overridden ? FontWeight.w600 : null,
    );
    final grams = item.gramsKnown
        ? formatFoodNumber(
            item.baseFood.servingSizeGrams *
                item.baseFood.amount *
                item.quantity,
          )
        : '—';
    return Container(
      key: anchorKey,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onSelect(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('$grams g', style: weightStyle),
                    if (overridden) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.food_quantity_custom_weight,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SelectionQuantityControl(
            name: item.name,
            quantity: item.quantity,
            quantityAnchorKey: quantityAnchorKey,
            quantityStyle: Theme.of(context).textTheme.titleMedium,
            onDecrement: () => onDecrement(item.key),
            onIncrement: (source) => onIncrement(item.key, source),
          ),
        ],
      ),
    );
  }
}

class _SelectionReviewSheet extends StatefulWidget {
  final FoodSelectionStore store;
  final String mealLabel;

  const _SelectionReviewSheet({required this.store, required this.mealLabel});

  @override
  State<_SelectionReviewSheet> createState() => _SelectionReviewSheetState();
}

class _SelectionReviewSheetState extends State<_SelectionReviewSheet> {
  bool _isConfirming = false;
  FoodSelectionItem? _removedItem;
  bool _isRemoving = false;

  FoodSelectionStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    store.addListener(onStoreChanged);
  }

  @override
  void dispose() {
    store.removeListener(onStoreChanged);
    super.dispose();
  }

  void onStoreChanged() {
    if (mounted && store.isEmpty && _removedItem == null) {
      Navigator.pop(context);
    }
    if (mounted) setState(() {});
  }

  void _decrement(FoodSelectionItem item) {
    if (item.quantity > 1) {
      store.decrement(item.key);
      return;
    }

    setState(() {
      _removedItem = FoodSelectionItem(
        key: item.key,
        baselineFood: cloneFoodEntry(item.baselineFood),
        baseFood: cloneFoodEntry(item.baseFood),
        quantity: item.quantity,
        caloriesKnown: item.caloriesKnown,
        gramsKnown: item.gramsKnown,
        baselineGramsKnown: item.baselineGramsKnown,
      );
      _isRemoving = true;
    });
    store.decrement(item.key);
  }

  void _undoRemoval() {
    final removedItem = _removedItem;
    if (removedItem == null) return;
    setState(() {
      _removedItem = null;
      _isRemoving = false;
    });
    store.restore(removedItem);
  }

  String _itemMetadata(AppLocalizations l10n, FoodSelectionItem item) =>
      _selectedFoodServingMetadata(
        l10n,
        item.baseFood,
        item.quantity,
        caloriesKnown: item.caloriesKnown,
        gramsKnown: item.gramsKnown,
      );

  Widget _itemRow(
    BuildContext context,
    AppLocalizations l10n,
    FoodSelectionItem item, {
    bool enabled = true,
  }) {
    final metadata = _itemMetadata(l10n, item);
    return ListTile(
      key: ValueKey(item.key),
      title: Text(item.name),
      subtitle: AnimatedSwitcher(
        duration: selectionAnimationDuration(context),
        child: Text(metadata, key: ValueKey(metadata)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectionQuantityButton(
            tooltip: l10n.food_selection_decrement(item.name),
            onPressed: enabled ? () => _decrement(item) : null,
            icon: Icons.remove,
          ),
          SelectionQuantityText(quantity: item.quantity),
          SelectionQuantityButton(
            tooltip: l10n.food_selection_increment(item.name),
            onPressed: enabled ? () => store.increment(item.key) : null,
            icon: Icons.add,
          ),
          IconButton(
            tooltip: l10n.food_selection_delete(item.name),
            onPressed: enabled ? () => store.delete(item.key) : null,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _removingRow(
    BuildContext context,
    AppLocalizations l10n,
    FoodSelectionItem item,
  ) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('removing:${item.key}'),
      tween: Tween(begin: 1, end: 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      onEnd: () {
        if (mounted && _isRemoving && _removedItem?.key == item.key) {
          setState(() => _isRemoving = false);
        }
      },
      builder: (context, value, child) => ExcludeSemantics(
        child: IgnorePointer(
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: value,
              child: Opacity(opacity: value, child: child),
            ),
          ),
        ),
      ),
      child: _itemRow(context, l10n, item, enabled: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final summary = _selectionCaloriesSummary(l10n, store);
    final totals = '${l10n.serving_amount(store.servingCount)} · $summary';
    final items = store.items.toList(growable: false);
    final removedItem = _removedItem;
    final showingRemovedRow = _isRemoving && removedItem != null;
    final extraItemCount = removedItem == null ? 0 : 1;

    return FractionallySizedBox(
      heightFactor: 0.65,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 2,
                          children: [
                            Text(
                              l10n.food_selection_selected_count(
                                store.itemCount,
                              ),
                              style: theme.textTheme.titleLarge,
                            ),
                            AnimatedSwitcher(
                              duration: selectionAnimationDuration(context),
                              child: Text(
                                totals,
                                key: ValueKey(totals),
                                textAlign: TextAlign.end,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length + extraItemCount,
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    return _itemRow(context, l10n, items[index]);
                  }
                  if (showingRemovedRow) {
                    return _removingRow(context, l10n, removedItem);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(l10n.food_selection_item_removed)),
                        TextButton(
                          onPressed: _undoRemoval,
                          child: Text(l10n.food_selection_undo),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: store.isEmpty || _isConfirming
                        ? null
                        : () {
                            setState(() => _isConfirming = true);
                            Navigator.pop(context, true);
                          },
                    child: Text(
                      l10n.food_selection_confirm(
                        store.itemCount,
                        widget.mealLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _selectionCaloriesSummary(
  AppLocalizations l10n,
  FoodSelectionStore store,
) {
  final known = store.knownCalories().round();
  return store.unknownCaloriesCount == 0
      ? l10n.kcal_value(known.toString())
      : known == 0
      ? l10n.food_selection_unknown_calories(store.unknownCaloriesCount)
      : l10n.food_selection_known_calories(
          known.toString(),
          store.unknownCaloriesCount,
        );
}
