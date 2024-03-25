import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_view.dart';
import 'package:studyu_designer_v2/features/recruit/invite_codes_table.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

typedef InterventionProvider = Intervention? Function(String id);

class StudyRecruitScreen extends StudyPageWidget {
  const StudyRecruitScreen(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyRecruitControllerProvider(studyId));
    final controller = ref.watch(studyRecruitControllerProvider(studyId).notifier);

    return AsyncValueWidget<List<StudyInvite>?>(
        value: state.invites,
        data: (studyInvites) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _inviteCodesSectionHeader(context, ref),
                const SizedBox(height: 24.0), // spacing between body elements
                StudyInvitesTable(
                  invites: studyInvites!, // otherwise falls through to [AsyncValueWidget.empty]
                  onSelect: _onSelectInvite(context, ref),
                  getActions: controller.availableActions,
                  getInlineActions: controller.availableInlineActions,
                  getIntervention: controller.getIntervention,
                  getParticipantCountForInvite: controller.getParticipantCountForInvite,
                ),
              ],
            ),
        empty: () => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyBody(
                  icon: Icons.link_off_rounded,
                  title: tr.code_list_empty_title,
                  description: tr.code_list_empty_description,
                  button: _newInviteCodeButton(context, ref)),
            ));
  }

  Widget _inviteCodesSectionHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SelectableText(tr.code_list_section_title, style: Theme.of(context).textTheme.headlineSmall),
        Container(width: 32.0),
        _newInviteCodeButton(context, ref),
        Container(width: 32.0),
      ],
    );
  }

  Widget _newInviteCodeButton(BuildContext context, WidgetRef ref) {
    return PrimaryButton(
      icon: Icons.add,
      text: tr.action_button_code_new,
      onPressed: () {
        final formViewModel = ref.read(inviteCodeFormViewModelProvider(studyId));
        showFormSideSheet<InviteCodeFormViewModel>(
          context: context,
          formViewModel: formViewModel,
          formViewBuilder: (formViewModel) => InviteCodeFormView(formViewModel: formViewModel),
        );
      },
    );
  }

  _onSelectInvite(BuildContext context, WidgetRef ref) {
    // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
    return (StudyInvite invite) {
      final formViewModel = ref.read(inviteCodeFormViewModelProvider(studyId));
      formViewModel.read(invite);
      showFormSideSheet<InviteCodeFormViewModel>(
        context: context,
        formViewModel: formViewModel,
        formViewBuilder: (formViewModel) => InviteCodeFormView(formViewModel: formViewModel),
      );
    };
  }
}
