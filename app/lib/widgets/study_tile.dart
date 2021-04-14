import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/core.dart';

class StudyTile extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;

  final Future<void> Function() onTap;

  final EdgeInsetsGeometry contentPadding;

  const StudyTile(
      {@required this.title,
      @required this.description,
      @required this.iconName,
      this.onTap,
      this.contentPadding = const EdgeInsets.all(16),
      Key key})
      : super(key: key);

  StudyTile.fromStudy({@required Study study, this.onTap, this.contentPadding = const EdgeInsets.all(16), Key key})
      : title = study.title,
        description = study.description,
        iconName = study.iconName,
        super(key: key);

  StudyTile.fromUserStudy(
      {@required UserStudy study, this.onTap, this.contentPadding = const EdgeInsets.all(16), Key key})
      : title = study.study.title,
        description = study.study.description,
        iconName = study.study.iconName,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            contentPadding: contentPadding,
            onTap: onTap,
            title: Center(child: Text(title, style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
            subtitle: Center(child: Text(description)),
            leading: Icon(MdiIcons.fromString(iconName ?? 'accountHeart'), color: theme.primaryColor)),
      ],
    );
  }
}
