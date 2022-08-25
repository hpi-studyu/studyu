import 'package:flutter/material.dart';

class EmptyBody extends StatelessWidget {
  const EmptyBody(
      {this.icon,
      this.leading,
      this.leadingSpacing = 24.0,
      required this.title,
      required this.description,
      this.button,
      Key? key})
      : super(key: key);

  final IconData? icon;
  final Widget? leading;
  final double? leadingSpacing;
  final String? title;
  final String? description;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (leading != null) ? leading! : const SizedBox.shrink(),
          (leading != null)
              ? SizedBox(height: leadingSpacing!)
              : const SizedBox.shrink(),
          (icon != null)
              ? Icon(
                  icon,
                  size: 96.0,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                )
              : const SizedBox.shrink(),
          (title != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SelectableText(
                    title!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headline5!.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          (description != null)
              ? SelectableText(
                  description!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2!,
                )
              : const SizedBox.shrink(),
          (button != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: button,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
