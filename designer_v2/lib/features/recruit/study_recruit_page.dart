import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/qr_code_preview_dialog.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_view.dart';
import 'package:studyu_designer_v2/features/recruit/invite_codes_table.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';

typedef InterventionProvider = Intervention? Function(String id);

class StudyRecruitScreen extends StudyPageWidget {
  const StudyRecruitScreen(super.studyId, {super.key});

  static const _searchFieldWidth = 280.0;
  static const _inviteCodePageSizes = [15, 25, 50, 100];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyRecruitControllerProvider(studyId));
    final controller = ref.watch(
      studyRecruitControllerProvider(studyId).notifier,
    );
    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) => study.participation == Participation.invite
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _inviteCodesSectionHeader(context, ref),
                const SizedBox(height: 24.0),
                _inviteCodesContent(context, ref, state, controller),
              ],
            )
          : Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyBody(
                icon: Icons.share_rounded,
                title: tr.code_public_disabled,
                description: tr.code_public_disabled_description,
                button: _publicStudyActionButtons(context, ref),
              ),
            ),
    );
  }

  Widget _inviteCodesContent(
    BuildContext context,
    WidgetRef ref,
    StudyRecruitControllerState state,
    StudyRecruitController controller,
  ) {
    return state.invites.when(
      data: (studyInvites) {
        if (studyInvites == null || studyInvites.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: EmptyBody(
              icon: Icons.link_off_rounded,
              title: tr.code_list_empty_title,
              description: tr.code_list_empty_description,
              button: _newInviteCodeButton(context, ref),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudyInvitesTable(
              invites: studyInvites,
              onSelect: _onSelectInvite(context, ref),
              getActions: controller.availableActions,
              getInlineActions: controller.availableInlineActions,
              getIntervention: controller.getIntervention,
              getParticipantCountForInvite:
                  controller.getParticipantCountForInvite,
              sortColumn: state.inviteCodeSortColumn,
              sortAscending: state.inviteCodeSortAscending,
              onSortColumn: controller.setInviteCodeSorting,
              firstRowNumber: state.inviteCodeFirstRowNumber,
            ),
            const SizedBox(height: 12),
            _inviteCodePaginationControls(context, state, controller),
          ],
        );
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyRecruitControllerProvider(studyId));
    final isStudyClosed = state.studyWithMetadata?.model.isClosed;

    if (isStudyClosed ?? false) {
      return BannerBox(
        noPrefix: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: tr.banner_study_closed_title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextParagraph(text: tr.banner_study_closed_description),
          ],
        ),
        style: BannerStyle.info,
      );
    }

    if (state.isDraft &&
        state.studyWithMetadata?.model.participation == Participation.open) {
      return BannerBox(
        noPrefix: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [TextParagraph(text: tr.banner_text_study_recruit_draft)],
        ),
        style: BannerStyle.info,
      );
    }

    return null;
  }

  Widget _inviteCodesSectionHeader(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyRecruitControllerProvider(studyId));
    final controller = ref.watch(
      studyRecruitControllerProvider(studyId).notifier,
    );
    return Row(
      children: [
        SelectableText(
          tr.code_list_section_title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Container(width: 32.0),
        _newInviteCodeButton(context, ref),
        const Spacer(),
        SizedBox(
          width: _searchFieldWidth,
          child: Search(
            hintText: tr.code_list_search_hint,
            initialText: state.inviteCodeSearchQuery,
            onQueryChanged: controller.setInviteCodeSearchQuery,
          ),
        ),
      ],
    );
  }

  Widget _newInviteCodeButton(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyRecruitControllerProvider(studyId));
    final isStudyClosed = state.studyWithMetadata?.model.isClosed == true;

    return PrimaryButton(
      text: tr.action_button_code_new,
      onPressed: isStudyClosed
          ? null
          : () {
              final formViewModel = ref.watch(
                inviteCodeFormViewModelProvider(studyId),
              );
              showFormSideSheet<InviteCodeFormViewModel>(
                context: context,
                formViewModel: formViewModel,
                formViewBuilder: (formViewModel) =>
                    InviteCodeFormView(formViewModel: formViewModel),
                actionButtons: _inviteCodeFormActionButtons(
                  context,
                  ref,
                  formViewModel,
                ),
              );
            },
    );
  }

  List<Widget> _inviteCodeFormActionButtons(
    BuildContext context,
    WidgetRef ref,
    InviteCodeFormViewModel formViewModel,
  ) {
    return [
      DismissButton(
        onPressed: () => formViewModel.cancel().then((_) {
          if (context.mounted) Navigator.maybePop(context);
        }),
      ),
      ReactiveFormConsumer(
        builder: (context, form, child) {
          return PrimaryButton(
            text: tr.dialog_save,
            icon: null,
            enabled: formViewModel.isValid,
            onPressedFuture: formViewModel.isValid
                ? () async {
                    final wasCreate = formViewModel.formMode == FormMode.create;
                    final savedInvite = await formViewModel.save();
                    final controller = ref.read(
                      studyRecruitControllerProvider(studyId).notifier,
                    );
                    if (wasCreate) {
                      await controller.showCreatedInviteCode(savedInvite);
                    } else {
                      await controller.loadInviteCodePage(
                        ref
                            .read(studyRecruitControllerProvider(studyId))
                            .inviteCodePageIndex,
                      );
                    }
                    if (context.mounted) {
                      Navigator.maybePop(context);
                    }
                  }
                : null,
          );
        },
      ),
    ];
  }

  Widget _inviteCodePaginationControls(
    BuildContext context,
    StudyRecruitControllerState state,
    StudyRecruitController controller,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          tr.code_list_active_count(state.inviteCodeCount),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        Text(tr.code_list_page_size, style: theme.textTheme.bodySmall),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: state.inviteCodePageSize,
          items: _inviteCodePageSizes
              .map(
                (pageSize) => DropdownMenuItem<int>(
                  value: pageSize,
                  child: Text(pageSize.toString()),
                ),
              )
              .toList(),
          onChanged: (pageSize) {
            if (pageSize == null) return;
            controller.setInviteCodePageSize(pageSize);
          },
        ),
        const SizedBox(width: 16),
        Text(
          '${tr.code_list_page(state.inviteCodePageIndex + 1)} / ${state.inviteCodeTotalPages}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: state.hasPreviousInviteCodePage
              ? controller.loadPreviousInviteCodePage
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: MaterialLocalizations.of(context).previousPageTooltip,
        ),
        IconButton(
          onPressed: state.hasComputedNextInviteCodePage
              ? controller.loadNextInviteCodePage
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: MaterialLocalizations.of(context).nextPageTooltip,
        ),
      ],
    );
  }

  Widget _publicStudyActionButtons(BuildContext context, WidgetRef ref) {
    final deepLink = env.generateAppDeepLink('study/$studyId');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SecondaryButton(
          text: tr.action_copy_link,
          icon: Icons.link_rounded,
          onPressed: () {
            ref
                .read(clipboardServiceProvider)
                .copy(deepLink)
                .then(
                  (_) => ref
                      .read(notificationServiceProvider)
                      .show(Notifications.inviteCodeClipped),
                );
          },
        ),
        const SizedBox(width: 16.0),
        SecondaryButton(
          text: tr.action_qr_code_show,
          icon: Icons.qr_code_rounded,
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) =>
                  QrCodePreviewDialog(data: deepLink, filename: studyId),
            );
          },
        ),
      ],
    );
  }

  Null Function(StudyInvite invite) _onSelectInvite(
    BuildContext context,
    WidgetRef ref,
  ) {
    return (StudyInvite invite) {
      final formViewModel = ref.watch(inviteCodeFormViewModelProvider(studyId));
      formViewModel.read(invite);
      showFormSideSheet<InviteCodeFormViewModel>(
        context: context,
        formViewModel: formViewModel,
        formViewBuilder: (formViewModel) =>
            InviteCodeFormView(formViewModel: formViewModel),
      );
    };
  }
}
