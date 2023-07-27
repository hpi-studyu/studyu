import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/styling_information.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/bool_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/choice_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/question_form_wrapper.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/controllers/scale_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/views/bool_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/views/choice_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/views/scale_question_form_view.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

/// Wrapper that dispatches to the appropriate widget for the corresponding
/// [SurveyQuestionType] as given by [formViewModel.questionType]
class SurveyQuestionFormView extends ConsumerStatefulWidget {
  const SurveyQuestionFormView({required this.modelWrapper, this.isHtmlStyleable = true, super.key});

  final QuestionFormViewModelWrapper modelWrapper;
  final bool isHtmlStyleable;

  @override
  ConsumerState<SurveyQuestionFormView> createState() => _SurveyQuestionFormViewState();
}

class _SurveyQuestionFormViewState extends ConsumerState<SurveyQuestionFormView> {
  static final List<FormControlOption<SurveyQuestionType>> _questionTypeControlOptions =
    QuestionFormData.questionTypeFormDataFactories.keys
      .map((questionType) => FormControlOption(questionType, questionType.string))
      .toList();

  QuestionFormViewModel get formViewModel => widget.modelWrapper.model;

  late bool isQuestionHelpTextFieldVisible = formViewModel.questionInfoTextControl.value?.isNotEmpty ?? false;
  bool isStylingInformationDismissed = true;

  onDismissedCallback() => setState(() {
        isStylingInformationDismissed = !isStylingInformationDismissed;
      });

  WidgetBuilder get questionTypeBodyBuilder {
    final Map<SurveyQuestionType, WidgetBuilder> questionTypeWidgets = {
      SurveyQuestionType.choice: (_) => ChoiceQuestionFormView(formViewModel: formViewModel as ChoiceQuestionFormViewModel),
      SurveyQuestionType.bool: (_) => BoolQuestionFormView(formViewModel: formViewModel as BoolQuestionFormViewModel),
      SurveyQuestionType.scale: (_) => ScaleQuestionFormView(formViewModel: formViewModel as ScaleQuestionFormViewModel),
    };
    final questionType = widget.modelWrapper.type;

    if (!questionTypeWidgets.containsKey(questionType)) {
      throw Exception("Failed to build widget for SurveyQuestionType $questionType because"
          "there is no registered WidgetBuilder");
    }
    final builder = questionTypeWidgets[questionType]!;
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(builder: (context, formGroup, child) {
      // Wrap everything in a [ReactiveFormConsumer] for convenience so that the
      // sidesheet content is re-rendered when the form changes
      //
      // Note: if this becomes a performance issue, remove the
      // ReactiveFormConsumer here & use consumers / listeners selectively for
      // the UI parts that need to be rebuild
      return PointerInterceptor(
          child: Column(
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
          if (widget.isHtmlStyleable)
            HtmlStylingBanner(
              isDismissed: isStylingInformationDismissed,
              onDismissed: onDismissedCallback,
            ),
          const SizedBox(height: 24.0),
          _buildResponseTypeHeader(context),
          const SizedBox(height: 16.0),
          questionTypeBodyBuilder(context),
        ],
      ));
    });
  }

  String? getEnv(String name) {
    return null;
  }

  _buildResponseTypeHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: tr.form_field_question_response_options,
              labelHelpText: tr.form_field_question_response_options_tooltip,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              // TODO: extract custom dropdown component with theme + focus fix
              input: Theme(
                data: theme.copyWith(inputDecorationTheme: ThemeConfig.dropdownInputDecorationTheme(theme)),
                child: ReactiveDropdownField<SurveyQuestionType>(
                  formControl: widget.modelWrapper.questionTypeControl,
                  items: _questionTypeControlOptions.map((option) {
                    final menuItemTheme = ThemeConfig.dropdownMenuItemTheme(theme);
                    final iconTheme = menuItemTheme.iconTheme ?? theme.iconTheme;
                    return DropdownMenuItem(
                      value: option.value,
                      child: Row(
                        children: [
                          (option.value.icon != null)
                              ? Icon(option.value.icon,
                                  size: iconTheme.size, color: iconTheme.color, shadows: iconTheme.shadows)
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
          text: tr.form_field_question_response_options_description,
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
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                FormLabel(
                  labelText: tr.form_field_question,
                  helpText: tr.form_field_question_tooltip,
                ),
                if (widget.isHtmlStyleable) const SizedBox(width: 8),
                if (widget.isHtmlStyleable)
                  Opacity(
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
              ]),
              (!isQuestionHelpTextFieldVisible && !formViewModel.isReadonly)
                  ? Opacity(
                      opacity: ThemeConfig.kMuteFadeFactor,
                      child: Tooltip(
                        message: tr.form_field_question_help_text_add_tooltip,
                        child: Hyperlink(
                          text: "+ ${tr.form_field_question_help_text_add}",
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
            validationMessages: formViewModel.questionTextControl.validationMessages,
            minLines: 3,
            maxLines: 3,
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
          label: tr.form_field_question_help_text,
          labelHelpText: tr.form_field_question_help_text_tooltip,
          labelBuilder: (context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              FormLabel(
                labelText: tr.form_field_question_help_text,
                helpText: tr.form_field_question_help_text_tooltip,
              ),
              if (widget.isHtmlStyleable) const SizedBox(width: 8),
              if (widget.isHtmlStyleable)
                Opacity(
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
            ])
          ]),
          input: ReactiveTextField(
            formControl: formViewModel.questionInfoTextControl,
            validationMessages: formViewModel.questionInfoTextControl.validationMessages,
            minLines: 3,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: tr.form_field_question_help_text_hint,
              //helperText: "", // reserve space
            ),
          ),
        ),
      ],
    );
  }
}
