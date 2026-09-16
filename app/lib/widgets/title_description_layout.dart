import 'package:flutter/material.dart';

class TitleDescriptionLayout extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final String description;
  final Widget? descriptionWidget;
  final Widget child;
  final Widget? bottomContent;
  final Widget? bottomNavigationBar;
  final double maxWidth;
  final double descriptionBottomSpacing;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const TitleDescriptionLayout({
    super.key,
    this.title = '',
    this.description = '',
    this.titleIcon,
    this.descriptionWidget,
    required this.child,
    this.bottomContent,
    this.bottomNavigationBar,
    this.maxWidth = 700,
    this.descriptionBottomSpacing = 24,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 16),
    this.scrollable = true,
  });

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
        if (descriptionWidget != null || description.isNotEmpty) ...[
          descriptionWidget ?? Text(description),
          SizedBox(height: descriptionBottomSpacing),
        ],
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: scrollable
                    ? SingleChildScrollView(
                        padding: padding,
                        child: _buildContent(context),
                      )
                    : SizedBox.expand(
                        child: Padding(
                          padding: padding,
                          child: _buildContent(context),
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
          ?bottomNavigationBar,
        ],
      ),
    );
  }
}
