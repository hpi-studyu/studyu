import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/theme.dart';

/// Interface for widgets that render an optional banner
abstract class IWithBanner {
  Widget? banner(BuildContext context, WidgetRef ref);
}

enum BannerStyle { warning, info, error }

class BannerBox extends StatefulWidget {
  const BannerBox(
      {required this.body,
      required this.style,
      this.padding =
          const EdgeInsets.symmetric(vertical: 18.0, horizontal: 48.0),
      this.prefixIcon,
      this.noPrefix = false,
      this.dismissable = true,
      this.dismissIconSize = 24.0,
      Key? key})
      : super(key: key);

  final Widget? prefixIcon;
  final Widget body;
  final BannerStyle style;
  final EdgeInsets? padding;
  final bool noPrefix;
  final bool dismissable;
  final double dismissIconSize;

  @override
  State<BannerBox> createState() => _BannerBoxState();
}

class _BannerBoxState extends State<BannerBox> {
  bool isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerColor = _getBackgroundColor(theme);
    final icon = widget.prefixIcon ??
        Icon(
          _getDefaultIcon(),
          size: (theme.iconTheme.size ?? 14.0) * 1.25,
          color: theme.iconTheme.color,
        );

    if (isDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.6),
        border: Border.all(color: bannerColor),
      ),
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                  child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  (widget.noPrefix) ? const SizedBox.shrink() : icon,
                  (widget.noPrefix)
                      ? const SizedBox.shrink()
                      : const SizedBox(width: 24.0),
                  Opacity(
                    opacity: 0.85,
                    child: widget.body,
                  ),
                ],
              )),
              SizedBox(
                height: double.infinity,
                child: Opacity(
                  opacity: 0.5,
                  child: IconButton(
                    icon:
                        Icon(Icons.close_rounded, size: widget.dismissIconSize),
                    splashRadius: widget.dismissIconSize,
                    onPressed: () => setState(() {
                      isDismissed = true;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    // TODO custom ThemeData extension with banner theme
    switch (widget.style) {
      case BannerStyle.info:
        return ThemeConfig.containerColor(theme);
      case BannerStyle.warning:
        return const Color(0xFFFFC808);
      case BannerStyle.error:
        return theme.colorScheme.errorContainer;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getDefaultIcon() {
    // TODO custom ThemeData extension with banner theme
    switch (widget.style) {
      case BannerStyle.info:
        return Icons.info_rounded;
      case BannerStyle.warning:
        return Icons.warning_rounded;
      case BannerStyle.error:
        return Icons.error_rounded;
    }
  }
}
