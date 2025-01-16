import 'dart:convert';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:studyu_app/constants.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class FitbitHandler {
  static const String _fitbitCredentialsPrefix = 'fitbit_credentials_';

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
    Map<String, dynamic> json,
  ) {
    return fitbitter.FitbitCredentials(
      userID: json['userID'] as String,
      fitbitAccessToken: json['fitbitAccessToken'] as String,
      fitbitRefreshToken: json['fitbitRefreshToken'] as String,
    );
  }

  static Future<void> _storeCredentials(
    fitbitter.FitbitCredentials? credentials,
    String studyKey,
  ) async {
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
    }
  }

  static Future<fitbitter.FitbitCredentials?> _loadCredentials(
    String studyKey,
  ) async {
    final key = '$_fitbitCredentialsPrefix$studyKey';
    try {
      if (await SecureStorage.containsKey(key)) {
        final credentialsStr = await SecureStorage.read(key);
        if (credentialsStr != null) {
          final credentialsJson =
              jsonDecode(credentialsStr) as Map<String, dynamic>;
          return _credentialsFromJson(credentialsJson);
        }
      }
    } catch (e) {
      StudyULogger.error('Failed to load Fitbit credentials: $e');
    }
    return null;
  }

  static Future<fitbitter.FitbitCredentials?> _validateToken(
    Study study,
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
  ) async {
    try {
      final isValid = await fitbitter.FitbitConnector.isTokenValid(
        fitbitCredentials: credentials,
      );

      if (isValid) return credentials;

      final newCredentials = await fitbitter.FitbitConnector.refreshToken(
        fitbitCredentials: credentials,
        clientID: studyCredentials.clientId,
        clientSecret: studyCredentials.clientSecret,
      );

      await _storeCredentials(newCredentials, study.id);
      return newCredentials;
    } catch (e) {
      StudyULogger.error('Failed to refresh Fitbit token: $e');
      return null;
    }
  }

  static Future<fitbitter.FitbitCredentials?> _obtainCredentials(
    Study study,
  ) async {
    final fitbitCredentials = study.fitbitCredentials;

    if (fitbitCredentials == null) {
      StudyULogger.error('Study is missing Fitbit credentials.');
      return null;
    }

    final storedCredentials = await _loadCredentials(study.id);
    if (storedCredentials != null) {
      final validatedCredentials =
          await _validateToken(study, fitbitCredentials, storedCredentials);
      if (validatedCredentials != null) {
        return validatedCredentials;
      }
    }

    try {
      final newCredentials = await fitbitter.FitbitConnector.authorize(
        clientID: fitbitCredentials.clientId,
        clientSecret: fitbitCredentials.clientSecret,
        redirectUri: fitbitRedirectUrl,
        callbackUrlScheme: fitbitCallbackScheme,
      );

      if (newCredentials != null) {
        await _storeCredentials(newCredentials, study.id);
        return newCredentials;
      }
    } catch (e) {
      StudyULogger.error('Failed to authorize Fitbit credentials: $e');
    }

    return null;
  }

  static Future<List<FitbitData>> _getFitbitData(
    List<FitbitQuestionType> types,
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    String taskId,
    StudySubject subject,
    FitbitQuestion question,
  ) async {
    final latestDataEntry =
        await _findLatestDataEntry(subject, taskId, question.id);

    final List<FitbitData> fitbitData = [];
    for (final type in types) {
      switch (type) {
        case FitbitQuestionType.steps:
          final steps = await _fetchStepData(
            studyCredentials,
            credentials,
            latestDataEntry ?? DateTime.now(),
          );

          fitbitData.addAll(steps);
        case FitbitQuestionType.heartrate:
          final heartrate = await _fetchHeartData(
            studyCredentials,
            credentials,
            latestDataEntry ?? DateTime.now(),
          );

          fitbitData.addAll(heartrate);
        case FitbitQuestionType.sleep:
          final sleep = await _fetchSleepData(
            studyCredentials,
            credentials,
            latestDataEntry ?? DateTime.now(),
          );

          fitbitData.addAll(sleep);
      }
    }
    return fitbitData;
  }

  static Future<DateTime?> _findLatestDataEntry(
    StudySubject subject,
    String taskId,
    String questionId,
  ) async {
    if (subject.progress.isEmpty) {
      return null;
    }

    final SubjectProgress latestDataEntry = subject.progress.lastWhere(
      (entry) =>
          entry.taskId == taskId && entry.resultType == 'QuestionnaireState',
    );

    final questionnaireState =
        latestDataEntry.result as Result<QuestionnaireState>;
    final latestData = questionnaireState.result.answers.values.where(
      (answer) => answer.question == questionId,
    );

    if (latestData.isNotEmpty) {
      /// TODO: Right now, it returns the latest data entry date that is written to database. However, because of fitbit
      /// synchronization, it should return the latest fitbit data entry date. There are some problems in parsing the progress data from string
      return latestData.last.timestamp;
      /*List<String> responseRaw = latestData.last.response as List<String>;

      final fitbitData = responseRaw.map((e) {
        final json = jsonDecode(e) as Map<String, dynamic>;

        return FitbitData.fromJson(json);
      }).toList();

      print(fitbitData);

      return fitbitData.last.dateTime;*/
    }

    return null;
  }

  static Future<List<FitbitHeartData>> _fetchHeartData(
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime date,
  ) async {
    final fitbitter.FitbitHeartRateIntradayDataManager
        fitbitHeartRateIntradayDataManager =
        fitbitter.FitbitHeartRateIntradayDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final fitbitter.FitbitHeartRateIntradayAPIURL
        fitbitHeartRateIntradayAPIURL =
        fitbitter.FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
      date: DateTime.now(),
      fitbitCredentials: credentials,
      intradayDetailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
    );

    final List<fitbitter.FitbitHeartRateIntradayData>
        fitbitHeartRateIntradayData = await fitbitHeartRateIntradayDataManager
                .fetch(fitbitHeartRateIntradayAPIURL)
            as List<fitbitter.FitbitHeartRateIntradayData>;

    return fitbitHeartRateIntradayData
        .map((data) => FitbitHeartData(data.value!, data.dateOfMonitoring!))
        .toList();
  }

  static Future<List<FitbitSleepData>> _fetchSleepData(
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime date,
  ) async {
    final fitbitter.FitbitSleepDataManager fitbitSleepDataManager =
        fitbitter.FitbitSleepDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final fitbitter.FitbitSleepAPIURL fitbitSleepAPIURL =
        fitbitter.FitbitSleepAPIURL.listAndAfterDate(
      afterDate: date,
      fitbitCredentials: credentials,
    );

    final List<fitbitter.FitbitSleepData> fitbitSleepData =
        await fitbitSleepDataManager.fetch(fitbitSleepAPIURL)
            as List<fitbitter.FitbitSleepData>;

    return fitbitSleepData
        .map(
          (data) => FitbitSleepData(
            data.level!,
            data.entryDateTime!,
            data.dateOfSleep!,
          ),
        )
        .toList();
  }

  static Future<List<FitbitStepData>> _fetchStepData(
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime date,
  ) async {
    final fitbitter.FitbitActivityTimeseriesDataManager
        fitbitActivityTimeseriesDataManager =
        fitbitter.FitbitActivityTimeseriesDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final fitbitter.FitbitActivityTimeseriesAPIURL
        fitbitActivityTimeseriesAPIURL =
        fitbitter.FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
      startDate: date,
      endDate: DateTime.now(),
      fitbitCredentials: credentials,
      resource: fitbitter.Resource.steps,
    );

    final List<fitbitter.FitbitActivityTimeseriesData> fitbitStepData =
        await fitbitActivityTimeseriesDataManager
                .fetch(fitbitActivityTimeseriesAPIURL)
            as List<fitbitter.FitbitActivityTimeseriesData>;

    return fitbitStepData
        .map(
          (data) => FitbitStepData(
            data.value!,
            data.dateOfMonitoring!,
          ),
        )
        .toList();
  }

  static Future<List<FitbitData>> syncFitbitData(
    Study study,
    FitbitQuestion question,
    String taskId,
    StudySubject subject,
  ) async {
    final fitbitCredentials = await _obtainCredentials(study);

    if (fitbitCredentials == null) {
      throw Exception(
          'Failed to obtain Fitbit credentials. Please try syncing again');
    }

    final fitbitData = await _getFitbitData(
      question.types,
      study.fitbitCredentials!,
      fitbitCredentials,
      taskId,
      subject,
      question,
    );

    return fitbitData;
  }
}
