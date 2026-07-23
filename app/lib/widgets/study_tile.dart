import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class StudyTile extends StatelessWidget {
  final String? title;
  final String? description;
  final String iconName;

  final Future<void> Function()? onTap;

  final EdgeInsetsGeometry contentPadding;

  const StudyTile({
    required this.title,
    required this.description,
    required this.iconName,
    this.onTap,
    this.contentPadding = const EdgeInsets.all(16),
    super.key,
  });

  StudyTile.fromStudy({
    required Study study,
    this.onTap,
    this.contentPadding = const EdgeInsets.all(16),
    super.key,
  }) : title = study.title,
       description = study.description,
       iconName = study.iconName;

  StudyTile.fromUserStudy({
    required StudySubject subject,
    this.onTap,
    this.contentPadding = const EdgeInsets.all(16),
    super.key,
  }) : title = subject.study.title,
       description = subject.study.description,
       iconName = subject.study.iconName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: contentPadding,
      onTap: onTap,
      title: Center(
        child: Text(
          title!,
          style: theme.textTheme.titleLarge!.copyWith(
            color: theme.primaryColor,
          ),
        ),
      ),
      subtitle: Center(child: Text(description ?? '')),
      leading: Icon(
        MdiIconsHelper.fromString(iconName),
        color: theme.primaryColor,
      ),
    );
  }
}
