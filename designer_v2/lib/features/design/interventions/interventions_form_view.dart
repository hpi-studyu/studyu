import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudyDesignInterventionsFormView extends StudyDesignPageWidget {
  const StudyDesignInterventionsFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));
    final theme = Theme.of(context);

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel =
            ref.read(interventionsFormViewModelProvider(studyId));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                  text: "Define the different phases of interventions to be "
                          "studied, as well as the their "
                          "sequence and frequency. In N-of-1 trials, a single "
                          "participant will go through the intervention phases "
                          "once or multiple times in a pre-specified order "
                          "(so called multi-crossover trial). Each "
                          "intervention consists of one or more tasks "
                          "which are administered during the corresponding phase.\n\n"
                          "Note: If you specify more than two interventions, participants "
                      "are free to choose any two interventions to compare "
                      "when they begin the study. "
                      .hardcoded),
              const SizedBox(height: 8.0),
              const Hyperlink(
                icon: Icons.north_east_rounded,
                text: "Learn more about N-of-1 trials",
                url:
                    "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3118090/pdf/nihms297482.pdf",
              ),
              const SizedBox(height: 24.0),
              ReactiveFormConsumer(
                  // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
                  // By default, ReactiveFormArray only updates when adding/removing controls
                  builder: (context, form, child) {
                return ReactiveFormArray(
                  formArray: formViewModel.interventionsArray,
                  builder: (context, formArray, child) {
                    return FormArrayTable<InterventionFormViewModel>(
                      control: formViewModel.interventionsArray,
                      items:
                          formViewModel.interventionsCollection.formViewModels,
                      onSelectItem: formViewModel.onSelectItem,
                      getActionsAt: (viewModel, _) =>
                          formViewModel.availablePopupActions(viewModel),
                      onNewItem: formViewModel.onNewItem,
                      onNewItemLabel: 'Add intervention'.hardcoded,
                      rowTitle: (viewModel) =>
                          viewModel.formData?.title ??
                          'Missing item title'.hardcoded,
                      sectionTitle: "Intervention phases".hardcoded,
                      sectionTitleDivider: false,
                      emptyIcon: Icons.content_paste_off_rounded,
                      emptyTitle: "No interventions defined".hardcoded,
                      emptyDescription:
                          "You must define at least two interventions to compare."
                              .hardcoded,
                      hideLeadingTrailingWhenEmpty: true,
                      rowPrefix: (context, viewModel, rowIdx) {
                        return Row(
                          children: [
                            Text(
                              ''.alphabetLetterFrom(rowIdx).toUpperCase(),
                              style: TextStyle(
                                color: ThemeConfig.dropdownMenuItemTheme(theme)
                                    .iconTheme!
                                    .color,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        );
                      },
                    );
                  },
                );
              }),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Crossover Schedule".hardcoded,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  (formViewModel.canTestStudySchedule)
                      ? Opacity(
                          opacity: ThemeConfig.kMuteFadeFactor,
                          child: TextButton.icon(
                            onPressed: formViewModel.testStudySchedule,
                            icon: const Icon(Icons.play_circle_outline_rounded),
                            label: Text("Test schedule".hardcoded),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12.0),
              // TODO study schedule illustration
              StudyScheduleFormView(formViewModel: formViewModel),
            ],
          ),
        );
      },
    );
  }
}
