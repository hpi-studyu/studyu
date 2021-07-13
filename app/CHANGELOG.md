## 1.9.4

 - Update a dependency to the latest release.

## 1.9.3

 - **FIX**: Skip eligibilty screen if not defined.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.9.2

 - **REFACTOR**: Table columns now have underscores.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.9.1

 - Update a dependency to the latest release.

## 1.9.0

 - **FIX**: Fail on joining by invite w/o preselectedIds.
 - **FEAT**: Research can test draft studies.
 - **CHORE**: Clean up.

## 1.8.0

 - **FEAT**: Add Version, Licenses info dialog.
 - **CI**: fastlane iOS: Readd timeout to create_keychain.
 - **CI**: iOS fastlane: Remove possibly failing params.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.7.0

 - **FIX**: Adapt app to new task schedule model.
 - **FEAT**: Lock task outside of completion period.
 - **CI**: Upgrade fastlane.
 - **CHORE**: Adapt to flutter 2.3 release.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.6.0

 - **FEAT**: Indicate days left in current intervention.
 - **CI**: Fix Fastlane iOS using temp keychain.
 - **CI**: Set match provisioning profile.
 - **CI**: Use fastlane match.
 - **CI**: Remove unneeded parameters.
 - **CI**: Add fastlane ios keychain creation.
 - **CI**: Add team to get_certs.
 - **CI**: ios fastlane add get certificats.
 - **CI**: Add fastlane get provisioning profiles step.
 - **CI**: Add ios fastlane setup.
 - **CI**: Correctly set fastlane play credentials.
 - **CI**: Set jsonkey data.
 - **CI**: Fix Gemfile.lock for Windows.
 - **CI**: Add fastlane for android app.
 - **CI**: Remove codemagic CI signing.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade studyu_packages.
 - **CHORE**: Add pub.dev release needed files.

## 1.5.2

 - **FIX**: Upgrade supabase -> Fix jwt expired.
 - **FIX**: Add close button to consent item.
 - **CHORE**: Upgrade studyu packages.

## 1.5.1

 - **FIX**: Hide report section until study is finished.
 - **FIX**: Retry fetching subjects if JWT is expired.
 - **CI**: Add gradle files for codemagic.
 - **CHORE**: Upgrade studyu packages.

## 1.5.0

 - **TEST**: Fix tests.
 - **STYLE**: Fix lint.
 - **STYLE**: Address lints.
 - **REFACTOR**: Generate startDate on server.
 - **REFACTOR**: Move UserQueries to common.
 - **REFACTOR**: Rename studyou_core -> studyu_core.
 - **REFACTOR**: Rename numberOfPhases => numberOfInterventions.
 - **REFACTOR**: Rename var.
 - **REFACTOR**: Add isBaseline to Intervention.
 - **REFACTOR**: Rename var.
 - **REFACTOR**: Load env from common.
 - **REFACTOR**: Core only uses dart; added flutter common.
 - **REFACTOR**: Rename StudySubject variables to subject.
 - **REFACTOR**: Remove unneeded result properties.
 - **REFACTOR**: Save results in separate table.
 - **REFACTOR**: Rename UserStudy -> StudySubject.
 - **REFACTOR**: Pass interventionIds.
 - **REFACTOR**: Replace InterventionSet with List<Intervention>.
 - **REFACTOR**: Only save selectedInterventions in DB.
 - **REFACTOR**: Embed Study in userStudy.
 - **REFACTOR**: Add json_serializable to tables.
 - **REFACTOR**: Migrate to null-safety.
 - **REFACTOR**: Prepare for null-safety.
 - **REFACTOR**: Make more methods static.
 - **REFACTOR**: Rename StudyUConfig->AppConfig.
 - **REFACTOR**: Further improvements to SupabaseObjects.
 - **REFACTOR**: Time->ScheduleTime for less collisions.
 - **REFACTOR**: Reorg core library.
 - **REFACTOR**: Improve Supabase objects.
 - **REFACTOR**: Restructure package.
 - **REFACTOR**: Migrate Parse to Supabase.
 - **REFACTOR**: Move ParseConfig queries to core.
 - **REFACTOR**: Add more typing to routing.
 - **REFACTOR**: Setup generated i18n.
 - **REFACTOR**: Cleanup app language.
 - **REFACTOR**: Use new generated localizations class.
 - **REFACTOR**: Clean up code.
 - **REFACTOR**: Replace deprecated buttons with new ones.
 - **REFACTOR**: Adapt to merging of study and details.
 - **REFACTOR**: Rename _evaluateResponse -> _addQuestionnaireResponse.
 - **REFACTOR**: Do not use .then here.
 - **REFACTOR**: Add support for gen. localizations.
 - **REFACTOR**: Change StudyQueries to dart extensions.
 - **REFACTOR**: Move StudyQueries to model class.
 - **REFACTOR**: Remove unused QuestionWidgetModel.
 - **FIX**: Fix compatibility with newest beta.
 - **FIX**: Initialize notifications before scheduling.
 - **FIX**: Remove unneeded shrinkWrap.
 - **FIX**: Fix for CI.
 - **FIX**: Make recovering session more robust.
 - **FIX**: Don't call constructor to call extension.
 - **FIX**: Only fetch keys required for study selection.
 - **FIX**: Upgrade packages to beta channel.
 - **FIX**: Reset invite code and preselected IDs.
 - **FIX**: Scaffold.of deprecated.
 - **FIX**: Use relative path to package.
 - **FIX**: spelling.
 - **FIX**: Disable notifications on web.
 - **FIX**: Masterkey needed to create a user.
 - **FIX**: Improve UI of questionnaires.
 - **FIX**: Future retry button not reloading.
 - **FIX**: Add retry for creating subject.
 - **FIX**: Add language options for ios.
 - **FIX**: onSelectNotification expects Future.
 - **FIX**: Don't color border.
 - **FIX**: Use dart conform names.
 - **FIX**: Fix contact not displaying correctly.
 - **FIX**: Do not call notifications for web.
 - **FIX**: Use clientKey instead of masterKey.
 - **FIX**: Make user login more robust.
 - **FIX**: Typo not kIsWeb.
 - **FIX**: Fix installation-id for back4app.
 - **FIX**: Multiple completion off same task.
 - **FEAT**: Restructure contact screen.
 - **FEAT**: Add IRB contact field.
 - **FEAT**: Add FAQ and contact to Welcome page.
 - **FEAT**: Add FHIR Questionnaire Widget.
 - **FEAT**: Add project generator.
 - **FEAT**: Display support contact.
 - **FEAT**: Load preselectedIds from invite.
 - **FEAT**: Add header/footer to questionnaire.
 - **FEAT**: Add anonymous signup via fake email.
 - **FEAT**: Auto forward on kickoff screen.
 - **FEAT**: Add update repo study data.
 - **FEAT**: Add Complete button to Questionnaire.
 - **FEAT**: Add terms and privacy disclaimer to designer.
 - **FEAT**: Color Study publisher header.
 - **FEAT**: WelcomeScreen: Make Get Started more apparent.
 - **FEAT**: Replace User with locally generated UUID.
 - **FEAT**: Rework terms & privacy screen.
 - **FEAT**: Remove support/contact overview page.
 - **FEAT**: Add support for study invite code.
 - **FEAT**: Use fhir questionnaire with fallback.
 - **FEAT**: Implement conditional FHIR questions.
 - **FEAT**: Add FileSaveDialog + Gradle upgrade.
 - **FEAT**: Separate study publisher contact.
 - **FEAT**: Define generate localizations.
 - **CI**: Fix version bump by using single quote.
 - **CI**: Update dependencies workflow.
 - **CHORE**: Upgrade Parse to Null-safety.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Move packages to null-safety.
 - **CHORE**: Remove deps override.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade minor deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade lint to 1.5.3.
 - **CHORE**: Enable for core; remove avoid_as.
 - **CHORE**: Remove rule which is now part of lint.
 - **CHORE**: Upgrade deps.
 - **CHORE**: By default (codemagic) use test env.
 - **CHORE**: Remove debug skip to dashboard.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add test back4app environment.
 - **CHORE**: Disable default parse debug msgs.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Rename packages + prefix with studyu.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps mostly stable null-safety deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: v1.4.1.
 - **CHORE**: Setup .env files again.
 - **CHORE**: Use gotrue from git.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unneeded notifications setup.
 - **CHORE**: Upgrade pdf to 2.0.0.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade supabase deps.
 - **CHORE**: v1.4.0.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unnecessary form.
 - **CHORE**: Upgrade deps.
 - **CHORE**: v1.2.0.
 - **CHORE**: Refactor according to pdf 1.3.0 deprecation.
 - **CHORE**: Remove unused import.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade gradle: 6.7.1, plugin: 4.1.1.
 - **CHORE**: v1.1.0.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add mono_repo config.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unneeded envs.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unused packages.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade gradle for codemagic (Java 8).
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: fix formatting.
 - **CHORE**: Upgrade gradle.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unneeded package.
 - **CHORE**: Upgrade ios project.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade parse to working commit.
 - **CHORE**: Update android files.
 - **CHORE**: Remove heroku envs.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove version +.
 - **CHORE**: Switch back to parse sdk repo.
 - **CHORE**: Upgrade packages.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Set default .env file to back4App.
 - **CHORE**: Cleanup envs; Add back4app env.
 - **CHORE**: Minor deps upgrade.
 - **CHORE**: Minor version bump.
 - **CHORE**: Remove unneeded stuff.
 - **CHORE**: Remove cuptertino widgets import everywher.
 - **CHORE**: Add melos, tool for managing packages.
 - **CHORE**: Remove left over gitlab ci.
 - **CHORE**: Remove unused translations.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade gradle until fixed for flutter.
 - **CHORE**: Remove deprecated entry.
 - **CHORE**: Fix release signing.
 - **CHORE**: Remove mono_repo files.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Use health.studyu.app bundle ID.
 - **CHORE**: Check boxes in debug.
 - **CHORE**: Skip clicking all boxes in debug.
 - **CHORE**: Add release config.
 - **CHORE**: gitignore jks files.
 - **CHORE**: Upgrade gradle plugin.
 - **CHORE**: Cleanup json_annotation remains.

