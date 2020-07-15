import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyou_core/models/models.dart';

import '../database/daos/study_dao.dart';
import '../environments/environment.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    initData();
  }

  Future<void> initParse(Environment env) async {
    if (!Parse().hasParseBeenInitialized()) {
      await Parse().initialize(env.keyParseApplicationId, env.keyParseServerUrl,
          masterKey: env.keyParseMasterKey, debug: env.debug, coreStore: await CoreStoreSharedPrefsImp.getInstance());
      final response = await Parse().healthCheck();
      if (response.success) {
        print('Connection to Parse server successful');
      } else {
        print('Failed establishing connection to Parse server');
      }
    }
  }

  Future<void> initStudy() async {
    final model = context.read<AppModel>()..activeStudy = StudyInstance();
    final prefs = await SharedPreferences.getInstance();
    final selectedStudyObjectId = prefs.getString(UserUtils.selectedStudyObjectIdKey);
    print('Selected study: $selectedStudyObjectId');
    if (selectedStudyObjectId == null) {
      Navigator.pushReplacementNamed(context, Routes.welcome);
      return;
    }
    final studyInstance = await StudyDao.getUserStudy(selectedStudyObjectId);
    if (studyInstance != null) {
      model.activeStudy = studyInstance;
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, Routes.welcome);
    }
  }

  Future<void> initData() async {
    await initParse(Environment.of(context));
    initStudy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${Nof1Localizations.of(context).translate('loading')}...',
              style: Theme.of(context).textTheme.headline4,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
