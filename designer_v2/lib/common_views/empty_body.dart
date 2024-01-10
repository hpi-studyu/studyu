import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';

class EmptyBody extends StatelessWidget {
  const EmptyBody({
    this.icon,
    this.leading,
    this.leadingSpacing = 24.0,
    required this.title,
    required this.description,
    this.button,
    super.key,
  });

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
          (leading != null) ? SizedBox(height: leadingSpacing!) : const SizedBox.shrink(),
          (icon != null)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Icon(
                    icon,
                    size: 96.0,
                    color: theme.colorScheme.secondary,
                  ))
              : const SizedBox.shrink(),
          (title != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: SelectableText(
                    title!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                )
              : const SizedBox.shrink(),
          (description != null)
              ? SelectableText(description!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.faded(0.9),
                  ))
              : const SizedBox.shrink(),
          (button != null)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 16.0),
                  child: button,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
