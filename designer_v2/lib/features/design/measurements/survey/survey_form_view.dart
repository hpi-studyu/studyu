import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/side_sheet_modal.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class MeasurementSurveyFormView extends ConsumerWidget {
  const MeasurementSurveyFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final MeasurementSurveyFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "Survey title".hardcoded,
                //labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: "TODO Survey title help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyTitleControl,
                ),
              ),
              FormTableRow(
                label: "Intro text".hardcoded,
                labelHelpText: "TODO Intro text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyIntroTextControl,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                      hintText: "e.g. welcome & introduce participants to the survey".hardcoded
                  ),
                ),
              ),
              FormTableRow(
                label: "Outro text".hardcoded,
                labelHelpText: "TODO Outro text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.surveyOutroTextControl,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                      hintText: "e.g. thank participants for completing the survey".hardcoded
                  ),
                ),
              ),
            ]
        ),
        const SizedBox(height: 28.0),
        ReactiveFormConsumer(
          // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
          // By default, ReactiveFormArray only updates when adding/removing controls
          builder: (context, form, child) {
            return ReactiveFormArray(
              formArray: formViewModel.questionsArray,
              builder: (context, formArray, child) {
                return FormArrayTable<QuestionFormViewModel>(
                  items: formViewModel.questionModels,
                  onSelectItem: (viewModel) => _onSelectItem(viewModel, context, ref),
                  getActionsAt: (viewModel, _) => formViewModel.availablePopupActions(viewModel),
                  onNewItem: () => _onNewItem(context, ref),
                  onNewItemLabel: 'Add question'.hardcoded,
                  rowTitle: (viewModel) => viewModel.formData?.questionText ?? 'Missing item title'.hardcoded,
                  sectionTitle: "Questions".hardcoded,
                  emptyIcon: Icons.content_paste_off_rounded,
                  emptyTitle: "No questions defined".hardcoded,
                  emptyDescription: "You need to define at least one question to determine the effect of your intervention(s).".hardcoded,
                );
              },
            );
          }
        ),
        const SizedBox(height: 28.0),
        ScheduleControls(formViewModel: formViewModel),
      ],
    );
  }

  _onNewItem(BuildContext context, WidgetRef ref) {
    final routeArgs = formViewModel.buildNewFormRouteArgs();
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  _onSelectItem(QuestionFormViewModel item, BuildContext context, WidgetRef ref) {
    final routeArgs = formViewModel.buildFormRouteArgs(item);
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showSidesheetWithArgs(
      SurveyQuestionFormRouteArgs routeArgs,
      BuildContext context,
      WidgetRef ref)
  {
    final surveyQuestionFormViewModel = ref.read(
        surveyQuestionFormViewModelProvider(routeArgs));
    showFormSideSheet<QuestionFormViewModel>(
      context: context,
      formViewModel: surveyQuestionFormViewModel,
      formViewBuilder: (formViewModel) => SurveyQuestionFormView(
          formViewModel: formViewModel),
      ignoreAppBar: true,
    );
  }
}
