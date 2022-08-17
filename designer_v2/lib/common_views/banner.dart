import 'package:flutter/material.dart';

/// Interface for widgets that render an optional banner
abstract class IBannerProvider {
  Widget? banner(BuildContext context);
}

enum BannerStyle { warning, info, error }

class BannerBox extends StatelessWidget {
  const BannerBox({
    required this.text,
    required this.style,
    this.padding = const EdgeInsets.symmetric(vertical: 24.0, horizontal: 48.0),
    this.prefixIcon,
    Key? key}) : super(key: key);

  final IconData? prefixIcon;
  final String text;
  final BannerStyle style;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final bannerColor = _getBackgroundColor(Theme.of(context));

    return Container(
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.6),
        border: Border.all(color: bannerColor),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SelectableText(text),
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
}
