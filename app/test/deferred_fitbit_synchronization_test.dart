import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/kickoff.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/deferred_fitbit_sync.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/study_local_cleanup.dart';
import 'package:studyu_app/widgets/questionnaire/questions/fitbit_question_widget.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

const _studyId = 'fitbit-study';
const _subjectId = 'fitbit-subject';
const _userId = 'fitbit-user';
const _interventionId = 'fitbit-intervention';
const _periodId = 'fitbit-period';

class _FailingFitbitCredentialWritePlatform
    extends TestFlutterSecureStoragePlatform {
  _FailingFitbitCredentialWritePlatform(super.data);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) {
    if (key.startsWith('fitbit_credentials_')) {
      return Future<void>.error(Exception('credential write failed'));
    }
    return super.write(key: key, value: value, options: options);
  }
}

class _FailingSubjectCacheWritePlatform
    extends TestFlutterSecureStoragePlatform {
  _FailingSubjectCacheWritePlatform(super.data);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) {
    if (key == cacheSubjectKey) {
      return Future<void>.error(Exception('subject cache write failed'));
    }
    return super.write(key: key, value: value, options: options);
  }
}

({StudySubject subject, QuestionnaireTask task, FitbitQuestion question})
_buildFitbitStudy() {
  final question = FitbitQuestion.withId(
    questionType: FitbitQuestion.questionType,
    types: [FitbitQuestionType.steps, FitbitQuestionType.heartrate],
  );
  final task = QuestionnaireTask.withId()
    ..title = 'Fitbit task'
    ..questions.questions = [question]
    ..schedule.completionPeriods = [
      CompletionPeriod(
        id: _periodId,
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23, minute: 59),
      ),
    ];
  final intervention = Intervention(_interventionId, 'Intervention');
  final study = Study(_studyId, _userId)
    ..title = 'Fitbit study'
    ..status = StudyStatus.running
    ..schedule.includeBaseline = false
    ..schedule.numberOfCycles = 1
    ..schedule.phaseDuration = 1
    ..interventions = [intervention]
    ..observations = [task]
    ..fitbitCredentials = StudyFitbitCredentials(
      _studyId,
      FitbitAuthCredentials(clientId: 'client-id', clientSecret: 'secret'),
    );
  final subject =
      StudySubject.fromStudy(study, _userId, [_interventionId], null)
        ..id = _subjectId
        ..startedAt = DateTime(2026, 8);
  return (subject: subject, task: task, question: question);
}

QuestionnaireState _deferredAnswer(
  FitbitQuestion question,
  DateTime answerTimestamp,
) {
  final state = QuestionnaireState();
  state.answers[question.id] = Answer<List<FitbitData>>(
    question.id,
    answerTimestamp,
  )..response = [];
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStoragePlatform originalStoragePlatform;
  late Map<String, String> storageData;

  setUp(() {
    Cache.debugResetSubjectWrites();
    originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    storageData = {};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      storageData,
    );
    Cache.debugUploadBlobFilesOverride = (_, _) async {};
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalStoragePlatform;
    Cache.debugUploadBlobFilesOverride = null;
    Cache.debugSaveProgressOverride = null;
    Cache.debugSaveSubjectOverride = null;
    FitbitHandler.debugResolveDeferredQuestionOverride = null;
    FitbitHandler.debugSyncFitbitDataOverride = null;
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride = null;
    FitbitHandler.debugObtainCredentialsOverride = null;
    appConnectionStatusController.reset();
  });

  test('join-time authorization is conditional on Fitbit questions', () async {
    final fixture = _buildFitbitStudy();
    var authorizationCalls = 0;
    FitbitHandler.debugAuthorizeForOfflineParticipationOverride =
        (_, types) async {
          authorizationCalls++;
          expect(types.toSet(), {
            FitbitQuestionType.steps,
            FitbitQuestionType.heartrate,
          });
          return false;
        };

    expect(
      await FitbitHandler.authorizeForOfflineParticipation(
        Study('study-without-fitbit', _userId),
      ),
      isTrue,
    );
    expect(authorizationCalls, 0);
    expect(
      await FitbitHandler.authorizeForOfflineParticipation(
        fixture.subject.study,
      ),
      isFalse,
    );
    expect(authorizationCalls, 1);
  });

  test('offline authorization requires durable credentials', () async {
    final fixture = _buildFitbitStudy();
    FlutterSecureStoragePlatform.instance =
        _FailingFitbitCredentialWritePlatform(storageData);
    FitbitHandler.debugObtainCredentialsOverride = (_, _) async =>
        fitbitter.FitbitCredentials(
          userID: 'fitbit-user',
          fitbitAccessToken: 'access-token',
          fitbitRefreshToken: 'refresh-token',
        );

    expect(
      await FitbitHandler.authorizeForOfflineParticipation(
        fixture.subject.study,
      ),
      isFalse,
    );
  });

  test(
    'offline completion stores a reload-safe request with original window',
    () async {
      final fixture = _buildFitbitStudy();
      final answerTime = DateTime(2026, 8, 3, 14, 30);
      final completedAt = DateTime.utc(2026, 8, 3, 14, 31);

      await persistDeferredFitbitQuestionnaireResult(
        subject: fixture.subject,
        task: fixture.task,
        interventionId: _interventionId,
        periodId: _periodId,
        questionnaireState: _deferredAnswer(fixture.question, answerTime),
        completedAt: completedAt,
      );

      final reloaded = await Cache.loadDeferredFitbitRequests();
      expect(reloaded, hasLength(1));
      expect(reloaded.single.completedAt, completedAt);
      expect(reloaded.single.questionnaireAnswers, isEmpty);
      expect(reloaded.single.questions, hasLength(1));
      expect(reloaded.single.questions.single.windowEnd, answerTime);
      expect(
        reloaded.single.questions.single.windowStarts.values,
        everyElement(DateTime(2026, 8, 3)),
      );
      expect(fixture.subject.progress, hasLength(1));
      final cachedSubject = await Cache.loadSubject(
        backupSubject: fixture.subject,
      );
      expect(
        cachedSubject.completedTaskInstanceForDay(
          fixture.task.id,
          fixture.task.schedule.completionPeriods.single,
          completedAt,
        ),
        isTrue,
      );
      expect(
        (fixture.subject.progress.single.result as Result<QuestionnaireState>)
            .result
            .answers[fixture.question.id]!
            .response,
        isEmpty,
      );
    },
  );

  test(
    'reconnect after study end materializes and uploads deferred Fitbit progress',
    () async {
      final fixture = _buildFitbitStudy();
      final completedAt = DateTime.utc(2026, 8, 3, 14, 31);
      await Cache.storeSubject(fixture.subject);
      await persistDeferredFitbitQuestionnaireResult(
        subject: fixture.subject,
        task: fixture.task,
        interventionId: _interventionId,
        periodId: _periodId,
        questionnaireState: _deferredAnswer(
          fixture.question,
          DateTime(2026, 8, 3, 14, 30),
        ),
        completedAt: completedAt,
      );
      final remoteSubject = StudySubject.fromJson(fixture.subject.toFullJson())
        ..progress = [];
      final dataTime = DateTime(2026, 8, 3, 14, 29);
      FitbitHandler.debugResolveDeferredQuestionOverride =
          (_, request, _) async {
            expect(request.windowEnd, DateTime(2026, 8, 3, 14, 30));
            return [FitbitStepData(42, dataTime)];
          };
      var savedProgressCount = 0;
      Cache.debugSaveProgressOverride = (progress) async {
        savedProgressCount++;
        return progress;
      };
      Cache.debugSaveSubjectOverride = (subject) async => subject;

      final synchronization = await Cache.synchronize(remoteSubject);

      expect(synchronization.succeeded, isTrue);
      expect(savedProgressCount, 1);
      expect(synchronization.subject.progress, hasLength(1));
      final progress = synchronization.subject.progress.single;
      expect(progress.completedAt, completedAt);
      expect(progress.interventionId, _interventionId);
      expect(progress.result.periodId, _periodId);
      final state = (progress.result as Result<QuestionnaireState>).result;
      expect(state.answers[fixture.question.id]!.response, hasLength(1));
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
    },
  );

  test(
    'reconnect resolves a request when its subject cache write failed',
    () async {
      final fixture = _buildFitbitStudy();
      final remoteSubject = StudySubject.fromJson(fixture.subject.toFullJson())
        ..progress = [];
      FlutterSecureStoragePlatform.instance = _FailingSubjectCacheWritePlatform(
        storageData,
      );

      await expectLater(
        () => persistDeferredFitbitQuestionnaireResult(
          subject: fixture.subject,
          task: fixture.task,
          interventionId: _interventionId,
          periodId: _periodId,
          questionnaireState: _deferredAnswer(
            fixture.question,
            DateTime(2026, 8, 3, 14, 30),
          ),
        ),
        throwsException,
      );
      expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
      expect(await SecureStorage.containsKey(cacheSubjectKey), isFalse);

      FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
        storageData,
      );
      var resolveCalls = 0;
      FitbitHandler.debugResolveDeferredQuestionOverride = (_, _, _) async {
        resolveCalls++;
        return [FitbitStepData(42, DateTime(2026, 8, 3, 14, 29))];
      };
      var saveProgressCalls = 0;
      Cache.debugSaveProgressOverride = (progress) async {
        saveProgressCalls++;
        return progress;
      };
      Cache.debugSaveSubjectOverride = (subject) async => subject;

      final synchronization = await Cache.synchronize(remoteSubject);

      expect(synchronization.succeeded, isTrue);
      expect(resolveCalls, 1);
      expect(saveProgressCalls, 1);
      expect(remoteSubject.progress, hasLength(1));
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
      expect((await Cache.loadSubject()).progress, hasLength(1));
    },
  );

  test('Fitbit acquisition failure retains the request for retry', () async {
    final fixture = _buildFitbitStudy();
    await Cache.storeSubject(fixture.subject);
    await persistDeferredFitbitQuestionnaireResult(
      subject: fixture.subject,
      task: fixture.task,
      interventionId: _interventionId,
      periodId: _periodId,
      questionnaireState: _deferredAnswer(
        fixture.question,
        DateTime(2026, 8, 3, 14, 30),
      ),
    );
    FitbitHandler.debugResolveDeferredQuestionOverride = (_, _, _) =>
        Future.error(Exception('Fitbit unavailable'));
    var saveProgressCalls = 0;
    Cache.debugSaveProgressOverride = (progress) async {
      saveProgressCalls++;
      return progress;
    };
    Cache.debugSaveSubjectOverride = (subject) async => subject;

    final remoteSubject = StudySubject.fromJson(fixture.subject.toFullJson())
      ..progress = [];
    final synchronization = await Cache.synchronize(remoteSubject);

    expect(synchronization.succeeded, isFalse);
    expect(saveProgressCalls, 0);
    expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
  });

  test(
    'destructive action stays blocked while Fitbit work is pending',
    () async {
      final fixture = _buildFitbitStudy();
      await Cache.storeSubject(fixture.subject);
      await persistDeferredFitbitQuestionnaireResult(
        subject: fixture.subject,
        task: fixture.task,
        interventionId: _interventionId,
        periodId: _periodId,
        questionnaireState: _deferredAnswer(
          fixture.question,
          DateTime(2026, 8, 3, 14, 30),
        ),
      );
      FitbitHandler.debugResolveDeferredQuestionOverride = (_, _, _) =>
          Future.error(Exception('Fitbit unavailable'));
      final remoteSubject = StudySubject.fromJson(fixture.subject.toFullJson())
        ..progress = [];
      final appState = AppState();
      appState.debugHasParticipantSessionForSync = () => true;
      appState.debugRestoreParticipantSessionForSync = () async => false;
      appState.debugFetchRemoteSubjectForSync = (_) async => remoteSubject;
      appState.updateActiveSubject(fixture.subject);
      var remoteDeleted = false;

      final deleted = await deleteStudySubjectAndClearLocalData(
        subject: fixture.subject,
        synchronizeActiveSubject:
            appState.synchronizeActiveSubjectBeforeDestructiveAction,
        deleteRemoteSubject: () async => remoteDeleted = true,
        onRemoteDeleted: appState.clearActiveStudyState,
        stopActiveSynchronization:
            appState.stopAndAwaitActiveSubjectSynchronization,
        resumeActiveSynchronization:
            appState.resumeActiveSubjectSynchronization,
      );

      expect(deleted, isFalse);
      expect(remoteDeleted, isFalse);
      expect(appState.activeSubject, isNotNull);
      expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
      appState.dispose();
    },
  );

  test(
    'ambiguous retry removes the request without duplicate progress',
    () async {
      final fixture = _buildFitbitStudy();
      final completedAt = DateTime.utc(2026, 8, 3, 14, 31);
      await Cache.storeSubject(fixture.subject);
      await persistDeferredFitbitQuestionnaireResult(
        subject: fixture.subject,
        task: fixture.task,
        interventionId: _interventionId,
        periodId: _periodId,
        questionnaireState: _deferredAnswer(
          fixture.question,
          DateTime(2026, 8, 3, 14, 30),
        ),
        completedAt: completedAt,
      );
      final remoteSubject = StudySubject.fromJson(fixture.subject.toFullJson())
        ..progress = [];
      var resolveCalls = 0;
      var saveProgressCalls = 0;
      FitbitHandler.debugResolveDeferredQuestionOverride = (_, _, _) async {
        resolveCalls++;
        return [FitbitStepData(42, DateTime(2026, 8, 3, 14, 29))];
      };
      Cache.debugSaveProgressOverride = (progress) async {
        saveProgressCalls++;
        return progress;
      };
      Cache.debugSaveSubjectOverride = (_) =>
          Future.error(Exception('response lost after progress save'));

      final first = await Cache.synchronize(remoteSubject);
      expect(first.succeeded, isFalse);
      expect(remoteSubject.progress, hasLength(1));
      expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));

      Cache.debugSaveSubjectOverride = (subject) async => subject;
      final second = await Cache.synchronize(remoteSubject);

      expect(second.succeeded, isTrue);
      expect(resolveCalls, 1);
      expect(saveProgressCalls, 1);
      expect(remoteSubject.progress, hasLength(1));
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
    },
  );

  test(
    'two daily completions with the same period remain independently pending',
    () async {
      final fixture = _buildFitbitStudy();
      await Cache.storeSubject(fixture.subject);
      for (final day in [3, 4]) {
        await persistDeferredFitbitQuestionnaireResult(
          subject: fixture.subject,
          task: fixture.task,
          interventionId: _interventionId,
          periodId: _periodId,
          questionnaireState: _deferredAnswer(
            fixture.question,
            DateTime(2026, 8, day, 14, 30),
          ),
          completedAt: DateTime.utc(2026, 8, day, 14, 31),
        );
      }

      final pending = await Cache.loadDeferredFitbitRequests();
      expect(pending, hasLength(2));
      expect(pending.map((request) => request.id).toSet(), hasLength(2));

      final remoteSubject = StudySubject.fromJson(fixture.subject.toFullJson())
        ..progress = [];
      FitbitHandler.debugResolveDeferredQuestionOverride =
          (_, request, _) async => [
            FitbitStepData(
              42,
              request.windowEnd.subtract(const Duration(minutes: 1)),
            ),
          ];
      Cache.debugSaveProgressOverride = (progress) async => progress;
      Cache.debugSaveSubjectOverride = (subject) async => subject;

      final synchronization = await Cache.synchronize(remoteSubject);

      expect(synchronization.succeeded, isTrue);
      expect(synchronization.subject.progress, hasLength(2));
      expect(await Cache.loadDeferredFitbitRequests(), isEmpty);
    },
  );

  test('later offline period starts after the earlier placeholder', () async {
    final fixture = _buildFitbitStudy();
    final morning = DateTime(2026, 8, 3, 9);
    final evening = DateTime(2026, 8, 3, 18);
    await persistDeferredFitbitQuestionnaireResult(
      subject: fixture.subject,
      task: fixture.task,
      interventionId: _interventionId,
      periodId: 'morning',
      questionnaireState: _deferredAnswer(fixture.question, morning),
      completedAt: morning.toUtc(),
    );
    await persistDeferredFitbitQuestionnaireResult(
      subject: fixture.subject,
      task: fixture.task,
      interventionId: _interventionId,
      periodId: 'evening',
      questionnaireState: _deferredAnswer(fixture.question, evening),
      completedAt: evening.toUtc(),
    );

    final requests = await Cache.loadDeferredFitbitRequests();
    final eveningRequest = requests.singleWhere(
      (request) => request.periodId == 'evening',
    );
    expect(
      eveningRequest.questions.single.windowStarts.values,
      everyElement(morning),
    );
  });

  test(
    'pending blobs upload before deferred Fitbit progress is resolved',
    () async {
      final fixture = _buildFitbitStudy();
      final state = _deferredAnswer(
        fixture.question,
        DateTime(2026, 8, 3, 14, 30),
      );
      state.answers['media-question'] = Answer<String>(
        'media-question',
        DateTime(2026, 8, 3, 14),
      )..response = 'pending-blob-id';
      await Cache.storeSubject(fixture.subject);
      await persistDeferredFitbitQuestionnaireResult(
        subject: fixture.subject,
        task: fixture.task,
        interventionId: _interventionId,
        periodId: _periodId,
        questionnaireState: state,
      );
      var resolveCalls = 0;
      var progressSaveCalls = 0;
      Cache.debugUploadBlobFilesOverride = (_, _) =>
          Future<void>.error(Exception('blob upload failed'));
      FitbitHandler.debugResolveDeferredQuestionOverride = (_, _, _) async {
        resolveCalls++;
        return [];
      };
      Cache.debugSaveProgressOverride = (progress) async {
        progressSaveCalls++;
        return progress;
      };
      final remoteSubject = StudySubject.fromJson(fixture.subject.toFullJson())
        ..progress = [];

      final synchronization = await Cache.synchronize(remoteSubject);

      expect(synchronization.succeeded, isFalse);
      expect(resolveCalls, 0);
      expect(progressSaveCalls, 0);
      expect(remoteSubject.progress, isEmpty);
      expect(await Cache.loadDeferredFitbitRequests(), hasLength(1));
    },
  );

  testWidgets('degraded Fitbit completion stays local without invoking sync', (
    tester,
  ) async {
    final fixture = _buildFitbitStudy();
    var syncCalls = 0;
    FitbitHandler.debugSyncFitbitDataOverride = (_, _, _, _) async {
      syncCalls++;
      return [];
    };

    appConnectionStatusController.setStatus(
      AppConnectionStatus.backendUnavailable,
    );
    Answer? answer;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: FitbitQuestionWidget(
            question: fixture.question,
            taskId: fixture.task.id,
            onDone: (completedAnswer) => answer = completedAnswer,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(syncCalls, 0);
    expect(answer, isNotNull);
    expect(answer!.response, isEmpty);
  });

  testWidgets(
    'kickoff keeps Fitbit studies gated after authorization failure',
    (tester) async {
      final fixture = _buildFitbitStudy();
      final appState = AppState()..updateActiveSubject(fixture.subject);
      addTearDown(appState.dispose);
      var authorizationCalls = 0;
      FitbitHandler.debugAuthorizeForOfflineParticipationOverride =
          (_, _) async {
            authorizationCalls++;
            return false;
          };

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: Locale('en'),
            home: KickoffScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(authorizationCalls, 1);
      expect(find.byType(OutlinedButton), findsOneWidget);
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(authorizationCalls, 2);
      expect(find.byType(OutlinedButton), findsOneWidget);
    },
  );

  testWidgets('healthy Fitbit completion keeps the online sync path', (
    tester,
  ) async {
    final fixture = _buildFitbitStudy();
    final appState = AppState()..updateActiveSubject(fixture.subject);
    addTearDown(appState.dispose);
    var syncCalls = 0;
    final syncedData = [FitbitStepData(42, DateTime(2026, 8, 3, 14, 29))];
    FitbitHandler.debugSyncFitbitDataOverride = (_, _, _, _) async {
      syncCalls++;
      return syncedData;
    };
    appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
    Answer? answer;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: Scaffold(
            body: FitbitQuestionWidget(
              question: fixture.question,
              taskId: fixture.task.id,
              onDone: (completedAnswer) => answer = completedAnswer,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(syncCalls, 1);
    expect(answer, isNotNull);
    expect(answer!.response, hasLength(1));
  });

  test('calendar-day iteration includes every date across DST boundaries', () {
    final days = FitbitHandler.daysInWindowForTesting(
      DateTime(2026, 3, 28),
      DateTime(2026, 3, 30),
    );

    expect(days.map((day) => day.day), [28, 29, 30]);
    expect(days.every((day) => day.hour == 0), isTrue);
  });
}
