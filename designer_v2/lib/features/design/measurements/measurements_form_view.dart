import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/container_bounded.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_table.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyDesignMeasurementsFormView extends ConsumerWidget {
  const StudyDesignMeasurementsFormView(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));
    print("StudyDesignMeasurementsFormView.build");

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.read(measurementsFormViewModelProvider(studyId));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: BoundedContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SelectableText(
                  "Define the data you want to gather from participants to "
                  "evaluate the effect of your interventions & for additional context. "
                  "The data will be self-reported by participants in one or more "
                  "surveys served via the StudyU app.".hardcoded,
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      height: 1.35,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85)),
                ),
                const SizedBox(height: 32.0),
                ReactiveFormArray(
                  formArray: formViewModel.measurementsArray,
                  builder: (context, formArray, child) {
                    return MeasurementsTable(
                      items: formViewModel.measurementsData,
                      onSelectItem: formViewModel.onSelectItem,
                      getActionsAt: (item, _) => formViewModel.availablePopupActions(item),
                      onNewItem: formViewModel.onNewItem,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
