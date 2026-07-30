import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final String description;
  final Widget? descriptionWidget;
  final Widget child;
  final Widget? bottomContent;
  final Widget? bottomNavigationBar;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    this.titleIcon,
    this.descriptionWidget,
    required this.child,
    this.bottomContent,
    this.bottomNavigationBar,
    this.maxWidth = 700,
    this.padding = const EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 16.0),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (titleIcon != null) ...[
                              Icon(titleIcon, color: theme.primaryColor),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                title,
                                style: theme.textTheme.headlineMedium!.copyWith(
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
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
          if (bottomContent != null)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: bottomContent,
              ),
            ),
          if (bottomNavigationBar != null) bottomNavigationBar!,
        ],
      ),
    );
  }
}
