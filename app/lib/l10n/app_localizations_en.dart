// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loading => 'Loading';

  @override
  String get loading_error_title => 'Loading Error';

  @override
  String get loading_error_description =>
      'The study data could not be retrieved. If you are currently participating in a study, please first contact your study supervisor for assistance. Only contact support if you are not in a study or your supervisor instructs you to do so. Do not delete your data unless told by your supervisor or support. Deleting data will remove all your study data and you will have to rejoin the study.';

  @override
  String get try_again => 'Try again';

  @override
  String get delete_all_data => 'Delete all data';

  @override
  String get delete_all_data_description =>
      'Do you really want to delete all data? This will delete all your study data and you will have to rejoin the study.';

  @override
  String get reset_app => 'Reset App';

  @override
  String get what_is_studyu => 'What is StudyU?';

  @override
  String get description_part1 =>
      'Imagine reading the sentence: \"Eating after 6 pm decreases sleep quality\"';

  @override
  String get description_part2 =>
      'Now you might think something like: Well... good to know but is that affecting everyone and also ME?';

  @override
  String get description_part3 =>
      'The problem is: you did not take part in the study yourself, so we simply cannot answer that question. A traditional study can only answer whether it is more LIKELY that your sleep quality is affected. You would therefore have to test the effect of eating late on YOUR sleep.';

  @override
  String get description_part4 =>
      'This means that you would have to do your own personal study, in which you would have phases of eating late and phases of abstaining from eating late. You would regularly assess your sleep quality and in the end come to a result that could finally answer the question of whether eating late decreases your sleep quality or not. Giving you a reliable answer to such questions is the goal of StudyU.';

  @override
  String get description_part5 =>
      'StudyU offers the possibility to enroll to N-of-1 studies designed by experts. N-of-1 means that the number of people in the trials, which is usually indicated as N, is 1. And just like traditional trials, N-of-1 trials need a clearly defined plan (a so-called study protocol).';

  @override
  String get description_part6 =>
      'And because good study protocols are not easy to make, we have developed this App. Here you can choose between different N-of-1 studies, according to YOUR personal interest, and you will automatically receive a plan developed by experts that will give you a reliable result.';

  @override
  String get description_part7 =>
      'Once you have chosen one of our studies we will make sure that your health status allows participation. Afterwards you can enroll as a participant and adapt the study plan to your everyday life. Tasks (e.g. eating late and rating your tiredness) have to be done on a regular basis (e.g. once per day). Once you have reached the minimum study duration (usually just a few weeks) you will be able to unlock results for free.';

  @override
  String get description_part8 =>
      'But bear in mind that results are more reliable the longer you take actively part in the study. And in order to prevent systematic error you cannot go on with the study after unlocking results. Therefore, with the help of a progress bar we will indicate you how many tasks are still needed for the minimum and how much you could improve your results with going on for some more weeks.';

  @override
  String get description_part9 =>
      'But enough from our side, now it\'s time for StudyU!';

  @override
  String get get_started => 'Get started';

  @override
  String get study_selection => 'Study Selection';

  @override
  String get study_selection_description => 'Please select a study.';

  @override
  String get study_selection_single =>
      'You can only participate in one study at a time.';

  @override
  String get study_selection_single_why => 'Why?';

  @override
  String get study_selection_single_reason =>
      'If you were to participate in multiple studies at a time, the interventions of these studies might interfere with one another and alter the results.';

  @override
  String get study_selection_unsupported_title => 'Outdated app version';

  @override
  String get study_selection_unsupported =>
      'The study you are trying to join is not compatible with your app version. Please update the app to the latest version.';

  @override
  String get study_selection_closed_title => 'Study closed';

  @override
  String get study_selection_closed =>
      'This study is currently closed for new participants.';

  @override
  String get study_selection_hidden_studies =>
      'Some studies couldn\'t be shown, because your app version is outdated. Please update your app to see all available studies.';

  @override
  String get study_overview_title => 'Overview';

  @override
  String get eligibility_questionnaire_title => 'Questionnaire';

  @override
  String get please_answer_eligibility =>
      'Please answer a few questions to make sure that you can safely participate in this study.';

  @override
  String get intervention_selection_title => 'Interventions';

  @override
  String get please_select_interventions =>
      'Please select two interventions to apply during the study.';

  @override
  String get please_select_interventions_description =>
      'The effects of these two interventions will be measured and compared during the study. Interventions will follow the order you select. Choosing A before B means A comes first';

  @override
  String get no_interventions_available => 'No interventions available.';

  @override
  String get loading_interventions => 'Loading interventions';

  @override
  String get task_already_completed =>
      'You have already completed this task today';

  @override
  String get task_cannot_be_completed => 'The task cannot be completed';

  @override
  String get task_outside_period =>
      'The task cannot be completed outside of the intervention period';

  @override
  String get study_notification_body => 'A new task awaits your attention';

  @override
  String get intervention_phase_duration => 'Intervention phase duration';

  @override
  String get days => 'days';

  @override
  String get study_length => 'Study length';

  @override
  String get study_publisher => 'Study Publisher';

  @override
  String get tasks_daily => 'Tasks:';

  @override
  String get baseline_description =>
      'The baseline is a phase within a study in which the initial state is measured to allow later comparisons. During the baseline phase you should behave as usual, no study-specific interventions are carried out yet.';

  @override
  String get baseline => 'Baseline';

  @override
  String get days_left => 'days left';

  @override
  String get today_tasks => 'Today\'s tasks';

  @override
  String get intervention_current => 'Current intervention';

  @override
  String get study_current => 'Current study:';

  @override
  String get opt_out => 'Leave study';

  @override
  String get delete_data => 'Leave study and delete all data';

  @override
  String get soft_delete_desc => 'You will lose your progress in ';

  @override
  String get soft_delete_desc_2 =>
      ' and won\'t be able to recover it. Previously completed studies will not be deleted.\nYour anonymized data up to this point may still be used for research purposes.';

  @override
  String get hard_delete_desc =>
      'You are about to delete all data from your device and our servers. You will not be able to restore your data.\nYour anonymized data will not be available for research purposes anymore.';

  @override
  String get your_journey => 'Your Journey';

  @override
  String get journey_results_available => 'Results available';

  @override
  String get summary => 'Summary';

  @override
  String get consent => 'Consent';

  @override
  String get error => 'An error occurred!';

  @override
  String get tea_vs_coffee => 'Tea vs. Coffee';

  @override
  String get weed_vs_alcohol => 'Weed vs. Alcohol';

  @override
  String get back_pain => 'Back pain';

  @override
  String get video_task => 'Video task';

  @override
  String get finished => 'Finished';

  @override
  String get how_would_you_rate_your_pain_today =>
      'How would you rate your pain today? (0 = no pain, 10 = extreme pain)';

  @override
  String get thank_you_for_your_input => 'Thank you for your input';

  @override
  String get please_give_consent =>
      'Please give your consent to participate in this study. You are required to read all boxes by clicking on them.';

  @override
  String get please_give_consent_why => 'Why?';

  @override
  String get please_give_consent_reason =>
      'Studies need to request specific consent from participants, for reasons of safety and data privacy. Hence, you must explicitly consent to participate in each study.';

  @override
  String get user_did_not_give_consent =>
      'You did not give your consent. To participate you need to give consent.';

  @override
  String get setting_up_study => 'Setting up your study...';

  @override
  String get good_to_go => 'You are good to go!';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get help => 'Help';

  @override
  String get contact => 'Contact';

  @override
  String get contact_support => 'Contact Support';

  @override
  String support_email_body(String subjectId) {
    return 'Hello,\n\nI am experiencing a loading error in the StudyU app. My subject ID is: $subjectId\n\nPlease assist me with this issue.\n\nThank you.';
  }

  @override
  String get about => 'About';

  @override
  String get settings => 'Settings';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get confirm => 'Confirm selection';

  @override
  String get survey => 'Survey';

  @override
  String get complete => 'Complete';

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get completed => 'Completed';

  @override
  String get faq_full => 'Frequently Asked Questions';

  @override
  String get faq => 'FAQ';

  @override
  String get start_study => 'Start Study';

  @override
  String get next_day => 'Next day';

  @override
  String get could_not_save_results => 'Could not save results';

  @override
  String get take_a_photo => 'Take a photo';

  @override
  String get start_recording => 'Start recording';

  @override
  String get stop_recording => 'Stop recording';

  @override
  String get error_recording => 'Error occurred during recording';

  @override
  String get photo_captured => 'Photo captured';

  @override
  String get audio_recorded => 'Audio recorded';

  @override
  String get multimodal_not_supported =>
      'Multimodal Trials are currently not supported to run in a web browser. Please use the StudyU App for Android or iOS.';

  @override
  String get camera_access_denied => 'Camera access denied';

  @override
  String get no_camera_available => 'No camera available';

  @override
  String get microphone_access_denied => 'Microphone access denied';

  @override
  String get camera_error => 'Camera error';

  @override
  String get recording_error => 'Recording error';

  @override
  String get storing_photo => 'The photo is being stored';

  @override
  String get storing_audio => 'The audio file is being stored';

  @override
  String get upload_error => 'The file could not be uploaded';

  @override
  String get language => 'Language';

  @override
  String get en => 'English';

  @override
  String get de => 'German';

  @override
  String get allow_analytics => 'Allow app analytics';

  @override
  String get allow_analytics_desc =>
      'All collected data is used only to improve app performance and never for tracking purposes. You can read more about this in our data privacy.';

  @override
  String get video_test => 'This is a video test';

  @override
  String get survey_test => 'This is a survey test';

  @override
  String get current_report => 'Current report';

  @override
  String get report_history => 'Report history';

  @override
  String get current_power_level => 'Current status';

  @override
  String get not_enough_data => 'Not enough data';

  @override
  String get barely_enough_data => 'Barely enough data';

  @override
  String get enough_data => 'Enough data';

  @override
  String get terms => 'Terms of Use';

  @override
  String get terms_read => 'Read Terms of Use';

  @override
  String get terms_content =>
      'The terms of use give an overview on the purpose and use of the StudyU app. In case you have any questions please reach out to us via the contact information in the legal notice.';

  @override
  String get terms_agree => 'I have read and agree to the terms of use';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get privacy_read => 'Read Privacy Policy';

  @override
  String get privacy_content =>
      'The privacy policy describes which data is stored, why, when, where, access rights, and which rights you have. In case you have any questions please reach out to us via the contact information in the legal notice.';

  @override
  String get privacy_agree => 'I have read and agree to the privacy policy';

  @override
  String get imprint_read => 'Read Legal Notice';

  @override
  String get invite_code_button => 'Use invite code';

  @override
  String get private_study_invite_code => 'Private study invite code';

  @override
  String get invite_code => 'Invite code';

  @override
  String get invalid_invite_code => 'Not a valid invite code';

  @override
  String get save_pdf => 'Save as PDF';

  @override
  String get was_saved_to => 'The file was saved to ';

  @override
  String get save_not_supported => 'Error';

  @override
  String get save_not_supported_description =>
      'Downloading files is currently not supported in the web version.';

  @override
  String get eligible_no => 'You are not eligible for this study';

  @override
  String get eligible_yes => 'You are eligible for this study';

  @override
  String get eligible_mistake =>
      'If you made a mistake, you can still change your answers';

  @override
  String get eligible_back => 'Back to study selection';

  @override
  String get eligible_choice_multi_selection => 'Select all that apply';

  @override
  String get report_overview => 'Report overview';

  @override
  String get report_primary_result => 'Primary Result';

  @override
  String get report_disclaimer =>
      'This report is only valid if you entered all information correctly.';

  @override
  String get performance => 'Performance';

  @override
  String get performance_overview => 'Overview of completion of tasks';

  @override
  String get performance_overview_interventions => 'Interventions';

  @override
  String get performance_overview_observations => 'Observations';

  @override
  String get report_outcome_inconclusive =>
      'The results are inconclusive. There does not seem to be a statistically significant difference between the interventions.';

  @override
  String get report_outcome_neither =>
      'Both interventions seem to have a negative effect on the outcome for you.';

  @override
  String report_outcome_one(Object intervention) {
    return 'The intervention $intervention seems to improve the outcome for you.';
  }

  @override
  String get report_axis_phase => 'Phase';

  @override
  String get study_not_started =>
      'Your study has not started yet. Please check back tomorrow!';

  @override
  String get completed_study =>
      'You completed your last study. Look at past reports or start a new study.';

  @override
  String get app_support => 'App support';

  @override
  String get app_support_text =>
      'Contact for problems or questions with the app';

  @override
  String get study_support => 'Study support';

  @override
  String get study_support_text =>
      'Contact for problems or questions with the study';

  @override
  String get organization => 'Organization';

  @override
  String get irb => 'Institutional Review Board';

  @override
  String get researchers => 'Researchers';

  @override
  String get website => 'Website';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get additionalInfo => 'Additional information';

  @override
  String free_text_min_length_error(num min) {
    return 'Please enter at least $min characters';
  }

  @override
  String free_text_max_length_error(num max) {
    return 'Please enter at most $max characters';
  }

  @override
  String get free_text_alphanumeric_error =>
      'Please enter only alphanumeric characters';

  @override
  String get free_text_numeric_error => 'Please enter only numeric characters';

  @override
  String free_text_custom_error(String pattern) {
    return 'Please enter only characters matching the pattern $pattern';
  }

  @override
  String get app_outdated_message =>
      'A new version of the StudyU App is available. Please update to get the latest features and improvements. Thank you for your support!';

  @override
  String get update_now => 'Update now';

  @override
  String get text_summary_section_prefix_higher => 'Your ';

  @override
  String get text_summary_section_was_higher =>
      ' was higher during intervention: ';

  @override
  String get text_summary_section_was_lower =>
      ' was lower during intervention: ';

  @override
  String get text_summary_section_compared_to => ' compared to: ';

  @override
  String get text_summary_section_and => ' and ';

  @override
  String get text_summary_section_no_evidence =>
      'There was no evidence for a difference in ';

  @override
  String get text_summary_section_between => ' between interventions: ';

  @override
  String get intervention => 'Intervention';

  @override
  String get phase => 'Phase';

  @override
  String get day => 'Day';

  @override
  String get no_data_available_yet => 'No data available yet';

  @override
  String get value => 'Value';

  @override
  String get show_colorless_gauges => 'Enable accessible charts';

  @override
  String get welchs_t_test_results => 'Welch\'s t-test Results';

  @override
  String get sample_a => 'Sample A';

  @override
  String get sample_b => 'Sample B';

  @override
  String get sample_size => 'n';

  @override
  String get mean => 'mean';

  @override
  String get variance => 'var';

  @override
  String get t_statistic => 't-statistic';

  @override
  String get degrees_of_freedom => 'Degrees of freedom';

  @override
  String get p_value => 'p-value';

  @override
  String get result_significant => 'Significantly different';

  @override
  String get result_not_significant => 'Not significantly different';

  @override
  String get level_of_significance => 'Level of significance';

  @override
  String get t_test_outcome_based_on =>
      'The outcome is based on the following values:';

  @override
  String get statistical_information => 'Statistical Information';

  @override
  String get close => 'Close';

  @override
  String get significance_level_and_p_value => 'Significance level and p-value';

  @override
  String get descriptive_statistics => 'Descriptive statistics';

  @override
  String compare_results_between(String nameA, String nameB) {
    return 'Compare results between $nameA and $nameB';
  }

  @override
  String get missing_observations_note =>
      'Note: Missing observations indicate days when data was not recorded.';

  @override
  String get quick_summary => 'Quick Summary';

  @override
  String get average_score => 'Average score';

  @override
  String get data_completeness => 'Data completeness';

  @override
  String get statistic => 'Statistic';

  @override
  String get total_recordings => 'Total recordings';

  @override
  String get missing_recordings => 'Missing recordings';

  @override
  String get average => 'Average';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get support_email_sent => 'Support Email Sent';

  @override
  String get support_email_sent_description =>
      'Your support request has been prepared in your email app. Please send the email to reach our support team and wait for their reply.\n\nIf you are currently participating in a study, please continue tracking your results outside the app until the issue is resolved. Thank you for your understanding.';

  @override
  String get sync_fitbit_data => 'Sync Fitbit Data';

  @override
  String get fitbit_data_synced => 'Fitbit data synced successfully';

  @override
  String get fitbit_data_not_synced =>
      'Fitbit data could not be synced. Please be sure that you have synced your Fitbit data with the Fitbit app.';

  @override
  String error_syncing_fitbit_data(String error) {
    return 'Error syncing Fitbit data: $error';
  }

  @override
  String get fitbit_data_synced_dialog_title => 'Fitbit Data Synced';

  @override
  String get fitbit_data_synced_info =>
      'Data was synced for the following data types:';

  @override
  String fitbit_data_earliest_date(String date) {
    return 'Earliest date: $date';
  }

  @override
  String fitbit_data_latest_date(String date) {
    return 'Latest date: $date';
  }

  @override
  String get fitbit_data_details_btn => 'Details';

  @override
  String get fitbit_data_close_btn => 'Close';
}
