import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/validation.dart';

class StudyInfoFormViewModel extends FormViewModel<StudyInfoFormData> {
  StudyInfoFormViewModel({
    required this.study,
    super.delegate,
    super.formData,
    super.autosave = true,
    super.validationSet = StudyFormValidationSet,
  });

  final Study study;

  // - Form fields

  final FormControl<String> titleControl = FormControl();
  final FormControl<IconOption> iconControl = FormControl();
  final FormControl<String> descriptionControl = FormControl();
  final FormControl<String> organizationControl = FormControl();
  final FormControl<String> reviewBoardControl = FormControl();
  final FormControl<String> reviewBoardNumberControl =
      FormControl();
  final FormControl<String> researchersControl = FormControl();
  final FormControl<String> emailControl = FormControl();
  final FormControl<String> websiteControl = FormControl();
  final FormControl<String> phoneControl = FormControl();

  @override
  FormGroup get form => FormGroup({
    'title': titleControl,
    'icon': iconControl,
    'description': descriptionControl,
    'organization': organizationControl,
    'institutionalReviewBoard': reviewBoardControl,
    'institutionalReviewBoardNumber': reviewBoardNumberControl,
    'researchers': researchersControl,
    'email': emailControl,
    'website': websiteControl,
    'phone': phoneControl,
  });

  @override
  void setControlsFrom(StudyInfoFormData data) {
    titleControl.value = data.title;
    iconControl.value = IconOption(data.iconName);
    descriptionControl.value = data.description;
    organizationControl.value = data.contactInfoFormData.organization;
    reviewBoardControl.value =
        data.contactInfoFormData.institutionalReviewBoard;
    reviewBoardNumberControl.value =
        data.contactInfoFormData.institutionalReviewBoardNumber;
    researchersControl.value = data.contactInfoFormData.researchers;
    emailControl.value = data.contactInfoFormData.email;
    websiteControl.value = data.contactInfoFormData.website;
    phoneControl.value = data.contactInfoFormData.phone;
  }

  @override
  StudyInfoFormData buildFormData() {
    return StudyInfoFormData(
      title: titleControl.value!, // required
      iconName: iconControl.value?.name ?? '',
      description: descriptionControl.value,
      contactInfoFormData: StudyContactInfoFormData(
        organization: organizationControl.value,
        institutionalReviewBoard: reviewBoardControl.value,
        institutionalReviewBoardNumber:
            reviewBoardNumberControl.value,
        researchers: researchersControl.value,
        email: emailControl.value,
        website: websiteControl.value,
        phone: phoneControl.value,
      )
    );
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // unused

  // - Validation

  @override
  FormValidationConfigSet get validationConfig => {
    // TODO title.length, description.length, phoneFormat
    StudyFormValidationSet.draft: [
      titleRequired, descriptionRequired,
      emailFormat, websiteFormat
    ],
    StudyFormValidationSet.publish: [
      titleRequired, descriptionRequired, iconRequired, organizationRequired,
      reviewBoardRequired, reviewBoardNumberRequired, researchersRequired,
      emailRequired, phoneRequired,
      emailFormat, websiteFormat
    ],
    StudyFormValidationSet.test: [
      titleRequired, descriptionRequired, emailRequired
    ],
  };

  get titleRequired => FormControlValidation(
      control: titleControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'The study title must not be empty'.hardcoded,
      }
  );
  get descriptionRequired => FormControlValidation(
      control: descriptionControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'The study description must not be empty'.hardcoded,
      }
  );
  get iconRequired => FormControlValidation(
      control: iconControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'You must select an icon for your study'.hardcoded,
      }
  );
  get organizationRequired => FormControlValidation(
      control: organizationControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'The responsible organization must not be empty'.hardcoded,
      }
  );
  get reviewBoardRequired => FormControlValidation(
      control: reviewBoardControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'You must specify the responsible review board for your study'.hardcoded,
      }
  );
  get reviewBoardNumberRequired => FormControlValidation(
      control: reviewBoardNumberControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'You must provide a review board protocol number for your study'.hardcoded,
      }
  );
  get researchersRequired => FormControlValidation(
      control: researchersControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'You must specify the researcher(s) responsible for the study'.hardcoded,
      }
  );
  get emailRequired => FormControlValidation(
      control: emailControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'You must specify a contact email'.hardcoded,
      }
  );
  get phoneRequired => FormControlValidation(
      control: phoneControl,
      validators: [Validators.required],
      validationMessages: {
        ValidationMessage.required: (error) => 'You must specify a phone number for participants to contact'.hardcoded,
      }
  );
  get emailFormat => FormControlValidation(
      control: emailControl,
      validators: [Validators.email],
      validationMessages: {
        'email': (error) => 'Please enter a valid contact email address'.hardcoded,
      }
  );
  get websiteFormat => FormControlValidation(
      control: websiteControl,
      validators: [Validators.pattern(Patterns.url)],
      validationMessages: {
        'pattern': (error) => 'Please enter a valid contact website URL'.hardcoded,
      }
  );
}
