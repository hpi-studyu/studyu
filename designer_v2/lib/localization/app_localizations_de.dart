// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get studyu => 'StudyU';

  @override
  String get loading_message => 'Laden...';

  @override
  String get language => 'Sprache';

  @override
  String get language_select_tooltip => 'Sprache auswählen';

  @override
  String get locale_en => 'Englisch';

  @override
  String get locale_de => 'Deutsch';

  @override
  String get navlink_error_home => 'Zur Startseite';

  @override
  String get imprint => 'Impressum';

  @override
  String get link_forgot_password => 'Passwort vergessen?';

  @override
  String get link_signup_description => 'Noch kein Nutzerkonto?';

  @override
  String get link_signup => 'Registrieren';

  @override
  String get link_login_description => 'Bereits ein Nutzerkonto?';

  @override
  String get link_login_description2 => 'Zum Workspace?';

  @override
  String get link_login => 'Anmelden';

  @override
  String get action_button_login => 'Anmelden';

  @override
  String get action_button_signup => 'Nutzerkonto erstellen';

  @override
  String get action_button_password_reset => 'Passwort zurücksetzen';

  @override
  String get signup_tos_intro => 'Ich habe die ';

  @override
  String get signup_tos_terms_of_service => 'Nutzungsbedingungen ';

  @override
  String get signup_tos_and => 'und ';

  @override
  String get signup_tos_privacy_policy => 'Datenschutzbestimmungen ';

  @override
  String get signup_tos_outro =>
      'von StudyU gelesen und bin damit einverstanden.';

  @override
  String get login_page_title => 'Im Workspace anmelden';

  @override
  String get login_page_description =>
      'Gestalte deine Forschung oder Behandlung individuell und effizient mit digitalen N-of-1 Studien.';

  @override
  String get signup_page_title => 'Neuen Workspace anlegen';

  @override
  String get signup_page_description =>
      'Lege jetzt mit digitalen N-of-1 Studien los, um deine Forschung oder Behandlung effizienter und individueller zu gestalten. Free, open source & open science!';

  @override
  String get password_forgot_page_title => 'Passwort zurücksetzen';

  @override
  String get password_forgot_page_description =>
      'Bitte gib die mit deinem Nutzerkonto verknüpfte Email-Addresse ein & wir schicken dir eine Email zum Zurücksetzen deines Passworts.';

  @override
  String get password_recover_page_title => 'Neues Passwort festlegen';

  @override
  String get form_field_email => 'Email';

  @override
  String get form_field_email_hint => 'Email';

  @override
  String get form_field_password => 'Passwort';

  @override
  String get form_field_password_hint => 'Passwort';

  @override
  String get form_field_password_confirm => 'Passwort bestätigen';

  @override
  String get form_field_password_confirm_hint => 'Passwort erneut eingeben';

  @override
  String get form_field_email_invalid => 'Das ist keine gültige Email-Addresse';

  @override
  String get form_field_password_mustmatch =>
      'Die Passwörter stimmen nicht überein';

  @override
  String form_field_password_minlength(num minLength) {
    return 'Passwörter müssen mindestens $minLength Zeichen lang sein';
  }

  @override
  String get form_field_password_new => 'Neues Passwort';

  @override
  String get form_field_password_new_hint => 'Neues Passwort';

  @override
  String get form_field_password_new_confirm => 'Neues Passwort wiederholen';

  @override
  String get form_field_password_new_confirm_hint =>
      'Neues Passwort wiederholen';

  @override
  String get notification_password_reset_check_email =>
      'Schaue in deinen Email-Account nach, um dein Passwort zurückzusetzen!';

  @override
  String get notification_password_reset_success =>
      'Passwort erfolgreich zurückgesetzt';

  @override
  String get notification_credentials_invalid =>
      'Die Zugangsdaten sind ungültig';

  @override
  String get notification_user_already_registered =>
      'Ein Nutzerkonto mit dieser Email-Addresse existiert bereits';

  @override
  String get navlink_my_studies => 'Meine Studien';

  @override
  String get navlink_shared_studies => 'Mit mir geteilt';

  @override
  String get navlink_public_studies => 'Studienregister';

  @override
  String get navlink_public_studies_tooltip =>
      'Das Studienregister ist eine Sammmlung von Studien, die mit Hilfe von StudyU durchgeführt werden & \nvon den Erstellern für andere veröffentlicht wurden. Im Sinne von Open Science verfolgt es die Absicht, \ndie Transparenz und Zusammenarbeit aller Forscher und Kliniker auf der StudyU Plattform zu fördern.';

  @override
  String get navlink_public_studies_description =>
      'Das Studienregister ist eine Sammmlung von Studien, die mit Hilfe von StudyU durchgeführt werden & von den Erstellern für andere veröffentlicht wurden. Im Sinne von Open Science verfolgt es die Absicht, die Transparenz und Zusammenarbeit aller Forscher und Kliniker auf der StudyU Plattform zu fördern.';

  @override
  String get navlink_account_settings => 'Einstellungen';

  @override
  String get navlink_logout => 'Abmelden';

  @override
  String get study_status_draft => 'Entwurf';

  @override
  String get study_status_draft_description => 'Die Studie ist noch in Planung';

  @override
  String get study_status_running => 'Live';

  @override
  String get study_status_running_description =>
      'Die Studie wird gerade durchgeführt';

  @override
  String get study_status_closed => 'Abgeschlossen';

  @override
  String get study_status_closed_description =>
      'Diese Studie ist abgeschlossen.\nEs können sich keine neuen Teilnehmer mehr einschreiben.';

  @override
  String get participation_open_who => 'Für jeden offen';

  @override
  String get participation_open_who_description =>
      'Jeder kann sich für die Studie in der StudyU App anmelden.';

  @override
  String get participation_invite_who => 'Ausgewählte Teilnehmer';

  @override
  String get participation_invite_who_description =>
      'Nur ausgewählte Nutzer mit Teilnahme-Code könnten sich für die Studie in der StudyU App anmelden.';

  @override
  String get participation_open_as_adjective => 'für jeden offen';

  @override
  String get participation_invite_as_adjective =>
      'nur für ausgewählte Teilnehmer offen';

  @override
  String get participation_open_launch_description =>
      'Nach dem Start kann sich jeder in der StudyU App für die Studie anmelden.';

  @override
  String get participation_invite_launch_description =>
      'Nach dem Start kannst du Teilnehmer zu deiner Studie mittels Teilnahmecodes einladen.';

  @override
  String get phase_sequence_alternating => 'Alternierend (AB AB)';

  @override
  String get phase_sequence_counterbalanced => 'Ausgeglichen (AB BA)';

  @override
  String get phase_sequence_random => 'Zufällig';

  @override
  String get phase_sequence_custom => 'Benutzerdefiniert';

  @override
  String get phase_sequence_custom_label => 'Benutzerdefinierte Abfolge';

  @override
  String get phase_sequence_custom_label_help =>
      'Gib die Abfolge der Interventionsphasen an, z.B. ABBA';

  @override
  String get form_enrollment_option_open => 'Open';

  @override
  String get form_enrollment_option_invite => 'Private (Invite-only)';

  @override
  String get notification_code_deleted => 'Teilnahmecode gelöscht';

  @override
  String get notification_code_clipboard =>
      'Code wurde in die Zwischenablage kopiert';

  @override
  String get action_button_new_study => 'Neue Studie';

  @override
  String get search => 'Suche';

  @override
  String get studies_list_header_title => 'Titel';

  @override
  String get studies_list_header_status => 'Status';

  @override
  String get studies_list_header_participation => 'Teilnahme';

  @override
  String get studies_list_header_created_at => 'Erstellt';

  @override
  String get studies_list_header_participants_enrolled => 'Angemeldet';

  @override
  String get studies_list_header_participants_active => 'Aktiv';

  @override
  String get studies_list_header_participants_completed => 'Abgeschlossen';

  @override
  String get studies_not_found => 'Es konnten keine Studien gefunden werden';

  @override
  String get modify_query =>
      'Verändere deine Suchanfrage, um mehr Studien in die Suche miteinzubeziehen';

  @override
  String get studies_empty => 'Du hast noch keine Studien erstellt';

  @override
  String get studies_empty_description =>
      'Erstelle deine eigene Studie von Grund auf oder erstelle einen Entwurf aus einer bereits veröffentlichten Studie';

  @override
  String get navlink_learn => 'Lernen';

  @override
  String get navlink_study_design => 'Entwerfen';

  @override
  String get navlink_study_test => 'Testen';

  @override
  String get navlink_study_recruit => 'Rekrutieren';

  @override
  String get navlink_study_monitor => 'Durchführen';

  @override
  String get navlink_study_analyze => 'Analysieren';

  @override
  String get navlink_share => 'Teilen';

  @override
  String get navlink_study_design_info => 'Allgemeine Infos';

  @override
  String get navlink_study_design_enrollment => 'Teilnahme';

  @override
  String get navlink_study_design_interventions => 'Interventionen';

  @override
  String get navlink_study_design_measurements => 'Messungen';

  @override
  String get navlink_unavailable_tooltip => 'Diese Seite ist nicht zugänglich';

  @override
  String get study_settings => 'Studien-Einstellungen';

  @override
  String get study_settings_publish_study => 'Studie veröffentlichen';

  @override
  String get study_settings_publish_study_tooltip =>
      'Andere Forscher und Kliniker können deine Studie begutachten, sie testen und als Entwurf duplizieren.\nDie zur laufenden oder abgeschlossen Studie gehörigen Teilnehmer- und Ergebnisdaten werden nicht \nfür andere freigegeben (die Unterseiten Rekrutieren, Durchführen und Analysieren deiner Studie bleiben \nunzugänglich).';

  @override
  String get study_settings_publish_study_launch_description =>
      'Ich stimme zu, dass meine Studie im Studienregister veröffentlicht wird, um die Transparenz & Zusammenarbeit aller Forscher und Kliniker auf der StudyU Plattform zu fördern. (Andere Forscher und Kliniker können auf die Studie selbst zugreifen, die zur laufenden oder abgeschlossen Studie gehörigen Teilnehmer- und Ergebnisdaten werden aber nicht freigegeben)';

  @override
  String get study_settings_publish_results => 'Ergebnisse veröffentlichen';

  @override
  String get study_settings_publish_results_tooltip =>
      'Andere Forscher und Kliniker können auf die anonymisierten Ergebnisdaten einer Studie zugreifen, \nsie exportieren und analysieren (die Analysieren-Unterseite deiner Studie ist zugänglich). Die Studie \nselbst wird dadurch automatisch auch für andere Forscher und Kliniker im Studienregister veröffentlicht.';

  @override
  String get action_button_study_launch => 'Studie starten';

  @override
  String get action_button_study_close => 'Studie schließen';

  @override
  String get notification_study_deleted => 'Die Studie wurde gelöscht';

  @override
  String get notification_study_closed => 'Die Studie wurde geschlossen';

  @override
  String get notification_study_closed_description =>
      'Neue Teilnehmer können sich nicht mehr einschreiben';

  @override
  String get dialog_study_close_title => 'Teilnahme schließen?';

  @override
  String get dialog_study_close_description =>
      'Bist du sicher, dass die Teilnahme an der Studie geschlossen werden soll? Dadurch können keine neuen Teilnehmer mehr aufgenommen werden. Bereits eingeschriebene Teilnehmer werden die Studie weiterhin durchführen können. Das Schließen einer Studie kann nicht rückgängig gemacht werden.';

  @override
  String get dialog_study_delete_title => 'Dauerhaft löschen?';

  @override
  String get dialog_study_delete_description =>
      'Bist du sicher, dass die Studie gelöscht werden soll? Die Studie und alle gesammelten Daten gehen dabei unwiderruflich verloren.';

  @override
  String get form_question_create => 'Neue Frage';

  @override
  String get form_question_edit => 'Frage bearbeiten';

  @override
  String get form_question_readonly => 'Frage';

  @override
  String get form_field_question => 'Frage an Teilnehmer';

  @override
  String get form_field_question_tooltip =>
      'Gib die Frage ein, die von Teilnehmern in der App beantwortet werden soll';

  @override
  String get form_field_question_required =>
      'Die Frage an Teilnehmer darf nicht leer sein';

  @override
  String get form_field_question_help_text => 'Erläuterungen zur Frage';

  @override
  String get form_field_question_help_text_tooltip =>
      'Gib einen zusätzlichen Hilfstext ein, der in der App mit einem Hilfs-Icon neben der Frage angezeigt wird';

  @override
  String get form_field_question_help_text_hint =>
      'Gib zusätzliche Informationen oder Erklärungen zur Frage';

  @override
  String get form_field_question_help_text_add => 'Hilftext hinzufügen';

  @override
  String get form_field_question_help_text_add_tooltip =>
      'Gib einen zusätzlichen Hilfstext ein, der in der App mit einem Hilfs-Icon neben der Frage angezeigt wird';

  @override
  String get form_field_question_response_options => 'Antwortoptionen';

  @override
  String get form_field_question_response_options_tooltip =>
      'Definiere welche Optionen zur Beantwortung der Frage in der App verfügbar sind';

  @override
  String get form_field_question_response_options_description =>
      'Wähle die Antwortoptionen so, dass sie zur Frage passen und die von dir gewünschten Daten erhoben werden.';

  @override
  String get question_type_choice => 'Multiple-Choice';

  @override
  String get question_type_free_text => 'Freitext';

  @override
  String get question_type_bool => 'Ja/Nein';

  @override
  String get question_type_scale => 'Skala';

  @override
  String get question_type_image => 'Bild';

  @override
  String get question_type_audio => 'Audio';

  @override
  String get question_type_fitbit => 'Fitbit';

  @override
  String get form_array_response_options_bool_yes => 'Ja';

  @override
  String get form_array_response_options_bool_no => 'No';

  @override
  String get form_field_response_image => 'Bild';

  @override
  String get form_field_response_audio => 'Audio';

  @override
  String get form_field_response_audio_max_duration_label =>
      'Maximale Aufnahmedauer in Sekunden';

  @override
  String get form_field_response_choice_multiple => 'Mehrfachauswahl';

  @override
  String get form_field_response_choice_multiple_tooltip =>
      'Erlaubt die Auswahl von mehreren Antwortoptionen gleichzeitig,\nansonsten kann nur eine einzige Option ausgewählt werden';

  @override
  String get form_array_response_options_choice_new =>
      'Antwortoption hinzufügen';

  @override
  String get form_array_response_options_choice_hint => 'Option';

  @override
  String get form_field_response_scale_min_label => 'Start-Beschriftung';

  @override
  String get form_field_response_scale_min_label_tooltip =>
      'Gib eine Beschriftung ein, die an der zu dem Wert gehörigen Position auf der Skala angezeigt wird';

  @override
  String get form_field_response_scale_min_value => 'Startwert';

  @override
  String get form_field_response_scale_max_label => 'End-Beschriftung';

  @override
  String get form_field_response_scale_max_label_tooltip =>
      'Gib eine Beschriftung ein, die an der zu dem Wert gehörigen Position auf der Skala angezeigt wird';

  @override
  String get form_field_response_scale_max_value => 'Endwert';

  @override
  String get form_field_response_scale_label_hint => 'Optionale Beschriftung';

  @override
  String get form_array_response_scale_mid_values => 'Werte dazwischen zeigen';

  @override
  String get form_array_response_scale_mid_values_dirty_banner =>
      'Die Zwischenwerte und -Beschriftungen werden automatisch mit dem Start- und Endwert der Skala synchronisiert.';

  @override
  String get form_field_response_scale_colors_add => 'Farben hinzufügen';

  @override
  String get form_field_response_scale_color_add => 'Farbe hinzufügen';

  @override
  String get form_field_response_scale_color_min => 'Startfarbe';

  @override
  String get form_field_response_scale_color_max => 'Endfarbe';

  @override
  String get form_field_response_scale_color_tooltip =>
      'Definiere Farben für die Darstellung der Skala in der StudyU App';

  @override
  String get navlink_question_visuals => 'Visuelle Darstellung';

  @override
  String get navlink_question_visuals_description =>
      'Passe die Darstellung der Frage in der StudyU App an, um Teilnehmer visuell zu unterstützen. Es ändert sich dadurch nichts an den Daten & Werten, die erhoben werden.';

  @override
  String form_array_response_options_choice_countmin(num count) {
    return 'Die Frage muss mindestens $count gültige Antwortoptionen haben';
  }

  @override
  String form_array_response_options_choice_countmax(num count) {
    return 'Die Frage darf nicht mehr als $count gültige Antwortoptionen haben';
  }

  @override
  String get form_array_response_options_scale_rangevalid_min =>
      'Der Startwert muss kleiner als der Endwert der Skala sein';

  @override
  String form_array_response_options_scale_rangevalid_max(num count) {
    return 'Die Differenz zwischen dem Start- und Endwert der Skala darf maximal $count betragen';
  }

  @override
  String get audio_recording_max_duration_rangevalid_min =>
      'Die minimale Aufnahmedauer beträgt 1 Sekunde';

  @override
  String audio_recording_max_duration_rangevalid_max(num count) {
    return 'Die maximale Aufnahmedauer beträgt $count Sekunden';
  }

  @override
  String get free_text_question_logic_not_supported =>
      'Logik ist für Freitext-Fragen noch nicht verfügbar';

  @override
  String get free_text_question_type_any => 'Beliebig';

  @override
  String get free_text_question_type_alphanumeric => 'Alphanumerisch';

  @override
  String get free_text_question_type_numeric => 'Numerisch';

  @override
  String get free_text_question_type_custom => 'Benutzerdefiniert';

  @override
  String get free_text_range_label => 'Erlaubter Bereich der Textlänge';

  @override
  String get free_text_range_label_helper =>
      'Geben Sie die minimale und maximale Anzahl von Zeichen ein, die für die Antwort erlaubt sind';

  @override
  String get free_text_type_label => 'Erlaubter Texttyp';

  @override
  String get free_text_type_label_helper =>
      'Wählen Sie den Typ des Texts aus, der für die Antwort erlaubt ist';

  @override
  String get free_text_type_custom_label => 'Regulärer Ausdruck';

  @override
  String get free_text_type_custom_label_helper =>
      'Geben Sie einen regulären Ausdruck ein, den die Antwort erfüllen muss';

  @override
  String get free_text_type_custom_helper =>
      'Beispiel: Geben Sie [a-zA-Z]+ ein, um nur Buchstaben zuzulassen.';

  @override
  String get free_text_type_custom_explanation =>
      'Jede Eingabe, die nicht dem Ausdruck entspricht, wird abgelehnt. Die oben angegebenen Einschränkungen zur Zeichenlänge werden weiterhin angewendet. Ein führendes ^ Zeichen und ein abschließendes \$ Zeichen werden automatisch hinzugefügt.';

  @override
  String get free_text_example_label => 'Beispieltextfeld';

  @override
  String get free_text_example_label_helper =>
      'Dies ist ein Beispiel für das Textfeld, das dem Teilnehmer angezeigt wird. Die oben angegebenen Einschränkungen zur Länge und zum Eingabetyp werden angewendet.';

  @override
  String get free_text_example_valid => 'Ihre Beispiel-Eingabe ist gültig';

  @override
  String get free_text_example_default_helper =>
      'Führen Sie einen Validierungstest durch, indem Sie hier Text eingeben.';

  @override
  String free_text_validation_min_length(num countMin) {
    return 'Die Eingabe muss mindestens $countMin Zeichen lang sein.';
  }

  @override
  String free_text_validation_max_length(num countMax) {
    return 'Die Eingabe darf höchstens $countMax Zeichen lang sein.';
  }

  @override
  String get free_text_validation_pattern =>
      'Die Eingabe muss dem angegebenen Format entsprechen.';

  @override
  String get free_text_validation_number => 'Die Eingabe muss eine Zahl sein.';

  @override
  String free_text_example_explanation(
      String type, num countMin, num countMax) {
    return 'Eingaben vom Typ $type mit einer Zeichenlänge im Bereich von $countMin bis $countMax werden akzeptiert.';
  }

  @override
  String get free_text_question_type_any_explanation =>
      'Jede Eingabe wird akzeptiert.';

  @override
  String get free_text_question_type_alphanumeric_explanation =>
      'Alphanumerische Eingabe umfasst nur Buchstaben und Zahlen.';

  @override
  String get free_text_question_type_numeric_explanation =>
      'Numerische Eingabe umfasst Zahlen ohne Sonderzeichen.';

  @override
  String get free_text_question_type_custom_explanation =>
      'Die Eingabe muss dem angegebenen regulären Ausdruck entsprechen.';

  @override
  String get fitbit_question_title => 'Fitbit';

  @override
  String get fitbit_question_type_empty => 'No Fitbit data available';

  @override
  String get banner_study_readonly_title =>
      'Die Studie kann nicht bearbeitet werden.';

  @override
  String get banner_study_readonly_description =>
      'Du kannst nur Studien bearbeiten, die du selbst erstellt hast oder die mit dir zur Mitarbeit geteilt wurden. Studien, die bereits gestartet sind, können grundsätzlich nicht mehr verändert werden.';

  @override
  String get banner_study_closed_title => 'Diese Studie ist geschlossen.';

  @override
  String get banner_study_closed_description =>
      'Neue Teilnehmer können sich nicht in diese Studie einschreiben.';

  @override
  String get form_section_scheduling => 'Zeitplan & Einhaltung';

  @override
  String get form_section_scheduling_description =>
      'Um die Compliance von Teilnehmern zu verbessern, kannst du ein begrenztes Zeitfenster & eine App-Benachrichtigung als Erinnerung definieren.';

  @override
  String get form_field_has_reminder => 'Erinnerung';

  @override
  String get form_field_has_reminder_tooltip =>
      'Wähle diese Option, um Teilnehmer zur gegebenen Zeit über eine Benachrichtigung (Notification)\nan die Erfüllung der Aufgabe in der StudyU App zu erinnern.';

  @override
  String get form_field_has_reminder_label => 'Teilnehmer benachrichtigen';

  @override
  String get form_field_time_of_day_hint => 'hh:mm';

  @override
  String get form_field_time_restriction => 'Zeitbeschränkung';

  @override
  String get form_field_time_restriction_tooltip =>
      'Gib die Tageszeiten an, zu denen die Aufgabe von Teilnehmern erfüllt werden muss. Die Aufgabe kann außerhalb \ndieses Zeitfensters nicht abgeschlossen werden, d.h. es werden für diesen Tag dann keine Daten erhoben.';

  @override
  String get form_field_time_restriction_start_hint => 'Von';

  @override
  String get form_field_time_restriction_end_hint => 'Bis';

  @override
  String get form_study_design_info_description =>
      'Auf dieser Seite gibst du allgemeine Informationen für Teilnehmer der Studie an. Wenn du dich entscheidest, die Studie im Studienregister zu veröffentlichen, sind diese Informationen auch für andere Forscher und Kliniker einsehbar.';

  @override
  String get form_field_study_title => 'Studientitel';

  @override
  String get form_field_study_title_tooltip =>
      'Gib den Titel der Studie an, so wie er in der StudyU App angezeigt werden soll';

  @override
  String get form_field_study_title_required =>
      'Die Studie muss einen Titel haben';

  @override
  String get form_field_study_title_default => 'Unbenannte Studie';

  @override
  String get form_field_study_description => 'Beschreibung';

  @override
  String get form_field_study_description_tooltip =>
      'Beschreibe die Studie kurz und verständlich für Teilnehmer';

  @override
  String get form_field_study_description_hint =>
      'Beschreibe die Studie kurz und verständlich für Teilnehmer';

  @override
  String get form_field_study_description_required =>
      'Die Studie muss eine Beschreibung haben';

  @override
  String get form_field_study_tags => 'Schlagwörter';

  @override
  String get form_field_study_tags_hint =>
      'Füge ein Schlagwort hinzu und drücke die Enter Taste';

  @override
  String get form_field_study_tags_tooltip =>
      'Schlagwörter ermöglichen es anderen Wissenschaftlern und Teilnehmern die Studie besser zu finden';

  @override
  String form_field_study_tags_error_length(Object count) {
    return 'Es dürfen maximal $count Schlagwörter zu einer Studie hinzugefügt werden';
  }

  @override
  String form_field_study_tags_helper(Object count) {
    return 'Wähle bis zu $count Schlagwörter aus, die die Studie beschreiben';
  }

  @override
  String get form_field_study_icon_required => 'Die Studie muss ein Icon haben';

  @override
  String get form_section_publisher => 'Herausgeber und Kontakt';

  @override
  String get form_section_publisher_description =>
      'Teilnehmer der Studie können gemäß den hier angegebenen Informationen über die StudyU App mit dir in Kontakt treten. Andere Forscher oder Kliniker können dich nur kontaktieren, wenn die Studie im Studienregister veröffentlicht ist.';

  @override
  String get form_field_organization => 'Verantwortliche Organisation';

  @override
  String get form_field_organization_required =>
      'Die Studie muss eine verantwortliche Organisation haben';

  @override
  String get form_field_review_board => 'Institutionelles Prüfungsgremium';

  @override
  String get form_field_review_board_required =>
      'Du musst das für die Studie zuständige Prüfungsgremium angeben';

  @override
  String get form_field_review_board_number =>
      'Protokollnummer des Prüfungsgremiums';

  @override
  String get form_field_review_board_number_required =>
      'Du musst die der Studie zugewiesene Protokollnummer des zuständigen Prüfungsgremiums angeben';

  @override
  String get form_field_researchers => 'Verantwortliche Person(en)';

  @override
  String get form_field_researchers_required =>
      'Du musst einen oder mehrere für die Studie verantwortliche Forscher oder Kliniker angeben';

  @override
  String get form_field_website => 'Studien-Webseite';

  @override
  String get form_field_website_pattern =>
      'Bitte gib eine korrekte Webseite zur Studie an';

  @override
  String get form_field_contact_email => 'Email';

  @override
  String get form_field_contact_email_required =>
      'Die Studie muss eine Email-Addresse zur Kontaktaufnahme haben';

  @override
  String get form_field_contact_email_email =>
      'Bitte gib eine korrekte Email zur Kontaktaufnahme ein';

  @override
  String get form_field_contact_phone => 'Telefon';

  @override
  String get form_field_contact_phone_required =>
      'Die Studie muss eine Telefonnummer zur Kontaktaufnahme haben';

  @override
  String get form_field_contact_additional_info => 'Zusätzliche Informationen';

  @override
  String get form_study_design_enrollment_description =>
      'Auf dieser Seite gibst du an wer an deiner Studie unter welchen Bedingungen teilnehmen darf.';

  @override
  String get form_field_enrollment_type => 'Teilnehmer';

  @override
  String get form_field_enrollment_type_open_description =>
      'Jeder kann sich in der StudyU App für die Studie anmelden, solange die Eignung mittels Screening-Kriterien festgestellt wird und die Einwilligung zur Teilnahme abgegeben wird.';

  @override
  String get form_field_enrollment_type_invite_description =>
      'Nur ausgewählte Teilnehmer können sich für die Studie durch Eingabe eines Teilnahme-Codes in der StudyU App anmelden. Wähle diese Option aus, wenn die Teilnehmer der Studie bereits vorausgewählt wurden.';

  @override
  String get form_array_screener_questions_title => 'Screening-Kriterien';

  @override
  String get form_array_screener_questions_description =>
      'Du kannst Screening-Kriterien festlegen, um die Eignung für die Teilnahme an der Studie festzustellen & einzuschränken. Wenn die Teilnehmer deiner Studie bereits geprüft und vorausgewählt wurden, kannst du diesen Schritt auch überspringen.';

  @override
  String get form_array_screener_questions_new => 'Screening-Frage hinzufügen';

  @override
  String get form_array_screener_questions_test => 'Screening testen';

  @override
  String get form_array_consent_items_title =>
      'Einwilligung zur Studienteilnahme';

  @override
  String get form_array_consent_items_description =>
      'Hier kannst du die Erklärung(en) hinzufügen, die von Teilnehmern eingewilligt werden müssen, wenn sie sich in der StudyU App für die Studie anmelden. Wenn die Teilnehmer deiner Studie bereits vorausgewählt wurden und ihre Einwilligung erklärt haben, kannst du diesen Schritt auch überspringen.';

  @override
  String get form_array_consent_items_new => 'Einwilligung einholen';

  @override
  String get form_array_consent_items_test => 'Einwilligung testen';

  @override
  String get form_screener_question_create => 'Neue Screening-Frage';

  @override
  String get form_screener_question_edit => 'Screening-Frage bearbeiten';

  @override
  String get form_screener_question_readonly => 'Screening-Frage';

  @override
  String get form_screener_question_logic_qualify => 'Qualifizierend';

  @override
  String get form_screener_question_logic_disqualify => 'Disqualifizierend';

  @override
  String get navlink_screener_question_content => 'Inhalt';

  @override
  String get navlink_screener_question_logic => 'Logik';

  @override
  String get form_array_screener_question_logic_title => 'Screening-Logik';

  @override
  String get form_array_screener_question_logic_description =>
      'Definiere, welche Antworten zur Studienteilnahme berechtigen oder disqualifizieren. Um an der Studie teilnehmen zu können, muss für diese Frage mindestens eine qualifizierende Antwort & keine disqualifizierende Antwort ausgewählt werden.';

  @override
  String get form_array_screener_question_logic_tooltip =>
      'Definiere, welche Antworten zur Studienteilnahme berechtigen oder disqualifizieren';

  @override
  String get form_array_screener_question_logic_dirty_banner =>
      'Die hier aufgelisteten Antwortmöglichkeiten werden automatisch mit der Frage synchronisiert. Standardmäßig berechtigt jede Antwort zur Teilnahme an der Studie, es sei denn du markierst sie explizit als disqualifizierend.';

  @override
  String get form_consent_create => 'Neue Einwilligung';

  @override
  String get form_consent_edit => 'Einwilligung bearbeiten';

  @override
  String get form_consent_readonly => 'Einwilligung';

  @override
  String get form_field_consent_title => 'Kurztitel';

  @override
  String get form_field_consent_title_tooltip =>
      'Gib einen Kurztitel für die Einwilligungserklärung ein';

  @override
  String get form_field_consent_title_hint => 'Kurztitel eingeben';

  @override
  String get form_field_consent_title_required =>
      'Du musst einen Kurztitel für die Einwilligungserklärung angeben';

  @override
  String get form_field_consent_text => 'Einwilligungserklärung';

  @override
  String get form_field_consent_text_tooltip =>
      'Gib den Text ein, der bei der Anmeldung zur Studie in der StudyU App gelesen & bestätigt werden muss';

  @override
  String get form_field_consent_text_hint =>
      'Gib den Text ein, der gelesen & bestätigt werden muss';

  @override
  String get form_field_consent_text_required =>
      'Die Einwilligungserklärung darf nicht leer sein';

  @override
  String get form_study_design_interventions_description =>
      'Auf dieser Seite legst du die in der Studie zu untersuchenden Interventionen und deren zeitliche Abfolge fest. In N-of-1 Studien durchläuft der gleiche Teilnehmer eine festgelegte Abfolge von Interventionsphasen in einem oder mehreren Durchläufen (diese Art von Versuchsaufbau wird auch als Cross-over Studie bezeichnet). Jede Interventionsphase besteht aus einer oder mehreren Maßnahmen, die während der jeweils aktiven Phasen vom Teilnehmer erfüllt werden müssen.\n\nBitte beachte: wenn du mehr als zwei Interventionsphasen festlegst, können Teilnehmer bei der Anmeldung zur Studie zwei beliebige Interventionen auswählen, die im weiteren Verlauf miteinander verglichen werden.';

  @override
  String get link_n_of_1_learn_more => 'Mehr über N-of-1 Studien erfahren';

  @override
  String get link_n_of_1_learn_more_url =>
      'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3118090/pdf/nihms297482.pdf';

  @override
  String form_array_interventions_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_interventions_minlength',
      two:
          'Du brauchst mindestens einen Fragebogen, um den Effekt der Intervention(en) zu messen.',
    );
    return '$_temp0';
  }

  @override
  String get form_array_interventions => 'Interventionsphasen';

  @override
  String get form_array_interventions_new => 'Neue Intervention';

  @override
  String get form_array_interventions_empty_title =>
      'Noch keine Interventionen definiert';

  @override
  String get form_array_interventions_empty_description =>
      'Du brauchst mindestens zwei Interventionen, die verglichen werden sollen.';

  @override
  String get form_field_intervention_title => 'Titel';

  @override
  String get form_field_intervention_title_required =>
      'Der Titel der Interventionsphase darf nicht leer sein';

  @override
  String get form_field_intervention_title_default =>
      'Unbenannte Interventionsphase';

  @override
  String get form_field_intervention_title_tooltip =>
      'Gib den Titel der Interventionsphase an, so wie er in der App angezeigt werden soll';

  @override
  String get form_field_intervention_description => 'Beschreibung';

  @override
  String get form_field_intervention_description_tooltip =>
      'Gib einen Erklärungstext ein, der zu Beginn der Interventionsphase und als Beschreibung\nfür die Interventionsphase im Studienplan angezeigt wird';

  @override
  String get form_field_intervention_description_hint =>
      'Beschreibe die Interventionsphase kurz für Teilnehmer';

  @override
  String get form_array_intervention_tasks => 'Interventions-Maßnahmen';

  @override
  String get form_array_intervention_tasks_description =>
      'Hier legst du fest, welche Maßnahmen während der Interventionsphase von Teilnehmern täglich erfüllt werden sollen. Eine entsprechende Aufforderung wird in der StudyU App angezeigt.';

  @override
  String get form_array_intervention_tasks_new => 'Maßnahme hinzufügen';

  @override
  String get form_array_intervention_tasks_empty_title =>
      'Noch keine Maßnahmen festgelegt';

  @override
  String get form_array_intervention_tasks_empty_description =>
      'Du musst mindestens eine Maßnahme definieren, die während der Interventionsphase erfüllt werden soll.';

  @override
  String form_array_intervention_tasks_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_intervention_tasks_minlength',
      one:
          'Du musst mindestens eine Maßnahme definieren, die während der Interventionsphase erfüllt werden soll',
    );
    return '$_temp0';
  }

  @override
  String get form_intervention_task_create => 'Neue Maßnahme';

  @override
  String get form_intervention_task_edit => 'Maßnahme bearbeiten';

  @override
  String get form_intervention_task_readonly => 'Maßnahme';

  @override
  String get form_field_intervention_task_title => 'Titel';

  @override
  String get form_field_intervention_task_default => 'Unbenannte Maßnahme';

  @override
  String get form_field_intervention_task_title_tooltip =>
      'Gib den Titel der Maßnahme an, so wie er für die tägliche Aufforderung in der StudyU App angezeigt werden soll';

  @override
  String get form_field_intervention_task_title_required =>
      'Der Titel der Maßnahme darf nicht leer sein';

  @override
  String get form_field_intervention_task_description => 'Beschreibung';

  @override
  String get form_field_intervention_task_description_tooltip =>
      'Gib wahlweise eine ausführliche Erklärung ein, die als Beschreibung zur täglichen Aufforderung in der StudyU angezeigt wird';

  @override
  String get form_field_intervention_task_description_hint =>
      'Beschreibe die Maßnahme ausführlich, zB. kannst du ein Video verlinken';

  @override
  String get form_field_intervention_task_mark_as_completed_label =>
      'Teilnehmer müssen die Maßnahme \"Als bestätigt markieren\"';

  @override
  String get form_section_crossover_schedule => 'Versuchsplan';

  @override
  String get navlink_crossover_schedule_test => 'Versuchsplan testen';

  @override
  String get form_field_crossover_schedule_sequence => 'Abfolge der Phasen';

  @override
  String get form_field_crossover_schedule_sequence_tooltip =>
      'Wähle wie die Interventionsphasen im Versuchsplan zeitlich angeordnet werden';

  @override
  String get form_field_crossover_schedule_sequence_description =>
      'Die hier festgelegte Abfolge gilt standardmäßig für alle Teilnehmer. Für Studien mit ausgewählten Teilnehmern kann die Abfolge im Teilnahmecode individuell überschrieben werden.';

  @override
  String get form_field_crossover_schedule_phase_length => 'Phasenlänge';

  @override
  String get form_field_crossover_schedule_phase_length_tooltip =>
      'Lege fest wie lange ein einziger Durchlauf einer Interventionsphase dauert';

  @override
  String form_field_crossover_schedule_phase_length_range(num min, num max) {
    return 'Interventionsphasen müssen zwischen $min und $max Tagen lang sein';
  }

  @override
  String get form_field_amount_days => 'Tage';

  @override
  String get form_field_crossover_schedule_num_cycles =>
      'Anzahl Wiederholungen';

  @override
  String get form_field_crossover_schedule_num_cycles_tooltip =>
      'Lege fest wie oft jede Interventionsphase im Versuchsplan durchlaufen wird';

  @override
  String form_field_crossover_schedule_num_cycles_range(num min, num max) {
    return 'Die Anzahl der Wiederholungen für Interventionsphasen im Versuchsplan muss zwischen $min und $max liegen';
  }

  @override
  String get form_field_amount_crossover_schedule_num_cycles =>
      'Wiederholungen';

  @override
  String get form_field_crossover_schedule_include_baseline => 'Baseline';

  @override
  String get form_field_crossover_schedule_include_baseline_tooltip =>
      'Wähle diese Option, um die Studie mit einer interventionsfreien Phase zur Messung einer Baseline zu beginnen';

  @override
  String get form_field_crossover_schedule_include_baseline_label =>
      'Mit Baseline-Phase starten';

  @override
  String get form_study_design_measurements_description =>
      'Auf dieser Seite legst du fest, welche Daten im Laufe der Studie erhoben werden sollen - hauptsächlich um den Effekt der Interventionen zu bestimmen. Zur Erhebung der Daten füllen Teilnehmer jeden Tag einen oder mehrere Fragebögen in der StudyU-App aus. Die gesammelten Daten & Ergebnisse sind nach dem Start der Studie auf der Analysieren-Unterseite abrufbar.';

  @override
  String form_array_measurements_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_measurements_minlength',
      one:
          'Du brauchst mindestens einen Fragebogen, um den Effekt der Intervention(en) zu messen.',
    );
    return '$_temp0';
  }

  @override
  String get form_array_measurements_surveys => 'Fragebögen';

  @override
  String get form_array_measurements_surveys_new => 'Neuer Fragebogen';

  @override
  String get form_array_measurements_surveys_empty_title =>
      'Noch keine Fragebögen erstellt';

  @override
  String get form_array_measurements_surveys_empty_description =>
      'Du brauchst mindestens einen Fragebogen, um den Effekt der Intervention(en) zu messen.';

  @override
  String get form_field_measurement_survey_title => 'Fragebogen Titel';

  @override
  String get form_field_measurement_survey_title_required =>
      'Der Titel des Fragebogens darf nicht leer sein';

  @override
  String get form_field_measurement_survey_title_default =>
      'Unbenannter Fragebogen';

  @override
  String get form_field_measurement_survey_title_tooltip =>
      'Gib den Titel des Fragebogens an, so wie er in der App angezeigt werden soll';

  @override
  String get form_field_measurement_survey_intro_text => 'Begrüßungstext';

  @override
  String get form_field_measurement_survey_intro_text_tooltip =>
      'Gib einen zusätzlichen Text ein, der zu Beginn des Fragebogens angezeigt wird';

  @override
  String get form_field_measurement_survey_intro_text_hint =>
      'z.B. Teilnehmer begrüßen';

  @override
  String get form_field_measurement_survey_outro_text => 'Abschlusstext';

  @override
  String get form_field_measurement_survey_outro_text_tooltip =>
      'Gib einen zusätzlichen Text ein, der am Ende und nach Abschluss des Fragebogens angezeigt wird';

  @override
  String get form_field_measurement_survey_outro_text_hint =>
      'z.B. fürs Ausfüllen bedanken';

  @override
  String get form_array_measurement_survey_questions => 'Fragen';

  @override
  String get form_array_measurement_survey_questions_new => 'Neue Frage';

  @override
  String get form_array_measurement_survey_questions_empty_title =>
      'Noch keine Fragen erstellt';

  @override
  String get form_array_measurement_survey_questions_empty_description =>
      'Es ist mindestens eine Frage erforderlich, um den Effekt der Intervention(en) zu messen.';

  @override
  String form_array_measurement_survey_questions_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'form_array_measurement_survey_questions_minlength',
      one:
          'Es ist mindestens eine Frage erforderlich, um den Effekt der Intervention(en) zu messen.',
    );
    return '$_temp0';
  }

  @override
  String get report_status_primary => 'Primär';

  @override
  String get report_status_secondary => 'Sekundär';

  @override
  String get report_status_primary_description => 'Primärbericht';

  @override
  String get report_status_secondary_description => 'Sekundärbericht';

  @override
  String get form_report_create => 'Neuer Bericht';

  @override
  String get form_report_edit => 'Bericht bearbeiten';

  @override
  String get form_report_readonly => 'Bericht ansehen';

  @override
  String get form_field_report_title_required =>
      'Du musst einen Titel für deinen Bericht angeben';

  @override
  String get form_field_report_text_required =>
      'Die Beschreibung für deinen Bericht darf nicht leer sein';

  @override
  String get form_array_reports_empty_title => 'Keine Berichte definiert';

  @override
  String get form_array_report_items_title => 'Berichte';

  @override
  String get form_array_report_items_description =>
      'Definiere, wie der Bericht, den deine Teilnehmer erhalten, aussehen soll. Ein Bericht umfasst verschiedene Abschnitte, wobei der erste der primäre Abschnitt ist. Für jeden Abschnitt kannst du definieren, ob die Daten als Durchschnitt oder über eine lineare Regression der Benutzerdaten berichtet werden sollen. Du kannst wählen, ob die Daten für einzelne Tage, Phasen oder für jede Intervention berichtet werden. Die Datenquelle definiert, auf welcher Beobachtung der Berichtsabschnitt basiert.';

  @override
  String get form_array_reports_empty_description =>
      'Du musst mindestens einen Bericht definieren, um deinen Teilnehmern Feedback zu geben.';

  @override
  String get form_array_reports_new => 'Neuen Bericht hinzufügen';

  @override
  String get form_field_report_title => 'Titel';

  @override
  String get form_field_report_title_tooltip =>
      'Gib einen kurzen Titel für den Bericht ein.';

  @override
  String get form_field_report_title_hint => 'Kurzen Titel eingeben';

  @override
  String get form_field_report_text => 'Berichtsbeschreibung';

  @override
  String get form_field_report_text_tooltip =>
      'Gib eine Beschreibung für den Bericht ein';

  @override
  String get form_field_report_text_hint => 'Berichtsbeschreibung eingeben';

  @override
  String get form_field_report_section_type => 'Berichtstyp';

  @override
  String get form_field_report_section_type_tooltip =>
      'Wähle einen Berichtstyp';

  @override
  String get form_field_report_section_type_description =>
      'Wähle den Berichtstyp, der zu deinem Bericht passt.';

  @override
  String get form_field_report_improvementDirection_title =>
      'Verbesserungsrichtung';

  @override
  String get form_field_report_improvementDirection_tooltip =>
      'Definiere die Verbesserungsrichtung';

  @override
  String get reportSection_type_average => 'Durchschnitt';

  @override
  String get reportSection_type_textual_summary => 'Textuelle Zusammenfassung';

  @override
  String get reportSection_type_gauge_comparison => 'Tachometer-Vergleich';

  @override
  String get reportSection_type_descriptive_statistics =>
      'Deskriptive Statistik';

  @override
  String get form_field_report_average_temporalAggregation_title =>
      'Zeitliche Aggregation';

  @override
  String get form_field_report_average_temporalAggregation_tooltip =>
      'Definiere die zeitliche Aggregation';

  @override
  String get reportSection_type_temporalAggregation_day => 'Tag';

  @override
  String get reportSection_type_temporalAggregation_phase => 'Phase';

  @override
  String get reportSection_type_temporalAggregation_intervention =>
      'Intervention';

  @override
  String get form_field_report_temporalAggregation_required =>
      'Ein Wert für die zeitliche Aggregation muss definiert werden';

  @override
  String get reportSection_type_linearRegression => 'Lineare Regression';

  @override
  String get reportSection_type_improvementDirection_positive => 'Positiv';

  @override
  String get reportSection_type_improvementDirection_negative => 'Negativ';

  @override
  String get form_field_report_improvementDirection_required =>
      'Eine Verbesserungsrichtung muss definiert werden';

  @override
  String get form_field_report_linearRegression_alpha_title =>
      'Alpha-Vertrauensniveau';

  @override
  String get form_field_report_linearRegression_alpha_tooltip =>
      'Definiere das Alpha-Vertrauensniveau';

  @override
  String get form_field_report_linearRegression_alpha_hint =>
      'Gib einen numerischen Wert ein';

  @override
  String get form_field_report_alphaConfidence_required =>
      'Ein Alpha-Vertrauenswert muss definiert werden';

  @override
  String get form_field_report_alphaConfidence_number =>
      'Der Alpha-Vertrauenswert muss eine numerische Zahl sein';

  @override
  String get form_field_report_data_source_title => 'Datenquelle';

  @override
  String get form_field_report_data_source_tooltip =>
      'Die Datenquelle definiert, auf welcher Beobachtung der Berichtsabschnitt basiert. Die Beobachtung muss eine Frage mit einem numerischen Ergebnis sein, z.B. eine Skalenfrage.';

  @override
  String get form_field_report_data_source_required =>
      'Eine Datenquelle muss definiert werden';

  @override
  String get form_field_report_select_aggregation =>
      'Wähle einen Aggregationswert';

  @override
  String get study_test_page_description =>
      'Im Testmodus kannst du die Studie aus Teilnehmersicht testen.';

  @override
  String get navlink_study_test_help => 'Wie funktioniert\'s?';

  @override
  String get study_test_app_nav_title => 'Gehe zur App:';

  @override
  String get navlink_study_test_app_overview => 'Studienübersicht';

  @override
  String get navlink_study_test_app_eligibility => 'Teilnehmer-Screening';

  @override
  String get navlink_study_test_app_intervention => 'Interventionsauswahl';

  @override
  String get navlink_study_test_app_consent => 'Teilnahme-Einwilligung';

  @override
  String get navlink_study_test_app_journey => 'Studienverlaufsplan';

  @override
  String get navlink_study_test_app_dashboard => 'Tagesübersicht';

  @override
  String get action_button_study_test_reset => 'Zurücksetzen';

  @override
  String get action_button_study_test_open_new_tab => 'In neuem Fenster öffnen';

  @override
  String get banner_study_test_unavailable =>
      'Um den Testmodus nutzen zu können, gib bitte folgende Informationen korrekt & vollständig ein:';

  @override
  String get banner_study_preview_unavailable =>
      'Um die Vorschau nutzen zu können, gib bitte folgende Informationen korrekt und vollständig ein:';

  @override
  String get dialog_study_test_help_title => 'Teste deine Studie!';

  @override
  String get dialog_study_test_help_description =>
      'Im Testmodus siehst du deine Studie aus Teilnehmersicht in der StudyU App, sodass du sie für deine Zwecke anpassen & sicherstellen kannst, dass alles wie vorgesehen funktioniert.';

  @override
  String get dialog_study_test_section_tips => '⭐ Profi-Tipps';

  @override
  String get dialog_study_test_section_tips_text =>
      '• Über das Menü auf der linken Seite kannst du schnell zu verschiedenen Teilen deiner Studie gelangen\n• Du kannst die Studie im Schnelldurchlauf testen, in dem du auf der Tagesübersicht via \'next day\' zum nächsten Tag gehst\n• Sieh dir eine Vorschau der möglichen Ergebnisse an, in dem du die Daten aus dem aktuellen Testlauf exportierst (über die Analysieren-Unterseite)\n• Um als neuer Teilnehmer nochmal von vorne anzufangen, kannst du den Testdurchlauf jederzeit zurücksetzen';

  @override
  String get dialog_study_test_download_url_intro => '• Du kannst';

  @override
  String get dialog_study_test_download_url =>
      'https://github.com/hpi-studyu/studyu#app-stores';

  @override
  String get dialog_study_test_download_url_text =>
      'die StudyU App runterladen';

  @override
  String get dialog_study_test_download_url_outro =>
      ' um sie auf dem Smartphone zu testen';

  @override
  String get dialog_study_test_section_notice => '⚠️ Bitte beachte';

  @override
  String get dialog_study_test_section_notice_text =>
      '• Der Testdurchlauf und die dabei generierten Daten werden automatisch zurückgesetzt, wenn die Studie mit echten Teilnehmern startet';

  @override
  String get dialog_action_study_test_start => 'Testdurchlauf starten';

  @override
  String enrolled_count_tooltip(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Teilnehmer haben sich mit diesem Code zur Studie angemeldet',
      one: '$count Teilnehmer hat sich mit diesem Code zur Studie angemeldet',
      zero:
          'Bisher hat sich niemand mit diesem Teilnahme-Code zur Studie angemeldet',
    );
    return '$_temp0';
  }

  @override
  String get form_code_create => 'Neuer Teilnahmecode';

  @override
  String get form_code_readonly => 'Teilnahmecode';

  @override
  String get form_field_code => 'Code';

  @override
  String get form_field_code_tooltip =>
      'Gib einen eindeutigen Code ein, den Teilnehmer zur Anmeldung in der StudyU App verwenden können';

  @override
  String get form_field_code_required => 'Der Code darf nicht leer sein';

  @override
  String form_field_code_minlength(num minLength) {
    return 'Der Code muss mindestens $minLength Zeichen lang sein';
  }

  @override
  String form_field_code_maxlength(num maxLength) {
    return 'Der Code darf maximal $maxLength Zeichen lang sein';
  }

  @override
  String get form_field_code_alreadyused =>
      'Dieser Code wird bereits verwendet';

  @override
  String get form_field_is_preconfigured_schedule => 'Vordefinierter Zeitplan';

  @override
  String get form_field_is_preconfigured_schedule_description =>
      'Du kannst die Phasen und Interventionen für jeden Teilnehmer vordefinieren, der über diesen Code an der Studie teilnimmt. Die hier festgelegten Einstellungen haben Vorrang gegenüber den Standard-Einstellungen der Studie.';

  @override
  String get form_field_preconfigured_schedule_type => 'Zeitplan';

  @override
  String get form_field_preconfigured_schedule_intervention_a =>
      'Intervention A';

  @override
  String get form_field_preconfigured_schedule_intervention_b =>
      'Intervention B';

  @override
  String get form_field_preconfigured_schedule_intervention_default =>
      'Standard';

  @override
  String get form_field_preconfigured_schedule_intervention_hint =>
      'Intervention auswählen...';

  @override
  String get code_list_section_title => 'Teilnahmecodes';

  @override
  String get code_public_disabled => 'Teilnahmecodes deaktiviert';

  @override
  String get code_public_disabled_description =>
      'Teilnahmecodes sind für diese Studie deaktiviert, da die öffentliche Rekrutierung für diese Studie aktiviert ist. Alle Teilnehmer können ohne Teilnahmecodes beitreten.';

  @override
  String get code_list_empty_title => 'Noch keine Teilnehmer eingeladen';

  @override
  String get code_list_empty_description =>
      'Erstelle Teilnahmecodes, mit denen sich Teilnehmer zu deiner Studie in der StudyU App anmelden können.';

  @override
  String get code_list_header_code => 'Code';

  @override
  String get action_button_code_new => 'Neuer Code';

  @override
  String get participant_details_title => 'Teilnehmerdetails';

  @override
  String get participant_details_study_days_overview =>
      'Übersicht über Studientage';

  @override
  String get participant_details_study_days_description =>
      'Dieser Abschnitt bietet einen Überblick über die täglichen Aktivitäten des Teilnehmers in der Studie. Die Farblegende zeigt den Status der täglichen Aufgaben an. Bewege den Mauszeiger über die Studientage, um mehr Details über die tägliche Aktivität des Teilnehmers zu erfahren.';

  @override
  String get participant_details_color_legend_title => 'Legende';

  @override
  String get participant_details_color_tooltip_legend_title =>
      'Aktivitätsdetail Legende';

  @override
  String get participant_details_color_legend_completed_task =>
      'Abgeschlossene Aufgabe';

  @override
  String get participant_details_color_legend_completed_task_tooltip =>
      'Der Teilnehmer hat diese Aufgabe erledigt';

  @override
  String get participant_details_color_legend_missed_task =>
      'Verpasste Aufgabe';

  @override
  String get participant_details_color_legend_missed_task_tooltip =>
      'Der Teilnehmer hat diese Aufgabe verpasst';

  @override
  String get participant_details_color_legend_completed =>
      'Alle Aufgaben abgeschlossen';

  @override
  String get participant_details_color_legend_partially_completed =>
      'Einige Aufgaben unvollständig';

  @override
  String get participant_details_color_legend_missed =>
      'Alle Aufgaben verpasst';

  @override
  String get participant_details_completed_legend_tooltip =>
      'Alle Interventions- und Umfrageaufgaben wurden abgeschlossen';

  @override
  String get participant_details_partially_completed_legend_tooltip =>
      'Nicht alle Interventions- oder Umfrageaufgaben wurden abgeschlossen';

  @override
  String get participant_details_incomplete_legend_tooltip =>
      'Keine Interventions- oder Umfrageaufgaben wurden abgeschlossen';

  @override
  String get participant_details_progress_empty_title =>
      'Keine Daten verfügbar';

  @override
  String get participant_details_progress_empty_description =>
      'Sobald der Teilnehmer mit der Studie beginnt, werden hier tägliche Aktivitäten angezeigt.';

  @override
  String get monitoring_no_participants_title =>
      'Es gibt noch keine Teilnehmer in dieser Studie';

  @override
  String get monitoring_no_participants_description =>
      'Sobald Teilnehmer in der Studie eingeschrieben sind, kann hier deren Fortschritt überwacht werden.';

  @override
  String get monitoring_participants_title => 'Teilnehmerübersicht';

  @override
  String get monitoring_total => 'Gesamtzahl der Teilnehmer';

  @override
  String get monitoring_active => 'Aktiv';

  @override
  String get monitoring_active_tooltip =>
      'Anzahl der Teilnehmer, die derzeit in der Studie sind';

  @override
  String get monitoring_inactive => 'Inaktiv';

  @override
  String get monitoring_inactive_tooltip =>
      'Anzahl der Teilnehmer, die 3 Tage hintereinander keine Aktivität in der Studie gezeigt haben';

  @override
  String get monitoring_dropout => 'Abgebrochen';

  @override
  String get monitoring_dropout_tooltip =>
      'Anzahl der Teilnehmer, die die Studie vorzeitig abgebrochen haben oder für 5 Tage hintereinander keine Aktivität in der Studie gezeigt haben';

  @override
  String get monitoring_completed => 'Abgeschlossen';

  @override
  String get monitoring_completed_tooltip =>
      'Anzahl der Teilnehmer, die das Ende der Studie erreicht haben';

  @override
  String get monitoring_table_column_participant_id => 'ID';

  @override
  String get monitoring_table_column_invite_code => 'Einladungscode';

  @override
  String get monitoring_table_column_enrolled => 'Studienstart';

  @override
  String get monitoring_table_column_last_activity => 'Letzte Aktivität';

  @override
  String get monitoring_table_column_day_in_study => 'Studientag';

  @override
  String get monitoring_table_column_completed_interventions =>
      'Abgeschlossene Interventionen';

  @override
  String get monitoring_table_column_completed_surveys =>
      'Abgeschlossene Fragebögen';

  @override
  String get monitoring_table_row_tooltip_dropout =>
      'Dieser Teilnehmer hat die Studie verlassen und es wird keine neue Aktivität hinzugefügt';

  @override
  String get monitoring_table_days_in_study_header_tooltip =>
      'Die Anzahl der Tage, die der Teilnehmer in der Studie verbracht hat';

  @override
  String get monitoring_table_completed_interventions_header_tooltip =>
      'Eine Intervention zählt als abgeschlossen, wenn alle Aufgaben für den Tag erledigt wurden';

  @override
  String get monitoring_table_completed_surveys_header_tooltip =>
      'Die Umfrage zählt als abgeschlossen, wenn alle Aufgaben für den Tag erledigt wurden';

  @override
  String get banner_text_study_analyze_draft =>
      'Solange die Studie noch nicht live ist, basieren die Ergebnisse hier auf den Daten aus den Testläufen der Studie.\nDie Ergebnisdaten werden automatisch zurückgesetzt sobald die Studie mit echten Teilnehmern startet.';

  @override
  String get action_button_study_export => 'Daten exportieren';

  @override
  String get action_button_study_export_prompt =>
      'Möchtest du deine eigene Analyse durchführen?';

  @override
  String get study_export_unavailable_empty_tooltip =>
      'Es sind noch keine Ergebnisdaten verfügbar';

  @override
  String get study_export_unavailable_no_permission_tooltip =>
      'Du bist nicht berechtigt, auf die Ergebnisdaten der Studie zuzugreifen';

  @override
  String get study_launch_title => 'Super Arbeit! 👏 Alles bereit?';

  @override
  String get study_launch_participation_intro =>
      'Die von dir erstellte Studie ist';

  @override
  String get study_launch_participation_outro => '';

  @override
  String get study_launch_post_launch_intro =>
      'Wenn die Studie gestartet wird, beachte:';

  @override
  String get study_launch_post_launch_summary =>
      '- Der Entwurfsmodus wird gesperrt und du kannst keine Änderungen mehr an der Studie selbst vornehmen\n- Alle nicht die Studie selbst betreffenden Daten werden zurückgesetzt (einschließlich Testnutzern und Testergebnissen)';

  @override
  String get study_launch_success_title => 'Deine Studie ist live!';

  @override
  String get study_launch_success_description =>
      'Lade als nächstes Teilnehmer zur Anmeldung in der StudyU App ein.';

  @override
  String get study_public_launch_success_description =>
      'Deine Studie ist jetzt in der StudyU App für alle öffentlich verfügbar.';

  @override
  String get action_button_post_launch_followup => 'Teilnehmer einladen';

  @override
  String get action_button_post_launch_followup_skip => 'Später vielleicht';

  @override
  String get action_button_study_participation_change => 'Teilnahme\nändern';

  @override
  String get form_field_required => 'Das Feld darf nicht leer sein';

  @override
  String get form_invalid_prompt => 'Bitte fülle alle Felder vollständig aus';

  @override
  String get copy_suffix_label => 'Kopie';

  @override
  String date_diff_years(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Jahren',
      one: 'Vor einem Jahr',
    );
    return '$_temp0';
  }

  @override
  String date_diff_months(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Monaten',
      one: 'Vor einem Monat',
    );
    return '$_temp0';
  }

  @override
  String date_diff_days(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Tagen',
      one: 'Vor einem Tag',
    );
    return '$_temp0';
  }

  @override
  String date_diff_hours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Stunden',
      one: 'Vor einer Stunde',
    );
    return '$_temp0';
  }

  @override
  String date_diff_minutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Minuten',
      one: 'Vor einer Minute',
    );
    return '$_temp0';
  }

  @override
  String date_diff_seconds(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Sekunden',
      one: 'Vor einer Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get date_just_now => 'Gerade eben';

  @override
  String get action_edit => 'Bearbeiten';

  @override
  String get action_pin => 'Anheften';

  @override
  String get action_unpin => 'Nicht mehr anheften';

  @override
  String get action_delete => 'Löschen';

  @override
  String get action_remove => 'Entfernen';

  @override
  String get action_duplicate => 'Duplizieren';

  @override
  String get action_clipboard => 'In Zwischenablage kopieren';

  @override
  String get action_reportPrimary => 'Als Primärauswertung setzen';

  @override
  String get action_study_duplicate_draft => 'Als Entwurf duplizieren';

  @override
  String get action_study_export_results => 'Ergebnisdaten exportieren';

  @override
  String get dialog_continue => 'Fortfahren';

  @override
  String get dialog_close => 'Schließen';

  @override
  String get dialog_cancel => 'Abbrechen';

  @override
  String get dialog_save => 'Speichern';

  @override
  String get sync_initial => 'Keine Änderungen zum Speichern';

  @override
  String get sync_dirty => 'Es gibt nicht gespeicherte Änderungen';

  @override
  String get sync_saving => 'Änderungen werden gespeichert...';

  @override
  String get sync_done => 'Alle Änderungen gespeichert';

  @override
  String get sync_last_saved => 'Zuletzt gespeichert';

  @override
  String get sync_failed =>
      'Änderungen konnten nicht gespeichert werden & könnten verloren gehen.';

  @override
  String get iconpicker_nonempty_prompt => 'Icon auswählen';

  @override
  String get iconpicker_empty_prompt => 'Icon auswählen';

  @override
  String get iconpicker_dialog_title => 'Icon auswählen';

  @override
  String get dialog_unsaved_changes_title => 'Zurück und Änderungen verwerfen?';

  @override
  String get dialog_unsaved_changes_description =>
      'Du hast Änderungen vorgenommen, die noch nicht gespeichert wurden & verloren gehen, wenn du zurückgehst. Wenn du die Änderungen beibehalten möchtest, musst du sie vorher speichern.';

  @override
  String get dialog_action_unsaved_changes_stay => 'Hier bleiben';

  @override
  String get dialog_action_unsaved_changes_discard => 'Änderungen verwerfen';

  @override
  String get under_construction => 'Noch in Arbeit';

  @override
  String get under_construction_description =>
      'Hier wird gerade noch dran gearbeitet, bitte hab ein wenig Geduld & komm denächst wieder!';

  @override
  String get fitbit_credentials_instruction =>
      'Um Fitbit-Daten zu integrieren, folgen Sie diesen Schritten, um Ihre Client-ID und Ihren Client-Secret zu erhalten:';

  @override
  String get fitbit_credentials_step1 =>
      '1. Gehen Sie zum Fitbit Developer Portal.';

  @override
  String get fitbit_credentials_step2 =>
      '2. Melden Sie sich mit Ihrem Fitbit-Konto an oder erstellen Sie eins, falls Sie noch keines haben.';

  @override
  String get fitbit_credentials_step3 =>
      '3. Navigieren Sie zum Abschnitt \"Verwalten\" und wählen Sie \"App registrieren\".';

  @override
  String get fitbit_credentials_step4 =>
      '4. Füllen Sie die erforderlichen Felder wie Anwendungsname, Beschreibung und Redirect-URL (verwenden Sie: \"studyu://fitbit/auth\") aus.';

  @override
  String get fitbit_credentials_step5 =>
      '5. Wählen Sie unter \"OAuth 2.0 Application Type\" die Option \"Client\" und setzen Sie den Zugriff auf \"Nur Lesen\".';

  @override
  String get fitbit_credentials_step6 =>
      '6. Senden Sie das Formular ab, um Ihre \"Client ID\" und \"Client Secret\" zu erhalten.';

  @override
  String get fitbit_credentials_step7 =>
      '7. Bitte füllen Sie das folgende Formular aus, um Zugang zu Intraday-Daten zu erhalten. Ohne diesen Schritt können Sie keine Daten von Fitbit für Ihre Versuche abrufen.';

  @override
  String get fitbit_credentials_step8 =>
      '8. Kopieren Sie die unten stehenden Zugangsdaten und fügen Sie sie ein.';

  @override
  String get fitbit_credentials_success_instruction =>
      'Sobald Sie die Zugangsdaten eingegeben haben, wird die Fitbit-Integration für Ihre Studie aktiviert.';

  @override
  String get fitbit_credentials_add_question_instruction =>
      'Um eine Fitbit-Frage hinzuzufügen, navigieren Sie zum Bereich Messungen und erstellen Sie innerhalb einer Messung eine neue Fitbit-Frage.';

  @override
  String get fitbit_credentials_screenshot_step1 =>
      'Schritt 1: Developer Portal';

  @override
  String get fitbit_credentials_screenshot_step2 => 'Schritt 2: Login';

  @override
  String get fitbit_credentials_screenshot_step3 =>
      'Schritt 3: App registrieren';

  @override
  String get fitbit_credentials_screenshot_step4 =>
      'Schritt 4: Details eingeben';

  @override
  String get fitbit_credentials_screenshot_step5 =>
      'Schritt 5: Zugriff einstellen';

  @override
  String get fitbit_credentials_screenshot_step6 =>
      'Schritt 6: Zugangsdaten erhalten';

  @override
  String get fitbit_credentials_screenshot_step7 =>
      'Schritt 7: Formular ausfüllen';

  @override
  String get fitbit_credentials_cannot_change_title =>
      'Fitbit-Anmeldedaten können nicht geändert werden';

  @override
  String get fitbit_credentials_cannot_change_description =>
      'Fitbit-Anmeldedaten können nicht geändert werden, wenn die Studie nicht im Entwurfsmodus ist.';

  @override
  String get fitbit_only_participant_title =>
      'Wenn du diese Studie nur für dich selbst durchführst';

  @override
  String get fitbit_only_participant_subtitle =>
      'Da du sowohl Ersteller als auch einziger Teilnehmer dieser Studie bist, brauchst du das Formular für den Zugriff auf Intraday-Daten nicht auszufüllen. Befolge einfach diese Schritte:';

  @override
  String get fitbit_only_participant_step_1 =>
      'Wähle beim Erstellen deiner Fitbit-App als Anwendungstyp „Persönlich“.';

  @override
  String get fitbit_only_participant_step_2 =>
      'Verwende beim Synchronisieren deiner Daten unbedingt dasselbe Google-Konto, das du mit deiner Fitbit-Uhr und der von dir eingerichteten Fitbit-App verbunden hast.';

  @override
  String get client_id => 'Client ID';

  @override
  String get client_id_label_help =>
      'Geben Sie die Client-ID aus dem Fitbit Developer Portal ein.';

  @override
  String get client_id_hint => 'Client ID';

  @override
  String get client_secret => 'Client Secret';

  @override
  String get client_secret_label_help =>
      'Geben Sie den Client Secret aus dem Fitbit Developer Portal ein.';

  @override
  String get client_secret_hint => 'Client Secret';

  @override
  String get screenshots_for_guidance => 'Screenshots zur Anleitung:';

  @override
  String get fitbit_credentials_not_set =>
      'Fitbit-Anmeldedaten sind nicht gesetzt. Bitte navigieren Sie zum \'Fitbit\'-Tab im Studien-Designer, um Ihre Fitbit-Client-ID und Ihr Client-Secret einzugeben. Sobald dies abgeschlossen ist, kehren Sie hierher zurück, um Fitbit-Fragen hinzuzufügen.';

  @override
  String get fitbit_question_type_heartrate_description =>
      'Erfasst die Herzfrequenz, gemessen jede Minute über den Tag verteilt.';

  @override
  String get fitbit_question_type_steps_description =>
      'Zeichnet die Anzahl der gegangenen Schritte auf, gemessen jede Minute.';

  @override
  String get fitbit_question_type_sleep_description =>
      'Erfasst Schlafstadien (Wach, Leichtschlaf, Tiefschlaf, REM) in 30-Sekunden- bis 1-Minuten-Intervallen während des Schlafs.';
}
