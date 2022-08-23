import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/model_repository_events.dart';

class StudyLaunched extends ModelEvent<Study> {
  const StudyLaunched(super.modelId, super.model);
}
