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
    
    // Add the view model to the collection
    conditionFormViewModels.add(conditionVm);
    
    // Update the value change streams
    _updateConditionsValueChangesStream();
    
    // Immediately update the condition to make sure changes are propagated
    updateCondition();
    
    print('Added condition, now have ${conditionFormViewModels.formViewModels.length} conditions');
    print('Form array now has ${conditionsArray.controls.length} controls');
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
    print('Updating condition with composite: ${composite?.toJson()}');
    
    // Check if we have any conditions to save
    if (composite != null && composite.expressions.isNotEmpty) {
      // Create a new QuestionConditional with the composite expression
      final conditional = QuestionConditional.withCondition(composite);
      
      // Set the value on the parent control
      questionConditionalControl.value = conditional;
      
      // Ensure the parent control is marked as dirty to trigger value propagation
      questionConditionalControl.markAsDirty();
      
      print('Set questionConditionalControl.value: ${questionConditionalControl.value?.condition.toJson()}');
    } else {
      // No conditions, set to null
      questionConditionalControl.value = null;
      questionConditionalControl.markAsDirty();
      print('Set questionConditionalControl.value to null');
    }
    
    // Mark this form group as changed too
    markFormGroupChanged();
  }

  void _updateConditionsValueChangesStream() {
    _conditionsValueChangesSubscription?.cancel();

    // Create streams for all view models' forms and the logic type control
    final List<Stream> streams = [];
    
    // Add the logic type control to the streams
    streams.add(logicTypeControl.valueChanges.distinct());
    
    // Listen to the form array changes
    streams.add(conditionsArray.valueChanges.distinct());
    
    for (final viewModel in conditionFormViewModels.formViewModels) {
      // Listen to form value changes
      streams.add(viewModel.form.valueChanges.distinct());
      
      // Also listen to each control individually for more granular updates
      streams.add(viewModel.questionIdControl.valueChanges.distinct());
      streams.add(viewModel.comparatorControl.valueChanges.distinct());
      streams.add(viewModel.valueControl.valueChanges.distinct());
    }

    if (streams.isEmpty) {
      _conditionsValueChangesStream = const Stream<void>.empty();
    } else {
      _conditionsValueChangesStream =
          StreamGroup.merge(streams).asBroadcastStream();
      _conditionsValueChangesSubscription =
          _conditionsValueChangesStream.listen((_) {
        print('Condition value changed, updating condition');
        // First update the composite expression by building it from all form data
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
