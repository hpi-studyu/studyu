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
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudyDesignInterventionsFormView extends StudyDesignPageWidget {
  const StudyDesignInterventionsFormView(super.studyCreationArgs, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyCreationArgs));
    final theme = Theme.of(context);

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.read(interventionsFormViewModelProvider(studyCreationArgs));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                text: tr.form_study_design_interventions_description,
              ),
              const SizedBox(height: 8.0),
              Hyperlink(
                icon: Icons.north_east_rounded,
                text: tr.link_n_of_1_learn_more,
                url: tr.link_n_of_1_learn_more_url,
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
                      items: formViewModel.interventionsCollection.formViewModels,
                      onSelectItem: formViewModel.onSelectItem,
                      getActionsAt: (viewModel, _) =>
                          formViewModel.availablePopupActions(viewModel),
                      onNewItem: formViewModel.onNewItem,
                      onNewItemLabel: tr.form_array_interventions_new,
                      rowTitle: (viewModel) => viewModel.formData?.title ?? '',
                      sectionTitle: tr.form_array_interventions,
                      sectionTitleDivider: false,
                      emptyIcon: Icons.content_paste_off_rounded,
                      emptyTitle: tr.form_array_interventions_empty_title,
                      emptyDescription: tr.form_array_interventions_empty_description,
                      hideLeadingTrailingWhenEmpty: true,
                      rowPrefix: (context, viewModel, rowIdx) {
                        return Row(
                          children: [
                            Text(
                              ''.alphabetLetterFrom(rowIdx).toUpperCase(),
                              style: TextStyle(
                                color: ThemeConfig.dropdownMenuItemTheme(theme).iconTheme!.color,
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
                    tr.form_section_crossover_schedule,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  (formViewModel.canTestStudySchedule)
                      ? Opacity(
                          opacity: ThemeConfig.kMuteFadeFactor,
                          child: TextButton.icon(
                            onPressed: formViewModel.testStudySchedule,
                            icon: const Icon(Icons.play_circle_outline_rounded),
                            label: Text(tr.navlink_crossover_schedule_test),
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
