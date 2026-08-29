import 'dart:convert';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:flutter/foundation.dart';
import 'package:studyu_app/constants.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class FitbitHandler {
  static const String _fitbitCredentialsPrefix = 'fitbit_credentials_';

  @visibleForTesting
  static Future<List<FitbitData>> Function(
    Study study,
    DeferredFitbitQuestionRequest question,
    StudySubject subject,
  )?
  debugResolveDeferredQuestionOverride;

  @visibleForTesting
  static Future<List<FitbitData>> Function(
    Study study,
    FitbitQuestion question,
    String taskId,
    StudySubject subject,
  )?
  debugSyncFitbitDataOverride;

  @visibleForTesting
  static Future<bool> Function(Study study, List<FitbitQuestionType> types)?
  debugAuthorizeForOfflineParticipationOverride;

  @visibleForTesting
  static Future<fitbitter.FitbitCredentials?> Function(
    Study study,
    List<FitbitQuestionType> types,
  )?
  debugObtainCredentialsOverride;

  static Map<String, dynamic> _credentialsToJson(
    fitbitter.FitbitCredentials credentials,
  ) {
    return {
      'userID': credentials.userID,
      'fitbitAccessToken': credentials.fitbitAccessToken,
      'fitbitRefreshToken': credentials.fitbitRefreshToken,
    };
  }

  static fitbitter.FitbitCredentials _credentialsFromJson(
    Map<String, dynamic> jsonData,
  ) {
    return fitbitter.FitbitCredentials(
      userID: jsonData['userID'] as String,
      fitbitAccessToken: jsonData['fitbitAccessToken'] as String,
      fitbitRefreshToken: jsonData['fitbitRefreshToken'] as String,
    );
  }

  static Future<void> deleteFitbitCredentials(String studyKey) async {
    if (await SecureStorage.containsKey('$_fitbitCredentialsPrefix$studyKey')) {
      await SecureStorage.delete('$_fitbitCredentialsPrefix$studyKey');
    }
  }

  static Future<void> _storeCredentials(
    fitbitter.FitbitCredentials? credentials,
    String studyKey, {
    bool requirePersistence = false,
  }) async {
    final key = '$_fitbitCredentialsPrefix$studyKey';

    try {
      if (credentials == null) {
        await SecureStorage.delete(key);
      } else {
        await SecureStorage.write(
          key,
          jsonEncode(_credentialsToJson(credentials)),
        );
      }
    } catch (e) {
      StudyULogger.error('Failed to store Fitbit credentials: $e');
      if (requirePersistence) rethrow;
    }
  }

  static Future<fitbitter.FitbitCredentials?> _loadCredentials(
    String studyKey,
  ) async {
    final key = '$_fitbitCredentialsPrefix$studyKey';

    try {
      if (await SecureStorage.containsKey(key)) {
        final storedString = await SecureStorage.read(key);
        if (storedString != null) {
          final jsonData = jsonDecode(storedString) as Map<String, dynamic>;
          return _credentialsFromJson(jsonData);
        }
      }
    } catch (e) {
      StudyULogger.error('Failed to load Fitbit credentials: $e');
    }

    return null;
  }

  static Future<fitbitter.FitbitCredentials?> _validateToken(
    Study study,
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials currentCredentials, {
    bool requirePersistentCredentials = false,
  }) async {
    try {
      final valid = await fitbitter.FitbitConnector.isTokenValid(
        fitbitCredentials: currentCredentials,
      );

      if (valid) return currentCredentials;

      final newCredentials = await fitbitter.FitbitConnector.refreshToken(
        fitbitCredentials: currentCredentials,
        clientID: studyCredentials.clientId,
        clientSecret: studyCredentials.clientSecret,
      );

      await _storeCredentials(
        newCredentials,
        study.id,
        requirePersistence: requirePersistentCredentials,
      );

      return newCredentials;
    } catch (e) {
      StudyULogger.error('Failed to refresh Fitbit token: $e');
      return null;
    }
  }

  static Future<fitbitter.FitbitCredentials?> _loadValidCredentials(
    Study study, {
    bool requirePersistentCredentials = false,
  }) async {
    final fitbitCreds = study.fitbitCredentials?.fitbitCredentials;
    if (fitbitCreds == null) return null;
    final storedCredentials = await _loadCredentials(study.id);
    if (storedCredentials == null) return null;
    return _validateToken(
      study,
      fitbitCreds,
      storedCredentials,
      requirePersistentCredentials: requirePersistentCredentials,
    );
  }

  static Future<fitbitter.FitbitCredentials?> _obtainCredentials(
    Study study,
    List<FitbitQuestionType> types, {
    bool requirePersistentCredentials = false,
  }) async {
    final fitbitCreds = study.fitbitCredentials?.fitbitCredentials;

    if (fitbitCreds == null) {
      StudyULogger.error('Study is missing Fitbit credentials.');
      return null;
    }

    final validCredentials = await _loadValidCredentials(
      study,
      requirePersistentCredentials: requirePersistentCredentials,
    );
    if (validCredentials != null) return validCredentials;
    try {
      final obtainOverride = debugObtainCredentialsOverride;
      if (obtainOverride != null) {
        final credentials = await obtainOverride(study, types);
        if (credentials == null) return null;
        await _storeCredentials(
          credentials,
          study.id,
          requirePersistence: requirePersistentCredentials,
        );
        return credentials;
      }
      final scopes = <fitbitter.FitbitAuthScope>[];

      for (final type in types) {
        switch (type) {
          case FitbitQuestionType.steps:
            scopes.add(fitbitter.FitbitAuthScope.ACTIVITY);
          case FitbitQuestionType.heartrate:
            scopes.add(fitbitter.FitbitAuthScope.HEART_RATE);
          case FitbitQuestionType.sleep:
            scopes.add(fitbitter.FitbitAuthScope.SLEEP);
        }
      }

      final newCredentials = await fitbitter.FitbitConnector.authorize(
        clientID: fitbitCreds.clientId,
        clientSecret: fitbitCreds.clientSecret,
        redirectUri: fitbitRedirectUrl,
        callbackUrlScheme: fitbitCallbackScheme,
        scopeList: scopes,
      );

      if (newCredentials != null) {
        await _storeCredentials(
          newCredentials,
          study.id,
          requirePersistence: requirePersistentCredentials,
        );
        return newCredentials;
      }
    } catch (e) {
      StudyULogger.error('Failed to authorize Fitbit credentials: $e');
    }

    return null;
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static Iterable<DateTime> _daysInWindow(DateTime start, DateTime end) sync* {
    var day = _startOfDay(start);
    final lastDay = _startOfDay(end);
    while (!day.isAfter(lastDay)) {
      yield day;
      day = DateTime(day.year, day.month, day.day + 1);
    }
  }

  static Future<List<FitbitHeartData>> _fetchHeartData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime start,
    DateTime end,
  ) async {
    final manager = fitbitter.FitbitHeartRateIntradayDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );
    final data = <FitbitHeartData>[];
    for (final day in _daysInWindow(start, end)) {
      final url = fitbitter.FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
        date: day,
        fitbitCredentials: credentials,
        intradayDetailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
      );
      final items =
          await manager.fetch(url)
              as List<fitbitter.FitbitHeartRateIntradayData>;
      data.addAll(
        items.map(
          (item) => FitbitHeartData(item.value!, item.dateOfMonitoring!),
        ),
      );
    }
    return data
        .where(
          (data) => data.dateTime.isAfter(start) && !data.dateTime.isAfter(end),
        )
        .toList();
  }

  static Future<List<FitbitSleepData>> _fetchSleepData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime start,
    DateTime end,
  ) async {
    final manager = fitbitter.FitbitSleepDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final url = fitbitter.FitbitSleepAPIURL.dateRange(
      startDate: _startOfDay(start),
      endDate: end,
      fitbitCredentials: credentials,
    );

    final items = await manager.fetch(url) as List<fitbitter.FitbitSleepData>;

    //TODO: handle data that spans multiple days
    return items
        .map(
          (item) => FitbitSleepData(
            item.level!,
            item.entryDateTime!,
            item.dateOfSleep!,
          ),
        )
        .where(
          (data) =>
              data.entryDateTime.isAfter(start) &&
              !data.entryDateTime.isAfter(end),
        )
        .toList();
  }

  static Future<List<FitbitStepData>> _fetchStepData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime start,
    DateTime end,
  ) async {
    final manager = fitbitter.FitbitActivityTimeseriesIntradayDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final items = <fitbitter.FitbitActivityTimeseriesData>[];
    for (final day in _daysInWindow(start, end)) {
      final url =
          fitbitter.FitbitActivityTimeseriesIntradayAPIURL.dayWithResource(
            date: day,
            fitbitCredentials: credentials,
            resource: fitbitter.Resource.steps,
            detailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
          );
      items.addAll(
        await manager.fetch(url)
            as List<fitbitter.FitbitActivityTimeseriesData>,
      );
    }
    return items
        .map((item) => FitbitStepData(item.value!, item.dateOfMonitoring!))
        .where(
          (data) => data.dateTime.isAfter(start) && !data.dateTime.isAfter(end),
        )
        .toList();
  }

  static Future<List<FitbitData>> _getFitbitDataForWindow(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    Map<FitbitQuestionType, DateTime> starts,
    DateTime end,
  ) async {
    final allData = <FitbitData>[];
    for (final MapEntry(key: type, value: start) in starts.entries) {
      switch (type) {
        case FitbitQuestionType.steps:
          allData.addAll(
            await _fetchStepData(studyCredentials, credentials, start, end),
          );
        case FitbitQuestionType.heartrate:
          allData.addAll(
            await _fetchHeartData(studyCredentials, credentials, start, end),
          );
        case FitbitQuestionType.sleep:
          allData.addAll(
            await _fetchSleepData(studyCredentials, credentials, start, end),
          );
      }
    }
    return allData;
  }

  static Map<String, dynamic> parseLine(String line) {
    var cleanedLine = line.trim();
    if (cleanedLine.startsWith('"') && cleanedLine.endsWith('"')) {
      cleanedLine = cleanedLine.substring(1, cleanedLine.length - 1);
    }
    if (cleanedLine.startsWith('{') && cleanedLine.endsWith('}')) {
      cleanedLine = cleanedLine.substring(1, cleanedLine.length - 1).trim();
    }
    final parts = cleanedLine.split(',');
    final mapped = <String, dynamic>{};
    for (var part in parts) {
      part = part.trim();
      final idx = part.indexOf(':');
      if (idx == -1) continue;
      final key = part.substring(0, idx).trim();
      final val = part.substring(idx + 1).trim();
      if (key == 'value') {
        mapped[key] = double.tryParse(val) ?? val;
      } else {
        mapped[key] = val;
      }
    }
    return mapped;
  }

  static Future<DateTime?> _findLatestDataEntry(
    StudySubject subject,
    String taskId,
    String questionId,
    FitbitQuestionType type,
  ) async {
    if (subject.progress.isEmpty) return null;

    DateTime? latestDate;
    final typeLower = type.toReadable().toLowerCase();

    for (final entry in subject.progress) {
      if (entry.taskId != taskId || entry.resultType != 'QuestionnaireState') {
        continue;
      }

      final questionnaireState =
          (entry.result as Result<QuestionnaireState>).result;

      for (final answer in questionnaireState.answers.values) {
        if (answer.question != questionId || answer.response is! List) continue;

        final responses = answer.response as List<dynamic>;
        if (responses.isEmpty) {
          if (latestDate == null || answer.timestamp.isAfter(latestDate)) {
            latestDate = answer.timestamp;
          }
          continue;
        }

        for (final raw in responses) {
          final data = switch (raw) {
            FitbitData() => raw,
            Map<String, dynamic>() => FitbitData.fromJson(raw),
            _ => FitbitData.fromJson(parseLine(raw.toString())),
          };

          if (data.type.toLowerCase() != typeLower) continue;

          final DateTime date = switch (type) {
            FitbitQuestionType.sleep => (data as FitbitSleepData).entryDateTime,
            _ => data.dateTime,
          };

          if (latestDate == null || date.isAfter(latestDate)) {
            latestDate = date;
          }
        }
      }
    }

    return latestDate;
  }

  @visibleForTesting
  static List<DateTime> daysInWindowForTesting(DateTime start, DateTime end) =>
      _daysInWindow(start, end).toList();

  static List<FitbitQuestionType> requiredTypesForStudy(Study study) {
    final tasks = <Task>[
      ...study.observations,
      ...study.interventions.expand((intervention) => intervention.tasks),
    ];
    return tasks
        .whereType<QuestionnaireTask>()
        .expand((task) => task.questions.questions.whereType<FitbitQuestion>())
        .expand((question) => question.types)
        .toSet()
        .toList();
  }

  static Future<bool> authorizeForOfflineParticipation(Study study) async {
    final types = requiredTypesForStudy(study);
    if (types.isEmpty) return true;
    final override = debugAuthorizeForOfflineParticipationOverride;
    if (override != null) return override(study, types);
    return await _obtainCredentials(
          study,
          types,
          requirePersistentCredentials: true,
        ) !=
        null;
  }

  static Future<DeferredFitbitRequest> createDeferredRequest({
    required StudySubject subject,
    required QuestionnaireTask task,
    required String interventionId,
    required String periodId,
    required QuestionnaireState questionnaireState,
    DateTime? completedAt,
  }) async {
    final completionTime = (completedAt ?? DateTime.now()).toUtc();
    final fitbitQuestions = task.questions.questions
        .whereType<FitbitQuestion>();
    final requests = <DeferredFitbitQuestionRequest>[];
    for (final question in fitbitQuestions) {
      final answer = questionnaireState.answers[question.id];
      if (answer == null ||
          answer.response is! List ||
          (answer.response as List).isNotEmpty) {
        continue;
      }
      final windowEnd = answer.timestamp;
      final starts = <FitbitQuestionType, DateTime>{};
      for (final type in question.types) {
        starts[type] =
            await _findLatestDataEntry(subject, task.id, question.id, type) ??
            _startOfDay(windowEnd);
      }
      requests.add(
        DeferredFitbitQuestionRequest(
          questionId: question.id,
          answerTimestamp: answer.timestamp,
          windowEnd: windowEnd,
          windowStarts: starts,
        ),
      );
    }
    if (requests.isEmpty) {
      throw ArgumentError('Questionnaire has no deferred Fitbit answers');
    }
    final deferredQuestionIds = requests
        .map((request) => request.questionId)
        .toSet();
    return DeferredFitbitRequest(
      subjectId: subject.id,
      studyId: subject.studyId,
      taskId: task.id,
      interventionId: interventionId,
      periodId: periodId,
      completedAt: completionTime,
      questionnaireAnswers: questionnaireState
          .toJson()
          .where((answer) => !deferredQuestionIds.contains(answer['question']))
          .toList(),
      questions: requests,
    );
  }

  static Future<QuestionnaireState> resolveDeferredRequest(
    StudySubject subject,
    DeferredFitbitRequest request,
  ) async {
    if (subject.id != request.subjectId || subject.studyId != request.studyId) {
      throw ArgumentError('Deferred Fitbit request does not match subject');
    }
    final questionnaireState = QuestionnaireState.fromJson(
      request.questionnaireAnswers,
    );
    final override = debugResolveDeferredQuestionOverride;
    fitbitter.FitbitCredentials? credentials;
    if (override == null) {
      credentials = await _loadValidCredentials(subject.study);
      if (credentials == null) {
        throw Exception('Stored Fitbit credentials are unavailable');
      }
    }
    for (final question in request.questions) {
      final data = override != null
          ? await override(subject.study, question, subject)
          : await _getFitbitDataForWindow(
              subject.study.fitbitCredentials!.fitbitCredentials,
              credentials!,
              question.windowStarts,
              question.windowEnd,
            );
      questionnaireState.answers[question.questionId] =
          Answer<List<FitbitData>>(
            question.questionId,
            question.answerTimestamp,
          )..response = data;
    }
    return questionnaireState;
  }

  static Future<List<FitbitData>> syncFitbitData(
    Study study,
    FitbitQuestion question,
    String taskId,
    StudySubject subject,
  ) async {
    final override = debugSyncFitbitDataOverride;
    if (override != null) return override(study, question, taskId, subject);
    final credentials = await _obtainCredentials(study, question.types);

    if (credentials == null) {
      throw Exception(
        'Failed to obtain Fitbit credentials. Please try syncing again',
      );
    }
    final end = DateTime.now();
    final starts = <FitbitQuestionType, DateTime>{};
    for (final type in question.types) {
      starts[type] =
          await _findLatestDataEntry(subject, taskId, question.id, type) ??
          _startOfDay(end);
    }
    return _getFitbitDataForWindow(
      study.fitbitCredentials!.fitbitCredentials,
      credentials,
      starts,
      end,
    );
  }
}
