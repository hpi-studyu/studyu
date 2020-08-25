import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/study_tile.dart';

class StudySelectionScreen extends StatefulWidget {
  @override
  _StudySelectionScreenState createState() => _StudySelectionScreenState();
}

class _StudySelectionScreenState extends State<StudySelectionScreen> {
  Future _studiesFuture;

  @override
  void initState() {
    super.initState();
    _studiesFuture = StudyQueries.getPublishedStudies();
  }

  Future<void> navigateToStudyOverview(BuildContext context, StudyBase study) async {
    context.read<AppState>().selectedStudy = study;
    Navigator.pushNamed(context, Routes.studyOverview);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        Nof1Localizations.of(context).translate('study_selection_description'),
                        style: theme.textTheme.headline5,
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: Nof1Localizations.of(context).translate('study_selection_single'),
                            style: theme.textTheme.subtitle2,
                          ),
                          TextSpan(
                            text: ' ',
                            style: theme.textTheme.subtitle2,
                          ),
                          TextSpan(
                            text: Nof1Localizations.of(context).translate('study_selection_single_why'),
                            style: theme.textTheme.subtitle2.copyWith(color: theme.primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text(
                                          Nof1Localizations.of(context).translate('study_selection_single_reason')),
                                    ),
                                  ),
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
                ParseListFutureBuilder<ParseStudy>(
                  queryFunction: () => _studiesFuture,
                  builder: (_context, studies) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: studies.length,
                        itemBuilder: (context, index) {
                          return Hero(
                              tag: 'study_tile_${studies[index].id}',
                              child: Material(
                                  child: StudyTile.fromStudy(
                                study: studies[index],
                                onTap: () => navigateToStudyOverview(context, studies[index]),
                              )));
                        });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(hideNext: true),
    );
  }
}
