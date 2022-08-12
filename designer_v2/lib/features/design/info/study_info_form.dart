import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

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
  String get id => throw UnimplementedError();

  @override
  Study apply(Study study) {
    // TODO: implement apply
    throw UnimplementedError();
  }

  @override
  StudyInfoFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
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
