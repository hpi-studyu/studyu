// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get loading => 'Laden';

  @override
  String get loading_error_title => 'Ladefehler';

  @override
  String get loading_error_description =>
      'Die Studiendaten konnten nicht abgerufen werden. Wenn Sie aktuell an einer Studie teilnehmen, wenden Sie sich bitte zuerst an Ihre Studienleitung. Kontaktieren Sie den Support nur, wenn Sie nicht an einer Studie teilnehmen oder Ihre Studienleitung Sie dazu auffordert. Löschen Sie Ihre Daten nur, wenn Sie von der Studienleitung oder dem Support dazu aufgefordert werden. Das Löschen entfernt alle Ihre Studiendaten und Sie müssen der Studie erneut beitreten.';

  @override
  String get try_again => 'Erneut versuchen';

  @override
  String get delete_all_data => 'Alle Daten löschen';

  @override
  String get delete_all_data_description =>
      'Möchten Sie wirklich alle Daten löschen? Dadurch werden alle Ihre Studiendaten gelöscht und Sie müssen der Studie erneut beitreten.';

  @override
  String get reset_app => 'App zurücksetzen';

  @override
  String get what_is_studyu => 'Was ist StudyU?';

  @override
  String get description_part1 =>
      'Stellen Sie sich vor, Sie lesen den Satz: \"Studien konnten zeigen, dass Essen nach 18 Uhr die Schlafqualität verschlechtert.\"';

  @override
  String get description_part2 =>
      'Sie denken jetzt möglicherweise: Okay... gut zu wissen, aber trifft das wirklich auf jeden, also auch auf MICH zu?';

  @override
  String get description_part3 =>
      'Das Problem ist: Sie haben nicht persönlich an der Studie teilgenommen, sodass wir Ihnen die Frage nicht beantworten können. Eine gewöhnliche Studie kann nur beantworten, ob sich Ihre Schlafqualität WAHRSCHEINLICH reduziert. Sie müssten also bei sich selber testen, welche Wirkung spätes Essen auf IHREN Schlaf hat.';

  @override
  String get description_part4 =>
      'Das heißt nichts anderes, als dass Sie Ihre ganz persönliche Studie durchführen, in der Sie mal spät essen und mal auf spätes Essen verzichten. Sie würden regelmäßig Ihre Schlafqualität beurteilen und am Ende zu einem Ergebnis kommen, dass Ihnen endlich die Frage beantworten kann, ob Ihre Schlafqualität durch spätes Essen beeinflusst wird. Ihnen solche Fragen sicher beantworten zu können, ist das Ziel von StudyU.';

  @override
  String get description_part5 =>
      'StudyU bietet Ihnen die Möglichkeit, an professionell erstellten N-of-1 Studien teilzunehmen. N-of-1 heißt, dass die Anzahl der Studienteilnehmer, die normalerweise mit N angegeben wird, bei 1 liegt. Und genauso wie gewöhnliche Studien brauchen auch N-of-1 Studien einen klar festgelegten Plan (ein so genanntes Studienprotokoll).';

  @override
  String get description_part6 =>
      'Und da gute Studienprotokolle nicht einfach zu machen sind, haben wir diese App entwickelt. Hier können Sie zwischen verschiedenen N-of-1 Studien wählen, ganz nach IHREM persönlichen Interesse, und Sie erhalten ganz automatisch einen Plan, der von Experten entwickelt wurde und Ihnen ein zuverlässiges Ergebnis liefern wird.';

  @override
  String get description_part7 =>
      'Nachdem Sie sich für eine Studie entschieden haben, werden wir sichergehen, dass Ihr Gesundheitsstatus eine Teilnahme erlaubt. Danach können Sie sich als Teilnehmer einschreiben und den Studienplan an Ihren Alltag anpassen. Anschließend werden Sie regelmäßig (meistens 1x pro Tag) eine von zwei möglichen Aufgaben (bspw. essen nach 18 Uhr) absolvieren und Ihre Beobachtungen (bspw. Müdigkeit) eintragen. Ihre Ergebnisse können Sie kostenlos freischalten sobald Sie die minimale Studiendauer (meist nur wenige Wochen) erreicht haben.';

  @override
  String get description_part8 =>
      'Aber bitte beachten Sie Folgendes: Ergebnisse sind umso aussagekräftiger, je länger Sie aktiv an der Studie teilnehmen. Um systematische Fehler zu vermeiden, ist eine weitere Teilnahme nach Freischaltung der Ergebnisse ausgeschlossen. Daher werden wir Ihnen mit einem Fortschrittsbalken anzeigen, wie viele weitere Aufgaben mindestens noch absolviert werden müssen und wie sehr sie die Aussagekraft der Ergebnisse mit ein paar weiteren Wochen verbessern können.';

  @override
  String get description_part9 =>
      'Aber genug von unserer Seite, jetzt ist es Zeit für StudyU!';

  @override
  String get get_started => 'Los geht\'s';

  @override
  String get study_selection => 'Studienauswahl';

  @override
  String get study_selection_description => 'Bitte wählen Sie eine Studie aus.';

  @override
  String get study_selection_single =>
      'Sie können zu jeder Zeit maximal an einer Studie teilnehmen.';

  @override
  String get study_selection_single_why => 'Warum?';

  @override
  String get study_selection_single_reason =>
      'Wenn Sie zur selben Zeit an mehreren Studien teilnehmen würde, könnten die Kombination der Interventionen die Ergebnisse verfälschen.';

  @override
  String get study_selection_unsupported_title => 'Veraltete App-Version';

  @override
  String get study_selection_unsupported =>
      'Die Studie, an der Sie teilnehmen möchten, ist nicht mit Ihrer App-Version kompatibel. Bitte aktualisieren Sie die App auf die neueste Version.';

  @override
  String get study_selection_closed_title => 'Studie geschlossen';

  @override
  String get study_selection_closed =>
      'Diese Studie ist derzeit für neue Teilnehmer geschlossen.';

  @override
  String get study_selection_hidden_studies =>
      'Einige Studien konnten nicht angezeigt werden, da Ihre App-Version veraltet ist. Bitte aktualisieren Sie Ihre App, um alle verfügbaren Studien zu sehen.';

  @override
  String get study_overview_title => 'Übersicht';

  @override
  String get eligibility_questionnaire_title => 'Fragebogen';

  @override
  String get please_answer_eligibility =>
      'Bitte beantworten Sie ein paar Fragen um sicherzugehen, dass diese Studie für Sie geeignet ist';

  @override
  String get intervention_selection_title => 'Interventionen';

  @override
  String get please_select_interventions =>
      'Bitte wählen Sie zwei Interventionen für die Studie aus.';

  @override
  String get please_select_interventions_description =>
      'Die Auswirkungen dieser beiden Interventionen werden während der Studie gemessen und miteinander verglichen. Die Interventionen erfolgen in der Reihenfolge, in der Sie sie auswählen. Wenn Sie A vor B wählen, wird A zuerst durchgeführt.';

  @override
  String get no_interventions_available => 'Keine Interventionen verfügbar.';

  @override
  String get loading_interventions => 'Interventionen laden';

  @override
  String get task_already_completed =>
      'Die Aufgabe wurde heute bereits erledigt';

  @override
  String get task_cannot_be_completed =>
      'Die Aufgabe kann nicht bearbeitet werden';

  @override
  String get task_outside_period =>
      'Die Aufgabe kann nicht außerhalb der Interventionsphase bearbeitet werden';

  @override
  String get study_notification_body =>
      'Eine neue Aufgabe benötigt Ihre Aufmerksamkeit';

  @override
  String get intervention_phase_duration => 'Länge der Interventionphasen';

  @override
  String get days => 'Tage';

  @override
  String get study_length => 'Studienlänge';

  @override
  String get study_publisher => 'Studienherausgeber';

  @override
  String get tasks_daily => 'Aufgaben:';

  @override
  String get baseline_description =>
      'Die Baseline ist eine Phase innerhalb einer Studie, in der der Ausgangszustand gemessen wird, um spätere Vergleiche zu ermöglichen. Während der Baseline-Phase sollen Sie sich wie gewohnt verhalten, studienspezifische Maßnahmen werden noch keine durchgeführt.';

  @override
  String get baseline => 'Baseline';

  @override
  String get days_left => 'Tage übrig';

  @override
  String get today_tasks => 'Aufgaben heute';

  @override
  String get intervention_current => 'Aktuelle Maßnahme';

  @override
  String get study_current => 'Aktuelle Studie:';

  @override
  String get opt_out => 'Aussteigen';

  @override
  String get delete_data => 'Aussteigen und Daten löschen';

  @override
  String get soft_delete_desc => 'Sie werden Ihren Fortschritt in der Studie ';

  @override
  String get soft_delete_desc_2 =>
      ' unwiederbringlich verlieren. Bereits abgeschlossene Studien werden nicht gelöscht.\nIhre anonymisierten Daten bis zu diesem Zeitpunkt können weiterhin für Forschungszwecke verwendet werden.';

  @override
  String get hard_delete_desc =>
      'Sie werden alle Daten von Ihrem Gerät und unseren Servern löschen. Sie können Ihre Daten nicht wiederherstellen. Ihre anonymisierten Daten werden nicht mehr für Forschungszwecke zur Verfügung stehen.';

  @override
  String get your_journey => 'Deine Reise';

  @override
  String get journey_results_available => 'Ergebnisse verfügbar';

  @override
  String get summary => 'Übersicht';

  @override
  String get consent => 'Einverständnis';

  @override
  String get error => 'Fehler!';

  @override
  String get tea_vs_coffee => 'Tee vs. Kaffee';

  @override
  String get weed_vs_alcohol => 'Gras vs. Alkohol';

  @override
  String get back_pain => 'Rückenschmerzen';

  @override
  String get video_task => 'Videoaufgabe';

  @override
  String get finished => 'Fertig';

  @override
  String get how_would_you_rate_your_pain_today =>
      'Wie würden Sie heute Ihren Schmerz bewerten? (0 = kein Schmerz, 10 = extreme Schmerzen)';

  @override
  String get thank_you_for_your_input => 'Danke für Ihre Eingaben';

  @override
  String get please_give_consent =>
      'Bitte geben Sie Ihr Einverständnis ab, um an der Studie teilzunehmen. Sie müssen alle Boxen anklicken und lesen.';

  @override
  String get please_give_consent_why => 'Warum?';

  @override
  String get please_give_consent_reason =>
      'Aus Gründen der Sicherheit und des Datenschutzes müssen Studien das Einverständnis der Teilnehmer einholen. Aus diesem Grund müssen Sie für jede Studie erneut Ihr Einverständnis abgeben.';

  @override
  String get user_did_not_give_consent =>
      'Um an der Studie teilzunehmen müssen Sie erst Ihr Einverständnis abgeben.';

  @override
  String get setting_up_study => 'Studie wird vorbereitet...';

  @override
  String get good_to_go => 'Es kann losgehen!';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profil';

  @override
  String get help => 'Hilfe';

  @override
  String get contact => 'Kontakt';

  @override
  String get contact_support => 'Support kontaktieren';

  @override
  String support_email_body(String subjectId) {
    return 'Hallo,\n\nich habe einen Ladefehler in der StudyU App. Meine Subject-ID ist: $subjectId\n\nBitte helfen Sie mir bei diesem Problem.\n\nVielen Dank.';
  }

  @override
  String get about => 'Über StudyU';

  @override
  String get settings => 'Einstellungen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get confirm => 'Auswahl bestätigen';

  @override
  String get survey => 'Umfrage';

  @override
  String get complete => 'Absenden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get accept => 'Akzeptieren';

  @override
  String get decline => 'Ablehnen';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get done => 'Fertig';

  @override
  String get completed => 'Erledigt';

  @override
  String get faq_full => 'Häufig gestellte Fragen';

  @override
  String get faq => 'FAQ';

  @override
  String get start_study => 'Studie starten';

  @override
  String get next_day => 'Nächster Tag';

  @override
  String get could_not_save_results =>
      'Ergebnisse konnten nicht gespeichert werden.';

  @override
  String get take_a_photo => 'Foto aufnehmen';

  @override
  String get start_recording => 'Starte eine Aufnahme';

  @override
  String get stop_recording => 'Stoppe die Aufnahme';

  @override
  String get error_recording => 'Fehler bei der Aufnahme';

  @override
  String get photo_captured => 'Foto aufgenommen';

  @override
  String get audio_recorded => 'Audio aufgenommen';

  @override
  String get multimodal_not_supported =>
      'Multimodale Aufgaben werden in der Web-Version zur Zeit nicht unterstützt. Bitte verwenden Sie die App Version für iOS oder Android.';

  @override
  String get camera_access_denied => 'Zugriff auf Kamera verweigert';

  @override
  String get no_camera_available => 'Keine Kamera verfügbar';

  @override
  String get microphone_access_denied => 'Zugriff auf Mikrofon verweigert';

  @override
  String get camera_error => 'Kamerafehler';

  @override
  String get recording_error => 'Aufnahme fehlgeschlagen';

  @override
  String get storing_photo => 'Foto wird gespeichert';

  @override
  String get storing_audio => 'Audio wird gespeichert';

  @override
  String get upload_error => 'Die Datei konnte nicht hochgeladen werden';

  @override
  String get language => 'Sprache';

  @override
  String get en => 'Englisch';

  @override
  String get de => 'Deutsch';

  @override
  String get allow_analytics => 'Analysefunktionen erlauben';

  @override
  String get allow_analytics_desc =>
      'Die App sammelt Analysedaten ausschließlich zu Verbesserungszwecken und niemals zur Nutzerverfolgung. Details können in den Datenschutzbestimmungen nachgelesen werden.';

  @override
  String get video_test => 'Das ist ein Videotest';

  @override
  String get survey_test => 'Das ist ein Umfragetest';

  @override
  String get current_report => 'Aktueller Bericht';

  @override
  String get report_history => 'Reportverlauf';

  @override
  String get no_reports_found => 'Keine Berichte gefunden';

  @override
  String get current_power_level => 'Aktueller Status';

  @override
  String get not_enough_data => 'Nicht genügend Daten';

  @override
  String get barely_enough_data => 'Kaum genügend Daten';

  @override
  String get enough_data => 'Genügend Daten';

  @override
  String get terms => 'Bedingungen';

  @override
  String get terms_read => 'Nutzungsbedingungen lesen';

  @override
  String get terms_content =>
      'Die Nutzungsbedingungen geben einen Überblick zu dem Zweck und der Nutzung der StudyU App. Bei Fragen, bitte wenden Sie sich an uns mit den Kontaktinformationen im Impressum.';

  @override
  String get terms_agree =>
      'Ich habe die Nutzungsbedingungen gelesen und bin damit einverstanden';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacy_read => 'Datenschutzbestimmung lesen';

  @override
  String get privacy_content =>
      'Die Datenschutzbestimmung beschreibt welche Daten gespeichert werden, warum, wann, wo, Zugangsrechte und welche Rechte Sie haben. Bei Fragen, bitte wenden Sie sich an uns mit den Kontaktinformationen im Impressum.';

  @override
  String get privacy_agree =>
      'Ich habe die Datenschutzbestimmung gelesen und bin damit einverstanden';

  @override
  String get imprint_read => 'Impressum lesen';

  @override
  String get invite_code_button => 'Einladungscode verwenden';

  @override
  String get private_study_invite_code => 'Privater Studien Einladungscode';

  @override
  String get invite_code => 'Einladungscode';

  @override
  String get invalid_invite_code => 'Dies ist kein valider Einladungscode';

  @override
  String get save_pdf => 'Als PDF speichern';

  @override
  String get was_saved_to => 'Die Datei wurde gespeichert unter ';

  @override
  String get save_not_supported => 'Fehler';

  @override
  String get save_not_supported_description =>
      'Dateidownload ist in der Web-Version zur Zeit nicht unterstützt.';

  @override
  String get eligible_no => 'Diese Studie ist für Sie leider nicht auswählbar';

  @override
  String get eligible_yes => 'Sie sind berechtigt, diese Studie auszuwählen';

  @override
  String get eligible_mistake =>
      'Falls Sie einen Fehler gemacht haben, können Sie Ihre Antworten ändern';

  @override
  String get eligible_back => 'Zurück zur Studienauswahl';

  @override
  String get eligible_choice_multi_selection =>
      'Alle zutreffenden Antworten auswählen';

  @override
  String get report_overview => 'Ergebnisübersicht';

  @override
  String get report_primary_result => 'Hauptresultat';

  @override
  String get report_disclaimer =>
      'Die Ergebnisse sind nur korrekt, wenn Sie alle Informationen wahrheitsgemäß angegeben haben';

  @override
  String get performance => 'Fortschritt';

  @override
  String get performance_overview => 'Übersicht der erfüllten Aufgaben';

  @override
  String get performance_overview_interventions => 'Maßnahmen';

  @override
  String get performance_overview_observations => 'Messungen';

  @override
  String get report_outcome_inconclusive =>
      'Die Ergebnisse sind unschlüssig. Es gibt anscheinend keinen statistisch signifikanten Unterschied zwischen den Interventionen.';

  @override
  String get report_outcome_neither =>
      'Beide Interventionen scheinen einen negativen Effekt auf das Ereignis zu haben.';

  @override
  String report_outcome_one(Object intervention) {
    return 'Die Intervention $intervention scheint das Ergebnis zu verbessen.';
  }

  @override
  String get report_axis_phase => 'Phase';

  @override
  String get study_not_started =>
      'Ihre Studie hat noch nicht angefangen. Bitte schauen Sie morgen noch einmal vorbei!';

  @override
  String get completed_study =>
      'Sie haben Ihre letzte Studie abgeschlossen. Schauen Sie vergangene Ergebnisse an oder starten Sie eine neue Studie.';

  @override
  String get app_support => 'App Support';

  @override
  String get app_support_text =>
      'Bei Problemen oder Fragen zur App kontaktieren';

  @override
  String get study_support => 'Studien Support';

  @override
  String get study_support_text =>
      'Bei Problemen oder Fragen zur Studie kontaktieren';

  @override
  String get organization => 'Organisation';

  @override
  String get irb => 'Zuständige Ethikkommission';

  @override
  String get researchers => 'Forscher';

  @override
  String get website => 'Website';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Telefon';

  @override
  String get additionalInfo => 'Zusätzliche Informationen';

  @override
  String free_text_min_length_error(num min) {
    return 'Bitte geben Sie mindestens $min Zeichen ein';
  }

  @override
  String free_text_max_length_error(num max) {
    return 'Bitte geben Sie maximal $max Zeichen ein';
  }

  @override
  String get free_text_alphanumeric_error =>
      'Bitte geben Sie nur alphanumerische Zeichen ein';

  @override
  String get free_text_numeric_error =>
      'Bitte geben Sie nur numerische Zeichen ein';

  @override
  String free_text_custom_error(String pattern) {
    return 'Bitte geben Sie nur Zeichen ein, die dem Muster $pattern entsprechen';
  }

  @override
  String get app_outdated_message =>
      'Eine neue Version der StudyU App ist verfügbar. Bitte führen Sie eine Aktualisierung durch, um die neuesten Funktionen und Verbesserungen zu erhalten. Vielen Dank für Ihre Unterstützung!';

  @override
  String get update_now => 'Jetzt aktualisieren';

  @override
  String get text_summary_section_prefix_higher => 'Dein ';

  @override
  String get text_summary_section_was_higher =>
      ' war höher während der Intervention: ';

  @override
  String get text_summary_section_was_lower =>
      ' war niedriger während der Intervention: ';

  @override
  String get text_summary_section_compared_to => ' im Vergleich zu: ';

  @override
  String get text_summary_section_and => ' und ';

  @override
  String get text_summary_section_no_evidence =>
      'Es gab keinen Hinweis auf einen Unterschied bei ';

  @override
  String get text_summary_section_between => ' zwischen den Interventionen: ';

  @override
  String get intervention => 'Intervention';

  @override
  String get phase => 'Phase';

  @override
  String get day => 'Tag';

  @override
  String get no_data_available_yet => 'Noch keine Daten verfügbar';

  @override
  String get value => 'Wert';

  @override
  String get show_colorless_gauges => 'Barrierefreie Diagramme anzeigen';

  @override
  String get welchs_t_test_results => 'Welchs t-Test Ergebnisse';

  @override
  String get sample_a => 'Stichprobe A';

  @override
  String get sample_b => 'Stichprobe B';

  @override
  String get sample_size => 'n';

  @override
  String get mean => 'Mittelwert';

  @override
  String get variance => 'Varianz';

  @override
  String get t_statistic => 't-Wert';

  @override
  String get degrees_of_freedom => 'Freiheitsgrade';

  @override
  String get p_value => 'p-Wert';

  @override
  String get result_significant => 'Signifikanter Unterschied';

  @override
  String get result_not_significant => 'Kein signifikanter Unterschied';

  @override
  String get level_of_significance => 'Signifikanzniveau';

  @override
  String get t_test_outcome_based_on =>
      'Das Ergebnis basiert auf den folgenden Werten:';

  @override
  String get statistical_information => 'Statistische Informationen';

  @override
  String get close => 'Schließen';

  @override
  String get significance_level_and_p_value => 'Signifikanzniveau und p-Wert';

  @override
  String get descriptive_statistics => 'Deskriptive Statistik';

  @override
  String compare_results_between(String nameA, String nameB) {
    return 'Vergleiche Ergebnisse zwischen $nameA und $nameB';
  }

  @override
  String get missing_observations_note =>
      'Hinweis: Fehlende Beobachtungen bedeuten, dass an diesen Tagen keine Daten aufgezeichnet wurden.';

  @override
  String get quick_summary => 'Kurzfassung';

  @override
  String get average_score => 'Durchschnittswert';

  @override
  String get data_completeness => 'Datenvollständigkeit';

  @override
  String get statistic => 'Statistik';

  @override
  String get total_recordings => 'Gesamtaufzeichnungen';

  @override
  String get missing_recordings => 'Fehlende Aufzeichnungen';

  @override
  String get average => 'Durchschnitt';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get support_email_sent => 'Support-E-Mail geöffnet';

  @override
  String get support_email_sent_description =>
      'Ihre Support-Anfrage wurde in Ihrer E-Mail-App vorbereitet. Bitte senden Sie die E-Mail, um unser Support-Team zu erreichen und warten Sie auf eine Antwort.\n\nWenn Sie aktuell an einer Studie teilnehmen, dokumentieren Sie Ihre Ergebnisse bitte außerhalb der App, bis das Problem behoben ist. Vielen Dank für Ihr Verständnis.';

  @override
  String get no_contact_email =>
      'Keine Kontakt-E-Mail-Adresse angegeben. Bitte wenden Sie sich an Ihre Studienleitung.';

  @override
  String get sync_fitbit_data => 'Fitbit-Daten synchronisieren';

  @override
  String get fitbit_data_synced =>
      'Fitbit-Daten wurden erfolgreich synchronisiert';

  @override
  String get fitbit_data_not_synced =>
      'Fitbit-Daten konnten nicht synchronisiert werden. Bitte stellen Sie sicher, dass Sie Ihre Fitbit-Daten in der Fitbit-App synchronisiert haben.';

  @override
  String error_syncing_fitbit_data(String error) {
    return 'Fehler beim Synchronisieren der Fitbit-Daten: $error';
  }

  @override
  String get fitbit_data_synced_dialog_title => 'Fitbit-Daten synchronisiert';

  @override
  String get fitbit_data_synced_info =>
      'Daten wurden für die folgenden Datentypen synchronisiert:';

  @override
  String fitbit_data_earliest_date(String date) {
    return 'Frühestes Datum: $date';
  }

  @override
  String fitbit_data_latest_date(String date) {
    return 'Spätestes Datum: $date';
  }

  @override
  String get fitbit_data_details_btn => 'Details';

  @override
  String get fitbit_data_close_btn => 'Schließen';

  @override
  String get painIndicatorText => 'Schmerzlevel';

  @override
  String get dialogTitle => 'Schmerzlevel auswählen';

  @override
  String get okButton => 'OK';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get painLevel_0 => 'Kein Schmerz';

  @override
  String get painLevel_2 => 'Tut ein bisschen weh';

  @override
  String get painLevel_4 => 'Tut etwas mehr weh';

  @override
  String get painLevel_6 => 'Tut noch mehr weh';

  @override
  String get painLevel_8 => 'Tut sehr weh';

  @override
  String get painLevel_10 => 'Stärkster Schmerz';

  @override
  String get body_head => 'Kopf';

  @override
  String get body_head_front => 'Kopf (Vorne)';

  @override
  String get body_face => 'Gesicht';

  @override
  String get body_forehead => 'Stirn';

  @override
  String get body_eyes => 'Augen';

  @override
  String get body_nose => 'Nase';

  @override
  String get body_mouth => 'Mund';

  @override
  String get body_head_back => 'Kopf (Hinten)';

  @override
  String get body_inner_ear_balance => 'Innenohr / Gleichgewicht';

  @override
  String get body_neck => 'Nacken';

  @override
  String get body_neck_front => 'Hals (Vorne)';

  @override
  String get body_neck_back => 'Nacken (Hinten)';

  @override
  String get body_torso => 'Oberkörper';

  @override
  String get body_chest => 'Brust';

  @override
  String get body_left_chest => 'Linke Brust';

  @override
  String get body_right_chest => 'Rechte Brust';

  @override
  String get body_breastbone => 'Brustbein';

  @override
  String get body_upper_back => 'Oberer Rücken';

  @override
  String get body_left_shoulder_blade => 'Linkes Schulterblatt';

  @override
  String get body_right_shoulder_blade => 'Rechtes Schulterblatt';

  @override
  String get body_spine_upper_middle =>
      'Wirbelsäule (Oberer/Mittlerer Bereich)';

  @override
  String get body_abdomen => 'Bauch';

  @override
  String get body_upper_abdomen => 'Oberbauch';

  @override
  String get body_lower_abdomen => 'Unterbauch';

  @override
  String get body_left_side_abdomen => 'Linke Seite (Bauch)';

  @override
  String get body_right_side_abdomen => 'Rechte Seite (Bauch)';

  @override
  String get body_lower_back => 'Unterer Rücken';

  @override
  String get body_spine_lower => 'Wirbelsäule (Unterer Bereich)';

  @override
  String get body_left_flank => 'Linke Flanke (Seite)';

  @override
  String get body_right_flank => 'Rechte Flanke (Seite)';

  @override
  String get body_arms => 'Arme';

  @override
  String get body_left_arm => 'Linker Arm';

  @override
  String get body_left_shoulder => 'Linke Schulter';

  @override
  String get body_left_upper_arm => 'Linker Oberarm';

  @override
  String get body_left_bicep => 'Linker Bizeps';

  @override
  String get body_left_tricep => 'Linker Trizeps';

  @override
  String get body_left_elbow => 'Linker Ellbogen';

  @override
  String get body_left_lower_arm => 'Linker Unterarm';

  @override
  String get body_left_forearm => 'Linker Unterarm';

  @override
  String get body_left_wrist => 'Linkes Handgelenk';

  @override
  String get body_left_hand => 'Linke Hand';

  @override
  String get body_left_palm => 'Linke Handfläche';

  @override
  String get body_left_fingers => 'Linke Finger';

  @override
  String get body_right_arm => 'Rechter Arm';

  @override
  String get body_right_shoulder => 'Rechte Schulter';

  @override
  String get body_right_upper_arm => 'Rechter Oberarm';

  @override
  String get body_right_bicep => 'Rechter Bizeps';

  @override
  String get body_right_tricep => 'Rechter Trizeps';

  @override
  String get body_right_elbow => 'Rechter Ellbogen';

  @override
  String get body_right_lower_arm => 'Rechter Unterarm';

  @override
  String get body_right_forearm => 'Rechter Unterarm';

  @override
  String get body_right_wrist => 'Rechtes Handgelenk';

  @override
  String get body_right_hand => 'Rechte Hand';

  @override
  String get body_right_palm => 'Rechte Handfläche';

  @override
  String get body_right_fingers => 'Rechte Finger';

  @override
  String get body_lower_body => 'Unterkörper';

  @override
  String get body_pelvis => 'Becken';

  @override
  String get body_groin => 'Leiste';

  @override
  String get body_hips => 'Hüften';

  @override
  String get body_buttocks => 'Gesäß';

  @override
  String get body_legs => 'Beine';

  @override
  String get body_left_leg => 'Linkes Bein';

  @override
  String get body_left_upper_leg => 'Linker Oberschenkel';

  @override
  String get body_left_thigh_front => 'Oberschenkel (Vorne)';

  @override
  String get body_left_thigh_back => 'Oberschenkel (Hinten)';

  @override
  String get body_left_knee => 'Linkes Knie';

  @override
  String get body_left_lower_leg => 'Linker Unterschenkel';

  @override
  String get body_left_shin => 'Schienbein';

  @override
  String get body_left_calf => 'Wade';

  @override
  String get body_left_ankle => 'Linker Knöchel';

  @override
  String get body_left_foot => 'Linker Fuß';

  @override
  String get body_left_heel => 'Ferse';

  @override
  String get body_left_foot_sole => 'Fußsohle / Fußgewölbe';

  @override
  String get body_left_toes => 'Zehen';

  @override
  String get body_right_leg => 'Rechtes Bein';

  @override
  String get body_right_upper_leg => 'Rechter Oberschenkel';

  @override
  String get body_right_thigh_front => 'Oberschenkel (Vorne)';

  @override
  String get body_right_thigh_back => 'Oberschenkel (Hinten)';

  @override
  String get body_right_knee => 'Rechtes Knie';

  @override
  String get body_right_lower_leg => 'Rechter Unterschenkel';

  @override
  String get body_right_shin => 'Schienbein';

  @override
  String get body_right_calf => 'Wade';

  @override
  String get body_right_ankle => 'Rechter Knöchel';

  @override
  String get body_right_foot => 'Rechter Fuß';

  @override
  String get body_right_heel => 'Ferse';

  @override
  String get body_right_foot_sole => 'Fußsohle / Fußgewölbe';

  @override
  String get body_right_toes => 'Zehen';

  @override
  String get painTypeLabel => 'Schmerztyp';

  @override
  String get bodyPartLabel => 'Körperteil';

  @override
  String get painTypeUnspecified => 'Nicht angegeben';

  @override
  String get painTypeBurning => 'Brennend';

  @override
  String get painTypeStabbing => 'Stechend';

  @override
  String get painTypeAching => 'Schmerzhaft';

  @override
  String get painTypeThrobbing => 'Pochend';

  @override
  String get painTypeSharp => 'Scharf';

  @override
  String get painTypeDull => 'Dumpf';

  @override
  String get painTypeCramping => 'Krampfartig';

  @override
  String get painTypeRadiating => 'Ausstrahlend';

  @override
  String get painTypeTingling => 'Kribbelnd';

  @override
  String get painTypeShooting => 'Einschießend';

  @override
  String get painTypePulsing => 'Pulsierend';

  @override
  String get painTypePressure => 'Druck';

  @override
  String get painTypeTightness => 'Engegefühl';

  @override
  String get painTypeSoreness => 'Wund';

  @override
  String get painTypeStiffness => 'Steifheit';

  @override
  String get preview_mode => 'Vorschau-Modus';

  @override
  String get preview_mode_active => 'Vorschau-Modus aktiv';

  @override
  String get preview_mode_active_state => 'Der Vorschau-Modus ist jetzt aktiv.';

  @override
  String get preview_mode_inactive_state =>
      'Der Vorschau-Modus ist jetzt inaktiv.';

  @override
  String get preview_mode_description =>
      'Sie befinden sich derzeit im Vorschau-Modus. Dies ermöglicht Ihnen:\n\n• Schneller Vorlauf durch Studientage mit der \"Nächster Tag\" Schaltfläche\n• Mehrfaches Abschließen von Aufgaben ohne Einschränkungen\n• Erleben des vollständigen Studienablaufs ohne Beeinflussung echter Daten\n\nWichtig: Ergebnisse und Daten aus dem Vorschau-Modus werden nicht gespeichert oder mit tatsächlichen Teilnehmerergebnissen aus laufenden Studien vermischt.';

  @override
  String get preview_mode_results_not_saved =>
      'Ergebnisse werden zum Schutz der Studienintegrität nicht gespeichert.';

  @override
  String get ok => 'OK';

  @override
  String get submit => 'Absenden';

  @override
  String get daily_food_diary => 'Tägliches Ernährungstagebuch';

  @override
  String get saving => 'Speichern...';

  @override
  String saved_ago(String time) {
    return 'Gespeichert vor $time';
  }

  @override
  String get just_now => 'gerade eben';

  @override
  String seconds_ago(int seconds) {
    return 'vor $seconds Sekunden';
  }

  @override
  String minutes_ago(int minutes) {
    return 'vor $minutes Minute(n)';
  }

  @override
  String hours_ago(int hours) {
    return 'vor $hours Stunde(n)';
  }

  @override
  String get instructions => 'Anleitung';

  @override
  String get nutrition_instructions_default =>
      'Bitte erfassen Sie alle Lebensmittel und Getränke, die Sie heute konsumiert haben. Geben Sie für jede Mahlzeit oder jeden Snack so viele Details wie möglich an, einschließlich Portionsgrößen und Zubereitungsmethoden.';

  @override
  String min_meals_required(int count) {
    return 'Bitte erfassen Sie mindestens $count Mahlzeit(en)';
  }

  @override
  String get recall_details => 'Protokolldetails';

  @override
  String get date => 'Datum';

  @override
  String get recall_mode => 'Protokollmodus';

  @override
  String get recall_mode_realtime => 'Echtzeit-Erfassung';

  @override
  String get recall_mode_yesterday => 'Rückblick auf gestern';

  @override
  String get usual_intake_day => 'Gewöhnlicher Verzehrtag';

  @override
  String get usual_intake_question =>
      'War dies ein typischer Tag für Ihre Ernährung?';

  @override
  String get special_occasion => 'Besonderer Anlass';

  @override
  String get special_occasion_hint => 'z.B. Geburtstag, Feiertag, etc.';

  @override
  String meals_count(int count) {
    return 'Mahlzeiten ($count)';
  }

  @override
  String get add_meal => 'Mahlzeit hinzufügen';

  @override
  String get no_meals_recorded => 'Noch keine Mahlzeiten erfasst';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get meal_type_breakfast => 'Frühstück';

  @override
  String get meal_type_lunch => 'Mittagessen';

  @override
  String get meal_type_dinner => 'Abendessen';

  @override
  String get meal_type_snack => 'Snack';

  @override
  String get meal_type_brunch => 'Brunch';

  @override
  String get meal_type_other => 'Sonstiges';

  @override
  String food_items_count(int count) {
    return '$count Lebensmittel';
  }

  @override
  String get meal_entry_title => 'Mahlzeit erfassen';

  @override
  String get save => 'Speichern';

  @override
  String get meal_information => 'Mahlzeitinformationen';

  @override
  String get meal_type_label => 'Mahlzeittyp';

  @override
  String get custom_meal_label => 'Eigene Mahlzeitbezeichnung';

  @override
  String get time => 'Uhrzeit';

  @override
  String get where_did_you_eat => 'Wo haben Sie gegessen?';

  @override
  String get location_description => 'Ortsbeschreibung';

  @override
  String get location_description_hint =>
      'Beschreiben Sie, wo Sie gegessen haben';

  @override
  String get who_were_you_with => 'Mit wem waren Sie zusammen?';

  @override
  String get distractions_during_meal => 'Ablenkungen während der Mahlzeit?';

  @override
  String get skipped_this_meal => 'Diese Mahlzeit übersprungen';

  @override
  String get reason_for_skipping => 'Grund für das Auslassen';

  @override
  String food_items_section(int count) {
    return 'Lebensmittel ($count)';
  }

  @override
  String get add_food => 'Lebensmittel hinzufügen';

  @override
  String get no_food_items_yet => 'Noch keine Lebensmittel';

  @override
  String get not_specified => 'Nicht angegeben';

  @override
  String get context_home => 'Zuhause';

  @override
  String get context_restaurant => 'Restaurant';

  @override
  String get context_takeout => 'Zum Mitnehmen';

  @override
  String get context_vending => 'Automat';

  @override
  String get context_other => 'Sonstiges';

  @override
  String get company_alone => '👤 Allein';

  @override
  String get company_family => '👨‍👩‍👧‍👦 Familie';

  @override
  String get company_friends => '👥 Freunde';

  @override
  String get company_colleagues => '💼 Kollegen';

  @override
  String get company_other => '🤝 Andere';

  @override
  String get distraction_none => '🧘 Keine';

  @override
  String get distraction_tv => '📺 Fernseher';

  @override
  String get distraction_phone => '📱 Handy';

  @override
  String get distraction_work => '💻 Arbeit';

  @override
  String get distraction_other => '📖 Sonstiges';

  @override
  String get food_entry_title => 'Lebensmittel erfassen';

  @override
  String get food_information => 'Lebensmittelinformationen';

  @override
  String get entry_type => 'Eintragstyp';

  @override
  String get food_name => 'Lebensmittelname *';

  @override
  String get brand_name => 'Markenname';

  @override
  String get description => 'Beschreibung';

  @override
  String get description_hint => 'Optionale Notizen zu diesem Lebensmittel';

  @override
  String get recipe_info =>
      'Rezept: Nutzen Sie den Rezept-Builder für eine bessere Zutatenverwaltung';

  @override
  String get open_recipe_builder => 'Rezept-Builder öffnen';

  @override
  String get amount => 'Menge *';

  @override
  String get unit => 'Einheit *';

  @override
  String get serving_size => 'Portionsgröße (Gramm) *';

  @override
  String get portion_reference => 'Portionsreferenz';

  @override
  String get portion_reference_hint => 'z.B. 1 Tasse, 100g, mittlerer Apfel';

  @override
  String get portion_estimation_method => 'Portionsschätzmethode';

  @override
  String get portion_state => 'Portionszustand';

  @override
  String get yield_factor => 'Ertragsfaktor';

  @override
  String get yield_factor_hint => 'z.B. 0,75';

  @override
  String get edible_portion => 'Essbarer Anteil';

  @override
  String get edible_portion_hint => 'z.B. 0,85';

  @override
  String get nutrition_information => 'Nährwertinformationen';

  @override
  String get energy_kcal => 'Energie (kcal) *';

  @override
  String get protein_g => 'Protein (g)';

  @override
  String get carbs_g => 'Kohlenhydrate (g)';

  @override
  String get fat_g => 'Fett (g)';

  @override
  String get saturated_fat_g => 'Ges. Fettsäuren (g)';

  @override
  String get sugars_g => 'Zucker (g)';

  @override
  String get fiber_g => 'Ballaststoffe (g)';

  @override
  String get sodium_mg => 'Natrium (mg)';

  @override
  String get required_error => 'Erforderlich';

  @override
  String get enter_food_name => 'Bitte geben Sie einen Lebensmittelnamen ein';

  @override
  String get enter_serving_size => 'Bitte geben Sie die Portionsgröße ein';

  @override
  String get entry_type_single_ingredient => '🥕 Einzelne Zutat';

  @override
  String get entry_type_recipe => '📖 Rezept';

  @override
  String get entry_type_branded_product => '🏷️ Markenprodukt';

  @override
  String get entry_type_manual_entry => '✏️ Manuelle Eingabe';

  @override
  String get portion_method_household => 'Haushaltsmass';

  @override
  String get portion_method_photograph => 'Foto';

  @override
  String get portion_method_standard_unit => 'Standardeinheit';

  @override
  String get portion_method_user_weighted => 'Selbst gewogen';

  @override
  String get portion_method_unknown => 'Unbekannt';

  @override
  String get portion_state_raw => 'Roh';

  @override
  String get portion_state_cooked => 'Gekocht';

  @override
  String get portion_state_as_served => 'Wie serviert';
}
