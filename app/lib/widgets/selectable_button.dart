import 'package:flutter/material.dart';
import 'package:studyu_app/spacing.dart';

class SelectableButton extends StatelessWidget {
  final Widget child;
  final bool selected;
  final Function()? onTap;

  const SelectableButton({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
  });

  Color _getFillColor(ThemeData theme) =>
      selected ? theme.colorScheme.primary : theme.colorScheme.surface;

  Color _getTextColor(ThemeData theme) =>
      selected ? theme.colorScheme.onPrimary : theme.colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _getTextColor(theme),
          backgroundColor: _getFillColor(theme),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(
            vertical: StudyUSpacing.space4,
            horizontal: StudyUSpacing.space4,
          ),
        ),
        onPressed: onTap,
        child: child,
      ),
    );
  }
}
