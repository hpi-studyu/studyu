import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/styling_information.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';

class MeasurementSurveyFormView extends ConsumerStatefulWidget {
  const MeasurementSurveyFormView({required this.formViewModel, super.key});

  final MeasurementSurveyFormViewModel formViewModel;

  @override
  ConsumerState<MeasurementSurveyFormView> createState() => _MeasurementSurveyFormViewState();
}

class _MeasurementSurveyFormViewState extends ConsumerState<MeasurementSurveyFormView> {
  bool isStylingInformationDismissed = true;

  onDismissedCallback() => setState(() {
        isStylingInformationDismissed = !isStylingInformationDismissed;
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            control: widget.formViewModel.surveyTitleControl,
            label: tr.form_field_measurement_survey_title,
            labelHelpText: tr.form_field_measurement_survey_title_tooltip,
            input: ReactiveTextField(
              formControl: widget.formViewModel.surveyTitleControl,
              decoration: InputDecoration(
                hintText: tr.form_field_measurement_survey_title,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(200),
              ],
              validationMessages: widget.formViewModel.surveyTitleControl.validationMessages,
            ),
          ),
          FormTableRow(
            control: widget.formViewModel.surveyIntroTextControl,
            labelBuilder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormLabel(
                  labelText: tr.form_field_measurement_survey_intro_text,
                  helpText: tr.form_field_measurement_survey_intro_text_tooltip,
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(left: 3.0),
                  child: Opacity(
                    opacity: ThemeConfig.kMuteFadeFactor,
                    child: Tooltip(
                      message: "Use html to style your content",
                      child: Hyperlink(
                        text: "styleable",
                        onClick: () => setState(() {
                          isStylingInformationDismissed = !isStylingInformationDismissed;
                        }),
                        visitedColor: null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            input: ReactiveTextField(
              formControl: widget.formViewModel.surveyIntroTextControl,
              decoration: InputDecoration(hintText: tr.form_field_measurement_survey_intro_text_hint),
              inputFormatters: [
                LengthLimitingTextInputFormatter(2000),
              ],
              validationMessages: widget.formViewModel.surveyIntroTextControl.validationMessages,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 5,
            ),
          ),
          FormTableRow(
            control: widget.formViewModel.surveyOutroTextControl,
            labelBuilder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormLabel(
                  labelText: tr.form_field_measurement_survey_outro_text,
                  helpText: tr.form_field_measurement_survey_outro_text_tooltip,
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(left: 3.0),
                  child: Opacity(
                    opacity: ThemeConfig.kMuteFadeFactor,
                    child: Tooltip(
                      message: "Use html to style your content",
                      child: Hyperlink(
                        text: "styleable",
                        onClick: () => setState(() {
                          isStylingInformationDismissed = !isStylingInformationDismissed;
                        }),
                        visitedColor: null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            input: ReactiveTextField(
              formControl: widget.formViewModel.surveyOutroTextControl,
              decoration: InputDecoration(hintText: tr.form_field_measurement_survey_outro_text_hint),
              inputFormatters: [
                LengthLimitingTextInputFormatter(2000),
              ],
              validationMessages: widget.formViewModel.surveyOutroTextControl.validationMessages,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 5,
            ),
          ),
        ]),
        HtmlStylingBanner(
          isDismissed: isStylingInformationDismissed,
          onDismissed: onDismissedCallback,
        ),
        const SizedBox(height: 28.0),
        ReactiveFormConsumer(
            // [ReactiveFormConsumer] is needed to to rerender when descendant controls are updated
            // By default, ReactiveFormArray only updates when adding/removing controls
            builder: (context, form, child) {
          return ReactiveFormArray(
            formArray: widget.formViewModel.questionsArray,
            builder: (context, formArray, child) {
              return FormArrayTable<QuestionFormViewModel>(
                control: widget.formViewModel.questionsArray,
                items: widget.formViewModel.questionModels,
                onSelectItem: (viewModel) => _onSelectItem(viewModel, context, ref),
                getActionsAt: (viewModel, _) => widget.formViewModel.availablePopupActions(viewModel),
                onNewItem: () => _onNewItem(context, ref),
                onNewItemLabel: tr.form_array_measurement_survey_questions_new,
                rowTitle: (viewModel) => viewModel.formData?.questionText ?? '',
                sectionTitle: tr.form_array_measurement_survey_questions,
                emptyIcon: Icons.content_paste_off_rounded,
                emptyTitle: tr.form_array_measurement_survey_questions_empty_title,
                emptyDescription: tr.form_array_measurement_survey_questions_empty_description,
                hideLeadingTrailingWhenEmpty: true,
                rowPrefix: (context, viewModel, rowIdx) {
                  return Row(
                    children: [
                      Tooltip(
                        message: viewModel.questionType.string,
                        child: Icon(
                          viewModel.questionType.icon,
                          color: ThemeConfig.dropdownMenuItemTheme(theme).iconTheme!.color,
                          size: ThemeConfig.dropdownMenuItemTheme(theme).iconTheme!.size,
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
        const SizedBox(height: 28.0),
        ScheduleControls(formViewModel: widget.formViewModel),
      ],
    );
  }

  _onNewItem(BuildContext context, WidgetRef ref) {
    final routeArgs = widget.formViewModel.buildNewFormRouteArgs();
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  _onSelectItem(QuestionFormViewModel item, BuildContext context, WidgetRef ref) {
    final routeArgs = widget.formViewModel.buildFormRouteArgs(item);
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showSidesheetWithArgs(SurveyQuestionFormRouteArgs routeArgs, BuildContext context, WidgetRef ref) {
    final surveyQuestionFormViewModel = ref.read(surveyQuestionFormViewModelProvider(routeArgs));
    showFormSideSheet<QuestionFormViewModel>(
      context: context,
      formViewModel: surveyQuestionFormViewModel,
      formViewBuilder: (formViewModel) => SurveyQuestionFormView(formViewModel: formViewModel),
      ignoreAppBar: true,
    );
  }
}
