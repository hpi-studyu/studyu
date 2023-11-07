import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/theme.dart';

class StandardDialog extends StatelessWidget {
  const StandardDialog({
    this.title,
    this.titleText,
    required this.body,
    this.width,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(42.0, 36.0, 42.0, 36.0),
    this.minWidth = 400,
    this.minHeight = 300,
    this.maxWidth,
    this.maxHeight,
    this.actionButtons = const [],
    this.backgroundColor,
    this.borderRadius = 20.0,
    super.key,
  });

  final Widget? title;
  final String? titleText;
  final Widget body;
  final List<Widget> actionButtons;

  final Color? backgroundColor;
  final double? borderRadius;

  final double? width;
  final double? height;
  final double minWidth;
  final double minHeight;
  final double? maxWidth;
  final double? maxHeight;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogWidth = width ?? MediaQuery.of(context).size.width * 0.4;
    //final dialogHeight = height ?? MediaQuery.of(context).size.height * 0.4;

    final Widget? titleWidget = title ??
        ((titleText != null)
            ? SelectableText(
                titleText!,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
            : null);

    return Dialog(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              spreadRadius: 0,
              blurRadius: 3,
              offset: const Offset(1, 1),
            )
          ],
        ),
        child: Container(
          constraints: BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth ?? double.infinity,
            minHeight: minHeight,
            maxHeight: maxHeight ?? double.infinity,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? ThemeConfig.bodyBackgroundColor(theme),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
          ),
          child: SizedBox(
            width: width ?? dialogWidth,
            height: height,
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  padding.top,
                  padding.right,
                  padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (titleWidget != null) ? titleWidget : const SizedBox.shrink(),
                    (titleWidget != null) ? SizedBox(height: padding.top * 2 / 3) : const SizedBox.shrink(),
                    Expanded(
                      child: SingleChildScrollView(child: body),
                    ),
                    SizedBox(height: padding.bottom * 3 / 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: withSpacing(actionButtons, spacing: 8.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
