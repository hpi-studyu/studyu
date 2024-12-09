import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';

import '../../forms/form_validation.dart';
import '../study_form_validation.dart';

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
        StudyFormValidationSet.publish: [],
        StudyFormValidationSet.test: [],
      };

  /*static Map<String, dynamic>? clientCredentialsValidator(
      AbstractControl<dynamic> control) {
    if (control is FormGroup) {
      final clientId = control.control('client_id').value as String?;
      final clientSecret = control.control('client_secret').value as String?;

      if ((clientId != null && clientId.isNotEmpty) &&
          (clientSecret == null || clientSecret.isEmpty)) {
        return {
          'clientSecretRequired':
              'Client secret is required when client ID is filled',
        } as Map<String, dynamic>;
      }

      if ((clientSecret != null && clientSecret.isNotEmpty) &&
          (clientId == null || clientId.isEmpty)) {
        return {
          'clientIdRequired':
              'Client ID is required when client secret is filled'
        } as Map<String, dynamic>;
      }
    }

    return null;
  }*/

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();
}
