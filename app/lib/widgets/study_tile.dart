import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';

class StudyTile extends StatelessWidget {
  final String? title;
  final String? description;
  final String iconName;
  final Future<void> Function()? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const StudyTile({
    required this.title,
    required this.description,
    required this.iconName,
    this.onTap,
    this.contentPadding,
    super.key,
  });

  StudyTile.fromStudy({
    required Study study,
    this.onTap,
    this.contentPadding,
    super.key,
  }) : title = study.title,
       description = study.description,
       iconName = study.iconName;

  StudyTile.fromUserStudy({
    required StudySubject subject,
    this.onTap,
    this.contentPadding,
    super.key,
  }) : title = subject.study.title,
       description = subject.study.description,
       iconName = subject.study.iconName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: contentPadding ?? const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudyIconCircle(iconName: iconName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyIconCircle extends StatelessWidget {
  final String iconName;

  const _StudyIconCircle({required this.iconName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        MdiIcons.fromString(iconName),
        color: theme.colorScheme.onPrimary,
        size: 20,
      ),
    );
  }
}
