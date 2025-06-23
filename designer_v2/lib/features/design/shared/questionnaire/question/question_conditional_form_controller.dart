import 'dart:async';

import 'package:async/async.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';

abstract class IConditionalQuestionProperties {
  String get currentQuestionId;
  CompositeExpression? get compositeExpression;
  bool get isReadonly; // Added this line

  FormControl<LogicType> get logicTypeControl;
  FormArray<ConditionRowFormViewModel> get conditionsArray;
  FormControl<QuestionConditional<dynamic>?> get questionConditionalControl;

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
  FormArray<ConditionRowFormViewModel> conditionsArray =
      FormArray<ConditionRowFormViewModel>([]);

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
    for (final control in conditionsArray.controls) {
      final expression = control.value?.buildExpression();
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
    conditionsArray
        .add(FormControl<ConditionRowFormViewModel>(value: conditionVm));
    _updateConditionsValueChangesStream();
    markFormGroupChanged();
  }

  @override
  void updateCondition() {
    final composite = compositeExpression;
    if (composite != null) {
      questionConditionalControl.value =
          QuestionConditional<bool>.withCondition(composite);
    } else {
      questionConditionalControl.value = null;
    }
    markFormGroupChanged();
  }

  @override
  void removeCondition(int index) {
    conditionsArray.removeAt(index);
    _updateConditionsValueChangesStream();
    markFormGroupChanged();
  }

  void _updateConditionsValueChangesStream() {
    _conditionsValueChangesSubscription?.cancel();

    final streams = conditionsArray.controls
        .map((control) => control.value!.form.valueChanges)
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
  FormGroup get form => FormGroup({
        'logicType': logicTypeControl,
        'conditions': conditionsArray,
      });

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
      conditionsArray.clear();
      for (final expression in compositeExpression.expressions) {
        addCondition(initialExpression: expression);
      }
    } else {
      logicTypeControl.value = LogicType.and;
      conditionsArray.clear();
    }
  }

  @override
  dynamic buildFormData() {
    final composite = compositeExpression ??
        CompositeExpression(logicType: LogicType.and, expressions: []);
    return QuestionConditional<bool>.withCondition(composite);
  }
}
