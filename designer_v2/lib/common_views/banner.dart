import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface for widgets that render an optional banner
abstract class IWithBanner {
  Widget? banner(BuildContext context, WidgetRef ref);
}

enum BannerStyle { warning, info, error }

class BannerBox extends StatelessWidget {
  const BannerBox({
    required this.body,
    required this.style,
    this.padding = const EdgeInsets.symmetric(vertical: 18.0, horizontal: 48.0),
    this.prefixIcon,
    this.noPrefix = false,
    Key? key}) : super(key: key);

  final Widget? prefixIcon;
  final Widget body;
  final BannerStyle style;
  final EdgeInsets? padding;
  final bool noPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerColor = _getBackgroundColor(theme);
    final icon = prefixIcon ?? Icon(
      _getDefaultIcon(),
      size: (theme.iconTheme.size ?? 14.0) * 1.25,
      color: theme.iconTheme.color,
    );

    return Container(
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.6),
        border: Border.all(color: bannerColor),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            (noPrefix) ? const SizedBox.shrink() : icon,
            (noPrefix) ? const SizedBox.shrink() : const SizedBox(width: 24.0),
            body,
          ],
        )
      )
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    // TODO custom ThemeData extension with banner theme
    switch (style) {
      case BannerStyle.info:
        return theme.colorScheme.secondaryContainer;
      case BannerStyle.warning:
        return const Color(0xfff6e29c);
      case BannerStyle.error:
        return theme.colorScheme.errorContainer;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getDefaultIcon() {
    // TODO custom ThemeData extension with banner theme
    switch (style) {
      case BannerStyle.info:
        return Icons.info_rounded;
      case BannerStyle.warning:
        return Icons.warning_rounded;
      case BannerStyle.error:
        return Icons.error_rounded;
    }
  }
}
