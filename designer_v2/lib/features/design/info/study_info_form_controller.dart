import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/study_tag_repository.dart';
import 'package:studyu_designer_v2/utils/validation.dart';

class StudyInfoFormViewModel extends FormViewModel<StudyInfoFormData> {
  StudyInfoFormViewModel({
    required this.study,
    required this.studyTagsRepository,
    super.delegate,
    super.formData,
    super.autosave = true,
    super.validationSet = StudyFormValidationSet,
  });

  final Study study;
  final IStudyTagRepository studyTagsRepository;

  // - Form fields

  final FormControl<String> titleControl = FormControl();
  final FormControl<IconOption> iconControl = FormControl();
  final FormControl<String> descriptionControl = FormControl();
  final FormControl<List<String>> studyTagsControl = FormControl(
    validators: [
      const TagsValidator(),
    ],
  );
  final FormControl<String> organizationControl = FormControl();
  final FormControl<String> reviewBoardControl = FormControl();
  final FormControl<String> reviewBoardNumberControl = FormControl();
  final FormControl<String> researchersControl = FormControl();
  final FormControl<String> emailControl = FormControl();
  final FormControl<String> websiteControl = FormControl();
  final FormControl<String> phoneControl = FormControl();
  final FormControl<String> additionalInfoControl = FormControl();

  @override
  late final FormGroup form = FormGroup({
    'title': titleControl,
    'icon': iconControl,
    'description': descriptionControl,
    'studyTags': studyTagsControl,
    'organization': organizationControl,
    'institutionalReviewBoard': reviewBoardControl,
    'institutionalReviewBoardNumber': reviewBoardNumberControl,
    'researchers': researchersControl,
    'email': emailControl,
    'website': websiteControl,
    'phone': phoneControl,
    'additionalInfo': additionalInfoControl
  });

  @override
  void setControlsFrom(StudyInfoFormData data) {
    titleControl.value = data.title;
    iconControl.value = IconOption(data.iconName);
    descriptionControl.value = data.description;
    studyTagsControl.value = data.studyTags.map((e) => e.name).toList();
    organizationControl.value = data.contactInfoFormData.organization;
    reviewBoardControl.value = data.contactInfoFormData.institutionalReviewBoard;
    reviewBoardNumberControl.value = data.contactInfoFormData.institutionalReviewBoardNumber;
    researchersControl.value = data.contactInfoFormData.researchers;
    emailControl.value = data.contactInfoFormData.email;
    websiteControl.value = data.contactInfoFormData.website;
    phoneControl.value = data.contactInfoFormData.phone;
    additionalInfoControl.value = data.contactInfoFormData.additionalInfo;
  }

  @override
  StudyInfoFormData buildFormData() {
    return StudyInfoFormData(
        title: titleControl.value!, // required
        iconName: iconControl.value?.name ?? '',
        description: descriptionControl.value,
        studyTags: studyTagsControl.value!.map((e) => study.studyTags.firstWhere((element) => element.name == e)).toList(),
        contactInfoFormData: StudyContactInfoFormData(
          organization: organizationControl.value,
          institutionalReviewBoard: reviewBoardControl.value,
          institutionalReviewBoardNumber: reviewBoardNumberControl.value,
          researchers: researchersControl.value,
          email: emailControl.value,
          website: websiteControl.value,
          phone: phoneControl.value,
          additionalInfo: additionalInfoControl.value,
        ));
  }

  /*@override
  Future save() {
    return super.save();
  }*/

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // unused

  // - Validation

  @override
  FormValidationConfigSet get sharedValidationConfig => {
        // TODO phoneFormat
        StudyFormValidationSet.draft: [titleRequired, emailFormat, websiteFormat, tagsFormat],
        StudyFormValidationSet.publish: [
          titleRequired,
          descriptionRequired,
          iconRequired,
          organizationRequired,
          reviewBoardRequired,
          reviewBoardNumberRequired,
          researchersRequired,
          emailRequired,
          phoneRequired,
          emailFormat,
          websiteFormat,
          tagsFormat,
        ],
        StudyFormValidationSet.test: [titleRequired],
      };

  get titleRequired => FormControlValidation(control: titleControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_study_title_required,
      });
  get descriptionRequired => FormControlValidation(control: descriptionControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_study_description_required,
      });
  get iconRequired => FormControlValidation(control: iconControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_study_icon_required,
      });
  get organizationRequired => FormControlValidation(control: organizationControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_organization_required,
      });
  get reviewBoardRequired => FormControlValidation(control: reviewBoardControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_review_board_required,
      });
  get reviewBoardNumberRequired => FormControlValidation(control: reviewBoardNumberControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_review_board_number_required,
      });
  get researchersRequired => FormControlValidation(control: researchersControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_researchers_required,
      });
  get emailRequired => FormControlValidation(control: emailControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_contact_email_required,
      });
  get phoneRequired => FormControlValidation(control: phoneControl, validators: [
        Validators.required
      ], validationMessages: {
        ValidationMessage.required: (error) => tr.form_field_contact_phone_required,
      });
  get emailFormat => FormControlValidation(control: emailControl, validators: [
        Validators.email
      ], validationMessages: {
        'email': (error) => tr.form_field_contact_email_email,
      });
  get websiteFormat => FormControlValidation(control: websiteControl, validators: [
        Validators.pattern(Patterns.url)
      ], validationMessages: {
        'pattern': (error) => tr.form_field_website_pattern,
      });

  get tagsFormat => FormControlValidation(control: studyTagsControl, validators: [
        const TagsValidator(),
      ], validationMessages: {
        'validateTags': (error) => tr.form_field_study_tags_error_length(3),
      });
}

class TagsValidator extends Validator<dynamic> {
  const TagsValidator() : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    print("accessing validator");
    return control.isNotNull &&
        control.value is List &&
        control.value.length <= 3
    // todo check if studyTagsControl already contains the new tag
        ? null
        : {'validateTags': true};
  }
}
