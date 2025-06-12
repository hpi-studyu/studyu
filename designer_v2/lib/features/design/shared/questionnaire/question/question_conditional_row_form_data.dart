import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class ConditionRowFormData implements IStudyFormData {
  final String? questionId;
  final dynamic comparator;
  final dynamic value;

  const ConditionRowFormData({
    this.questionId,
    this.comparator,
    this.value,
  });

  // Creates a copy of this ConditionRowFormData with the given fields replaced
  ConditionRowFormData copyWith({
    String? questionId,
    dynamic comparator,
    dynamic value,
  }) {
    return ConditionRowFormData(
      questionId: questionId ?? this.questionId,
      comparator: comparator ?? this.comparator,
      value: value ?? this.value,
    );
  }

  @override
  IFormData copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  // TODO: implement id
  FormDataID get id => throw UnimplementedError();

  @override
  Study apply(Study study) {
    // TODO: implement apply
    throw UnimplementedError();
  }
}
