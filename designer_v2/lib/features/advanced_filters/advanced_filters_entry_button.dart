import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'advanced_filters_panel.dart';
import 'advanced_filters_state.dart';

class AdvancedFiltersEntryButton extends ConsumerWidget {
  const AdvancedFiltersEntryButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Advanced filters',
      child: FilledButton.tonalIcon(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Advanced filters'),
        onPressed: () => openAdvancedFilters(context, ref),
      ),
    );
  }
}

/// Call this from anywhere (keyboard shortcut, etc.)
void openAdvancedFilters(BuildContext context, WidgetRef ref) {
  final isWide = MediaQuery.of(context).size.width >= 900;
  ref.read(advancedFiltersOpenProvider.notifier).state = true;

  if (isWide) {
    showModalSideSheet(context: context, child: const AdvancedFiltersPanel()).whenComplete(() {
      ref.read(advancedFiltersOpenProvider.notifier).state = false;
    });
  } else {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const AdvancedFiltersPanel(),
    ).whenComplete(() {
      ref.read(advancedFiltersOpenProvider.notifier).state = false;
    });
  }
}

/// Minimal side-sheet built on top of a general dialog.
/// Replace with your design system’s sheet/drawer if you have one.
Future<void> showModalSideSheet({
  required BuildContext context,
  required Widget child,
  double width = 420,
}) {
  return showGeneralDialog(
    context: context,
    barrierLabel: 'Advanced Filters',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (ctx, _, __) {
      final h = MediaQuery.of(ctx).size.height;
      final theme = Theme.of(ctx);
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 8,
          color: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), bottomLeft: Radius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: width, height: h),
            child: child,
          ),
        ),
      );
    },
  );
}
