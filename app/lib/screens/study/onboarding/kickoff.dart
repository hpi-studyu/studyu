import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';
import 'package:studyu/util/user.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';

class KickoffScreen extends StatefulWidget {
  @override
  _KickoffScreen createState() => _KickoffScreen();
}

class _KickoffScreen extends State<KickoffScreen> {
  UserStudy study;
  bool ready = false;

  Future<void> _storeUserStudy(BuildContext context) async {
    study.userId = await UserQueries.loadUserId();

    try {
      study = await study.save();
      context.read<AppState>().activeStudy = study;
      await UserQueries.saveActiveUserStudyId(study.id);
    } finally {
      setState(() => ready = true);
      Navigator.pushNamed(context, Routes.dashboard);
    }
  }

  @override
  void initState() {
    super.initState();
    study = context.read<AppState>().activeStudy;
    _storeUserStudy(context);
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

  String _getStatusText(BuildContext context) =>
      !ready ? AppLocalizations.of(context).setting_up_study : AppLocalizations.of(context).good_to_go;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(study.study.title),
        leading: Icon(MdiIcons.fromString(study.study.iconName)),
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
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
