import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget? descriptionWidget;
  final Widget child;
  final Widget? bottomContent;
  final Widget? bottomNavigationBar;
  final List<OnboardingCheckboxItem> bottomCheckboxItems;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    this.descriptionWidget,
    required this.child,
    this.bottomContent,
    this.bottomCheckboxItems = const [],
    this.bottomNavigationBar,
    this.maxWidth = 700,
    this.padding = const EdgeInsets.fromLTRB(24.0, 56.0, 24.0, 16.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.isNotEmpty) ...[
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium!.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (descriptionWidget != null ||
                          description.isNotEmpty) ...[
                        descriptionWidget ?? Text(description),
                        const SizedBox(height: 24),
                      ],
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (bottomContent != null || bottomCheckboxItems.isNotEmpty)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child:
                    bottomContent ??
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final item in bottomCheckboxItems)
                              CheckboxListTile(
                                title: Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: item.value,
                                onChanged: item.onChanged,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
          if (bottomNavigationBar != null) bottomNavigationBar!,
        ],
      ),
    );
  }
}

class OnboardingCheckboxItem {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const OnboardingCheckboxItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });
}
