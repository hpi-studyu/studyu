import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart' as studyu;

Duration selectionAnimationDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 180);

Offset? globalCenter(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox ||
      !renderObject.attached ||
      !renderObject.hasSize) {
    return null;
  }
  return renderObject.localToGlobal(renderObject.size.center(Offset.zero));
}

class SelectionFeedbackCard extends StatelessWidget {
  final bool selected;
  final Widget child;

  const SelectionFeedbackCard({
    required this.selected,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.55)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    return Semantics(
      selected: selected,
      child: TweenAnimationBuilder<Color?>(
        duration: selectionAnimationDuration(context),
        tween: ColorTween(end: color),
        builder: (context, color, child) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: color,
          child: child,
        ),
        child: child,
      ),
    );
  }
}

class SelectionQuantityText extends StatefulWidget {
  final int quantity;
  final TextStyle? style;

  const SelectionQuantityText({required this.quantity, this.style, super.key});

  @override
  State<SelectionQuantityText> createState() => _SelectionQuantityTextState();
}

class _SelectionQuantityTextState extends State<SelectionQuantityText> {
  int _direction = 1;

  @override
  void didUpdateWidget(SelectionQuantityText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _direction = widget.quantity > oldWidget.quantity ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: selectionAnimationDuration(context),
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey(widget.quantity);
          final offset = 0.3 * _direction * (incoming ? 1 : -1);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: Offset(0, offset), end: Offset.zero)
                  .animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: Text(
          '${widget.quantity}',
          key: ValueKey(widget.quantity),
          style: widget.style,
        ),
      ),
    );
  }
}

class SelectionQuantityButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final VisualDensity? visualDensity;

  const SelectionQuantityButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.visualDensity,
    super.key,
  });

  @override
  State<SelectionQuantityButton> createState() =>
      _SelectionQuantityButtonState();
}

class _SelectionQuantityButtonState extends State<SelectionQuantityButton> {
  bool _pressed = false;
  bool _pointerInteraction = false;
  int _releaseGeneration = 0;

  bool get _motionDisabled => MediaQuery.disableAnimationsOf(context);

  @override
  void didUpdateWidget(SelectionQuantityButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null) {
      _releaseGeneration++;
      _pressed = false;
      _pointerInteraction = false;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onPressed == null || _motionDisabled) return;
    _releaseGeneration++;
    _pointerInteraction = true;
    setState(() => _pressed = true);
  }

  void _releasePointer(PointerEvent event) {
    if (!_pointerInteraction) return;
    _scheduleRelease();
  }

  void _scheduleRelease() {
    final generation = ++_releaseGeneration;
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || generation != _releaseGeneration) return;
      setState(() {
        _pressed = false;
        _pointerInteraction = false;
      });
    });
  }

  void _onPressed() {
    if (!_pointerInteraction && !_motionDisabled) {
      setState(() => _pressed = true);
      _scheduleRelease();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final motionDisabled = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _releasePointer,
      onPointerCancel: _releasePointer,
      child: AnimatedScale(
        scale: motionDisabled || !_pressed ? 1 : 0.96,
        duration: motionDisabled
            ? Duration.zero
            : const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: SizedBox.square(
          dimension: 48,
          child: IconButton(
            tooltip: widget.tooltip,
            onPressed: widget.onPressed == null ? null : _onPressed,
            icon: Icon(widget.icon),
            visualDensity: widget.visualDensity,
          ),
        ),
      ),
    );
  }
}

class SelectionQuantityControl extends StatelessWidget {
  final String name;
  final int quantity;
  final ValueChanged<Offset?> onIncrement;
  final VoidCallback onDecrement;
  final GlobalKey? quantityAnchorKey;
  final TextStyle? quantityStyle;

  const SelectionQuantityControl({
    required this.name,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.quantityAnchorKey,
    this.quantityStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      selected: true,
      label: l10n.food_selection_selected(name, quantity),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectionQuantityButton(
            tooltip: l10n.food_selection_decrement(name),
            onPressed: onDecrement,
            icon: Icons.remove,
            visualDensity: VisualDensity.compact,
          ),
          SelectionQuantityText(
            key: quantityAnchorKey,
            quantity: quantity,
            style: quantityStyle,
          ),
          Builder(
            builder: (buttonContext) => SelectionQuantityButton(
              tooltip: l10n.food_selection_increment(name),
              onPressed: () => onIncrement(globalCenter(buttonContext)),
              icon: Icons.add,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

String formatFoodNumber(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toStringAsFixed(1);

num foodServingAmount(double value) =>
    value == value.roundToDouble() ? value.round() : value;

String foodTotalMetadata(
  AppLocalizations l10n,
  studyu.FoodEntry food,
  int quantity, {
  bool gramsKnown = true,
  bool caloriesKnown = true,
}) {
  final grams = gramsKnown
      ? '${formatFoodNumber(food.servingSizeGrams * food.amount * quantity)} g'
      : '— g';
  final calories = caloriesKnown
      ? l10n.kcal_value(
          (food.nutrition.energyKcal *
                  (food.entryType == studyu.FoodEntryType.meal
                      ? food.amount
                      : 1) *
                  quantity)
              .round()
              .toString(),
        )
      : '— kcal';
  return '$grams · $calories';
}

String selectedFoodServingMetadata(
  AppLocalizations l10n,
  studyu.FoodEntry food,
  int quantity,
) {
  final unit = food.unit.trim();
  final baseServing = unit.isEmpty || unit.toLowerCase() == 'serving'
      ? l10n.serving_amount(foodServingAmount(food.amount))
      : '${formatFoodNumber(food.amount)} $unit';
  final serving = quantity == 1
      ? baseServing
      : unit.isEmpty || unit.toLowerCase() == 'serving'
      ? l10n.serving_amount(foodServingAmount(food.amount * quantity))
      : '$quantity × $baseServing';
  return '$serving · ${l10n.kcal_value((food.nutrition.energyKcal * quantity).round().toString())}';
}

String? foodImageUrl(studyu.FoodEntry food) {
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

class FoodDetailsAffordance extends StatelessWidget {
  const FoodDetailsAffordance({super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: AppLocalizations.of(context)!.details,
    child: const SizedBox(
      width: 40,
      height: 48,
      child: Icon(Icons.chevron_right, size: 22),
    ),
  );
}

Widget fallbackFoodIcon(ThemeData theme, IconData icon, {double size = 22}) =>
    Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: size, color: theme.colorScheme.onSurfaceVariant),
    );
