import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/side_sheet_modal.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudyDesignEnrollmentFormView extends StudyDesignPageWidget {
  const StudyDesignEnrollmentFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel =
            ref.read(enrollmentFormViewModelProvider(studyId));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                  text: "Define the questions you want to ask people to check "
                          "if they are eligible to participate in your study. "
                          "For invitation-based studies, you may choose not to add "
                          "any screening questions if you are manually qualifying "
                          "& recruiting participants before inviting them to "
                          "StudyU."
                      .hardcoded),
              const SizedBox(height: 32.0),
              FormTableLayout(rows: [
                FormTableRow(
                    label: "Recruiting".hardcoded,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    input: Column(
                      children: formViewModel.enrollmentTypeControlOptions
                          .map((option) => ReactiveRadioListTile<Participation>(
                                formControl:
                                    formViewModel.enrollmentTypeControl,
                                value: option.value,
                                title: Text(option.label),
                                subtitle: (option.description) != null
                                    ? TextParagraph(
                                        text: option.description!,
                                        selectable: false,
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6)))
                                    : null,
                              ) as Widget)
                          .toList()
                          .separatedBy(() => const SizedBox(height: 8.0)),
                    )),
              ]),
              const SizedBox(height: 24.0),
              ReactiveFormConsumer(
                  // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
                  // By default, ReactiveFormArray only updates when adding/removing controls
                  builder: (context, form, child) {
                return ReactiveFormArray(
                  formArray: formViewModel.questionsArray,
                  builder: (context, formArray, child) {
                    return FormArrayTable<QuestionFormViewModel>(
                      items: formViewModel.questionModels,
                      onSelectItem: (viewModel) {
                        final routeArgs =
                            formViewModel.buildFormRouteArgs(viewModel);
                        _showSidesheetWithArgs(routeArgs, context, ref);
                      },
                      getActionsAt: (viewModel, _) =>
                          formViewModel.availablePopupActions(viewModel),
                      onNewItem: () {
                        final routeArgs = formViewModel.buildNewFormRouteArgs();
                        _showSidesheetWithArgs(routeArgs, context, ref);
                      },
                      onNewItemLabel: 'Add screener question'.hardcoded,
                      rowTitle: (viewModel) =>
                          viewModel.formData?.questionText ??
                          'Missing item title'.hardcoded,
                      leadingWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Screening criteria".hardcoded,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          TextButton.icon(
                              onPressed: formViewModel.testScreener,
                              icon: const Icon(Icons.play_circle_fill),
                              label: Text("Test screener".hardcoded),
                          )
                        ],
                      ),
                      //emptyIcon: Icons.content_paste_off_rounded,
                      emptyTitle: "No screening criteria".hardcoded,
                      emptyDescription:
                          "Optional screener questions can help determine whether a potential participant is qualified to participate in your study."
                              .hardcoded,
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showSidesheetWithArgs(ScreenerQuestionFormRouteArgs routeArgs,
      BuildContext context, WidgetRef ref) {
    final surveyQuestionFormViewModel =
        ref.read(screenerQuestionFormViewModelProvider(routeArgs));
    showFormSideSheet<QuestionFormViewModel>(
      context: context,
      formViewModel: surveyQuestionFormViewModel,
      formViewBuilder: (formViewModel) =>
          SurveyQuestionFormView(formViewModel: formViewModel),
      ignoreAppBar: true,
    );
  }
}
