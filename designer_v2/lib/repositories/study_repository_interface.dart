import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

abstract class IStudyRepository implements ModelRepository<Study> {
  Future<void> launch(Study study);
  Future<void> deleteParticipants(Study study);
  Future<void> close(Study study);
  // Future<void> deleteProgress(Study study);
}
