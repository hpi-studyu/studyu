import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyTestControllerState extends StudyControllerBaseState {
  const StudyTestControllerState({
    required super.currentUser,
    super.studyWithMetadata,
    this.serializedSession = '',
  });

  final String serializedSession;

  bool get canTest => serializedSession.isNotEmpty;

  String get appUrl {
    if (!canTest || !study.hasValue) {
      return '';
    }
    String appUrl = env.appUrl ?? '';
    appUrl += "?mode=preview&session=${Uri.encodeComponent(serializedSession)}";
    appUrl += "&studyid=$studyId";
    return appUrl;
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
