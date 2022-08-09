import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/subjects.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

typedef ModelID = String;

// TODO make this immutable
class WrappedModel<T> {
  WrappedModel(T model) : _model = model {
    this.model = model;
  }

  T _model;
  T get model => _model;
  set model(T model) {
    _model = model;
    asyncValue = AsyncData<T>(model);
  }

  AsyncValue<T> asyncValue = AsyncValue<T>.loading();

  bool isLocalOnly = true;
  bool isDirty = false;
  bool isDeleted = false;
  DateTime? lastSaved;
  DateTime? lastFetched;
  DateTime? lastUpdated;

  markWithError(Object error, {StackTrace? stackTrace}) {
    asyncValue = AsyncError<T>(error).copyWithPrevious(asyncValue);
  }

  markAsLoading() {
    asyncValue = AsyncLoading<T>().copyWithPrevious(asyncValue);
  }

  markAsFetched() {
    if (isDirty) {
      throw Exception(
          "Dirty model marked as fetched, potentially resulting in "
          "loss of unsaved changes.");
    }
    isLocalOnly = false;
    lastFetched = DateTime.now();
  }

  markAsSaved() {
    isDirty = false;
    isLocalOnly = false;
    lastSaved = DateTime.now();
  }
}

class ModelRepositoryException implements Exception {}
class ModelNotFoundException implements ModelRepositoryException {}

abstract class IModelRepository<T> implements IModelActionProvider<T> {
  ModelID getKey(T model);
  WrappedModel<T>? get(ModelID modelId);
  Future<List<WrappedModel<T>>> fetchAll();
  Future<WrappedModel<T>> fetch(ModelID modelId);
  Future<WrappedModel<T>?> save(T model); // upsert
  Future<void> delete(ModelID modelId);
  Future<void> duplicateAndSave(T model);
  Stream<WrappedModel<T>> watch(ModelID modelId, {fetchOnSubscribe = true});
  Stream<List<WrappedModel<T>>> watchAll({fetchOnSubscribe = true});
  Future<WrappedModel<T>?> ensurePersisted(ModelID modelId);
  void dispose();
}

abstract class IModelRepositoryDelegate<T> {
  Future<List<T>> fetchAll();
  Future<T> fetch(ModelID modelId);
  Future<T> save(T model);
  Future<void> delete(T model);
  T createNewInstance();
  T createDuplicate(T model);
  onError(Object error, StackTrace? stackTrace);
}

// TODO: revisit user-facing error handling & flow
abstract class ModelRepository<T> extends IModelRepository<T> {
  ModelRepository(this.delegate);

  /// Injected delegate reference
  final IModelRepositoryDelegate<T> delegate;

  /// Stream controller for broadcasting all models stored in the repository
  final BehaviorSubject<List<WrappedModel<T>>> _allModelsStreamController = BehaviorSubject();

  /// Stream controllers for subscriptions on individual models of type [T]
  final Map<ModelID, BehaviorSubject<WrappedModel<T>>> modelStreamControllers = {};

  /// Collection of all models of type [T]
  ///
  /// Contains both unpersisted / local-only objects of type [T] (see
  /// [_unpersistedModels]) as well as models fetched from the backend
  final Map<ModelID, WrappedModel<T>> _allModels = {};

  @override
  WrappedModel<T>? get(ModelID modelId, {bool strict = false}) {
    if (_allModels.containsKey(modelId)) {
      return _allModels[modelId];
    }
    if (strict) {
      throw ModelNotFoundException();
    }
    return null;
  }

  @override
  Future<List<WrappedModel<T>>> fetchAll() async {
    List<WrappedModel<T>> wrappedModels = [];
    try {
      final models = await delegate.fetchAll();
      wrappedModels = _upsertAllLocally(models);
      for (final wrappedModel in wrappedModels) {
        wrappedModel.markAsFetched();
      }
    } catch(e, stackTrace) {
      emitError(_allModelsStreamController, e, stackTrace);
      rethrow;
    }

    emitUpdate();

    return wrappedModels;
  }

  @override
  Future<WrappedModel<T>> fetch(ModelID modelId) async {
    if (modelId == Config.newModelId) {
      throw ModelNotFoundException();
    }

    final existingWrappedModel = get(modelId);
    existingWrappedModel?.markAsLoading();

    late final WrappedModel<T>? wrappedModel;
    try {
      final model = await delegate.fetch(modelId);
      wrappedModel = _upsertLocally(model);
      wrappedModel.markAsFetched();
    } catch(e, stackTrace) {
      // Associate error with existing object if possible, otherwise bubble up
      if (existingWrappedModel != null) {
        existingWrappedModel.markWithError(e);
        emitError(modelStreamControllers[modelId], e, stackTrace);
      } else {
        rethrow;
      }
    }

    emitUpdate();

    return wrappedModel!;
  }

  @override
  Future<WrappedModel<T>?> save(T model) {
    final modelId = getKey(model);
    final prevModel = get(modelId)?.model;

    final saveOperation = OptimisticUpdate(
      applyOptimistic: () {
        final wrappedModel = _upsertLocally(model);
        wrappedModel.markAsLoading();
      },
      apply: () async {
        final savedModel = await delegate.save(model);
        final wrappedModel = _upsertLocally(savedModel);
        wrappedModel.markAsSaved();
      },
      rollback: () {
        if (prevModel == null) { // didn't exist previously
          _allModels.remove(modelId);
        } else { // undo any changes
          final wrappedModel = get(modelId);
          wrappedModel!.model = prevModel;
        }
      },
      onUpdate: emitUpdate,
      onError: (e, stackTrace) {
        get(modelId)?.markWithError(e);
        emitError(modelStreamControllers[modelId], e, stackTrace);
      },
      rethrowErrors: true,
    );

    return saveOperation.execute().then((_) => get(modelId));

    /*
    // Cache the model locally if this is the first time we encounter it
    final modelId = getKey(model);
    if (!_allModels.containsKey(modelId)) {
      _upsertLocally(model);
    }

    WrappedModel<T> wrappedModel = _allModels[modelId]!;
    wrappedModel.markAsLoading();

    try {
      final savedModel = await delegate.save(model);
      wrappedModel = _upsertLocally(savedModel);
      wrappedModel.markAsSaved();
    } catch(e, stackTrace) {
      // Associate error with existing object
      wrappedModel.markWithError(e);
      emitError(modelStreamControllers[modelId], e, stackTrace);
      rethrow;
    }

    emitUpdate();

    return wrappedModel;

     */
  }

  @override
  Future<void> delete(ModelID modelId) async {
    final wrappedModel = get(modelId);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    wrappedModel.markAsLoading();

    final deleteOperation = OptimisticUpdate(
      applyOptimistic: () => wrappedModel.isDeleted = true,
      apply: () {
        if (!wrappedModel.isLocalOnly) {
          return delegate.delete(wrappedModel.model);
        }
        // Model already flagged as deleted, free it for garbage collection
        return Future(() => _allModels.remove(modelId));
      },
      rollback: () => wrappedModel.isDeleted = false,
      onUpdate: emitUpdate,
      onError: (e, stackTrace) {
        emitError(modelStreamControllers[modelId], e, stackTrace);
      }
    );

    return deleteOperation.execute();
  }

  @override
  Future<void> duplicateAndSave(T model) {
    final duplicateModel = delegate.createDuplicate(model);
    final duplicateModelId = getKey(duplicateModel);

    final duplicateOperation = OptimisticUpdate(
      applyOptimistic: () {
        final wrappedModel = _upsertLocally(duplicateModel);
        wrappedModel.markAsLoading();
      },
      apply: () => save(duplicateModel),
      rollback: () => delete(duplicateModelId),
      onUpdate: emitUpdate,
    );

    return duplicateOperation.execute();
  }

  @override
  Stream<List<WrappedModel<T>>> watchAll({fetchOnSubscribe = true}) {
    // Note: we don't use Stream.fromFuture here because it automatically
    // closes the stream when the future resolves
    if (fetchOnSubscribe) {
      fetchAll();
    }
    return _allModelsStreamController.stream;
  }

  /// Returns a stream that emits the model of type [T] identified by the
  /// given [ModelID].
  ///
  /// If [fetchOnSubscribe] is true, the individual model will be fetched
  /// from the network and upserted into the local cache.
  ///
  /// If the requested [ModelId] is not available, the stream will be created
  /// anyway, but emit a [ModelNotFoundException] error event.
  @override
  Stream<WrappedModel<T>> watch(ModelID modelId, {fetchOnSubscribe = true}) {
    WrappedModel<T>? wrappedModel;

    if (modelId == Config.newModelId) {
      // Create new model to subscribe to
      final newModel = delegate.createNewInstance();
      wrappedModel = _upsertLocally(newModel, emitUpdate: true);
      modelId = getKey(newModel); // subscribe to the newly created study
    } else {
      // Subscribe to existing model (may not be fetched yet)
      wrappedModel = get(modelId, strict: !fetchOnSubscribe);
    }

    // Reuse existing stream if any
    if (modelStreamControllers.containsKey(modelId)) {
      return modelStreamControllers[modelId]!.stream;
    }

    // Construct a transformed stream that selects the corresponding study from
    // the stream of all studies.
    //
    // It would be convenient to use a simple stream transform like .map here,
    // but this doesn't give us a way to send error events (e.g. from network
    // fetches) on the stream we are returning.
    //
    // Hence, we need to create a new controller here that implements
    // the stream transform as a subscription callback and cleans up after
    // itself when it's no longer needed.
    final BehaviorSubject<WrappedModel<T>> controller = BehaviorSubject();

    final subscription = watchAll(fetchOnSubscribe: false).listen((wrappedModels) {
      WrappedModel<T>? subscribedModel;
      for (final wrappedModel in wrappedModels) {
        if (getKey(wrappedModel.model) == modelId) {
          subscribedModel = wrappedModel;
          break;
        }
      }
      if (subscribedModel != null) {
        if (!controller.isClosed) {
          controller.add(subscribedModel);
        }
      }
    });

    void discardController() {
      subscription.cancel();
      controller.close();
      modelStreamControllers.remove(modelId);
    }
    controller.onCancel = discardController;

    if (fetchOnSubscribe) {
      if (!(wrappedModel != null && wrappedModel.isLocalOnly)) {
        fetch(modelId).catchError((e) {
          if (!controller.isClosed) {
            controller.addError(e);
          }
          return e;
        });
      }
    }

    modelStreamControllers[modelId] = controller;

    return controller.stream;
  }

  @override
  Future<WrappedModel<T>?> ensurePersisted(ModelID modelId) {
    final wrappedModel = get(modelId, strict: true)!;
    if (wrappedModel.isLocalOnly) {
      return save(wrappedModel.model);
    }
    return Future.value(wrappedModel);
  }

  WrappedModel<T> _upsertLocally(T newModel, {emitUpdate = false}) {
    final newModelId = getKey(newModel);
    if (_allModels.containsKey(newModelId)) {
      // Model already exists, replace with the new object
      final wrapped = _allModels[newModelId]!;
      wrapped.model = newModel;
    } else {
      // Model does not exist locally yet, add it to the client-side list
      _allModels[newModelId] = WrappedModel(newModel);
    }
    if (emitUpdate) {
      this.emitUpdate();
    }
    return _allModels[newModelId]!;
  }

  List<WrappedModel<T>> _upsertAllLocally(List<T> newModels, {emitUpdate = false}) {
    List<WrappedModel<T>> wrappedModels = [];
    for (final newModel in newModels) {
      final wrapped = _upsertLocally(newModel, emitUpdate: false);
      wrappedModels.add(wrapped);
    }
    if (emitUpdate) {
      this.emitUpdate();
    }
    return wrappedModels;
  }

  emitUpdate() {
    if (!_allModelsStreamController.isClosed) {
      _allModelsStreamController.add(
        // Filter out models marked as deleted
          _allModels.values.where((model) => !model.isDeleted).toList()
      );
    }
  }

  emitError(StreamController? controller, Object e, StackTrace? stackTrace) {
    if (controller != null && !controller.isClosed) {
      controller.addError(e, stackTrace);
    }
    delegate.onError(e, stackTrace);
  }

  @override
  dispose() {
    _allModelsStreamController.close();
    modelStreamControllers.forEach((_, controller) {
      controller.close();
    });
  }

  @override
  List<ModelAction> availableActions(T model) {
    return []; // Subclass responsibility
  }
}
