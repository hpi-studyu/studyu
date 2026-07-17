import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/onboarding_page.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
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
  context.push('/${RouteNames.studyOverview}');
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
          key: const ValueKey('dialog_ok'),
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    ),
  );
}

Future<void> showStudyClosedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('study_closed_dialog'),
      title: Text(AppLocalizations.of(context)!.study_selection_closed_title),
      content: Text(AppLocalizations.of(context)!.study_selection_closed),
      actions: [
        TextButton(
          key: const ValueKey('dialog_ok'),
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.ok),
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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.welcome);
            }
          },
        ),
        title: Text(AppLocalizations.of(context)!.browse_public_studies),
      ),
      body: OnboardingPage(
        title: '',
        description: '',
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        descriptionWidget: Column(
          children: [
            StudyOnboardingDescription(
              text: AppLocalizations.of(context)!.study_selection_single,
              actionLabel: AppLocalizations.of(
                context,
              )!.study_selection_single_why,
              onAction: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(
                    AppLocalizations.of(context)!.study_selection_single_reason,
                  ),
                ),
              ),
            ),
            TextButton(
              key: const ValueKey('study_selection_invite_code'),
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const InviteCodeDialog(),
              ),
              child: Text(
                AppLocalizations.of(context)!.study_selection_invite_code_hint,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hiddenStudies) ...[
              MaterialBanner(
                padding: const EdgeInsets.all(8),
                leading: const Icon(
                  MdiIcons.exclamationThick,
                  color: Colors.orange,
                  size: 32,
                ),
                content: Text(
                  AppLocalizations.of(context)!.study_selection_hidden_studies,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                actions: const [SizedBox.shrink()],
                backgroundColor: Colors.yellow[100],
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 360,
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
          ],
        ),
      ),
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.private_study_invite_code),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.private_study_invite_code_description),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller,
            validator: (_) => _errorMessage,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(labelText: l10n.invite_code),
          ),
        ],
      ),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: Text(AppLocalizations.of(context)!.next),
          onPressed: () async {
            try {
              final (invite, study) = await Study.fetchByInviteCode(
                _controller.text,
              );

              if (!mounted) return;

              if (study == null) {
                setState(() {
                  _errorMessage = AppLocalizations.of(
                    context,
                  )!.invalid_invite_code;
                });
                return;
              }

              setState(() {
                _errorMessage = null;
              });

              if (study.isClosed) {
                if (!context.mounted) return;
                context.pop();
                await showStudyClosedDialog(context);
                return;
              }

              if (!context.mounted) return;
              context.pop();

              await navigateToStudyOverview(
                context,
                study,
                inviteCode: _controller.text,
                preselectedIds: invite?.preselectedInterventionIds,
              );
            } catch (e) {
              if (e is ArgumentError) {
                // Study.fromJson schema mismatch — the study was authored with a
                // newer app/schema than this client understands. Signal the user
                // to update the app rather than mislabeling it as an invalid code.
                if (!mounted) return;
                setState(() {
                  _errorMessage = null;
                });
                if (!context.mounted) return;
                context.pop();
                await showAppOutdatedDialog(context);
              } else if (e is PostgrestException) {
                // RPC / network failure while looking up the invite code.
                if (!mounted) return;
                setState(() {
                  _errorMessage = AppLocalizations.of(
                    context,
                  )!.error_occurred_with_message(e.message);
                });
              } else {
                if (!mounted) return;
                setState(() {
                  _errorMessage = AppLocalizations.of(
                    context,
                  )!.invalid_invite_code;
                });
              }
            }
          },
        ),
      ],
    );
  }
}
