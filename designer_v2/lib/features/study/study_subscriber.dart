import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';

/*
class StudyBaseController<T extends StudyControllerBaseState> extends StateNotifier<T> {
  StudyBaseController(T state, {
    required this.studyId,
    required this.studyRepository,
  }) : super(state);

  final StudyID studyId;
  final IStudyRepository studyRepository;

  StreamSubscription<WrappedModel<Study>>? studySubscription;

  subscribeStudy(StudyID studyId) {
    if (studySubscription != null) {
      studySubscription!.cancel();
    }
    studySubscription = studyRepository.watch(studyId).listen((wrappedModel) {
      onStudyUpdate(wrappedModel);
    }, onError: (error) {
      /* TODO: figure out a way to resolve data dependencies for the current page
          during app initialization so that we don't need to render the loading state
          if the study doesn't exist
      */
      if (error is StudyNotFoundException) {
        router.dispatch(RoutingIntents.error(error));
      }
      // TODO: improve error handling
    });
  }

  onStudyUpdate(WrappedModel<Study> wrappedModel) {

  }

  @override
  dispose() {
    studySubscription?.cancel();
    super.dispose();
  }
}

 */
