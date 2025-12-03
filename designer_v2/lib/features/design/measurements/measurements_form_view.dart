import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_list_view.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyDesignMeasurementsFormView extends StudyDesignPageWidget {
  const StudyDesignMeasurementsFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(
          measurementsFormViewModelProvider(studyId),
        );
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                text: tr.form_study_design_measurements_description,
              ),
              const SizedBox(height: 32.0),
              ReactiveFormConsumer(
                // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
                // By default, ReactiveFormArray only updates when adding/removing controls
                builder: (context, form, child) {
                  return ReactiveFormArray(
                    formArray: formViewModel.measurementsArray,
                    builder: (context, formArray, child) {
                      return FormListView<
                        ManagedFormViewModel<IFormDataWithSchedule>
                      >(
                        control: formViewModel.measurementsArray,
                        items: formViewModel.measurementViewModels,
                        onSelectItem: formViewModel.onSelectItem,
                        getActionsAt: (viewModel, _) =>
                            formViewModel.availablePopupActions(viewModel),
                        onNewItem: () => _onNewItem(context, formViewModel),
                        onNewItemLabel: tr.form_array_measurements_surveys_new,
                        rowTitle: (viewModel) =>
                            ((viewModel.formData as dynamic).title
                                as String?) ??
                            '',
                        sectionTitle: tr.form_array_measurements_surveys,
                        // sectionTitleDivider: false,
                        emptyIcon: Icons.content_paste_off_rounded,
                        emptyTitle:
                            tr.form_array_measurements_surveys_empty_title,
                        emptyDescription: tr
                            .form_array_measurements_surveys_empty_description,
                        hideLeadingTrailingWhenEmpty: true,
                        reorderable: !formViewModel.isReadonly,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          // Reorder the view models
                          final item = formViewModel.measurementViewModels
                              .removeAt(oldIndex);
                          formViewModel.measurementViewModels.insert(
                            newIndex,
                            item,
                          );
                          // Reorder the underlying form array to match
                          final controlItem = formViewModel.measurementsArray
                              .removeAt(oldIndex);
                          formViewModel.measurementsArray.insert(
                            newIndex,
                            controlItem,
                          );
                          formViewModel.save();
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNewItem(
    BuildContext context,
    MeasurementsFormViewModel formViewModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.assignment),
            title: Text(tr.form_array_measurements_surveys_new),
            onTap: () {
              Navigator.pop(context);
              formViewModel.onNewSurvey();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('New Nutrition Task'),
            onTap: () {
              Navigator.pop(context);
              formViewModel.onNewNutrition();
            },
          ),
        ],
      ),
    );
  }
}
