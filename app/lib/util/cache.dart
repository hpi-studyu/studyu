import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class Cache {
  static bool isSynchronizing = false;

  static Future<void> storeSubject(StudySubject? subject) async {
    if (subject == null) return;
    StudySubject newSubject;
    newSubject = await synchronize(subject);
    Analytics.logger.info("Save to local cache");
    SecureStorage.write(cacheSubjectKey, jsonEncode(newSubject.toFullJson()));
    assert(newSubject == (await loadSubject()));
  }

  static Future<StudySubject> loadSubject() async {
    Analytics.logger.info("Load subject from cache");
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      return StudySubject.fromJson(jsonDecode((await SecureStorage.read(cacheSubjectKey))!));
    } else {
      Analytics.logger.warning("No cached subject found");
      throw Exception("No cached subject found");
    }
  }

  static Future<void> storeAnalytics(StudyUAnalytics analytics) async {
    SecureStorage.write(StudyUAnalytics.keyStudyUAnalytics, jsonEncode(analytics.toJson()));
  }

  static Future<StudyUAnalytics?> loadAnalytics() async {
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      return StudyUAnalytics.fromJson(jsonDecode((await SecureStorage.read(StudyUAnalytics.keyStudyUAnalytics))!));
    }
    return null;
  }

  static Future<void> delete() async {
    Analytics.logger.warning("Delete cache");
    SecureStorage.delete(cacheSubjectKey);
  }

  static Future<StudySubject> synchronize(StudySubject remoteSubject) async {
    if (isSynchronizing) return remoteSubject;
    // No local subject found
    if (!(await SecureStorage.containsKey(cacheSubjectKey))) return remoteSubject;
    final localSubject = await loadSubject();
    // local and remote subject are equal, nothing to synchronize
    if (localSubject == remoteSubject) return remoteSubject;
    // remote subject has newer study
    if (!kDebugMode && remoteSubject.startedAt!.isAfter(localSubject.startedAt!)) return remoteSubject;

    Analytics.logger.info("Synchronize with cache");
    isSynchronizing = true;

    try {
      // only minimal update
      // Check if progress has changed
      if (localSubject.progress.length != remoteSubject.progress.length) {
        Analytics.logger.info("[Sync] Found different progress length");
        /*if (remoteSubject.progress.isNotEmpty) {
        // sort remote progress list from oldest to newest
        remoteSubject.progress.sort((a, b) =>
            a.completedAt.compareTo(b.completedAt));
        // merge all local progress older than the latest remote progress to remote subject and upload
        newProgress = localSubject.progress.where((element) =>
            element.completedAt.isAfter(remoteSubject.progress.last.completedAt)
        ).toList();
      } else {
        newProgress = localSubject.progress;
      }*/
        // save new progress
        final List<SubjectProgress> newProgress = [...localSubject.progress, ...remoteSubject.progress];
        newProgress.removeWhere(
            (element) => localSubject.progress.contains(element) && remoteSubject.progress.contains(element));
        for (var p in newProgress) {
          await p.save();
        }

        // merge local and remote progress and remove duplicates
        final List<SubjectProgress> finalProgress = [...localSubject.progress, ...remoteSubject.progress];
        final duplicates = <DateTime?>{};
        finalProgress.retainWhere((element) => duplicates.add(element.completedAt));
        // replace remote progress with our merge
        remoteSubject.progress = finalProgress;
        await remoteSubject.save();
      } else {
        // Unable to determine what has changed
        // We can either drop local or overwrite remote
        // ... for now do nothing
        if (!kDebugMode && localSubject.startedAt == remoteSubject.startedAt) {
          Analytics.logger.severe("Cache synchronization found local changes that cannot be merged");
          Analytics.captureMessage(
              "localSubject: ${localSubject.toFullJson()} \nremoteSubject: ${remoteSubject.toFullJson()}");
          Analytics.captureException(Exception("CacheSynchronizationException"));
        }
      }
    } on SocketException catch (_) {
      Analytics.logger.info("SocketException on synchronizing (normal if offline)");
    } catch (exception) {
      Analytics.logger.warning(exception);
    }
    isSynchronizing = false;
    return remoteSubject;
  }
}
