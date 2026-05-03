import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/spacing.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/study_tile.dart';
import 'package:studyu_app/widgets/welcome_button.dart';
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
      title: Text(
        AppLocalizations.of(context)!.study_selection_unsupported_title,
      ),
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

Future<void> showStudyClosedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.study_selection_closed_title),
      content: Text(AppLocalizations.of(context)!.study_selection_closed),
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
                padding: const EdgeInsets.fromLTRB(StudyUSpacing.space6, StudyUSpacing.space6, StudyUSpacing.space6, StudyUSpacing.space2),
                child: Text(
                  AppLocalizations.of(context)!.study_selection_description,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(StudyUSpacing.space6, 0, StudyUSpacing.space6, StudyUSpacing.space5),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        )!.study_selection_single,
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        )!.study_selection_single_why,
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: theme.primaryColor,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.primaryColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.study_selection_single_reason,
                              ),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_hiddenStudies)
                MaterialBanner(
                  padding: const EdgeInsets.all(StudyUSpacing.space2),
                  leading: Icon(
                    Icons.warning,
                    color: theme.colorScheme.secondary,
                    size: 32,
                  ),
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.study_selection_hidden_studies,
                    style: theme.textTheme.titleSmall,
                  ),
                  actions: const [SizedBox.shrink()],
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
              Expanded(
                child: RetryFutureBuilder<ExtractionResult<Study>>(
                  tryFunction: () => publishedStudies,
                  successBuilder:
                      (
                        BuildContext context,
                        ExtractionResult<Study>? extractionResult,
                      ) {
                        final studies = extractionResult!.extracted;
                        if (extractionResult
                            is ExtractionFailedException<Study>) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_hiddenStudies) return;
                            debugPrint(
                              '${extractionResult.notExtracted.length} studies could not be extracted.',
                            );
                            setState(() {
                              _hiddenStudies = true;
                            });
                          });
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: StudyUSpacing.space2),
                          itemCount: studies.length + 1,
                          itemBuilder: (context, index) {
                            if (index == studies.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: StudyUSpacing.space4,
                                  vertical: StudyUSpacing.space3,
                                ),
                                child: Center(
                                  child: WelcomeButton(
                                    icon: Icons.vpn_key,
                                    label: AppLocalizations.of(
                                      context,
                                    )!.invite_code_button,
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (_) =>
                                            const InviteCodeDialog(),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                            final study = studies[index];
                            return Hero(
                              tag: 'study_tile_${studies[index].id}',
                              child: Material(
                                color: Colors.transparent,
                                child: StudyTile.fromStudy(
                                  study: study,
                                  onTap: () async {
                                    await navigateToStudyOverview(
                                      context,
                                      study,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
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
        labelText: AppLocalizations.of(context)!.invite_code,
      ),
    ),
    actions: [
      OutlinedButton.icon(
        icon: const Icon(Icons.arrow_forward),
        label: Text(AppLocalizations.of(context)!.next),
        onPressed: () async {
          Map<String, dynamic>? studyResult;
          try {
            studyResult = await Supabase.instance.client
                .rpc(
                  'get_study_record_from_invite',
                  params: {'invite_code': _controller.text},
                )
                .single();
          } on PostgrestException catch (error) {
            print(error.message);
            setState(() {
              _errorMessage = error.message;
            });
          }
          if (studyResult == null || studyResult['id'] == null) {
            setState(() {
              _errorMessage = AppLocalizations.of(context)!.invalid_invite_code;
            });
          } else {
            setState(() {
              _errorMessage = null;
            });

            Study study;
            try {
              study = Study.fromJson(studyResult);
              // ignore: avoid_catching_errors
            } on ArgumentError catch (error) {
              debugPrint('Study selection from invite failed: $error');
              if (!context.mounted) return;
              Navigator.pop(context);
              await showAppOutdatedDialog(context);
              return;
            }

            if (study.isClosed) {
              if (!context.mounted) return;
              Navigator.pop(context);
              await showStudyClosedDialog(context);
              return;
            }

            if (!context.mounted) return;
            Navigator.pop(context);

            // Get preselected_intervention_ids from study_invite table
            final inviteResult = await Supabase.instance.client
                .from('study_invite')
                .select('preselected_intervention_ids')
                .eq('code', _controller.text)
                .maybeSingle();
            if (!context.mounted) return;
            if (inviteResult != null &&
                inviteResult.containsKey('preselected_intervention_ids') &&
                inviteResult['preselected_intervention_ids'] != null) {
              final preselectedIds = List<String>.from(
                inviteResult['preselected_intervention_ids'] as List,
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
        },
      ),
    ],
  );
}
