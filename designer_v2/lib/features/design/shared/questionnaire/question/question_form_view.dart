import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/bool_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/choice_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/scale_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';

/// Wrapper that dispatches to the appropriate widget for the corresponding
/// [SurveyQuestionType] as given by [formViewModel.questionType]
class SurveyQuestionFormView extends ConsumerStatefulWidget {
  const SurveyQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  ConsumerState<SurveyQuestionFormView> createState() =>
      _SurveyQuestionFormViewState();
}

class _SurveyQuestionFormViewState
    extends ConsumerState<SurveyQuestionFormView> {
  QuestionFormViewModel get formViewModel => widget.formViewModel;

  late bool isQuestionHelpTextFieldVisible =
      formViewModel.questionInfoTextControl.value?.isNotEmpty ?? false;

  WidgetBuilder get questionTypeBodyBuilder {
    final Map<SurveyQuestionType, WidgetBuilder> questionTypeWidgets = {
      SurveyQuestionType.choice: (_) =>
          ChoiceQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.bool: (_) =>
          BoolQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.scale: (_) =>
          ScaleQuestionFormView(formViewModel: formViewModel),
    };
    final questionType = formViewModel.questionType;

    if (!questionTypeWidgets.containsKey(questionType)) {
      throw Exception(
          "Failed to build widget for SurveyQuestionType $questionType because"
          "there is no registered WidgetBuilder");
    }
    final builder = questionTypeWidgets[questionType]!;
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQuestionText(context),
        (isQuestionHelpTextFieldVisible)
            ? Column(
                children: [
                  const SizedBox(height: 16.0),
                  _buildQuestionHelpText(context),
                ],
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 24.0),
        _buildResponseTypeHeader(context),
        const SizedBox(height: 16.0),
        ReactiveValueListenableBuilder(
          // re-renders when question type changes
          formControl: formViewModel.questionTypeControl,
          builder: (context, control, child) {
            return questionTypeBodyBuilder(context);
          },
        ),
      ],
    );
  }

  _buildResponseTypeHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: "Response options".hardcoded,
              labelHelpText:
                  "Define the options that participants can answer your question with"
                      .hardcoded,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              // TODO: extract custom dropdown component with theme + focus fix
              input: Theme(
                data: theme.copyWith(
                    inputDecorationTheme:
                        ThemeConfig.dropdownInputDecorationTheme(theme)),
                child: ReactiveDropdownField<SurveyQuestionType>(
                  formControl: formViewModel.questionTypeControl,
                  onChanged: (_) {
                    // prevent gray focus box from being rendered after
                    // the dropdown was interacted with + scrolled out of view
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  items: formViewModel.questionTypeControlOptions.map((option) {
                    final menuItemTheme =
                        ThemeConfig.dropdownMenuItemTheme(theme);
                    final iconTheme =
                        menuItemTheme.iconTheme ?? theme.iconTheme;

                    return DropdownMenuItem(
                      value: option.value,
                      child: Row(
                        children: [
                          (option.value.icon != null)
                              ? Icon(option.value.icon,
                                  size: iconTheme?.size,
                                  color: iconTheme?.color,
                                  shadows: iconTheme?.shadows)
                              : const SizedBox.shrink(),
                          const SizedBox(width: 16.0),
                          Text(option.label)
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        TextParagraph(
          text: "Choose the response type that best matches your question and "
                  "define the response options according to the data you want "
                  "to collect."
              .hardcoded,
          style: ThemeConfig.bodyTextMuted(theme),
        )
      ],
    );
  }

  _buildQuestionText(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          control: formViewModel.questionTextControl,
          labelBuilder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FormLabel(
                labelText: "Your question".hardcoded,
                //labelTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                helpText:
                    "Enter the question that the participant will be prompted with in the app"
                        .hardcoded,
              ),
              (!isQuestionHelpTextFieldVisible && !formViewModel.isReadonly)
                  ? Opacity(
                      opacity: ThemeConfig.kMuteFadeFactor,
                      child: Tooltip(
                        message:
                            "Enter an additional text that is shown with a help icon next to the question in the app"
                                .hardcoded,
                        child: Hyperlink(
                          text: "+ Add a help text",
                          onClick: () => setState(() {
                            isQuestionHelpTextFieldVisible = true;
                          }),
                          visitedColor: null,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          input: ReactiveTextField(
            formControl: formViewModel.questionTextControl,
            validationMessages:
                formViewModel.questionTextControl.validationMessages,
            minLines: 3,
            maxLines: 3,
            /*
            decoration: InputDecoration(
              hintText: "Enter the question you want to ask the participant"
                  .hardcoded,
              //helperText: "", // reserve space
            ),
             */
          ),
        ),
      ],
    );
  }

  _buildQuestionHelpText(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          control: formViewModel.questionInfoTextControl,
          label: "Question help text".hardcoded,
          labelHelpText:
              "Enter a text that is shown with a help icon next to the question in the app"
                  .hardcoded,
          input: ReactiveTextField(
            formControl: formViewModel.questionInfoTextControl,
            validationMessages:
                formViewModel.questionInfoTextControl.validationMessages,
            minLines: 3,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  "Provide additional context, help or instructions for the question"
                      .hardcoded,
              //helperText: "", // reserve space
            ),
          ),
        ),
      ],
    );
  }
}
