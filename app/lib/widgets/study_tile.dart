import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

class StudyTile extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;

  final Future<void> Function() onTap;

  const StudyTile(
      {@required this.title, @required this.description, @required this.iconName, @required this.onTap, Key key})
      : super(key: key);

  StudyTile.fromStudy({@required StudyBase study, this.onTap, Key key})
      : title = study.title,
        description = study.description,
        iconName = study.iconName,
        super(key: key);

  StudyTile.fromUserStudy({@required UserStudyBase study, this.onTap, Key key})
      : title = study.title,
        description = study.description,
        iconName = study.iconName,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            contentPadding: EdgeInsets.all(16),
            onTap: onTap,
            title: Center(child: Text(title, style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
            subtitle: Center(child: Text(description)),
            leading: Icon(MdiIcons.fromString(iconName ?? 'accountHeart'), color: theme.primaryColor)),
      ],
    );
  }
}
