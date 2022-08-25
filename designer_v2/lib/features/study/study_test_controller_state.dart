import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class StudyTestControllerState extends StudyControllerBaseState {
  const StudyTestControllerState({
    required super.currentUser,
    super.studyWithMetadata,
    this.serializedSession = '',
  });

  final String serializedSession;

  bool get canTest => serializedSession.isNotEmpty && missingRequirements == null;

  String get appUrl {
    if (!canTest || !study.hasValue) {
      return '';
    }
    String appUrl = "$appDeepLink";
    appUrl += "?mode=preview&session=${Uri.encodeComponent(serializedSession)}";
    appUrl += "&studyid=$studyId";
    return appUrl;
  }

  // TODO shared abstraction / validation mechanism with study publish flow
  Map<String, dynamic>? get missingRequirements {
    if (!this.study.hasValue) {
      return null;
    }

    _isValid(dynamic val) {
      if (val is bool) {
        return val;
      }
      return val?.isNotEmpty ?? false;
    }

    final study = this.study.value!;
    final missing = {
      'Title': study.title,
      'Description': study.description,
      // TODO: define/discuss requirements for testing
      'Interventions': study.interventions,
      'Observations': study.observations,
      // 'Consent': study.questionnaire.questions,
      // maybe: study.hasEligibilityCheck,
      // maybe:study.eligibilityCriteria,
    };
    missing.removeWhere((title, element) => _isValid(element));

    return (missing.isEmpty) ? null : missing;
  }

  @override
  StudyTestControllerState copyWith({
    WrappedModel<Study>? studyWithMetadata,
    String? serializedSession,
  }) {
    return StudyTestControllerState(
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      serializedSession: serializedSession ?? this.serializedSession,
      currentUser: currentUser,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [...super.props, serializedSession];
}
