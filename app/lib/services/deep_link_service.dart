import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;

/// Result types for deep link processing
sealed class DeepLinkResult {}

/// Deep link was successfully processed
class DeepLinkSuccess extends DeepLinkResult {
  final Study study;
  final String? inviteCode;
  final List<String>? preselectedInterventionIds;
  final bool alreadyEnrolled;

  DeepLinkSuccess({
    required this.study,
    this.inviteCode,
    this.preselectedInterventionIds,
    this.alreadyEnrolled = false,
  });
}

/// Deep link processing failed
class DeepLinkError extends DeepLinkResult {
  final DeepLinkErrorType type;
  DeepLinkError(this.type);
}

/// User needs to authenticate first
class DeepLinkNeedsAuth extends DeepLinkResult {}

/// Types of deep link errors
enum DeepLinkErrorType { studyNotFound, inviteOnly, invalidInvite }

class DeepLinkService {
  /// Fetches a study by its ID
  static Future<Study?> fetchStudyById(String studyId) async {
    try {
      return await SupabaseQuery.getById<Study>(studyId);
    } catch (e) {
      debugPrint('Failed to fetch study by ID: $e');
      return null;
    }
  }

  /// Fetches a study by invite code
  static Future<(StudyInvite?, Study?)> fetchStudyByInviteCode(
    String code,
  ) async {
    try {
      final inviteResult = await env.client
          .from('study_invite')
          .select()
          .eq('code', code);
      if (inviteResult.isEmpty) {
        return (null, null);
      }
      final invite = StudyInvite.fromJson(inviteResult.first);
      final study = await fetchStudyById(invite.studyId);
      return (invite, study);
    } catch (e) {
      debugPrint('Failed to fetch study by invite code: $e');
      return (null, null);
    }
  }

  /// Process a deep link and return the result
  ///
  /// This is the main entry point for deep link handling. It validates
  /// authentication, fetches the study/invite, and returns an appropriate result.
  static Future<DeepLinkResult> processDeepLink({
    required String? studyId,
    required String? inviteCode,
    required bool isAuthenticated,
    String? activeStudyId,
  }) async {
    // If user is not authenticated, they need to go through the auth flow
    if (!isAuthenticated) {
      return DeepLinkNeedsAuth();
    }

    // Process study deep link
    if (studyId != null) {
      return _processStudyDeepLink(
        studyId: studyId,
        activeStudyId: activeStudyId,
      );
    }

    // Process invite deep link
    if (inviteCode != null) {
      return _processInviteDeepLink(inviteCode: inviteCode);
    }

    // No valid deep link data provided
    return DeepLinkError(DeepLinkErrorType.studyNotFound);
  }

  /// Process a study ID deep link
  static Future<DeepLinkResult> _processStudyDeepLink({
    required String studyId,
    String? activeStudyId,
  }) async {
    final study = await fetchStudyById(studyId);

    if (study == null) {
      return DeepLinkError(DeepLinkErrorType.studyNotFound);
    }

    // Check if study requires an invite
    if (study.participation == Participation.invite) {
      return DeepLinkError(DeepLinkErrorType.inviteOnly);
    }

    // Check if user is already enrolled in this study
    if (activeStudyId == study.id) {
      return DeepLinkSuccess(study: study, alreadyEnrolled: true);
    }

    return DeepLinkSuccess(study: study);
  }

  /// Process an invite code deep link
  static Future<DeepLinkResult> _processInviteDeepLink({
    required String inviteCode,
  }) async {
    final (invite, study) = await fetchStudyByInviteCode(inviteCode);

    if (invite == null || study == null) {
      return DeepLinkError(DeepLinkErrorType.invalidInvite);
    }

    return DeepLinkSuccess(
      study: study,
      inviteCode: inviteCode,
      preselectedInterventionIds: invite.preselectedInterventionIds,
    );
  }
}
