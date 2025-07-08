import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @loading_error_title.
  ///
  /// In en, this message translates to:
  /// **'Loading Error'**
  String get loading_error_title;

  /// No description provided for @loading_error_description.
  ///
  /// In en, this message translates to:
  /// **'The study data could not be retrieved. If you are currently participating in a study, please first contact your study supervisor for assistance. Only contact support if you are not in a study or your supervisor instructs you to do so. Do not delete your data unless told by your supervisor or support. Deleting data will remove all your study data and you will have to rejoin the study.'**
  String get loading_error_description;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get delete_all_data;

  /// No description provided for @delete_all_data_description.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete all data? This will delete all your study data and you will have to rejoin the study.'**
  String get delete_all_data_description;

  /// No description provided for @reset_app.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get reset_app;

  /// No description provided for @what_is_studyu.
  ///
  /// In en, this message translates to:
  /// **'What is StudyU?'**
  String get what_is_studyu;

  /// No description provided for @description_part1.
  ///
  /// In en, this message translates to:
  /// **'Imagine reading the sentence: \"Eating after 6 pm decreases sleep quality\"'**
  String get description_part1;

  /// No description provided for @description_part2.
  ///
  /// In en, this message translates to:
  /// **'Now you might think something like: Well... good to know but is that affecting everyone and also ME?'**
  String get description_part2;

  /// No description provided for @description_part3.
  ///
  /// In en, this message translates to:
  /// **'The problem is: you did not take part in the study yourself, so we simply cannot answer that question. A traditional study can only answer whether it is more LIKELY that your sleep quality is affected. You would therefore have to test the effect of eating late on YOUR sleep.'**
  String get description_part3;

  /// No description provided for @description_part4.
  ///
  /// In en, this message translates to:
  /// **'This means that you would have to do your own personal study, in which you would have phases of eating late and phases of abstaining from eating late. You would regularly assess your sleep quality and in the end come to a result that could finally answer the question of whether eating late decreases your sleep quality or not. Giving you a reliable answer to such questions is the goal of StudyU.'**
  String get description_part4;

  /// No description provided for @description_part5.
  ///
  /// In en, this message translates to:
  /// **'StudyU offers the possibility to enroll to N-of-1 studies designed by experts. N-of-1 means that the number of people in the trials, which is usually indicated as N, is 1. And just like traditional trials, N-of-1 trials need a clearly defined plan (a so-called study protocol).'**
  String get description_part5;

  /// No description provided for @description_part6.
  ///
  /// In en, this message translates to:
  /// **'And because good study protocols are not easy to make, we have developed this App. Here you can choose between different N-of-1 studies, according to YOUR personal interest, and you will automatically receive a plan developed by experts that will give you a reliable result.'**
  String get description_part6;

  /// No description provided for @description_part7.
  ///
  /// In en, this message translates to:
  /// **'Once you have chosen one of our studies we will make sure that your health status allows participation. Afterwards you can enroll as a participant and adapt the study plan to your everyday life. Tasks (e.g. eating late and rating your tiredness) have to be done on a regular basis (e.g. once per day). Once you have reached the minimum study duration (usually just a few weeks) you will be able to unlock results for free.'**
  String get description_part7;

  /// No description provided for @description_part8.
  ///
  /// In en, this message translates to:
  /// **'But bear in mind that results are more reliable the longer you take actively part in the study. And in order to prevent systematic error you cannot go on with the study after unlocking results. Therefore, with the help of a progress bar we will indicate you how many tasks are still needed for the minimum and how much you could improve your results with going on for some more weeks.'**
  String get description_part8;

  /// No description provided for @description_part9.
  ///
  /// In en, this message translates to:
  /// **'But enough from our side, now it\'s time for StudyU!'**
  String get description_part9;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get get_started;

  /// No description provided for @study_selection.
  ///
  /// In en, this message translates to:
  /// **'Study Selection'**
  String get study_selection;

  /// No description provided for @study_selection_description.
  ///
  /// In en, this message translates to:
  /// **'Please select a study.'**
  String get study_selection_description;

  /// No description provided for @study_selection_single.
  ///
  /// In en, this message translates to:
  /// **'You can only participate in one study at a time.'**
  String get study_selection_single;

  /// No description provided for @study_selection_single_why.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get study_selection_single_why;

  /// No description provided for @study_selection_single_reason.
  ///
  /// In en, this message translates to:
  /// **'If you were to participate in multiple studies at a time, the interventions of these studies might interfere with one another and alter the results.'**
  String get study_selection_single_reason;

  /// No description provided for @study_selection_unsupported_title.
  ///
  /// In en, this message translates to:
  /// **'Outdated app version'**
  String get study_selection_unsupported_title;

  /// No description provided for @study_selection_unsupported.
  ///
  /// In en, this message translates to:
  /// **'The study you are trying to join is not compatible with your app version. Please update the app to the latest version.'**
  String get study_selection_unsupported;

  /// No description provided for @study_selection_closed_title.
  ///
  /// In en, this message translates to:
  /// **'Study closed'**
  String get study_selection_closed_title;

  /// No description provided for @study_selection_closed.
  ///
  /// In en, this message translates to:
  /// **'This study is currently closed for new participants.'**
  String get study_selection_closed;

  /// No description provided for @study_selection_hidden_studies.
  ///
  /// In en, this message translates to:
  /// **'Some studies couldn\'t be shown, because your app version is outdated. Please update your app to see all available studies.'**
  String get study_selection_hidden_studies;

  /// No description provided for @study_overview_title.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get study_overview_title;

  /// No description provided for @eligibility_questionnaire_title.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire'**
  String get eligibility_questionnaire_title;

  /// No description provided for @please_answer_eligibility.
  ///
  /// In en, this message translates to:
  /// **'Please answer a few questions to make sure that you can safely participate in this study.'**
  String get please_answer_eligibility;

  /// No description provided for @intervention_selection_title.
  ///
  /// In en, this message translates to:
  /// **'Interventions'**
  String get intervention_selection_title;

  /// No description provided for @please_select_interventions.
  ///
  /// In en, this message translates to:
  /// **'Please select two interventions to apply during the study.'**
  String get please_select_interventions;

  /// No description provided for @please_select_interventions_description.
  ///
  /// In en, this message translates to:
  /// **'The effects of these two interventions will be measured and compared during the study. Interventions will follow the order you select. Choosing A before B means A comes first'**
  String get please_select_interventions_description;

  /// No description provided for @no_interventions_available.
  ///
  /// In en, this message translates to:
  /// **'No interventions available.'**
  String get no_interventions_available;

  /// No description provided for @loading_interventions.
  ///
  /// In en, this message translates to:
  /// **'Loading interventions'**
  String get loading_interventions;

  /// No description provided for @task_already_completed.
  ///
  /// In en, this message translates to:
  /// **'You have already completed this task today'**
  String get task_already_completed;

  /// No description provided for @task_cannot_be_completed.
  ///
  /// In en, this message translates to:
  /// **'The task cannot be completed'**
  String get task_cannot_be_completed;

  /// No description provided for @task_outside_period.
  ///
  /// In en, this message translates to:
  /// **'The task cannot be completed outside of the intervention period'**
  String get task_outside_period;

  /// No description provided for @study_notification_body.
  ///
  /// In en, this message translates to:
  /// **'A new task awaits your attention'**
  String get study_notification_body;

  /// No description provided for @intervention_phase_duration.
  ///
  /// In en, this message translates to:
  /// **'Intervention phase duration'**
  String get intervention_phase_duration;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @study_length.
  ///
  /// In en, this message translates to:
  /// **'Study length'**
  String get study_length;

  /// No description provided for @study_publisher.
  ///
  /// In en, this message translates to:
  /// **'Study Publisher'**
  String get study_publisher;

  /// No description provided for @tasks_daily.
  ///
  /// In en, this message translates to:
  /// **'Tasks:'**
  String get tasks_daily;

  /// No description provided for @baseline_description.
  ///
  /// In en, this message translates to:
  /// **'The baseline is a phase within a study in which the initial state is measured to allow later comparisons. During the baseline phase you should behave as usual, no study-specific interventions are carried out yet.'**
  String get baseline_description;

  /// No description provided for @baseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get baseline;

  /// No description provided for @days_left.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get days_left;

  /// No description provided for @today_tasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks'**
  String get today_tasks;

  /// No description provided for @intervention_current.
  ///
  /// In en, this message translates to:
  /// **'Current intervention'**
  String get intervention_current;

  /// No description provided for @study_current.
  ///
  /// In en, this message translates to:
  /// **'Current study:'**
  String get study_current;

  /// No description provided for @opt_out.
  ///
  /// In en, this message translates to:
  /// **'Leave study'**
  String get opt_out;

  /// No description provided for @delete_data.
  ///
  /// In en, this message translates to:
  /// **'Leave study and delete all data'**
  String get delete_data;

  /// No description provided for @soft_delete_desc.
  ///
  /// In en, this message translates to:
  /// **'You will lose your progress in '**
  String get soft_delete_desc;

  /// No description provided for @soft_delete_desc_2.
  ///
  /// In en, this message translates to:
  /// **' and won\'t be able to recover it. Previously completed studies will not be deleted.\nYour anonymized data up to this point may still be used for research purposes.'**
  String get soft_delete_desc_2;

  /// No description provided for @hard_delete_desc.
  ///
  /// In en, this message translates to:
  /// **'You are about to delete all data from your device and our servers. You will not be able to restore your data.\nYour anonymized data will not be available for research purposes anymore.'**
  String get hard_delete_desc;

  /// No description provided for @your_journey.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get your_journey;

  /// No description provided for @journey_results_available.
  ///
  /// In en, this message translates to:
  /// **'Results available'**
  String get journey_results_available;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @consent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consent;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred!'**
  String get error;

  /// No description provided for @tea_vs_coffee.
  ///
  /// In en, this message translates to:
  /// **'Tea vs. Coffee'**
  String get tea_vs_coffee;

  /// No description provided for @weed_vs_alcohol.
  ///
  /// In en, this message translates to:
  /// **'Weed vs. Alcohol'**
  String get weed_vs_alcohol;

  /// No description provided for @back_pain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get back_pain;

  /// No description provided for @video_task.
  ///
  /// In en, this message translates to:
  /// **'Video task'**
  String get video_task;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @how_would_you_rate_your_pain_today.
  ///
  /// In en, this message translates to:
  /// **'How would you rate your pain today? (0 = no pain, 10 = extreme pain)'**
  String get how_would_you_rate_your_pain_today;

  /// No description provided for @thank_you_for_your_input.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your input'**
  String get thank_you_for_your_input;

  /// No description provided for @please_give_consent.
  ///
  /// In en, this message translates to:
  /// **'Please give your consent to participate in this study. You are required to read all boxes by clicking on them.'**
  String get please_give_consent;

  /// No description provided for @please_give_consent_why.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get please_give_consent_why;

  /// No description provided for @please_give_consent_reason.
  ///
  /// In en, this message translates to:
  /// **'Studies need to request specific consent from participants, for reasons of safety and data privacy. Hence, you must explicitly consent to participate in each study.'**
  String get please_give_consent_reason;

  /// No description provided for @user_did_not_give_consent.
  ///
  /// In en, this message translates to:
  /// **'You did not give your consent. To participate you need to give consent.'**
  String get user_did_not_give_consent;

  /// No description provided for @setting_up_study.
  ///
  /// In en, this message translates to:
  /// **'Setting up your study...'**
  String get setting_up_study;

  /// No description provided for @good_to_go.
  ///
  /// In en, this message translates to:
  /// **'You are good to go!'**
  String get good_to_go;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support;

  /// Body of the support email, includes the subject ID
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\nI am experiencing a loading error in the StudyU app. My subject ID is: {subjectId}\n\nPlease assist me with this issue.\n\nThank you.'**
  String support_email_body(String subjectId);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm selection'**
  String get confirm;

  /// No description provided for @survey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get survey;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @faq_full.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq_full;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @start_study.
  ///
  /// In en, this message translates to:
  /// **'Start Study'**
  String get start_study;

  /// No description provided for @next_day.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get next_day;

  /// No description provided for @could_not_save_results.
  ///
  /// In en, this message translates to:
  /// **'Could not save results'**
  String get could_not_save_results;

  /// No description provided for @take_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get take_a_photo;

  /// No description provided for @start_recording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get start_recording;

  /// No description provided for @stop_recording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stop_recording;

  /// No description provided for @error_recording.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during recording'**
  String get error_recording;

  /// No description provided for @photo_captured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured'**
  String get photo_captured;

  /// No description provided for @audio_recorded.
  ///
  /// In en, this message translates to:
  /// **'Audio recorded'**
  String get audio_recorded;

  /// No description provided for @multimodal_not_supported.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Trials are currently not supported to run in a web browser. Please use the StudyU App for Android or iOS.'**
  String get multimodal_not_supported;

  /// No description provided for @camera_access_denied.
  ///
  /// In en, this message translates to:
  /// **'Camera access denied'**
  String get camera_access_denied;

  /// No description provided for @no_camera_available.
  ///
  /// In en, this message translates to:
  /// **'No camera available'**
  String get no_camera_available;

  /// No description provided for @microphone_access_denied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access denied'**
  String get microphone_access_denied;

  /// No description provided for @camera_error.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get camera_error;

  /// No description provided for @recording_error.
  ///
  /// In en, this message translates to:
  /// **'Recording error'**
  String get recording_error;

  /// No description provided for @storing_photo.
  ///
  /// In en, this message translates to:
  /// **'The photo is being stored'**
  String get storing_photo;

  /// No description provided for @storing_audio.
  ///
  /// In en, this message translates to:
  /// **'The audio file is being stored'**
  String get storing_audio;

  /// No description provided for @upload_error.
  ///
  /// In en, this message translates to:
  /// **'The file could not be uploaded'**
  String get upload_error;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get en;

  /// No description provided for @de.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get de;

  /// No description provided for @allow_analytics.
  ///
  /// In en, this message translates to:
  /// **'Allow app analytics'**
  String get allow_analytics;

  /// No description provided for @allow_analytics_desc.
  ///
  /// In en, this message translates to:
  /// **'All collected data is used only to improve app performance and never for tracking purposes. You can read more about this in our data privacy.'**
  String get allow_analytics_desc;

  /// No description provided for @video_test.
  ///
  /// In en, this message translates to:
  /// **'This is a video test'**
  String get video_test;

  /// No description provided for @survey_test.
  ///
  /// In en, this message translates to:
  /// **'This is a survey test'**
  String get survey_test;

  /// No description provided for @current_report.
  ///
  /// In en, this message translates to:
  /// **'Current report'**
  String get current_report;

  /// No description provided for @report_history.
  ///
  /// In en, this message translates to:
  /// **'Report history'**
  String get report_history;

  /// No description provided for @no_reports_found.
  ///
  /// In en, this message translates to:
  /// **'No reports defined yet'**
  String get no_reports_found;

  /// No description provided for @current_power_level.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get current_power_level;

  /// No description provided for @not_enough_data.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get not_enough_data;

  /// No description provided for @barely_enough_data.
  ///
  /// In en, this message translates to:
  /// **'Barely enough data'**
  String get barely_enough_data;

  /// No description provided for @enough_data.
  ///
  /// In en, this message translates to:
  /// **'Enough data'**
  String get enough_data;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms;

  /// No description provided for @terms_read.
  ///
  /// In en, this message translates to:
  /// **'Read Terms of Use'**
  String get terms_read;

  /// No description provided for @terms_content.
  ///
  /// In en, this message translates to:
  /// **'The terms of use give an overview on the purpose and use of the StudyU app. In case you have any questions please reach out to us via the contact information in the legal notice.'**
  String get terms_content;

  /// No description provided for @terms_agree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the terms of use'**
  String get terms_agree;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @privacy_read.
  ///
  /// In en, this message translates to:
  /// **'Read Privacy Policy'**
  String get privacy_read;

  /// No description provided for @privacy_content.
  ///
  /// In en, this message translates to:
  /// **'The privacy policy describes which data is stored, why, when, where, access rights, and which rights you have. In case you have any questions please reach out to us via the contact information in the legal notice.'**
  String get privacy_content;

  /// No description provided for @privacy_agree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the privacy policy'**
  String get privacy_agree;

  /// No description provided for @imprint_read.
  ///
  /// In en, this message translates to:
  /// **'Read Legal Notice'**
  String get imprint_read;

  /// No description provided for @invite_code_button.
  ///
  /// In en, this message translates to:
  /// **'Use invite code'**
  String get invite_code_button;

  /// No description provided for @private_study_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Private study invite code'**
  String get private_study_invite_code;

  /// No description provided for @invite_code.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get invite_code;

  /// No description provided for @invalid_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Not a valid invite code'**
  String get invalid_invite_code;

  /// No description provided for @save_pdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get save_pdf;

  /// No description provided for @was_saved_to.
  ///
  /// In en, this message translates to:
  /// **'The file was saved to '**
  String get was_saved_to;

  /// No description provided for @save_not_supported.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get save_not_supported;

  /// No description provided for @save_not_supported_description.
  ///
  /// In en, this message translates to:
  /// **'Downloading files is currently not supported in the web version.'**
  String get save_not_supported_description;

  /// No description provided for @eligible_no.
  ///
  /// In en, this message translates to:
  /// **'You are not eligible for this study'**
  String get eligible_no;

  /// No description provided for @eligible_yes.
  ///
  /// In en, this message translates to:
  /// **'You are eligible for this study'**
  String get eligible_yes;

  /// No description provided for @eligible_mistake.
  ///
  /// In en, this message translates to:
  /// **'If you made a mistake, you can still change your answers'**
  String get eligible_mistake;

  /// No description provided for @eligible_back.
  ///
  /// In en, this message translates to:
  /// **'Back to study selection'**
  String get eligible_back;

  /// No description provided for @eligible_choice_multi_selection.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get eligible_choice_multi_selection;

  /// No description provided for @report_overview.
  ///
  /// In en, this message translates to:
  /// **'Report overview'**
  String get report_overview;

  /// No description provided for @report_primary_result.
  ///
  /// In en, this message translates to:
  /// **'Primary Result'**
  String get report_primary_result;

  /// No description provided for @report_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'This report is only valid if you entered all information correctly.'**
  String get report_disclaimer;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @performance_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview of completion of tasks'**
  String get performance_overview;

  /// No description provided for @performance_overview_interventions.
  ///
  /// In en, this message translates to:
  /// **'Interventions'**
  String get performance_overview_interventions;

  /// No description provided for @performance_overview_observations.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get performance_overview_observations;

  /// No description provided for @report_outcome_inconclusive.
  ///
  /// In en, this message translates to:
  /// **'The results are inconclusive. There does not seem to be a statistically significant difference between the interventions.'**
  String get report_outcome_inconclusive;

  /// No description provided for @report_outcome_neither.
  ///
  /// In en, this message translates to:
  /// **'Both interventions seem to have a negative effect on the outcome for you.'**
  String get report_outcome_neither;

  /// No description provided for @report_outcome_one.
  ///
  /// In en, this message translates to:
  /// **'The intervention {intervention} seems to improve the outcome for you.'**
  String report_outcome_one(Object intervention);

  /// No description provided for @report_axis_phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get report_axis_phase;

  /// No description provided for @study_not_started.
  ///
  /// In en, this message translates to:
  /// **'Your study has not started yet. Please check back tomorrow!'**
  String get study_not_started;

  /// No description provided for @completed_study.
  ///
  /// In en, this message translates to:
  /// **'You completed your last study. Look at past reports or start a new study.'**
  String get completed_study;

  /// No description provided for @app_support.
  ///
  /// In en, this message translates to:
  /// **'App support'**
  String get app_support;

  /// No description provided for @app_support_text.
  ///
  /// In en, this message translates to:
  /// **'Contact for problems or questions with the app'**
  String get app_support_text;

  /// No description provided for @study_support.
  ///
  /// In en, this message translates to:
  /// **'Study support'**
  String get study_support;

  /// No description provided for @study_support_text.
  ///
  /// In en, this message translates to:
  /// **'Contact for problems or questions with the study'**
  String get study_support_text;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @irb.
  ///
  /// In en, this message translates to:
  /// **'Institutional Review Board'**
  String get irb;

  /// No description provided for @researchers.
  ///
  /// In en, this message translates to:
  /// **'Researchers'**
  String get researchers;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInfo;

  /// No description provided for @free_text_min_length_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least {min} characters'**
  String free_text_min_length_error(num min);

  /// No description provided for @free_text_max_length_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter at most {max} characters'**
  String free_text_max_length_error(num max);

  /// No description provided for @free_text_alphanumeric_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter only alphanumeric characters'**
  String get free_text_alphanumeric_error;

  /// No description provided for @free_text_numeric_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter only numeric characters'**
  String get free_text_numeric_error;

  /// No description provided for @free_text_custom_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter only characters matching the pattern {pattern}'**
  String free_text_custom_error(String pattern);

  /// No description provided for @app_outdated_message.
  ///
  /// In en, this message translates to:
  /// **'A new version of the StudyU App is available. Please update to get the latest features and improvements. Thank you for your support!'**
  String get app_outdated_message;

  /// No description provided for @update_now.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get update_now;

  /// No description provided for @text_summary_section_prefix_higher.
  ///
  /// In en, this message translates to:
  /// **'Your '**
  String get text_summary_section_prefix_higher;

  /// No description provided for @text_summary_section_was_higher.
  ///
  /// In en, this message translates to:
  /// **' was higher during intervention: '**
  String get text_summary_section_was_higher;

  /// No description provided for @text_summary_section_was_lower.
  ///
  /// In en, this message translates to:
  /// **' was lower during intervention: '**
  String get text_summary_section_was_lower;

  /// No description provided for @text_summary_section_compared_to.
  ///
  /// In en, this message translates to:
  /// **' compared to: '**
  String get text_summary_section_compared_to;

  /// No description provided for @text_summary_section_and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get text_summary_section_and;

  /// No description provided for @text_summary_section_no_evidence.
  ///
  /// In en, this message translates to:
  /// **'There was no evidence for a difference in '**
  String get text_summary_section_no_evidence;

  /// No description provided for @text_summary_section_between.
  ///
  /// In en, this message translates to:
  /// **' between interventions: '**
  String get text_summary_section_between;

  /// No description provided for @intervention.
  ///
  /// In en, this message translates to:
  /// **'Intervention'**
  String get intervention;

  /// No description provided for @phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get phase;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @no_data_available_yet.
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get no_data_available_yet;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @show_colorless_gauges.
  ///
  /// In en, this message translates to:
  /// **'Enable accessible charts'**
  String get show_colorless_gauges;

  /// No description provided for @welchs_t_test_results.
  ///
  /// In en, this message translates to:
  /// **'Welch\'s t-test Results'**
  String get welchs_t_test_results;

  /// No description provided for @sample_a.
  ///
  /// In en, this message translates to:
  /// **'Sample A'**
  String get sample_a;

  /// No description provided for @sample_b.
  ///
  /// In en, this message translates to:
  /// **'Sample B'**
  String get sample_b;

  /// No description provided for @sample_size.
  ///
  /// In en, this message translates to:
  /// **'n'**
  String get sample_size;

  /// No description provided for @mean.
  ///
  /// In en, this message translates to:
  /// **'mean'**
  String get mean;

  /// No description provided for @variance.
  ///
  /// In en, this message translates to:
  /// **'var'**
  String get variance;

  /// No description provided for @t_statistic.
  ///
  /// In en, this message translates to:
  /// **'t-statistic'**
  String get t_statistic;

  /// No description provided for @degrees_of_freedom.
  ///
  /// In en, this message translates to:
  /// **'Degrees of freedom'**
  String get degrees_of_freedom;

  /// No description provided for @p_value.
  ///
  /// In en, this message translates to:
  /// **'p-value'**
  String get p_value;

  /// No description provided for @result_significant.
  ///
  /// In en, this message translates to:
  /// **'Significantly different'**
  String get result_significant;

  /// No description provided for @result_not_significant.
  ///
  /// In en, this message translates to:
  /// **'Not significantly different'**
  String get result_not_significant;

  /// No description provided for @level_of_significance.
  ///
  /// In en, this message translates to:
  /// **'Level of significance'**
  String get level_of_significance;

  /// No description provided for @t_test_outcome_based_on.
  ///
  /// In en, this message translates to:
  /// **'The outcome is based on the following values:'**
  String get t_test_outcome_based_on;

  /// No description provided for @statistical_information.
  ///
  /// In en, this message translates to:
  /// **'Statistical Information'**
  String get statistical_information;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @significance_level_and_p_value.
  ///
  /// In en, this message translates to:
  /// **'Significance level and p-value'**
  String get significance_level_and_p_value;

  /// No description provided for @descriptive_statistics.
  ///
  /// In en, this message translates to:
  /// **'Descriptive statistics'**
  String get descriptive_statistics;

  /// Label for comparing results between two interventions or samples
  ///
  /// In en, this message translates to:
  /// **'Compare results between {nameA} and {nameB}'**
  String compare_results_between(String nameA, String nameB);

  /// No description provided for @missing_observations_note.
  ///
  /// In en, this message translates to:
  /// **'Note: Missing observations indicate days when data was not recorded.'**
  String get missing_observations_note;

  /// No description provided for @quick_summary.
  ///
  /// In en, this message translates to:
  /// **'Quick Summary'**
  String get quick_summary;

  /// No description provided for @average_score.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get average_score;

  /// No description provided for @data_completeness.
  ///
  /// In en, this message translates to:
  /// **'Data completeness'**
  String get data_completeness;

  /// No description provided for @statistic.
  ///
  /// In en, this message translates to:
  /// **'Statistic'**
  String get statistic;

  /// No description provided for @total_recordings.
  ///
  /// In en, this message translates to:
  /// **'Total recordings'**
  String get total_recordings;

  /// No description provided for @missing_recordings.
  ///
  /// In en, this message translates to:
  /// **'Missing recordings'**
  String get missing_recordings;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @support_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Support Email Sent'**
  String get support_email_sent;

  /// No description provided for @support_email_sent_description.
  ///
  /// In en, this message translates to:
  /// **'Your support request has been prepared in your email app. Please send the email to reach our support team and wait for their reply.\n\nIf you are currently participating in a study, please continue tracking your results outside the app until the issue is resolved. Thank you for your understanding.'**
  String get support_email_sent_description;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
