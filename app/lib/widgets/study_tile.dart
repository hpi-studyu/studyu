import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

class StudyTile extends StatelessWidget {
  final StudyBase study;
  final Future<void> Function(BuildContext context, StudyBase study) onTap;

  const StudyTile({@required this.study, this.onTap, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
        contentPadding: EdgeInsets.all(16),
        onTap: onTap != null ? () => onTap(context, study) : null,
        title: Center(child: Text(study.title, style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
        subtitle: Center(child: Text(study.description)),
        leading: Icon(MdiIcons.fromString(study.iconName ?? 'accountHeart'), color: theme.primaryColor));
  }
}
