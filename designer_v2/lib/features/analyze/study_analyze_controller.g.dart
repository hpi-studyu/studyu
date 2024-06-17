// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_analyze_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyAnalyzeControllerHash() =>
    r'35cd3286b97372b300d4d3e871e3d86040913837';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$StudyAnalyzeController
    extends BuildlessAutoDisposeNotifier<StudyAnalyzeControllerState> {
  late final String studyId;

  StudyAnalyzeControllerState build(
    String studyId,
  );
}

/// See also [StudyAnalyzeController].
@ProviderFor(StudyAnalyzeController)
const studyAnalyzeControllerProvider = StudyAnalyzeControllerFamily();

/// See also [StudyAnalyzeController].
class StudyAnalyzeControllerFamily extends Family<StudyAnalyzeControllerState> {
  /// See also [StudyAnalyzeController].
  const StudyAnalyzeControllerFamily();

  /// See also [StudyAnalyzeController].
  StudyAnalyzeControllerProvider call(
    String studyId,
  ) {
    return StudyAnalyzeControllerProvider(
      studyId,
    );
  }

  @override
  StudyAnalyzeControllerProvider getProviderOverride(
    covariant StudyAnalyzeControllerProvider provider,
  ) {
    return call(
      provider.studyId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studyAnalyzeControllerProvider';
}

/// See also [StudyAnalyzeController].
class StudyAnalyzeControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyAnalyzeController, StudyAnalyzeControllerState> {
  /// See also [StudyAnalyzeController].
  StudyAnalyzeControllerProvider(
    String studyId,
  ) : this._internal(
          () => StudyAnalyzeController()..studyId = studyId,
          from: studyAnalyzeControllerProvider,
          name: r'studyAnalyzeControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyAnalyzeControllerHash,
          dependencies: StudyAnalyzeControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyAnalyzeControllerFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  StudyAnalyzeControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  StudyAnalyzeControllerState runNotifierBuild(
    covariant StudyAnalyzeController notifier,
  ) {
    return notifier.build(
      studyId,
    );
  }

  @override
  Override overrideWith(StudyAnalyzeController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyAnalyzeControllerProvider._internal(
        () => create()..studyId = studyId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<StudyAnalyzeController,
      StudyAnalyzeControllerState> createElement() {
    return _StudyAnalyzeControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyAnalyzeControllerProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyAnalyzeControllerRef
    on AutoDisposeNotifierProviderRef<StudyAnalyzeControllerState> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyAnalyzeControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyAnalyzeController,
        StudyAnalyzeControllerState> with StudyAnalyzeControllerRef {
  _StudyAnalyzeControllerProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyAnalyzeControllerProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
