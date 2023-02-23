import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class ReportsFormData implements IStudyFormData {
  @override
  Study apply(Study study) {
    // TODO: implement apply
    throw UnimplementedError();
  }

  @override
  IFormData copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  // TODO: implement id
  FormDataID get id => throw UnimplementedError();

  static fromStudy(Study study) {}
}
