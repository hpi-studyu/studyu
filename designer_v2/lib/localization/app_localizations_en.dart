// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get studyu => 'StudyU';

  @override
  String get loading_message => 'Loading...';

  @override
  String get language => 'Language';

  @override
  String get language_select_tooltip => 'Select a language';

  @override
  String get locale_en => 'English';

  @override
  String get locale_de => 'German';

  @override
  String get navlink_error_home => 'Go back home';

  @override
  String get imprint => 'Legal notice';

  @override
  String get link_forgot_password => 'Forgot password?';

  @override
  String get link_signup_description => 'Don\'t have an account?';

  @override
  String get link_signup => 'Sign up';

  @override
  String get link_login_description => 'Already have an account?';

  @override
  String get link_login_description2 => 'Log into your workspace?';

  @override
  String get link_login => 'Sign in';

  @override
  String get action_button_login => 'Sign in';

  @override
  String get action_button_signup => 'Create account';

  @override
  String get action_button_password_reset => 'Reset password';

  @override
  String get signup_tos_intro => 'I have read and agree to StudyU\'s ';

  @override
  String get signup_tos_terms_of_service => 'terms of service ';

  @override
  String get signup_tos_and => 'and ';

  @override
  String get signup_tos_privacy_policy => 'privacy policy';

  @override
  String get signup_tos_outro => '';

  @override
  String get login_page_title => 'Sign in to your workspace';

  @override
  String get login_page_description =>
      'Accelerate your research with digital N-of-1 studies.';

  @override
  String get signup_page_title => 'Create your workspace';

  @override
  String get signup_page_description =>
      'Get started with digital N-of-1 studies for your research or clinical practice. Free, open source & open science!';

  @override
  String get password_forgot_page_title => 'Reset password';

  @override
  String get password_forgot_page_description =>
      'Enter the email associated with your account and we\'ll send an email with instructions to reset your password';

  @override
  String get password_recover_page_title => 'Set a new password';

  @override
  String get form_field_email => 'Email';

  @override
  String get form_field_email_hint => 'Email';

  @override
  String get form_field_password => 'Password';

  @override
  String get form_field_password_hint => 'Password';

  @override
  String get form_field_password_confirm => 'Confirm password';

  @override
  String get form_field_password_confirm_hint => 'Enter password again';

  @override
  String get form_field_email_invalid => 'Must enter a valid email';

  @override
  String get form_field_password_mustmatch => 'Both passwords must match';

  @override
  String form_field_password_minlength(num minLength) {
    return 'Passwords must have a minimum of $minLength characters';
  }

  @override
  String get form_field_password_new => 'New password';

  @override
  String get form_field_password_new_hint => 'Enter new password';

  @override
  String get form_field_password_new_confirm => 'Confirm new password';

  @override
  String get form_field_password_new_confirm_hint => 'Enter new password again';

  @override
  String get notification_password_reset_check_email =>
      'Check your email for a password reset link!';

  @override
  String get notification_password_reset_success =>
      'Password was reset successfully';

  @override
  String get notification_credentials_invalid => 'Invalid credentials';

  @override
  String get notification_user_already_registered => 'User already registered';

  @override
  String get navlink_my_studies => 'My Studies';

  @override
  String get navlink_shared_studies => 'Shared With Me';

  @override
  String get navlink_public_studies => 'Study Registry';

  @override
  String get navlink_public_studies_tooltip =>
      'The study registry is a public collection of studies conducted on the StudyU \nplatform. In the spirit of open science, it fosters collaboration and transparency \namong all researchers and clinicians on the platform.';

  @override
  String get navlink_public_studies_description =>
      'The study registry is a public collection of studies conducted on the StudyU platform. In the spirit of open science, it fosters collaboration and transparency among all researchers and clinicians on the platform.';

  @override
  String get navlink_account_settings => 'Settings';

  @override
  String get navlink_logout => 'Sign out';

  @override
  String get study_status_draft => 'Draft';

  @override
  String get study_status_draft_description =>
      'This study is still being drafted.';

  @override
  String get study_status_running => 'Live';

  @override
  String get study_status_running_description =>
      'This study is currently in progress.';

  @override
  String get study_status_closed => 'Closed';

  @override
  String get study_status_closed_description =>
      'This study has been completed.\nNew participants can no longer enroll.';

  @override
  String get participation_open_who => 'Everyone';

  @override
  String get participation_open_who_description =>
      'All StudyU users may enroll to the study in the StudyU App.';

  @override
  String get participation_invite_who => 'Invite-only';

  @override
  String get participation_invite_who_description =>
      'Only participants with an invite code can enroll in the StudyU App.';

  @override
  String get participation_open_as_adjective => 'open to everyone';

  @override
  String get participation_invite_as_adjective => 'invite-only';

  @override
  String get participation_open_launch_description =>
      'Once launched, all users of the StudyU platform can enroll in your study as long as they meet your screening criteria.';

  @override
  String get participation_invite_launch_description =>
      'Once launched, you can invite participants by sending them a code to access and enroll in your study';

  @override
  String get phase_sequence_alternating => 'Alternating (AB AB)';

  @override
  String get phase_sequence_counterbalanced => 'Counterbalanced (AB BA)';

  @override
  String get phase_sequence_random => 'Random';

  @override
  String get phase_sequence_custom => 'Custom';

  @override
  String get phase_sequence_custom_label => 'Custom sequence';

  @override
  String get phase_sequence_custom_label_help =>
      'Enter a sequence of interventions by using the letters A and B';

  @override
  String get form_enrollment_option_open => 'Open';

  @override
  String get form_enrollment_option_invite => 'Private (Invite-only)';

  @override
  String get notification_code_deleted => 'Invite code deleted';

  @override
  String get notification_code_clipboard => 'Code copied to clipboard';

  @override
  String get action_button_new_study => 'New study';

  @override
  String get search => 'Search';

  @override
  String get studies_list_header_title => 'Title';

  @override
  String get studies_list_header_status => 'Status';

  @override
  String get studies_list_header_participation => 'Participation';

  @override
  String get studies_list_header_created_at => 'Created';

  @override
  String get studies_list_header_participants_enrolled => 'Enrolled';

  @override
  String get studies_list_header_participants_active => 'Active';

  @override
  String get studies_list_header_participants_completed => 'Completed';

  @override
  String get studies_not_found => 'No Studies found';

  @override
  String get modify_query => 'Modify your query';

  @override
  String get studies_empty => 'You don\'t have any studies yet';

  @override
  String get studies_empty_description =>
      'Build your own study from scratch or create a new draft copy from an already published study!';

  @override
  String get navlink_learn => 'Learn';

  @override
  String get navlink_study_design => 'Design';

  @override
  String get navlink_study_test => 'Test';

  @override
  String get navlink_study_recruit => 'Recruit';

  @override
  String get navlink_study_monitor => 'Monitor';

  @override
  String get navlink_study_analyze => 'Analyze';

  @override
  String get navlink_share => 'Share';

  @override
  String get navlink_study_design_info => 'Study Info';

  @override
  String get navlink_study_design_enrollment => 'Participation';

  @override
  String get navlink_study_design_interventions => 'Interventions';

  @override
  String get navlink_study_design_measurements => 'Measurements';

  @override
  String get navlink_unavailable_tooltip => 'This page is not available to you';

  @override
  String get study_settings => 'Study settings';

  @override
  String get study_settings_publish_study => 'Publish study';

  @override
  String get study_settings_publish_study_tooltip =>
      'Other researchers and clinicians will be able to access, test, review or create a \ncopy of your study design. They won\'t be able to access any data related to \nin-progress studies such as participants or study results (your study\'s \nRecruit, Monitor & Analyze pages will be unavailable).';

  @override
  String get study_settings_publish_study_launch_description =>
      'To facilitate collaboration among researchers and clinicians, I agree that the my study will be published to the StudyU study registry for others. (Other researchers and clinicians will be able to contact you and review the study design, but they won\'t be able to access participation or result data unless shared explicitly)';

  @override
  String get study_settings_publish_results => 'Publish results';

  @override
  String get study_settings_publish_results_tooltip =>
      'Make your anonymized study results & data available in the study registry. \nOther researchers and clinicians will be able to access, export and \nanalyze the results from your study (the Analyze page will be available). \n This will automatically publish your study design to the registry.';

  @override
  String get action_button_study_launch => 'Launch';

  @override
  String get action_button_study_close => 'Close study';

  @override
  String get notification_study_deleted => 'Study was deleted';

  @override
  String get notification_study_closed => 'Study was closed';

  @override
  String get notification_study_closed_description =>
      'New participants can no longer enroll in this study.';

  @override
  String get dialog_study_close_title => 'Close participation?';

  @override
  String get dialog_study_close_description =>
      'Are you sure that you want to stop new enrollments for this study? New participants can no longer join, but those who are already enrolled can still continue. This action cannot be undone.';

  @override
  String get dialog_study_delete_title => 'Permanently delete?';

  @override
  String get dialog_study_delete_description =>
      'Are you sure you want to delete this study? You will permanently lose the study and all data that has been collected.';

  @override
  String get form_question_create => 'New Question';

  @override
  String get form_question_edit => 'Edit Question';

  @override
  String get form_question_readonly => 'View Question';

  @override
  String get form_field_question => 'Your question';

  @override
  String get form_field_question_tooltip =>
      'Enter the question that the participant will be prompted with in the app';

  @override
  String get form_field_question_required => 'Your question must not be empty';

  @override
  String get form_field_question_help_text => 'Question help text';

  @override
  String get form_field_question_help_text_tooltip =>
      'Enter a text that is shown with a help icon next to the question in the app';

  @override
  String get form_field_question_help_text_hint =>
      'Provide additional context, help or instructions for the question';

  @override
  String get form_field_question_help_text_add => 'Add a help text';

  @override
  String get form_field_question_help_text_add_tooltip =>
      'Add a text that is shown with a help icon next to the question in the app';

  @override
  String get form_field_question_response_options => 'Response options';

  @override
  String get form_field_question_response_options_tooltip =>
      'Define the options that participants can answer your question with';

  @override
  String get form_field_question_response_options_description =>
      'Choose the response type that best matches your question and define the response options according to the data you want to collect.';

  @override
  String get question_type_choice => 'Multiple choice';

  @override
  String get question_type_free_text => 'Free text';

  @override
  String get question_type_bool => 'Yes/no';

  @override
  String get question_type_scale => 'Scale';

  @override
  String get question_type_image => 'Image';

  @override
  String get question_type_audio => 'Audio';

  @override
  String get question_type_fitbit => 'Fitbit';

  @override
  String get form_array_response_options_bool_yes => 'Yes';

  @override
  String get form_array_response_options_bool_no => 'No';

  @override
  String get form_field_response_image => 'Image';

  @override
  String get form_field_response_audio => 'Audio';

  @override
  String get form_field_response_audio_max_duration_label =>
      'Maximum recording duration in seconds';

  @override
  String get form_field_response_choice_multiple => 'Select multiple';

  @override
  String get form_field_response_choice_multiple_tooltip =>
      'Allow the participant to select multiple response options. Otherwise only a single option can be selected.';

  @override
  String get form_array_response_options_choice_new => 'Add option';

  @override
  String get form_array_response_options_choice_hint => 'Option';

  @override
  String get form_field_response_scale_min_label => 'Custom low label';

  @override
  String get form_field_response_scale_min_label_tooltip =>
      'Enter a custom label to display at the value\'s position on the scale';

  @override
  String get form_field_response_scale_min_value => 'Low value';

  @override
  String get form_field_response_scale_max_label => 'Custom high label';

  @override
  String get form_field_response_scale_max_label_tooltip =>
      'Enter a custom label to display at the value\'s position on the scale';

  @override
  String get form_field_response_scale_max_value => 'High value';

  @override
  String get form_field_response_scale_label_hint => 'Optional label';

  @override
  String get form_array_response_scale_mid_values => 'See mid-values';

  @override
  String get form_array_response_scale_mid_values_dirty_banner =>
      'The mid-values values and labels are cleared automatically to reflect the low and high of the scale.';

  @override
  String get form_field_response_scale_colors_add => 'Add start & end colors';

  @override
  String get form_field_response_scale_color_add => 'Add color';

  @override
  String get form_field_response_scale_color_min => 'Low color';

  @override
  String get form_field_response_scale_color_max => 'High color';

  @override
  String get form_field_response_scale_color_tooltip =>
      'Set a custom color for the scale shown in the app';

  @override
  String get navlink_question_visuals => 'Visuals';

  @override
  String get navlink_question_visuals_description =>
      'Customize the look & feel of the question in the app to your liking. This does not change the data that is collected, but can help guide the study participant visually';

  @override
  String form_array_response_options_choice_countmin(num count) {
    return 'Your question must have at least $count non-empty response options';
  }

  @override
  String form_array_response_options_choice_countmax(num count) {
    return 'Your question must have at most $count non-empty response options';
  }

  @override
  String get form_array_response_options_scale_rangevalid_min =>
      'The high value of the scale must be greater than the low value';

  @override
  String form_array_response_options_scale_rangevalid_max(num count) {
    return 'Do not exceed $count as a maximum difference between the high and low values of the scale';
  }

  @override
  String get audio_recording_max_duration_rangevalid_min =>
      'The minimum recording duration is 1 second';

  @override
  String audio_recording_max_duration_rangevalid_max(num count) {
    return 'The maximum recording duration is $count seconds';
  }

  @override
  String get free_text_question_logic_not_supported =>
      'The screener question logic is not yet supported for free text questions.';

  @override
  String get free_text_question_type_any => 'Any text';

  @override
  String get free_text_question_type_alphanumeric => 'Alphanumeric';

  @override
  String get free_text_question_type_numeric => 'Numeric';

  @override
  String get free_text_question_type_custom => 'Custom';

  @override
  String get free_text_range_label => 'Allowed range of text length';

  @override
  String get free_text_range_label_helper =>
      'Enter the minimum and maximum number of characters that are allowed for the answer';

  @override
  String get free_text_type_label => 'Allowed text type';

  @override
  String get free_text_type_label_helper =>
      'Choose the type of text that is allowed for the answer';

  @override
  String get free_text_type_custom_label => 'Regular expression';

  @override
  String get free_text_type_custom_label_helper =>
      'Enter a regular expression that the answer must match';

  @override
  String get free_text_type_custom_helper =>
      'Example: Enter [a-zA-Z]+ to only allow letters.';

  @override
  String get free_text_type_custom_explanation =>
      'Any input that does not match the expression will be rejected. The input length constraints specified above are still applied. A leading ^ and trailing \$ character will be added automatically.';

  @override
  String get free_text_example_label => 'Example text field';

  @override
  String get free_text_example_label_helper =>
      'This is an example of the text field that will be shown to the participant. The length and input type constraints specified above will be applied.';

  @override
  String get free_text_example_valid => 'Your example input is valid';

  @override
  String get free_text_example_default_helper =>
      'Perform a validation test by entering text here.';

  @override
  String free_text_validation_min_length(num countMin) {
    return 'The input must be at least $countMin characters long.';
  }

  @override
  String free_text_validation_max_length(num countMax) {
    return 'The input must be at most $countMax characters long.';
  }

  @override
  String get free_text_validation_pattern =>
      'The input must match the specified format.';

  @override
  String get free_text_validation_number => 'The input must be a number.';

  @override
  String free_text_example_explanation(
      String type, num countMin, num countMax) {
    return 'Inputs of type $type with a character length range of $countMin to $countMax will be accepted.';
  }

  @override
  String get free_text_question_type_any_explanation =>
      'Any input will be accepted.';

  @override
  String get free_text_question_type_alphanumeric_explanation =>
      'Alphanumeric input includes letters and numbers only.';

  @override
  String get free_text_question_type_numeric_explanation =>
      'Numeric input includes numbers without special characters.';

  @override
  String get free_text_question_type_custom_explanation =>
      'The input must match the specified regular expression.';

  @override
  String get fitbit_question_title => 'Fitbit';

  @override
  String get fitbit_question_type_empty => 'No Fitbit data available';

  @override
  String get banner_study_readonly_title => 'This study cannot be edited.';

  @override
  String get banner_study_readonly_description =>
      'You can only make changes to studies where you are an owner or collaborator. Studies that have been launched cannot be changed by anyone.';

  @override
  String get banner_study_closed_title => 'This study is closed.';

  @override
  String get banner_study_closed_description =>
      'New participants can no longer enroll in this study.';

  @override
  String get form_section_scheduling => 'Scheduling and Compliance';

  @override
  String get form_section_scheduling_description =>
      'To improve compliance, you can set a limited window of time for participants to complete the task & send a reminder notification at the specified time.';

  @override
  String get form_field_has_reminder => 'App reminder';

  @override
  String get form_field_has_reminder_tooltip =>
      'Select this option to send a reminder notification from the StudyU App to the participant\'s phone at the time specified.';

  @override
  String get form_field_has_reminder_label => 'Send notification';

  @override
  String get form_field_time_of_day_hint => 'hh:mm';

  @override
  String get form_field_time_restriction => 'Time restriction';

  @override
  String get form_field_time_restriction_tooltip =>
      'Provide the hours of the day during which participants need to complete the task. Please note that the task will not \nbe available for completion outside these hours & will be considered as missed for the purpose of data collection.';

  @override
  String get form_field_time_restriction_start_hint => 'From';

  @override
  String get form_field_time_restriction_end_hint => 'To';

  @override
  String get form_study_design_info_description =>
      'Provide general information about your study to participants. If you decide to make your study available in the study registry, this information will be available to other researchers and clinicians as well.';

  @override
  String get form_field_study_title => 'Study title';

  @override
  String get form_field_study_title_tooltip =>
      'Provide the title of the study as it should be displayed in the StudyU App';

  @override
  String get form_field_study_title_required =>
      'The study title must not be empty';

  @override
  String get form_field_study_title_default => 'Unnamed study';

  @override
  String get form_field_study_description => 'Description';

  @override
  String get form_field_study_description_tooltip =>
      'Give a short summary of your study to participants';

  @override
  String get form_field_study_description_hint =>
      'Give a short summary of your study to participants';

  @override
  String get form_field_study_description_required =>
      'The study description must not be empty';

  @override
  String get form_field_study_tags => 'Tags';

  @override
  String get form_field_study_tags_hint =>
      'Write down a tag and press the Enter key';

  @override
  String get form_field_study_tags_tooltip =>
      'Add tags to your study to make it easier to find for other researchers and clinicians';

  @override
  String form_field_study_tags_error_length(Object count) {
    return 'You can only add up to $count tags to your study';
  }

  @override
  String form_field_study_tags_helper(Object count) {
    return 'Select up to $count tags from the list or add your own.';
  }

  @override
  String get form_field_study_icon_required =>
      'You must select an icon for your study';

  @override
  String get form_section_publisher => 'Publisher and Contact Information';

  @override
  String get form_section_publisher_description =>
      'Participants will be able to contact you via the StudyU App using this information. Other clinicians or researchers will only be able to contact you if you agree to publish your study to the study registry.';

  @override
  String get form_field_organization => 'Responsible organization';

  @override
  String get form_field_organization_required =>
      'The responsible organization must not be empty';

  @override
  String get form_field_review_board => 'Institutional Review Board';

  @override
  String get form_field_review_board_required =>
      'You must specify the responsible review board for your study';

  @override
  String get form_field_review_board_number =>
      'Institutional Review Board Protocol Number';

  @override
  String get form_field_review_board_number_required =>
      'You must provide a review board protocol number for your study';

  @override
  String get form_field_researchers => 'Responsible person(s)';

  @override
  String get form_field_researchers_required =>
      'You must specify the researcher(s) responsible for the study';

  @override
  String get form_field_website => 'Website';

  @override
  String get form_field_website_pattern =>
      'Please enter a valid contact website URL';

  @override
  String get form_field_contact_email => 'Email';

  @override
  String get form_field_contact_email_required =>
      'You must specify a contact email';

  @override
  String get form_field_contact_email_email =>
      'Please enter a valid contact email address';

  @override
  String get form_field_contact_phone => 'Phone';

  @override
  String get form_field_contact_phone_required =>
      'You must specify a phone number for participants to contact';

  @override
  String get form_field_contact_additional_info => 'Additional information';

  @override
  String get form_study_design_enrollment_description =>
      'Define who will be able to participate in your study, the criteria they have to meet and the terms they have to consent to.';

  @override
  String get form_field_enrollment_type => 'Participant pool';

  @override
  String get form_field_enrollment_type_open_description =>
      'Your study will be open for enrollment to all users of the StudyU platform as long as they match your screening criteria, if any.';

  @override
  String get form_field_enrollment_type_invite_description =>
      'Only select participants will be able to enroll in your study using a designated invite code. Choose this option if you have a preselected pool of participants.';

  @override
  String get form_array_screener_questions_title => 'Screening criteria';

  @override
  String get form_array_screener_questions_description =>
      'Optional screener questions can help determine whether a potential participant is qualified to participate in the study. For invite-only studies, you may choose not to add any screening questions if you are manually qualifying & recruiting participants before inviting them to StudyU.';

  @override
  String get form_array_screener_questions_new => 'Add screener question';

  @override
  String get form_array_screener_questions_test => 'Test screener';

  @override
  String get form_array_consent_items_title => 'Participant consent';

  @override
  String get form_array_consent_items_description =>
      'Provide the terms that participants have to consent to when enrolling in your study via the StudyU App. You may choose not to add any terms here if you obtain your participants\' consent by some other method before recruiting them to your study on StudyU.';

  @override
  String get form_array_consent_items_new => 'Add consent text';

  @override
  String get form_array_consent_items_test => 'Test consent';

  @override
  String get form_screener_question_create => 'New Screener Question';

  @override
  String get form_screener_question_edit => 'Edit Screener Question';

  @override
  String get form_screener_question_readonly => 'View Screener Question';

  @override
  String get form_screener_question_logic_qualify => 'Qualify';

  @override
  String get form_screener_question_logic_disqualify => 'Disqualify';

  @override
  String get navlink_screener_question_content => 'Content';

  @override
  String get navlink_screener_question_logic => 'Logic';

  @override
  String get form_array_screener_question_logic_title => 'Screening rules';

  @override
  String get form_array_screener_question_logic_description =>
      'Define which responses qualify or disqualify participants from enrolling in your study. To qualify as a participant, at least one of the qualifying response options and none of the disqualifying ones must be selected for this question in the screening survey.';

  @override
  String get form_array_screener_question_logic_tooltip =>
      'Define which response options are qualifying or disqualifying when selected by the participant.';

  @override
  String get form_array_screener_question_logic_dirty_banner =>
      'The options you see here are cleared automatically to reflect the available responses. Every option is qualifying by default unless you explicitly mark them as disqualifying.';

  @override
  String get form_consent_create => 'New Participant Consent';

  @override
  String get form_consent_edit => 'Edit Participant Consent';

  @override
  String get form_consent_readonly => 'View Participant Consent';

  @override
  String get form_field_consent_title => 'Title';

  @override
  String get form_field_consent_title_tooltip =>
      'Enter a short title for the terms the participant must read & accept.\nFor each consent text, a card with the title & icon is shown on the app\'s consent screen.';

  @override
  String get form_field_consent_title_hint => 'Enter a short title';

  @override
  String get form_field_consent_title_required =>
      'You must provide a title for your participant consent';

  @override
  String get form_field_consent_text => 'Text';

  @override
  String get form_field_consent_text_tooltip =>
      'Enter the terms the participant must read & accept when enrolling in the study.\nThe terms are shown when clicking on the corresponding card in the app\'s consent screen.';

  @override
  String get form_field_consent_text_hint =>
      'Enter the full terms to be read & accepted';

  @override
  String get form_field_consent_text_required =>
      'The text for your participant consent must not be empty';

  @override
  String get form_study_design_interventions_description =>
      'Define the different phases of interventions to be studied, as well as the their sequence and frequency. In N-of-1 trials, a single participant will go through the intervention phases once or multiple times in a pre-specified order (so called multi-crossover trial). Each intervention consists of one or more tasks which are administered during the corresponding phase.\n\nNote: If you specify more than two interventions, participants are free to choose any two interventions to compare when they begin the study.';

  @override
  String get link_n_of_1_learn_more => 'Learn more about N-of-1 trials';

  @override
  String get link_n_of_1_learn_more_url =>
      'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3118090/pdf/nihms297482.pdf';

  @override
  String form_array_interventions_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_interventions_minlength',
      two: 'You must define at least two interventions to compare.',
    );
    return '$_temp0';
  }

  @override
  String get form_array_interventions => 'Intervention phases';

  @override
  String get form_array_interventions_new => 'Add intervention';

  @override
  String get form_array_interventions_empty_title => 'No interventions defined';

  @override
  String get form_array_interventions_empty_description =>
      'You must define at least two interventions to compare.';

  @override
  String get form_field_intervention_title => 'Title';

  @override
  String get form_field_intervention_title_required =>
      'The intervention title must not be empty';

  @override
  String get form_field_intervention_title_default => 'Unnamed intervention';

  @override
  String get form_field_intervention_title_tooltip =>
      'Provide the title of the intervention phase as it should be displayed in the StudyU App';

  @override
  String get form_field_intervention_description => 'Description';

  @override
  String get form_field_intervention_description_tooltip =>
      'Enter an explanation text that is shown when the intervention phase starts or when the participant\nclicks on the respective phase in the study plan';

  @override
  String get form_field_intervention_description_hint =>
      'Describe the intervention phase to participants';

  @override
  String get form_array_intervention_tasks => 'Intervention tasks';

  @override
  String get form_array_intervention_tasks_description =>
      'Define one or more tasks that participants should complete during this intervention phase. Every day, participants will be prompted to complete these tasks in the StudyU App.';

  @override
  String get form_array_intervention_tasks_new => 'Add intervention task';

  @override
  String get form_array_intervention_tasks_empty_title =>
      'No intervention tasks defined';

  @override
  String get form_array_intervention_tasks_empty_description =>
      'You must define at least one task for participants to complete during this intervention phase.';

  @override
  String form_array_intervention_tasks_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_intervention_tasks_minlength',
      one:
          'You must define at least one task for participants to complete during this intervention phase',
    );
    return '$_temp0';
  }

  @override
  String get form_intervention_task_create => 'New Intervention Task';

  @override
  String get form_intervention_task_edit => 'Edit Intervention Task';

  @override
  String get form_intervention_task_readonly => 'View Intervention Task';

  @override
  String get form_field_intervention_task_title => 'Title';

  @override
  String get form_field_intervention_task_default => 'Unnamed task';

  @override
  String get form_field_intervention_task_title_tooltip =>
      'Provide the title of the intervention task for the daily prompt in the StudyU App';

  @override
  String get form_field_intervention_task_title_required =>
      'The intervention task title must not be empty';

  @override
  String get form_field_intervention_task_description => 'Description';

  @override
  String get form_field_intervention_task_description_tooltip =>
      'Enter a detailed description that is shown when clicking on the daily prompt in the StudyU App';

  @override
  String get form_field_intervention_task_description_hint =>
      'Give a detailed description of the task to be performed, link to a video instruction, etc.';

  @override
  String get form_field_intervention_task_mark_as_completed_label =>
      'Require participants to \"Mark as completed\"';

  @override
  String get form_section_crossover_schedule => 'Study schedule';

  @override
  String get navlink_crossover_schedule_test => 'Test schedule';

  @override
  String get form_field_crossover_schedule_sequence => 'Sequencing';

  @override
  String get form_field_crossover_schedule_sequence_tooltip =>
      'Choose the pattern for how intervention phases are sequenced in the study schedule';

  @override
  String get form_field_crossover_schedule_sequence_description =>
      'This is the default sequence of interventions for each participant. You may override this sequencing individually for each participant in invite-only studies.';

  @override
  String get form_field_crossover_schedule_phase_length => 'Phase length';

  @override
  String get form_field_crossover_schedule_phase_length_tooltip =>
      'Set the number of days it takes to complete one phase in the study schedule';

  @override
  String form_field_crossover_schedule_phase_length_range(num min, num max) {
    return 'Intervention phases must be between $min and $max days long';
  }

  @override
  String get form_field_amount_days => 'days';

  @override
  String get form_field_crossover_schedule_num_cycles => 'Number of cycles';

  @override
  String get form_field_crossover_schedule_num_cycles_tooltip =>
      'Define the number of repetitions for each phase in the study schedule';

  @override
  String form_field_crossover_schedule_num_cycles_range(num min, num max) {
    return 'The number of cycles in your study schedule must be between $min and $max';
  }

  @override
  String get form_field_amount_crossover_schedule_num_cycles => 'cycles';

  @override
  String get form_field_crossover_schedule_include_baseline => 'Baseline phase';

  @override
  String get form_field_crossover_schedule_include_baseline_tooltip =>
      'Add an intervention-free baseline phase at the beginning of your study';

  @override
  String get form_field_crossover_schedule_include_baseline_label =>
      'Include in schedule';

  @override
  String get form_study_design_measurements_description =>
      'Define the data that you want to gather from participants during the study - primarily to evaluate the effect of your interventions. The data will be self-reported by participants in one or more surveys served via the StudyU App on a daily basis. The collected data and results will be available on the Analyze page when the study is launched.';

  @override
  String form_array_measurements_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_measurements_minlength',
      one:
          'You need to define at least one survey to determine the effect of your intervention(s).',
    );
    return '$_temp0';
  }

  @override
  String get form_array_measurements_surveys => 'Surveys';

  @override
  String get form_array_measurements_surveys_new => 'Add survey';

  @override
  String get form_array_measurements_surveys_empty_title =>
      'No surveys defined';

  @override
  String get form_array_measurements_surveys_empty_description =>
      'You need to define at least one survey to determine the effect of your intervention(s).';

  @override
  String get form_field_measurement_survey_title => 'Survey title';

  @override
  String get form_field_measurement_survey_title_required =>
      'The survey title must not be empty';

  @override
  String get form_field_measurement_survey_title_default => 'Unnamed survey';

  @override
  String get form_field_measurement_survey_title_tooltip =>
      'Provide the title of the survey as it should be displayed in the StudyU App';

  @override
  String get form_field_measurement_survey_intro_text => 'Intro text';

  @override
  String get form_field_measurement_survey_intro_text_tooltip =>
      'Enter a text that is shown at the very beginning of the survey';

  @override
  String get form_field_measurement_survey_intro_text_hint =>
      'e.g. welcome & introduce participants to the survey';

  @override
  String get form_field_measurement_survey_outro_text => 'Outro text';

  @override
  String get form_field_measurement_survey_outro_text_tooltip =>
      'Enter a text that is shown at the very end of the survey after completion';

  @override
  String get form_field_measurement_survey_outro_text_hint =>
      'e.g. thank participants for completing the survey';

  @override
  String get form_array_measurement_survey_questions => 'Questions';

  @override
  String get form_array_measurement_survey_questions_new => 'Add question';

  @override
  String get form_array_measurement_survey_questions_empty_title =>
      'No questions defined';

  @override
  String get form_array_measurement_survey_questions_empty_description =>
      'You need to define at least one question to determine the effect of your intervention(s).';

  @override
  String form_array_measurement_survey_questions_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_measurement_survey_questions_minlength',
      one:
          'You need to define at least one question to determine the effect of your intervention(s)',
    );
    return '$_temp0';
  }

  @override
  String get report_status_primary => 'Primary';

  @override
  String get report_status_secondary => 'Secondary';

  @override
  String get report_status_primary_description => 'Primary Report';

  @override
  String get report_status_secondary_description => 'Secondary Report';

  @override
  String get form_report_create => 'New Report';

  @override
  String get form_report_edit => 'Edit Report';

  @override
  String get form_report_readonly => 'View Report';

  @override
  String get form_field_report_title_required =>
      'You must provide a title for your report';

  @override
  String get form_field_report_text_required =>
      'The description for your report must not be empty';

  @override
  String get form_array_reports_empty_title => 'No reports defined';

  @override
  String get form_array_report_items_title => 'Reports';

  @override
  String get form_array_report_items_description =>
      'Define how the report that your participants receive should look like. A report includes various sections, the first of which is the primary section. For each section you can define if the data should be reported as average or via a linear regression of the user\'s data. You can choose whether the data is reported for individual days, phases or for each intervention. The data source defines which observation the report section is based on.';

  @override
  String get form_array_reports_empty_description =>
      'You need to define at least one report to provide feedback to your participants.';

  @override
  String get form_array_reports_new => 'Add new report';

  @override
  String get form_field_report_title => 'Title';

  @override
  String get form_field_report_title_tooltip =>
      'Enter a short title for the report.';

  @override
  String get form_field_report_title_hint => 'Enter a short title';

  @override
  String get form_field_report_text => 'Report description';

  @override
  String get form_field_report_text_tooltip =>
      'Enter a description for the report';

  @override
  String get form_field_report_text_hint => 'Enter a report description';

  @override
  String get form_field_report_section_type => 'Report Type';

  @override
  String get form_field_report_section_type_tooltip => 'Choose a report type';

  @override
  String get form_field_report_section_type_description =>
      'Choose the report type that matches your report.';

  @override
  String get form_field_report_improvementDirection_title =>
      'Improvement Direction';

  @override
  String get form_field_report_improvementDirection_tooltip =>
      'Define the improvement direction';

  @override
  String get reportSection_type_average => 'Average';

  @override
  String get reportSection_type_textual_summary => 'Textual Summary';

  @override
  String get reportSection_type_gauge_comparison => 'Gauge Comparison';

  @override
  String get reportSection_type_descriptive_statistics =>
      'Descriptive Statistics';

  @override
  String get form_field_report_average_temporalAggregation_title =>
      'Temporal Aggregation';

  @override
  String get form_field_report_average_temporalAggregation_tooltip =>
      'Define the temporal aggregation';

  @override
  String get reportSection_type_temporalAggregation_day => 'Day';

  @override
  String get reportSection_type_temporalAggregation_phase => 'Phase';

  @override
  String get reportSection_type_temporalAggregation_intervention =>
      'Intervention';

  @override
  String get form_field_report_temporalAggregation_required =>
      'A temporal aggregation value needs to be defined';

  @override
  String get reportSection_type_linearRegression => 'Linear Regression';

  @override
  String get reportSection_type_improvementDirection_positive => 'Positive';

  @override
  String get reportSection_type_improvementDirection_negative => 'Negative';

  @override
  String get form_field_report_improvementDirection_required =>
      'An improvement direction needs to be defined';

  @override
  String get form_field_report_linearRegression_alpha_title =>
      'Alpha Confidence';

  @override
  String get form_field_report_linearRegression_alpha_tooltip =>
      'Define the alpha confidence';

  @override
  String get form_field_report_linearRegression_alpha_hint =>
      'Enter a numerical value';

  @override
  String get form_field_report_alphaConfidence_required =>
      'An alpha confidence value needs to be defined';

  @override
  String get form_field_report_alphaConfidence_number =>
      'The alpha confidence value must be a numeric value';

  @override
  String get form_field_report_data_source_title => 'Data Source';

  @override
  String get form_field_report_data_source_tooltip =>
      'The data source defines which observation the report section is based on. The observation needs to be a question with a numerical result, e.g. a scale question.';

  @override
  String get form_field_report_data_source_required =>
      'A data source needs to be defined';

  @override
  String get form_field_report_select_aggregation =>
      'Select an aggregation value';

  @override
  String get study_test_page_description =>
      'In the test mode you can test your study as a participant.';

  @override
  String get navlink_study_test_help => 'How does this work?';

  @override
  String get study_test_app_nav_title => 'Choose a page:';

  @override
  String get navlink_study_test_app_overview => 'Study Overview';

  @override
  String get navlink_study_test_app_eligibility => 'Screener';

  @override
  String get navlink_study_test_app_intervention => 'Intervention Selection';

  @override
  String get navlink_study_test_app_consent => 'Consent';

  @override
  String get navlink_study_test_app_journey => 'Schedule';

  @override
  String get navlink_study_test_app_dashboard => 'Daily Dashboard';

  @override
  String get action_button_study_test_reset => 'Reset';

  @override
  String get action_button_study_test_open_new_tab => 'Open in new tab';

  @override
  String get banner_study_test_unavailable =>
      'The test mode is unavailable until you update the following information:';

  @override
  String get banner_study_preview_unavailable =>
      'The preview is unavailable until you update the following information:';

  @override
  String get dialog_study_test_help_title => 'Test your study!';

  @override
  String get dialog_study_test_help_description =>
      'This page allows you to experience your study like one of your study\'s participants, so that you can tailor the design to your needs and verify everything works correctly.';

  @override
  String get dialog_study_test_section_tips => '⭐ Pro tips';

  @override
  String get dialog_study_test_section_tips_text =>
      '• Use the menu in the top-left to quickly preview and jump to different parts of your study\n• Fast-forward through the participant\'s schedule by clicking \'next day\' on the app\'s dashboard page\n• Preview what your results will look like by exporting and analyzing the data from your latest test session (via the Analyze tab)\n• To get a fresh experience, you can reset all data and enroll as a new test user';

  @override
  String get dialog_study_test_download_url_intro => '• You can also';

  @override
  String get dialog_study_test_download_url =>
      'https://github.com/hpi-studyu/studyu#app-stores';

  @override
  String get dialog_study_test_download_url_text => 'download the StudyU App';

  @override
  String get dialog_study_test_download_url_outro =>
      ' on your phone for testing';

  @override
  String get dialog_study_test_section_notice => '⚠️ Please note';

  @override
  String get dialog_study_test_section_notice_text =>
      '• All test users and their data will be reset once you launch the study';

  @override
  String get dialog_action_study_test_start => 'Start testing';

  @override
  String enrolled_count_tooltip(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants are enrolled in the study with this code',
      one: '$count participant is enrolled in the study with this code',
      zero: 'Nobody has enrolled in the study with this code yet',
    );
    return '$_temp0';
  }

  @override
  String get form_code_create => 'New Invite Code';

  @override
  String get form_code_readonly => 'Invite Code';

  @override
  String get form_field_code => 'Code';

  @override
  String get form_field_code_tooltip =>
      'Enter a unique code that participants can use to enroll in your study';

  @override
  String get form_field_code_required => 'The code must not be empty';

  @override
  String form_field_code_minlength(num minLength) {
    return 'The code must have at least $minLength characters';
  }

  @override
  String form_field_code_maxlength(num maxLength) {
    return 'The code must have at most $maxLength characters';
  }

  @override
  String get form_field_code_alreadyused => 'This code is already in use';

  @override
  String get form_field_is_preconfigured_schedule => 'Predefined Schedule';

  @override
  String get form_field_is_preconfigured_schedule_description =>
      'You can predefine the phases and interventions for any participant who joins your study via this invite code. If enabled, these settings will override the default schedule defined in your study design.';

  @override
  String get form_field_preconfigured_schedule_type => 'Schedule';

  @override
  String get form_field_preconfigured_schedule_intervention_a =>
      'Intervention A';

  @override
  String get form_field_preconfigured_schedule_intervention_b =>
      'Intervention B';

  @override
  String get form_field_preconfigured_schedule_intervention_default =>
      'Default';

  @override
  String get form_field_preconfigured_schedule_intervention_hint =>
      'Select intervention...';

  @override
  String get code_list_section_title => 'Invite codes';

  @override
  String get code_public_disabled => 'Invite codes disabled';

  @override
  String get code_public_disabled_description =>
      'The invite codes are disabled for this study as it is open for public recruitment. All participants can join without an invite code.';

  @override
  String get code_list_empty_title => 'You haven\'t invited anyone yet';

  @override
  String get code_list_empty_description =>
      'Add participants to your study via invite codes.';

  @override
  String get code_list_header_code => 'Code';

  @override
  String get action_button_code_new => 'New code';

  @override
  String get participant_details_title => 'Participant details';

  @override
  String get participant_details_study_days_overview => 'Study days overview';

  @override
  String get participant_details_study_days_description =>
      'This section provides an overview of the participant\'s progress in the study. The color coding indicates the status of the participant\'s tasks on each day. Hover over each day to see more details about the participant\'s activity.';

  @override
  String get participant_details_color_legend_title => 'Legend';

  @override
  String get participant_details_color_tooltip_legend_title =>
      'Activity Detail Legend';

  @override
  String get participant_details_color_legend_completed_task =>
      'Completed task';

  @override
  String get participant_details_color_legend_completed_task_tooltip =>
      'The participant has completed this task';

  @override
  String get participant_details_color_legend_missed_task => 'Missed task';

  @override
  String get participant_details_color_legend_missed_task_tooltip =>
      'The participant has missed this task';

  @override
  String get participant_details_color_legend_completed =>
      'Completed all tasks';

  @override
  String get participant_details_color_legend_partially_completed =>
      'Some tasks incomplete';

  @override
  String get participant_details_color_legend_missed => 'Missed all tasks';

  @override
  String get participant_details_completed_legend_tooltip =>
      'All intervention and survey tasks have been completed for this day';

  @override
  String get participant_details_partially_completed_legend_tooltip =>
      'Not all intervention or survey tasks have been completed for this day';

  @override
  String get participant_details_incomplete_legend_tooltip =>
      'No intervention or survey tasks have been completed for this day';

  @override
  String get participant_details_progress_empty_title =>
      'No progress data available yet';

  @override
  String get participant_details_progress_empty_description =>
      'Once the participant has started the study, you can monitor their progress here.';

  @override
  String get monitoring_no_participants_title =>
      'There are no participants in this study yet';

  @override
  String get monitoring_no_participants_description =>
      'Once participants have enrolled in your study, you can monitor their progress and view their data here.';

  @override
  String get monitoring_participants_title => 'Participant overview';

  @override
  String get monitoring_total => 'Total number of participants';

  @override
  String get monitoring_active => 'Active';

  @override
  String get monitoring_active_tooltip =>
      'Number of participants who are currently in the study';

  @override
  String get monitoring_inactive => 'Inactive';

  @override
  String get monitoring_inactive_tooltip =>
      'Number of participants who have not completed a task for more than 3 days in a row';

  @override
  String get monitoring_dropout => 'Dropout';

  @override
  String get monitoring_dropout_tooltip =>
      'Number of participants who have left the study before the end or are inactive more than 5 days in a row';

  @override
  String get monitoring_completed => 'Completed';

  @override
  String get monitoring_completed_tooltip =>
      'Number of participants who have reached the end of the study';

  @override
  String get monitoring_table_column_participant_id => 'ID';

  @override
  String get monitoring_table_column_invite_code => 'Invite code';

  @override
  String get monitoring_table_column_enrolled => 'Started at';

  @override
  String get monitoring_table_column_last_activity => 'Last activity';

  @override
  String get monitoring_table_column_day_in_study => 'Day in study';

  @override
  String get monitoring_table_column_completed_interventions =>
      'Completed interventions';

  @override
  String get monitoring_table_column_completed_surveys => 'Completed surveys';

  @override
  String get monitoring_table_row_tooltip_dropout =>
      'This participant has dropped out of the study and no new activity will be added';

  @override
  String get monitoring_table_days_in_study_header_tooltip =>
      'The number of days the participant has been in the study';

  @override
  String get monitoring_table_completed_interventions_header_tooltip =>
      'An intervention is completed, if all of its tasks have been completed for that day';

  @override
  String get monitoring_table_completed_surveys_header_tooltip =>
      'A survey is completed, if all of its tasks have been completed for that day';

  @override
  String get banner_text_study_analyze_draft =>
      'Because this study has not been launched yet, this page is currently based on the data generated during study testing.\nThe data on this page will be reset once you launch the study with real participants.';

  @override
  String get action_button_study_export => 'Export data';

  @override
  String get action_button_study_export_prompt =>
      'Want to run your own analysis?';

  @override
  String get study_export_unavailable_empty_tooltip =>
      'There is no data available yet';

  @override
  String get study_export_unavailable_no_permission_tooltip =>
      'You do not have sufficient permission to access this study\'s data';

  @override
  String get study_launch_title => 'Great work! 👏 Ready to launch?';

  @override
  String get study_launch_participation_intro =>
      'The study you are creating is';

  @override
  String get study_launch_participation_outro => '';

  @override
  String get study_launch_post_launch_intro => 'After launching your study:';

  @override
  String get study_launch_post_launch_summary =>
      '- The study design will be locked and you won’t be able to make any changes\n- All data from test runs will be reset (incl. test users, their tasks and results)';

  @override
  String get study_launch_success_title => 'Your study is live!';

  @override
  String get study_launch_success_description =>
      'Next, you can start inviting and enrolling your participants in the StudyU App.';

  @override
  String get study_public_launch_success_description =>
      'Your study is now available for everyone in the StudyU App.';

  @override
  String get action_button_post_launch_followup => 'Add participants';

  @override
  String get action_button_post_launch_followup_skip => 'Skip for now';

  @override
  String get action_button_study_participation_change =>
      'Change\nparticipation';

  @override
  String get form_field_required => 'Field must not be empty';

  @override
  String get form_invalid_prompt => 'Please fill out all fields as required';

  @override
  String get copy_suffix_label => 'Copy';

  @override
  String date_diff_years(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String date_diff_months(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String date_diff_days(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String date_diff_hours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String date_diff_minutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String date_diff_seconds(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds ago',
      one: '1 second ago',
    );
    return '$_temp0';
  }

  @override
  String get date_just_now => 'Just now';

  @override
  String get action_edit => 'Edit';

  @override
  String get action_pin => 'Pin';

  @override
  String get action_unpin => 'Remove pin';

  @override
  String get action_delete => 'Delete';

  @override
  String get action_remove => 'Remove';

  @override
  String get action_duplicate => 'Duplicate';

  @override
  String get action_clipboard => 'Copy to clipboard';

  @override
  String get action_reportPrimary => 'Set as primary report';

  @override
  String get action_study_duplicate_draft => 'Copy as draft';

  @override
  String get action_study_export_results => 'Export results';

  @override
  String get dialog_continue => 'Continue';

  @override
  String get dialog_close => 'Close';

  @override
  String get dialog_cancel => 'Cancel';

  @override
  String get dialog_save => 'Save';

  @override
  String get sync_initial => 'No changes to be saved';

  @override
  String get sync_dirty => 'There are unsaved changes';

  @override
  String get sync_saving => 'Saving changes...';

  @override
  String get sync_done => 'All changes saved';

  @override
  String get sync_last_saved => 'Last saved';

  @override
  String get sync_failed => 'Changes could not be saved';

  @override
  String get iconpicker_nonempty_prompt => 'Change icon';

  @override
  String get iconpicker_empty_prompt => 'Pick an icon';

  @override
  String get iconpicker_dialog_title => 'Pick an icon';

  @override
  String get dialog_unsaved_changes_title => 'Go back and discard changes?';

  @override
  String get dialog_unsaved_changes_description =>
      'There are unsaved changes that will be lost when you go back. If you want to keep your changes, you need to save your work before going back.';

  @override
  String get dialog_action_unsaved_changes_stay => 'Stay';

  @override
  String get dialog_action_unsaved_changes_discard => 'Discard changes';

  @override
  String get under_construction => 'Under construction';

  @override
  String get under_construction_description =>
      'We are still busy working on this part, check back soon!';

  @override
  String get fitbit_credentials_instruction =>
      'To integrate Fitbit data, follow these steps to obtain your Client ID and Client Secret:';

  @override
  String get fitbit_credentials_step1 =>
      '1. Go to the Fitbit Developer Portal.';

  @override
  String get fitbit_credentials_step2 =>
      '2. Log in with your Fitbit account or create one if you do not have it.';

  @override
  String get fitbit_credentials_step3 =>
      '3. Navigate to the \"Manage\" section and select \"Register an App\".';

  @override
  String get fitbit_credentials_step4 =>
      '4. Fill in the required fields such as application name, description, and Redirect URL (use: \"studyu://fitbit/auth\").';

  @override
  String get fitbit_credentials_step5 =>
      '5. Select \"Client\" under \"OAuth 2.0 Application Type\" and set \"Access\" to \"Read-Only.\"';

  @override
  String get fitbit_credentials_step6 =>
      '6. Submit the form to get your \"Client ID\" and \"Client Secret\".';

  @override
  String get fitbit_credentials_step7 =>
      '7. Please fill the following form to obtain access for intraday data. Without this, you cannot obtain any data from Fitbit for your trials.';

  @override
  String get fitbit_credentials_step8 =>
      '8. Copy and paste the credentials below.';

  @override
  String get fitbit_credentials_success_instruction =>
      'Once you enter the credentials, Fitbit integration will be enabled for your study.';

  @override
  String get fitbit_credentials_add_question_instruction =>
      'To add a Fitbit question, navigate to the measurements section and create a new Fitbit Question within a measurement.';

  @override
  String get fitbit_credentials_screenshot_step1 => 'Step 1: Developer Portal';

  @override
  String get fitbit_credentials_screenshot_step2 => 'Step 2: Login';

  @override
  String get fitbit_credentials_screenshot_step3 => 'Step 3: Register App';

  @override
  String get fitbit_credentials_screenshot_step4 => 'Step 4: Input Details';

  @override
  String get fitbit_credentials_screenshot_step5 => 'Step 5: Set Access';

  @override
  String get fitbit_credentials_screenshot_step6 => 'Step 6: Get Credentials';

  @override
  String get fitbit_credentials_screenshot_step7 => 'Step 7: Fill Form';

  @override
  String get fitbit_credentials_cannot_change_title =>
      'Fitbit credentials can\'t be changed';

  @override
  String get fitbit_credentials_cannot_change_description =>
      'Fitbit credentials can\'t be changed while the study is not in draft mode.';

  @override
  String get fitbit_only_participant_title =>
      'If you\'re running this study just for yourself';

  @override
  String get fitbit_only_participant_subtitle =>
      'Since you\'re both creating and participating in this study, you don\'t need to fill out the intraday data request form. Simply follow these easy steps:';

  @override
  String get fitbit_only_participant_step_1 =>
      'When creating your Fitbit app, choose \'Personal\' as the app type.';

  @override
  String get fitbit_only_participant_step_2 =>
      'When syncing data, make sure to use the same Google account that\'s connected to your Fitbit watch and the Fitbit app you\'ve set up.';

  @override
  String get client_id => 'Client ID';

  @override
  String get client_id_label_help =>
      'Enter the Client ID from Fitbit Developer Portal.';

  @override
  String get client_id_hint => 'Client ID';

  @override
  String get client_secret => 'Client Secret';

  @override
  String get client_secret_label_help =>
      'Enter the Client Secret from Fitbit Developer Portal.';

  @override
  String get client_secret_hint => 'Client Secret';

  @override
  String get screenshots_for_guidance => 'Screenshots for Guidance:';

  @override
  String get fitbit_credentials_not_set =>
      'Fitbit credentials are not set. Please navigate to the \'Fitbit\' tab in the study designer to enter your Fitbit client ID and client secret. Once completed, return here to add Fitbit questions.';
}
