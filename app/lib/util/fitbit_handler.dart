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
    Map<String, dynamic> jsonData,
  ) {
    return fitbitter.FitbitCredentials(
      userID: jsonData['userID'] as String,
      fitbitAccessToken: jsonData['fitbitAccessToken'] as String,
      fitbitRefreshToken: jsonData['fitbitRefreshToken'] as String,
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
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials currentCredentials,
  ) async {
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

      await _storeCredentials(newCredentials, study.id);

      return newCredentials;
    } catch (e) {
      StudyULogger.error('Failed to refresh Fitbit token: $e');
      return null;
    }
  }

  static Future<fitbitter.FitbitCredentials?> _obtainCredentials(
      Study study,) async {
    final fitbitCreds = study.fitbitCredentials;

    if (fitbitCreds == null) {
      StudyULogger.error('Study is missing Fitbit credentials.');
      return null;
    }

    final storedCredentials = await _loadCredentials(study.id);

    if (storedCredentials != null) {
      final validCredentials = await _validateToken(
        study,
        fitbitCreds,
        storedCredentials,
      );

      if (validCredentials != null) return validCredentials;
    }
    try {
      final newCredentials = await fitbitter.FitbitConnector.authorize(
        clientID: fitbitCreds.clientId,
        clientSecret: fitbitCreds.clientSecret,
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

  static DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<List<FitbitHeartData>> _fetchHeartData(
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest,
  ) async {
    final manager = fitbitter.FitbitHeartRateIntradayDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final startDate = DateTime(latest.year, latest.month, latest.day);

    final url = fitbitter.FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
      date: startDate,
      fitbitCredentials: credentials,
      intradayDetailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
    );

    final items =
        await manager.fetch(url) as List<fitbitter.FitbitHeartRateIntradayData>;

    return items
        .map((item) => FitbitHeartData(item.value!, item.dateOfMonitoring!))
        .where((data) => data.dateTime.isAfter(latest))
        .toList();
  }

  static Future<List<FitbitSleepData>> _fetchSleepData(
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest,
  ) async {
    final manager = fitbitter.FitbitSleepDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final startDate = DateTime(latest.year, latest.month, latest.day);

    final url = fitbitter.FitbitSleepAPIURL.dateRange(
      startDate: startDate,
      endDate: DateTime.now(),
      fitbitCredentials: credentials,
    );

    final items = await manager.fetch(url) as List<fitbitter.FitbitSleepData>;

    return items
        .map((item) => FitbitSleepData(
              item.level!,
              item.entryDateTime!,
              item.dateOfSleep!,
            ),)
        .where((data) => data.dateTime.isAfter(latest))
        .toList();
  }

  static Future<List<FitbitStepData>> _fetchStepData(
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest,
  ) async {
    final manager = fitbitter.FitbitActivityTimeseriesIntradayDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final startDate = DateTime(latest.year, latest.month, latest.day);

    final days = DateTime.now().difference(startDate).inDays;

    if (days > 1) {
      final List<fitbitter.FitbitActivityTimeseriesData> items = [];

      for (int i = 0; i < days; i++) {
        final url =
            fitbitter.FitbitActivityTimeseriesIntradayAPIURL.dayWithResource(
          date: startDate.add(Duration(days: i)),
          fitbitCredentials: credentials,
          resource: fitbitter.Resource.steps,
          detailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
        );

        StudyULogger.warning(url);

        items.addAll(await manager.fetch(url)
            as List<fitbitter.FitbitActivityTimeseriesData>,);
      }

      return items
          .map((item) => FitbitStepData(item.value!, item.dateOfMonitoring!))
          .where((data) => data.dateTime.isAfter(latest))
          .toList();
    } else {
      final url =
          fitbitter.FitbitActivityTimeseriesIntradayAPIURL.dayWithResource(
        date: startDate,
        fitbitCredentials: credentials,
        resource: fitbitter.Resource.steps,
        detailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
      );

      final items = await manager.fetch(url)
          as List<fitbitter.FitbitActivityTimeseriesData>;

      return items
          .map((item) => FitbitStepData(item.value!, item.dateOfMonitoring!))
          .where((data) => data.dateTime.isAfter(latest))
          .toList();
    }
  }

  static Future<List<FitbitData>> _getFitbitData(
    List<FitbitQuestionType> types,
    FitbitCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    String taskId,
    StudySubject subject,
    FitbitQuestion question,
  ) async {
    final allData = <FitbitData>[];
    for (final type in types) {
      final latest =
          await _findLatestDataEntry(subject, taskId, question.id, type) ??
              _startOfToday();

      switch (type) {
        case FitbitQuestionType.steps:
          allData.addAll(
              await _fetchStepData(studyCredentials, credentials, latest),);
        case FitbitQuestionType.heartrate:
          allData.addAll(
              await _fetchHeartData(studyCredentials, credentials, latest),);
        case FitbitQuestionType.sleep:
          allData.addAll(
              await _fetchSleepData(studyCredentials, credentials, latest),);
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

    final latestProgress = subject.progress.lastWhere(
      (entry) =>
          entry.taskId == taskId && entry.resultType == 'QuestionnaireState',
    );

    if (latestProgress.taskId != taskId) return null;

    final questionnaireState =
        latestProgress.result as Result<QuestionnaireState>;

    final answers = questionnaireState.result.answers.values.where(
      (answer) => answer.question == questionId,
    );

    if (answers.isEmpty) return null;

    final raw = answers.first.response as List<dynamic>;
    final stringList = raw.cast<String>();
    final parsedList = stringList.map(parseLine).toList();
    final fitbitData = parsedList.map(FitbitData.fromJson).toList();
    final filtered = fitbitData
        .where(
          (data) => data.type.toLowerCase() == type.toReadable().toLowerCase(),
        )
        .toList();

    if (filtered.isEmpty) return null;

    switch (type) {
      case FitbitQuestionType.steps:
        return filtered.last.dateTime;
      case FitbitQuestionType.heartrate:
        return filtered.last.dateTime;
      case FitbitQuestionType.sleep:
        return (filtered.last as FitbitSleepData).entryDateTime;
    }

    return null;
  }

  static Future<List<FitbitData>> syncFitbitData(
    Study study,
    FitbitQuestion question,
    String taskId,
    StudySubject subject,
  ) async {
    final credentials = await _obtainCredentials(study);

    if (credentials == null) {
      throw Exception(
          'Failed to obtain Fitbit credentials. Please try syncing again',);
    }
    return _getFitbitData(
      question.types,
      study.fitbitCredentials!,
      credentials,
      taskId,
      subject,
      question,
    );
  }
}
