import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';

class KickoffScreen extends StatefulWidget {
  @override
  _KickoffScreen createState() => _KickoffScreen();
}

class _KickoffScreen extends State<KickoffScreen> {
  ParseUserStudy study;
  bool ready;

  Future<void> _storeUserStudy() async {
    final userId = await UserQueries.getOrCreateUser().then((user) => user.objectId);
    study.userId = userId;

    final selectedStudyObjectId = await StudyQueries.saveUserStudy(study);
    if (selectedStudyObjectId != null) {
      await SharedPreferences.getInstance()
          .then((pref) => pref.setString(UserQueries.selectedStudyObjectIdKey, selectedStudyObjectId));
    }
    setState(() => ready = true);
  }

  @override
  void initState() {
    super.initState();
    ready = false;
    study = context.read<AppState>().activeStudy;
    _storeUserStudy();
  }

  Widget _constructStatusIcon(BuildContext context) => !ready
      ? SizedBox(
          height: 64,
          width: 64,
          child: CircularProgressIndicator(),
        )
      : Icon(
          MdiIcons.checkboxMarkedCircle,
          color: Colors.green,
          size: 64,
        );

  String _getStatusText(BuildContext context) => !ready
      ? Nof1Localizations.of(context).translate('setting_up_study')
      : Nof1Localizations.of(context).translate('good_to_go');

  Widget _constructStatusButton(BuildContext context) {
    final theme = Theme.of(context);
    return OutlineButton.icon(
      icon: Icon(MdiIcons.rocket),
      onPressed: ready ? () => Navigator.pushNamed(context, Routes.dashboard) : null,
      label: Text(
        Nof1Localizations.of(context).translate('get_started'),
        style: theme.textTheme.button.copyWith(
          color: ready ? theme.primaryColor : theme.disabledColor,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(study.title),
        leading: Icon(MdiIcons.fromString(study.iconName)),
      ),
      body: Builder(builder: (_context) {
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _constructStatusIcon(context),
                  SizedBox(height: 32),
                  Text(
                    _getStatusText(context),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 32),
                  _constructStatusButton(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
