import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class FitbitCredentialsFormData implements IStudyFormData {
  final String clientId;
  final String clientSecret;

  FitbitCredentialsFormData({
    required this.clientId,
    required this.clientSecret,
  });

  factory FitbitCredentialsFormData.fromStudy(Study study) {
    final fitbitCredentials = study.fitbitCredentials;
    return FitbitCredentialsFormData(
      clientId: fitbitCredentials?.fitbitCredentials.clientId ?? '',
      clientSecret: fitbitCredentials?.fitbitCredentials.clientSecret ?? '',
    );
  }

  @override
  Study apply(Study study) {
    final credentials =
        FitbitCredentials(clientId: clientId, clientSecret: clientSecret);

    study.fitbitCredentials = StudyFitbitCredentials(study.id, credentials);

    return study;
  }

  @override
  IFormData copy() {
    throw UnimplementedError();
  }

  @override
  FormDataID get id => throw UnimplementedError();
}
