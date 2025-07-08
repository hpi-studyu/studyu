import 'dart:async';

import 'package:async/async.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';

abstract class IConditionalQuestionProperties {
  String get currentQuestionId;
  CompositeExpression? get compositeExpression;
  bool get isReadonly;

  FormControl<LogicType> get logicTypeControl;
  FormArray get conditionsArray;
  FormControl<QuestionConditional<dynamic>?> get questionConditionalControl;
  
  List<ConditionRowFormViewModel> get conditionModels;

  void addCondition({Expression? initialExpression});
  void updateCondition();
  void removeCondition(int index);

  Stream<void> get conditionsValueChanges;
}

class ConditionalQuestionFormViewModel extends FormViewModel
    implements IConditionalQuestionProperties {
  ConditionalQuestionFormViewModel({
    required this.currentQuestionId,
    required this.questionConditionalControl,
  });

  @override
  final String currentQuestionId;

  @override
  final FormControl<QuestionConditional<dynamic>?> questionConditionalControl;

  @override
  FormControl<LogicType> logicTypeControl = FormControl<LogicType>(
    value: LogicType.and,
  );

  @override
  late final FormArray conditionsArray = FormArray([]);

  late final FormViewModelCollection<ConditionRowFormViewModel,
          ConditionRowFormData> conditionFormViewModels =
      FormViewModelCollection([], conditionsArray);

  @override
  List<ConditionRowFormViewModel> get conditionModels =>
      conditionFormViewModels.formViewModels;

  @override
  late final FormGroup form = FormGroup({
    'logicType': logicTypeControl,
    'conditions': conditionsArray,
  });

  Stream<void> _conditionsValueChangesStream = const Stream<void>.empty();
  StreamSubscription<void>? _conditionsValueChangesSubscription;

  @override
  Stream<void> get conditionsValueChanges =>
      _conditionsValueChangesStream.isBroadcast
          ? _conditionsValueChangesStream
          : _conditionsValueChangesStream.asBroadcastStream();

  @override
  CompositeExpression? get compositeExpression {
    final List<Expression> currentExpressions = [];
    for (final formViewModel in conditionFormViewModels.formViewModels) {
      final expression = formViewModel.buildFormData().buildExpression();
      if (expression != null) {
        currentExpressions.add(expression);
      }
    }
    if (currentExpressions.isEmpty) {
      return null;
    }
    return CompositeExpression(
      logicType: logicTypeControl.value ?? LogicType.and,
      expressions: currentExpressions,
    );
  }

  @override
  void addCondition({Expression? initialExpression}) {
    final conditionVm = ConditionRowFormViewModel(
      currentQuestionId: currentQuestionId,
      initialExpression: initialExpression,
    );

    if (initialExpression != null) {
      final formData = ConditionRowFormData(
        questionId: conditionVm.extractQuestionId(initialExpression),
        comparator: conditionVm.extractComparator(initialExpression),
        value: conditionVm.extractValue(initialExpression),
      );
      conditionVm.setControlsFrom(formData);
    }
    conditionFormViewModels.add(conditionVm);
    _updateConditionsValueChangesStream();
  }

  @override
  void removeCondition(int index) {
    conditionFormViewModels
        .remove(conditionFormViewModels.formViewModels[index]);
    _updateConditionsValueChangesStream();
    markFormGroupChanged();
  }

  @override
  void read([dynamic formData]) {
    conditionFormViewModels.read();
    super.read(formData);
  }

  @override
  void updateCondition() {
    final composite = compositeExpression;
    if (composite != null) {
      questionConditionalControl.value =
          QuestionConditional.withCondition(composite);
    } else {
      questionConditionalControl.value = null;
    }
    markFormGroupChanged();
  }

  void _updateConditionsValueChangesStream() {
    _conditionsValueChangesSubscription?.cancel();

    final streams = conditionFormViewModels.formViewModels
        .map((viewModel) =>
            viewModel.form.valueChanges.map((formData) => formData).distinct())
        .toList();

    if (streams.isEmpty) {
      _conditionsValueChangesStream = const Stream<void>.empty();
    } else {
      _conditionsValueChangesStream =
          StreamGroup.merge(streams).asBroadcastStream();
      _conditionsValueChangesSubscription =
          _conditionsValueChangesStream.listen((_) {
        updateCondition();
      });
    }
  }

  @override
  void dispose() {
    _conditionsValueChangesSubscription?.cancel();
    super.dispose();
  }

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: 'Create Conditional',
        FormMode.edit: 'Edit Conditional',
        FormMode.readonly: 'View Conditional',
      };

  @override
  void setControlsFrom(dynamic data) {
    final conditional = questionConditionalControl.value;
    if (conditional != null) {
      final compositeExpression = conditional.condition;
      logicTypeControl.value = compositeExpression.logicType;

      conditionFormViewModels.reset(null);

      for (final expression in compositeExpression.expressions) {
        addCondition(initialExpression: expression);
      }
    } else {
      logicTypeControl.value = LogicType.and;
      conditionFormViewModels.reset(null);
    }
    _updateConditionsValueChangesStream();
  }

  @override
  QuestionConditional buildFormData() {
    print('Building QuestionConditional from form data');
    final composite = compositeExpression ??
        CompositeExpression(logicType: LogicType.and, expressions: []);
    return QuestionConditional.withCondition(composite);
  }
}
