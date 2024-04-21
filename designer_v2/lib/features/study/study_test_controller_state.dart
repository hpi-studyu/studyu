import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class StudyTestControllerState extends StudyControllerBaseState {
  const StudyTestControllerState({
    required super.studyId,
    required super.studyRepository,
    required super.router,
    required super.currentUser,
    super.studyWithMetadata,
    this.serializedSession = '',
    this.languageCode = 'en',
  });

  final String serializedSession;
  final String languageCode;

  bool get canTest => serializedSession.isNotEmpty;

  String get appUrl {
    if (!canTest || !study.hasValue) {
      return '';
    }
    String appUrl = env.appUrl ?? '';
    appUrl += "/preview?session=${Uri.encodeComponent(serializedSession)}";
    appUrl += "&studyid=$studyId";
    appUrl += "&languageCode=$languageCode";
    return appUrl;
  }

  @override
  StudyTestControllerState copyWith({
    WrappedModel<Study>? studyWithMetadata,
    String? serializedSession,
    String? languageCode,
  }) {
    return StudyTestControllerState(
      studyId: studyId,
      studyRepository: studyRepository,
      router: router,
      currentUser: currentUser,
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      serializedSession: serializedSession ?? this.serializedSession,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [...super.props, serializedSession];
}
