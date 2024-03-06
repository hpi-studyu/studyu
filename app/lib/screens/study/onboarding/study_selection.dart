import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/study_tile.dart';

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

class StudySelectionScreenArgs {
  final Template? template;
  final List<TemplateSubStudy> subStudies;

  StudySelectionScreenArgs({this.template, this.subStudies = const []});
}

class StudySelectionScreen extends StatelessWidget {
  const StudySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Study> subStudies = [];
    Template? template;
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is StudySelectionScreenArgs) {
      subStudies = args.subStudies;
      template = args.template;
    }
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
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
                      subStudies.isEmpty ? loc.study_selection_description : loc.sub_study_selection_description,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: loc.study_selection_single,
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: ' ',
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: loc.study_selection_single_why,
                            style: theme.textTheme.titleSmall!.copyWith(color: theme.primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text(loc.study_selection_single_reason),
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              template != null
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.selected_template_trial, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                              text: "${loc.title}: ",
                              style: theme.textTheme.titleSmall,
                            ),
                            TextSpan(
                              text: template.title,
                            ),
                          ])),
                          const SizedBox(height: 2),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                              text: "${loc.description}: ",
                              style: theme.textTheme.titleSmall,
                            ),
                            TextSpan(
                              text: template.description,
                            ),
                          ])),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              Expanded(
                child: RetryFutureBuilder<List<Study>>(
                  tryFunction: () async =>
                      subStudies.isEmpty ? Study.publishedPublicStudies() : Future.value(subStudies),
                  successBuilder: (BuildContext context, List<Study>? studies) {
                    // Filter out sub-studies and templates without sub studies
                    final filteredStudies = subStudies.isEmpty
                        ? studies!
                            .where((study) =>
                                !study.isSubStudy &&
                                (!study.isTemplate || studies.any((s) => s.parentTemplateId == study.id)))
                            .toList()
                        : studies!;

                    return ListView.builder(
                      itemCount: filteredStudies.length,
                      itemBuilder: (context, index) {
                        final study = filteredStudies[index];
                        return Hero(
                          tag: 'study_tile_${study.id}',
                          child: Material(
                            child: StudyTile.fromStudy(
                              study: study,
                              onTap: () => study is Template
                                  ? Navigator.pushNamed(context, Routes.studySelection,
                                      arguments: StudySelectionScreenArgs(
                                          template: study,
                                          subStudies: studies
                                              .where((s) => s is TemplateSubStudy && s.parentTemplateId == study.id)
                                              .map((s) => s as TemplateSubStudy)
                                              .toList()))
                                  : navigateToStudyOverview(context, study),
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
                    await showDialog(context: context, builder: (_) => const InviteCodeDialog());
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
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.invite_code),
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
                  _errorMessage = AppLocalizations.of(context)!.invalid_invite_code;
                });
              } else {
                setState(() {
                  _errorMessage = null;
                });

                Map<String, dynamic>? studyResult;
                try {
                  studyResult = await (Supabase.instance.client.rpc(
                    'get_study_record_from_invite',
                    params: {'invite_code': _controller.text},
                  ).single());
                } on PostgrestException catch (error) {
                  print(error.message);
                  setState(() {
                    _errorMessage = error.message;
                  });
                }

                if (studyResult != null) {
                  final study = Study.fromJson(studyResult);

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
          )
        ],
      );
}
