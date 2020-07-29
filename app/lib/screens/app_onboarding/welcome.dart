import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../models/app_state.dart';
import '../../routes.dart';
import '../../util/localization.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('assets/images/icon_wide.png'), height: 200),
              SizedBox(height: 20),
              OutlineButton.icon(
                icon: Icon(Icons.info),
                onPressed: () => Navigator.pushNamed(context, Routes.about),
                label: Text(Nof1Localizations.of(context).translate('what_is_studyu'),
                    style: theme.textTheme.button.copyWith(color: theme.primaryColor, fontSize: 20)),
              ),
              SizedBox(height: 20),
              OutlineButton.icon(
                icon: Icon(MdiIcons.rocket),
                onPressed: () => Navigator.pushNamed(context, Routes.terms),
                label: Text(Nof1Localizations.of(context).translate('get_started'),
                    style: theme.textTheme.button.copyWith(color: Theme.of(context).primaryColor, fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
      // Only display button in debug
      persistentFooterButtons: kReleaseMode
          ? null
          : [
              FlatButton(
                onPressed: () {
                  context.read<AppModel>()
                    ..selectedStudy = Study()
                    ..selectedInterventions = [Intervention('a', 'A'), Intervention('a', 'B')];
                  Navigator.pushNamed(context, Routes.dashboard);
                },
                child: Text('Skip to Dashboard'),
              ),
            ],
    );
  }
}
