import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../models/app_state.dart';
import '../routes.dart';

class StudyTile extends StatelessWidget {
  final StudyBase study;

  const StudyTile({@required this.study, Key key}) : super(key: key);

  Future<void> navigateToStudyOverview(BuildContext context, StudyBase selectedStudy) async {
    context.read<AppState>().selectedStudy = selectedStudy;
    Navigator.pushNamed(context, Routes.studyOverview);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
        contentPadding: EdgeInsets.all(16),
        onTap: () {
          navigateToStudyOverview(context, study);
        },
        title: Center(child: Text(study.title, style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
        subtitle: Center(child: Text(study.description)),
        leading: Icon(MdiIcons.fromString(study.iconName ?? 'accountHeart'), color: theme.primaryColor));
  }
}
