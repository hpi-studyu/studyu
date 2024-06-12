import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/study_tile.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> navigateToStudyOverview(
  BuildContext context,
  Study study, {
  String? inviteCode,
  List<String>? preselectedIds,
}) async {
  context.read<AppState>().preselectedInterventionIds = preselectedIds;
  context.read<AppState>().inviteCode = inviteCode;
  context.read<AppState>().selectedStudy = study;
  Navigator.pushNamed(context, Routes.studyOverview);
}

Future<void> showAppOutdatedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title:
          Text(AppLocalizations.of(context)!.study_selection_unsupported_title),
      content: Text(AppLocalizations.of(context)!.study_selection_unsupported),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

class StudySelectionScreen extends StatefulWidget {
  const StudySelectionScreen({super.key});

  @override
  State<StudySelectionScreen> createState() => _StudySelectionScreenState();
}

class _StudySelectionScreenState extends State<StudySelectionScreen> {
  bool _hiddenStudies = false;
  final publishedStudies = Study.publishedPublicStudies();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.study_selection_description,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!
                                .study_selection_single,
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: ' ',
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context)!
                                .study_selection_single_why,
                            style: theme.textTheme.titleSmall!
                                .copyWith(color: theme.primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .study_selection_single_reason,),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_hiddenStudies) Column(
                      children: [
                        MaterialBanner(
                          padding: const EdgeInsets.all(8),
                          leading: Icon(
                            MdiIcons.exclamationThick,
                            color: Colors.orange,
                            size: 32,
                          ),
                          content: Text(
                            AppLocalizations.of(context)!
                                .study_selection_hidden_studies,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          actions: const [SizedBox.shrink()],
                          backgroundColor: Colors.yellow[100],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ) else const SizedBox.shrink(),
              Expanded(
                child: RetryFutureBuilder<ExtractionResult<Study>>(
                  tryFunction: () async => publishedStudies,
                  successBuilder: (BuildContext context,
                      ExtractionResult<Study>? extractionResult,) {
                    final studies = extractionResult!.extracted;
                    if (extractionResult is ExtractionFailedException<Study>) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_hiddenStudies) return;
                        debugPrint(
                            '${extractionResult.notExtracted.length} studies could not be extracted.',);
                        setState(() {
                          _hiddenStudies = true;
                        });
                      });
                    }
                    return ListView.builder(
                      itemCount: studies.length,
                      itemBuilder: (context, index) {
                        final study = studies[index];
                        return Hero(
                          tag: 'study_tile_${studies[index].id}',
                          child: Material(
                            child: StudyTile.fromStudy(
                              study: study,
                              onTap: () async {
                                await navigateToStudyOverview(context, study);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: OutlinedButton.icon(
                  icon: Icon(MdiIcons.key),
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (_) => const InviteCodeDialog(),);
                  },
                  label: Text(AppLocalizations.of(context)!.invite_code_button),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomOnboardingNavigation(hideNext: true),
    );
  }
}

class InviteCodeDialog extends StatefulWidget {
  const InviteCodeDialog({super.key});

  @override
  State<InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends State<InviteCodeDialog> {
  final _controller = TextEditingController();
  String? _errorMessage;

  _InviteCodeDialogState();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.private_study_invite_code),
        content: TextFormField(
          controller: _controller,
          validator: (_) => _errorMessage,
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.invite_code,),
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: Text(AppLocalizations.of(context)!.next),
            onPressed: () async {
              Map<String, dynamic>? result;
              try {
                result = await Supabase.instance.client
                    .rpc(
                      'get_study_from_invite',
                      params: {'invite_code': _controller.text},
                    )
                    .select()
                    .single();
              } on PostgrestException catch (error) {
                print(error.message);
                setState(() {
                  _errorMessage = error.message;
                });
              }

              if (result == null) {
                setState(() {
                  _errorMessage =
                      AppLocalizations.of(context)!.invalid_invite_code;
                });
              } else {
                setState(() {
                  _errorMessage = null;
                });

                Map<String, dynamic>? studyResult;
                try {
                  studyResult = await Supabase.instance.client.rpc(
                    'get_study_record_from_invite',
                    params: {'invite_code': _controller.text},
                  ).single();
                } on PostgrestException catch (error) {
                  print(error.message);
                  setState(() {
                    _errorMessage = error.message;
                  });
                }

                if (studyResult != null) {
                  Study study;
                  try {
                    study = Study.fromJson(studyResult);
                    // ignore: avoid_catching_errors
                  } on ArgumentError catch (error) {
                    // We are catching ArgumentError because unknown enums throw an ArgumentError
                    // and UnknownJsonTypeError is a subclass of ArgumentError
                    debugPrint('Study selection from invite failed: $error');
                    if (!context.mounted) return;
                    await showAppOutdatedDialog(context);
                    return;
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  if (result.containsKey('preselected_intervention_ids') &&
                      result['preselected_intervention_ids'] != null) {
                    final preselectedIds = List<String>.from(
                      result['preselected_intervention_ids'] as List,
                    );
                    await navigateToStudyOverview(
                      context,
                      study,
                      inviteCode: _controller.text,
                      preselectedIds: preselectedIds,
                    );
                  } else {
                    await navigateToStudyOverview(
                      context,
                      study,
                      inviteCode: _controller.text,
                    );
                  }
                }
              }
            },
          ),
        ],
      );
}
