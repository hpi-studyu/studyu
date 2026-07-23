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
import 'package:studyu_designer_v2/domain/study_invite.dart';
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

  static const _searchFieldWidth = 300.0;
  static const _sectionSpacing = 24.0;
  static const _headerControlSpacing = 16.0;
  static const _titleSubtitleSpacing = 4.0;
  static const _footerTopSpacing = 24.0;
  static const _feedbackBottomSpacing = 24.0;
  static const _feedbackHorizontalPadding = 24.0;
  static const _feedbackVerticalPadding = 18.0;
  static const _paginationSpacing = 8.0;
  static const _paginationGroupSpacing = 16.0;
  static const _paginationButtonSize = 40.0;
  static const _footerDropdownWidth = 64.0;
  static const _footerDropdownHeight = 40.0;
  static const _footerDropdownBorderRadius = 50.0;
  static const _footerDropdownHorizontalPadding = 10.0;
  static const _footerDropdownIconSize = 20.0;
  static const _footerDropdownSplashRadius = 18.0;
  static const _footerDropdownMenuWidth = 96.0;
  static const _footerDropdownMenuItemHeight = 48.0;
  static const _footerDropdownMenuElevation = 5.0;
  static const _feedbackBorderRadius = 8.0;
  static const _loadingIndicatorHeight = 3.0;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _inviteCodesSectionHeader(context, ref),
                const SizedBox(height: _sectionSpacing),
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
          final hasSearchQuery = state.inviteCodeSearchQuery.trim().isNotEmpty;
          if (hasSearchQuery) {
            return Padding(
              padding: const EdgeInsets.only(top: _sectionSpacing),
              child: EmptyBody(
                icon: Icons.filter_alt_off_rounded,
                title: tr.code_list_no_results_title,
                description: tr.code_list_no_results_description,
                button: SecondaryButton(
                  text: tr.code_list_clear_filters,
                  onPressed: () async {
                    await controller.setInviteCodeSearchQuery('');
                    await controller.setInviteCodeFilters(
                      const InviteCodeFilters(),
                    );
                  },
                ),
              ),
            );
          }
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.isPageTransitionLoading)
              const LinearProgressIndicator(minHeight: _loadingIndicatorHeight),
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
            ),
            const SizedBox(height: _footerTopSpacing),
            if (state.hasPaginationError) ...[
              _inviteCodePaginationFeedback(context, state, controller),
              const SizedBox(height: _feedbackBottomSpacing),
            ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              tr.code_list_section_title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: _titleSubtitleSpacing),
            Text(
              tr.code_list_total_count(state.inviteCodeCount),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: _searchFieldWidth,
          child: Search(
            hintText: tr.code_list_search_hint,
            initialText: state.inviteCodeSearchQuery,
            onQueryChanged: ref
                .read(studyRecruitControllerProvider(studyId).notifier)
                .setInviteCodeSearchQuery,
          ),
        ),
        const SizedBox(width: _headerControlSpacing),
        _newInviteCodeButton(context, ref),
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
    final isPaginationDisabled = state.isPageTransitionLoading;
    return Row(
      children: [
        Text(tr.code_list_rows_per_page, style: theme.textTheme.bodyLarge),
        const SizedBox(width: _paginationSpacing),
        Theme(
          data: theme.copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: Container(
            width: _footerDropdownWidth,
            height: _footerDropdownHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(_footerDropdownBorderRadius),
              ),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: PopupMenuButton<int>(
              enabled: !isPaginationDisabled,
              tooltip: '',
              padding: EdgeInsets.zero,
              splashRadius: _footerDropdownSplashRadius,
              elevation: _footerDropdownMenuElevation,
              shadowColor: theme.shadowColor,
              surfaceTintColor: Colors.transparent,
              color: theme.colorScheme.surface,
              constraints: const BoxConstraints.tightFor(
                width: _footerDropdownMenuWidth,
              ),
              menuPadding: EdgeInsets.zero,
              onSelected: controller.setInviteCodePageSize,
              itemBuilder: (context) => [
                for (final pageSize in _inviteCodePageSizes)
                  PopupMenuItem<int>(
                    value: pageSize,
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      height: _footerDropdownMenuItemHeight,
                      alignment: Alignment.center,
                      color: pageSize == state.inviteCodePageSize
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.transparent,
                      child: Text(
                        pageSize.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _footerDropdownHorizontalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.inviteCodePageSize.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: _footerDropdownIconSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Text(
          _inviteCodePaginationSummary(state),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(width: _paginationGroupSpacing),
        IconButton(
          onPressed: state.hasPreviousInviteCodePage && !isPaginationDisabled
              ? controller.loadPreviousInviteCodePage
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: MaterialLocalizations.of(context).previousPageTooltip,
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: const Size.square(_paginationButtonSize),
            side: BorderSide(color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(width: _paginationSpacing),
        IconButton(
          onPressed:
              state.hasComputedNextInviteCodePage && !isPaginationDisabled
              ? controller.loadNextInviteCodePage
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: MaterialLocalizations.of(context).nextPageTooltip,
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: const Size.square(_paginationButtonSize),
            side: BorderSide(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _inviteCodePaginationFeedback(
    BuildContext context,
    StudyRecruitControllerState state,
    StudyRecruitController controller,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _feedbackHorizontalPadding,
              vertical: _feedbackVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.65),
              borderRadius: const BorderRadius.all(
                Radius.circular(_feedbackBorderRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    tr.code_list_page_fetch_error,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: _paginationGroupSpacing),
        SecondaryButton(
          text: tr.code_list_retry,
          icon: null,
          onPressed: controller.retryInviteCodePageLoad,
        ),
      ],
    );
  }

  String _inviteCodePaginationSummary(StudyRecruitControllerState state) {
    if (state.inviteCodeCount == 0) {
      return tr.code_list_page_range(0, 0, 0);
    }
    if (state.isPageTransitionLoading) {
      return tr.code_list_page_loading(
        state.pendingInviteCodeRangeStart,
        state.pendingInviteCodeRangeEnd,
      );
    }
    return tr.code_list_page_range(
      state.inviteCodeRangeStart,
      state.inviteCodeRangeEnd,
      state.inviteCodeCount,
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
