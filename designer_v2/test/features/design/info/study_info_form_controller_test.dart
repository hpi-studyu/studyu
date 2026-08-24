import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  group('StudyInfoFormViewModel phone validation', () {
    late StudyInfoFormViewModel draftViewModel;
    late StudyInfoFormViewModel publishViewModel;

    setUp(() {
      final study = Study('study-id', 'owner-id');
      draftViewModel = StudyInfoFormViewModel(
        study: study,
        validationSet: StudyFormValidationSet.draft,
      );
      publishViewModel = StudyInfoFormViewModel(
        study: study,
        validationSet: StudyFormValidationSet.publish,
      );
    });

    test('allows arbitrary phone text in draft mode', () {
      draftViewModel.phoneControl.value = '123';

      draftViewModel.phoneControl.updateValueAndValidity();

      expect(draftViewModel.phoneControl.errors, isEmpty);
    });

    test('allows empty phone in draft mode', () {
      draftViewModel.phoneControl.value = '';

      draftViewModel.phoneControl.updateValueAndValidity();

      expect(draftViewModel.phoneControl.errors, isEmpty);
    });

    test('requires phone in publish mode', () {
      publishViewModel.phoneControl.value = '';

      publishViewModel.phoneControl.updateValueAndValidity();

      expect(
        publishViewModel.phoneControl.hasError(ValidationMessage.required),
        isTrue,
      );
    });
  });

  group('StudyInfoFormViewModel website validation', () {
    late StudyInfoFormViewModel viewModel;

    setUp(() {
      viewModel = StudyInfoFormViewModel(
        study: Study('study-id', 'owner-id'),
        validationSet: StudyFormValidationSet.draft,
      );
    });

    test('accepts supported website formats', () {
      for (final website in [
        'example.com',
        'https://example.com/path',
        'http://sub.example.org:8080/x',
      ]) {
        viewModel.websiteControl.value = website;
        viewModel.websiteControl.updateValueAndValidity();

        expect(
          viewModel.websiteControl.errors,
          isEmpty,
          reason: 'expected `$website` to be valid',
        );
      }
    });

    test('rejects unsupported website formats', () {
      for (final website in ['example', 'ftp://example.com', 'example .com']) {
        viewModel.websiteControl.value = website;
        viewModel.websiteControl.updateValueAndValidity();

        expect(
          viewModel.websiteControl.hasError(ValidationMessage.pattern),
          isTrue,
          reason: 'expected `$website` to be invalid',
        );
      }
    });
  });

  test('unknown saved icon names resolve to empty selection', () {
    final study = Study('study-id', 'owner-id')..iconName = 'missingLegacyIcon';
    final viewModel = StudyInfoFormViewModel(
      study: study,
      formData: StudyInfoFormData.fromStudy(study),
      validationSet: StudyFormValidationSet.draft,
    );

    expect(viewModel.iconControl.value, isNull);
  });
}
