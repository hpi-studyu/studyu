import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/pages/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/side_sheet_modal.dart';
import 'package:studyu_designer_v2/domain/forms/study_invite_code_form.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_view.dart';
import 'package:studyu_designer_v2/features/recruit/invite_codes_table.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyRecruitScreen extends ConsumerWidget {
  const StudyRecruitScreen(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(studyRecruitControllerProvider(studyId));
    final controller = ref.watch(studyRecruitControllerProvider(studyId).notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            SelectableText("Access Codes".hardcoded,
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.bold)),
            Container(width: 32.0),
            PrimaryButton(
              icon: Icons.add,
              text: "New code".hardcoded,
              onPressed: () {
                /*
                showFormSideSheet(
                  context: context,
                  formController: formController,
                  formViewBuilder: (formController) =>
                      InviteCodeFormView(formController: formController),
                );*/

                showDefaultSideSheet(
                  context: context,
                  title: StudyInviteCodeForm.kTitle,
                  body: InviteCodeFormView(studyId: studyId),
                  actionButtons: [
                    const DismissButton(),
                    ReactiveForm(
                      formGroup: controller.inviteCodeForm.form,
                      child: ReactiveFormConsumer(
                          builder: (context, form, child) {
                            return PrimaryButton(
                                text: "Save".hardcoded,
                                icon: null,
                                onPressed: controller.saveFormCallback
                            );
                          }
                      ),
                    ),
                  ]
                );
              },
            ),
            Container(width: 32.0),
          ],
        ),
        const SizedBox(height: 24.0), // spacing between body elements
        AsyncValueWidget<List<StudyInvite>?>(
          value: state.studyInvites,
          data: (studyInvites) => StudyInvitesTable(
            invites: studyInvites!, // otherwise falls through to [AsyncValueWidget.empty]
            onSelectInvite: (_) {},
            getActionsForInvite: controller.getActionsForInvite,
          ),
          empty: () => EmptyBody(
            icon: Icons.link_off_rounded,
            title: "You haven't invited anyone yet".hardcoded,
            description: "Add participants to your study via invitation codes".hardcoded,
            button: PrimaryButton(
              icon: Icons.add,
              text: "New invitation".hardcoded,
              onPressed: () => print("pressed"),
            ),
          ),
        )
      ],
    );
  }
}
