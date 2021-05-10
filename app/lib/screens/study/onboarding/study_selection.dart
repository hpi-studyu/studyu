import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';
import 'package:studyou_core/env.dart' as env;
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/study_tile.dart';

Future<void> navigateToStudyOverview(BuildContext context, Study study) async {
  context.read<AppState>().selectedStudy = study;
  Navigator.pushNamed(context, Routes.studyOverview);
}

class StudySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).study_selection_description,
                      style: theme.textTheme.headline5,
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: AppLocalizations.of(context).study_selection_single,
                          style: theme.textTheme.subtitle2,
                        ),
                        TextSpan(
                          text: ' ',
                          style: theme.textTheme.subtitle2,
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context).study_selection_single_why,
                          style: theme.textTheme.subtitle2.copyWith(color: theme.primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: Text(AppLocalizations.of(context).study_selection_single_reason),
                                  ),
                                ),
                        )
                      ]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RetryFutureBuilder<List<Study>>(
                  tryFunction: () async => Study.publishedPublicStudies(),
                  successBuilder: (BuildContext context, List<Study> studies) {
                    return ListView.builder(
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
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: OutlinedButton.icon(
                    icon: Icon(MdiIcons.key),
                    onPressed: () async {
                      await showDialog(context: context, builder: (_) => InviteCodeDialog());
                    },
                    label: Text('I have an invite code')),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(hideNext: true),
    );
  }
}

class InviteCodeDialog extends StatefulWidget {
  @override
  _InviteCodeDialogState createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends State<InviteCodeDialog> {
  final _controller = TextEditingController();
  String errorMessage = 'hello';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: AlertDialog(
          title: Text('Private study invite code'),
          content: TextFormField(
            controller: _controller,
            validator: (_) => errorMessage,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(labelText: 'Invite code'),
          ),
          actions: [
            OutlinedButton.icon(
              icon: Icon(Icons.arrow_forward),
              label: Text('Next'),
              onPressed: () async {
                final res =
                    await env.client.rpc('get_study_from_invite', params: {'invite_code': _controller.text}).execute();
                print(res.data);
                if (res.error != null) {
                  print(res.error.message);
                  setState(() {
                    errorMessage = res.error.message;
                  });
                } else if (res.data == null) {
                  setState(() {
                    errorMessage = 'Not a valid invite code';
                  });
                } else {
                  setState(() {
                    errorMessage = null;
                  });
                  final study = await SupabaseQuery.getById<Study>(res.data as String);
                  Navigator.pop(context);
                  context.read<AppState>().inviteCode = _controller.text;
                  navigateToStudyOverview(context, study);
                }
              },
            )
          ],
        ),
      );
}
