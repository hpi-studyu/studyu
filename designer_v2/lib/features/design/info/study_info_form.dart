import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';

class StudyInfoFormData implements IStudyFormData {
  final String title;

  StudyInfoFormData({
    required this.title,
  });

  factory StudyInfoFormData.fromStudy(Study study) {
    return StudyInfoFormData(
        title: study.title ?? '',
    );
  }

  @override
  Study apply(Study study) {
    // TODO: implement apply
    throw UnimplementedError();
  }
}

class StudyInfoFormViewModel extends FormViewModel<StudyInfoFormData> {

  StudyInfoFormViewModel({super.formData});

  // - Form fields

  final FormControl<String> titleControl = FormControl();
  // TODO: other controls

  @override
  FormGroup get form => FormGroup({
    'title': titleControl,
  });

  @override
  void setControlsFrom(StudyInfoFormData data) {
    //titleControl.value = data.title;
  }

  @override
  StudyInfoFormData buildFormData() {
    return StudyInfoFormData(
        title: titleControl.value!
    );
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError();
}
