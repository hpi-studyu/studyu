## 3.7.0

 - **FEAT**: Add ability to initialize with existing.
 - **CHORE**: Upgrade deps.

## 3.6.0

 - **FIX**: Return empty CSV if no results yet.
 - **FEAT**: Add gitUrl and webUrl.
 - **CHORE**: Upgrade deps.

## 3.5.0

 - **FIX**: Update deeplinks for designer.
 - **FEAT**: Add fetchResultsCSVTable.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps; Generate json_serializable.
 - **CHORE**: Use pub.dev hosted version of core and common.

## 3.4.2

 - **FIX**: Correct column snail case naming.

## 3.4.1

 - **REFACTOR**: Make supabase vars public.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.4.0

 - **FEAT**: Add method to check if elgibility is defined.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.3.2

 - **REFACTOR**: Table columns now have underscores.
 - **REFACTOR**: No need to use late init here.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.3.1

 - **FIX**: Do not require stats to be fetched.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.3.0

 - **FEAT**: Add app url env var.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.2.0

 - **REFACTOR**: Add default constructor for TimeOfDay.
 - **FIX**: Add default times.
 - **FEAT**: Add contains to CompletionPeriod.
 - **FEAT**: Spilt reminderTime and unlock/locking times.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.1.0

 - **FIX**: Fetch Subject with Study and Progress.
 - **FEAT**: Indicate days left in current intervention.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add pub.dev release needed files.

## 3.0.1

 - **FIX**: Upgrade supabase -> Fix jwt expired.
 - **CHORE**: Add status error logging.

## 3.0.0

> Note: This release has breaking changes.

 - **STYLE**: Format.
 - **STYLE**: Address lints.
 - **REFACTOR**: Filtering published studies now via RLS.
 - **REFACTOR**: Cleanup app language.
 - **REFACTOR**: Rename numberOfPhases => numberOfInterventions.
 - **REFACTOR**: Add isBaseline to Intervention.
 - **REFACTOR**: Rename StudyUConfig->AppConfig.
 - **REFACTOR**: Rename studyou_core -> studyu_core.
 - **REFACTOR**: Split Visibility into Participation and ResultSharing.
 - **REFACTOR**: Self manage state.
 - **REFACTOR**: Replace deprecated buttons with new ones.
 - **REFACTOR**: Change StudyQueries to dart extensions.
 - **REFACTOR**: Load env from common.
 - **REFACTOR**: Move StudyQueries to model class.
 - **REFACTOR**: No need for extensions.
 - **REFACTOR**: Core only uses dart; added flutter common.
 - **REFACTOR**: Repo Provider->GitProvider.
 - **REFACTOR**: Questionnaire -> StudyUQuestionnaire.
 - **REFACTOR**: Rename StudySubject variables to subject.
 - **REFACTOR**: AVOID using cast(); Use List.from.
 - **REFACTOR**: Generate ids on client.
 - **REFACTOR**: Remove unneeded result properties.
 - **REFACTOR**: Save results in separate table.
 - **REFACTOR**: Rename UserStudy -> StudySubject.
 - **REFACTOR**: startDate -> startedAt.
 - **REFACTOR**: Generate startDate on server.
 - **REFACTOR**: Pass interventionIds.
 - **REFACTOR**: Replace InterventionSet with List<Intervention>.
 - **REFACTOR**: Migrate Parse to Supabase.
 - **REFACTOR**: Make everything late, since set fromJson.
 - **REFACTOR**: Do not include baseline in generateWith.
 - **REFACTOR**: Embed Study in userStudy.
 - **REFACTOR**: Add json_serializable to tables.
 - **REFACTOR**: Migrate to null-safety.
 - **REFACTOR**: Prepare for null-safety.
 - **REFACTOR**: Make more methods static.
 - **REFACTOR**: Further improvements to SupabaseObjects.
 - **REFACTOR**: Add default tableName to SupabaseObject.
 - **REFACTOR**: Time->ScheduleTime for less collisions.
 - **REFACTOR**: Reorg core library.
 - **REFACTOR**: Improve Supabase objects.
 - **REFACTOR**: Move ParseConfig queries to core.
 - **REFACTOR**: Restructure package.
 - **REFACTOR**: Only save selectedInterventions in DB.
 - **FIX**: Fix compatibility with newest beta.
 - **FIX**: Fix installation-id for back4app.
 - **FIX**: Don't call constructor to call extension.
 - **FIX**: Do not depend on flutter.
 - **FIX**: Make some attributes optional.
 - **FIX**: Remove dotenv dependency.
 - **FIX**: Use clientKey instead of masterKey.
 - **FIX**: Fix missing selected keys for csv download.
 - **FIX**: Add redirectTo for non web.
 - **FIX**: Masterkey needed to create a user.
 - **FIX**: Use ParseHTTPClient for web bc faster.
 - **FIX**: Results only working for questionnaires.
 - **FIX**: Only fetch keys required for study selection.
 - **FIX**: Fix error display on start.
 - **FIX**: Make fhirQuestionnaire not required.
 - **FIX**: Fix for CI.
 - **FIX**: Fix next day creating more progress.
 - **FIX**: redirectTo now working thanks to.
 - **FIX**: ParseInit not reloading on error.
 - **FIX**: Add default study icon.
 - **FIX**: ParseFetchOneFutureBuilder refresh.
 - **FIX**: json_serializer DateTime.parse needs toString.
 - **FIX**: Scaffold.of deprecated.
 - **FIX**: Default study participation is invite only.
 - **FIX**: Fix release build web: Remove type.toString.
 - **FIX**: Future retry button not reloading.
 - **FIX**: Return null rather than failing to parse.
 - **FIX**: resultProperty can be null.
 - **FIX**: Force reload if parse query different.
 - **FIX**: Upgrade packages to beta channel.
 - **FEAT**: Add preselectedInterventionIds.
 - **FEAT**: Show name of sequence ABBA, ABAB.
 - **FEAT**: Use fhir questionnaire with fallback.
 - **FEAT**: Add login screen.
 - **FEAT**: Add StudyToken model.
 - **FEAT**: Add data logging to error.
 - **FEAT**: Add Github/GitLab login via gotrue.
 - **FEAT**: Add FHIR Questionnaire Widget.
 - **FEAT**: Add header, footer to task.
 - **FEAT**: Rework terms & privacy screen.
 - **FEAT**: Add 3 statistics to study.
 - **FEAT**: Add more study statistic and helpers.
 - **FEAT**: Add primaryKeyFiler.
 - **FEAT**: Add IRB contact field.
 - **FEAT**: Add visibility and userId to study.
 - **FEAT**: Replace User with locally generated UUID.
 - **FEAT**: Add FileSaveDialog + Gradle upgrade.
 - **FEAT**: Add invites to study model.
 - **FEAT**: Add support for study invite code.
 - **FEAT**: Add collaborators.
 - **FEAT**: Move edit button to fab + fixes.
 - **FEAT**: Add editorEmails + helpers to Study.
 - **FEAT**: Add update repo study data.
 - **FEAT**: Rearrange studies on dashboard.
 - **CI**: Update format of .g.dart files.
 - **CHORE**: Add mono_repo config.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Setup .env files again.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove deps override.
 - **CHORE**: Use gotrue from git.
 - **CHORE**: Upgrade Parse to Null-safety.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Move packages to null-safety.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade lint to 1.5.3.
 - **CHORE**: Format code.
 - **CHORE**: Rename packages + prefix with studyu.
 - **CHORE**: Remove rule which is now part of lint.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade supabase deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Rename StudyToken -> StudyInvite.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps mostly stable null-safety deps.
 - **CHORE**: Replace deprecated upsert.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Adjust formatting.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade pdf to 2.0.0.
 - **CHORE**: Cleanup json_annotation remains.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Enable for core; remove avoid_as.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add comment about keeping toString.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Add melos, tool for managing packages.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unused file.
 - **CHORE**: Remove left over gitlab ci.
 - **CHORE**: Add publish_to: none for linter.
 - **CHORE**: fix formatting.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove mono_repo files.
 - **CHORE**: Add master key env var.
 - **CHORE**: Adapt docker setup to supabase and melos.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade parse to working commit.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Switch back to parse sdk repo.
 - **CHORE**: Upgrade packages.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **BREAKING** **REFACTOR**: Merge StudyDetails into Study.

