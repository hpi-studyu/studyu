import 'package:studyu_designer_v2/repositories/model_repository.dart';

abstract class ModelEvent<T> {
  const ModelEvent(this.modelId, this.model);
  final ModelID modelId;
  final T model;
}

class IsFetched<T> extends ModelEvent<T> {
  const IsFetched(super.modelId, super.model);
}

class IsSaving<T> extends ModelEvent<T> {
  const IsSaving(super.modelId, super.model);
}

class IsSaved<T> extends ModelEvent<T> {
  const IsSaved(super.modelId, super.model);
}

class IsDeleted<T> extends ModelEvent<T> {
  const IsDeleted(super.modelId, super.model);
}
