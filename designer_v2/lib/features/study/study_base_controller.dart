import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudyBaseController<T extends StudyControllerBaseState>
    extends StateNotifier<T> {
  StudyBaseController(
    super.state, {
    required this.studyId,
    required this.studyRepository,
    required this.currentUser,
    required this.router,
  }) {
    subscribeStudy(studyId);
  }

  final StudyID studyId;
  final IStudyRepository studyRepository;
  final User? currentUser;
  final GoRouter router;

  StreamSubscription<WrappedModel<Study>>? studySubscription;

  void subscribeStudy(StudyID studyId) {
    if (studySubscription != null) {
      studySubscription!.cancel();
    }
    studySubscription = studyRepository
        .watch(studyId)
        .listen(onStudySubscriptionUpdate, onError: onStudySubscriptionError);
  }

  void onStudySubscriptionUpdate(WrappedModel<Study> wrappedModel) {
    state = state.copyWith(studyWithMetadata: wrappedModel) as T;
  }

  void onStudySubscriptionError(Object error) {
    // TODO: improve error handling
    if (error is StudyNotFoundException) {
      /* TODO: figure out a way to resolve data dependencies for the current page
           during app initialization so that we don't need to render the loading state
           if the study doesn't exist
      */
      router.dispatch(RoutingIntents.error(error));
    }
  }

  @override
  void dispose() {
    studySubscription?.cancel();
    super.dispose();
  }
}
