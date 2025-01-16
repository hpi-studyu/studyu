import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';

class FitbitCredentialsFormViewModel
    extends FormViewModel<FitbitCredentialsFormData> {
  FitbitCredentialsFormViewModel({
    required this.study,
    super.delegate,
    super.formData,
    super.autosave = true,
    super.validationSet,
  });

  final Study study;

  // - Form fields

  final FormControl<String> clientIdControl = FormControl();
  final FormControl<String> clientSecretControl = FormControl();

  @override
  late final FormGroup form = FormGroup({
    'client_id': clientIdControl,
    'client_secret': clientSecretControl,
  });

  @override
  void setControlsFrom(FitbitCredentialsFormData data) {
    clientIdControl.value = data.clientId;
    clientSecretControl.value = data.clientSecret;
  }

  @override
  FitbitCredentialsFormData buildFormData() {
    return FitbitCredentialsFormData(
      clientId: clientIdControl.value ?? '',
      clientSecret: clientSecretControl.value ?? '',
    );
  }

  @override
  FormValidationConfigSet get sharedValidationConfig => {
        StudyFormValidationSet.draft: [],
        StudyFormValidationSet.publish: [fitbitCredentialsValidation],
        StudyFormValidationSet.test: [],
      };

  FormControlValidation get fitbitCredentialsValidation =>
      FormControlValidation(
        control: form,
        validators: [
          Validators.delegate(_validateFitbitCredentials),
        ],
        validationMessages: {
          'fitbitCredentialsRequired': (_) => 'Fitbit credentials are required',
        },
      );

  //TODO: translations
  Map<String, dynamic>? _validateFitbitCredentials(
      AbstractControl<dynamic> control) {
    final hasFitbitQuestion = study.observations.any((observation) {
      if (observation.type != 'questionnaire') return false;

      final questionnaire = observation as QuestionnaireTask;
      return questionnaire.questions.questions
          .any((question) => question is FitbitQuestion);
    });

    if (!hasFitbitQuestion) return null;

    if (control is FormGroup) {
      final clientId = control.control('client_id').value as String?;
      final clientSecret = control.control('client_secret').value as String?;

      if (clientId == null || clientId.isEmpty) {
        return {'fitbitCredentialsRequired': true};
      }

      if (clientSecret == null || clientSecret.isEmpty) {
        return {'fitbitCredentialsRequired': true};
      }
    }

    return null;
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();
}
