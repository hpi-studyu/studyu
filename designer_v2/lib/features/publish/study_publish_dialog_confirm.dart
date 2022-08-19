import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class PublishConfirmationDialog extends StudyPageWidget {
  const PublishConfirmationDialog(super.studyId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(studyControllerProvider(studyId).notifier);
    final state = ref.watch(studyControllerProvider(studyId));
    final formViewModel = ref.watch(studySettingsFormViewModelProvider(studyId));

    final theme = Theme.of(context);

    return StandardDialog(
      titleText: "Great work! \u{1F44F} Ready to launch?".hardcoded,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'The study you are creating is'.hardcoded,
                            children: [
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: state.studyParticipation!.asAdjective,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        SelectableText(
                            state.studyParticipation!.launchDescription,
                            style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontStyle: FontStyle.italic)
                        ),
                      ],
                    )
                ),
                const SizedBox(width: 4.0),
                TextButton(
                  onPressed: () {
                    Navigator.maybePop(context)
                        .then((_) => controller.onChangeStudyParticipation());
                  },
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                          child: Text("Change\nparticipation".hardcoded, textAlign: TextAlign.center,)
                      )
                  ),
                ),
              ]
          ),
          const SizedBox(height: 24.0),
          SelectableText("After launching your study:".hardcoded),
          const SizedBox(height: 4.0),
          SelectableText(
              "- " +
                  "The study design will be locked & you won’t be able to "
                      "make any changes".hardcoded
                  + "\n" +
                  "- " +
                  "All data from test runs will be reset (incl. test users, "
                      "their tasks & results)".hardcoded,
              style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 32.0),
          Container(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.05),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReactiveCheckbox(
                      formControl: formViewModel.isPublishedToRegistryControl,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                        child: FormControlLabel(
                          formControl: formViewModel.isPublishedToRegistryControl,
                          text: "To facilitate collaboration among researchers & "
                              "clinicians, I agree that the my study will be published "
                              "to the StudyU study registry for others. "
                              "(Other researchers & clinicians will be able to contact "
                              "you and review the study design, but they won't "
                              "be able to access participation or result data unless "
                              "shared explicitly)".hardcoded
                        )
                    )
                  ],
                )
            ),
          )
        ],
      ),
      actionButtons: [
        const DismissButton(),
        PrimaryButton(
            text: "Launch".hardcoded,
            icon: null,
            onPressedFuture: () => controller.publishStudy()
          //.whenComplete(() => Navigator.maybePop(context)),
        ),
      ],
      maxWidth: 650,
      minWidth: 550,
    );
  }
}
