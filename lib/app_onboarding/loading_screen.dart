import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/daos/study_dao.dart';
import '../database/models/study_instance.dart';
import '../routes.dart';
import '../study_onboarding/app_state.dart';
import '../util/localization.dart';
import '../util/user.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final model = context.read<AppModel>()..activeStudy = StudyInstance();
      final selectedStudyObjectId = prefs.getString(UserUtils.selectedStudyObjectIdKey);
      if (selectedStudyObjectId == null) {
        Navigator.pushReplacementNamed(context, Routes.welcome);
      }
      StudyDao.getUserStudy(selectedStudyObjectId).then((studyInstance) {
        if (studyInstance != null) {
          model.activeStudy = studyInstance;
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else {
          Navigator.pushReplacementNamed(context, Routes.welcome);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('${Nof1Localizations.of(context).translate('loading')}...'),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
