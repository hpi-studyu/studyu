// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_base_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyBaseControllerHash() =>
    r'1277944be2302e5d8f5d0c9bdc36e05a05d2d104';

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

abstract class _$StudyBaseController
    extends BuildlessAutoDisposeNotifier<StudyControllerBaseState> {
  late final String studyId;

  StudyControllerBaseState build(
    String studyId,
  );
}

/// See also [StudyBaseController].
@ProviderFor(StudyBaseController)
const studyBaseControllerProvider = StudyBaseControllerFamily();

/// See also [StudyBaseController].
class StudyBaseControllerFamily extends Family<StudyControllerBaseState> {
  /// See also [StudyBaseController].
  const StudyBaseControllerFamily();

  /// See also [StudyBaseController].
  StudyBaseControllerProvider call(
    String studyId,
  ) {
    return StudyBaseControllerProvider(
      studyId,
    );
  }

  @override
  StudyBaseControllerProvider getProviderOverride(
    covariant StudyBaseControllerProvider provider,
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
  String? get name => r'studyBaseControllerProvider';
}

/// See also [StudyBaseController].
class StudyBaseControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyBaseController, StudyControllerBaseState> {
  /// See also [StudyBaseController].
  StudyBaseControllerProvider(
    String studyId,
  ) : this._internal(
          () => StudyBaseController()..studyId = studyId,
          from: studyBaseControllerProvider,
          name: r'studyBaseControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyBaseControllerHash,
          dependencies: StudyBaseControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyBaseControllerFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  StudyBaseControllerProvider._internal(
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
  StudyControllerBaseState runNotifierBuild(
    covariant StudyBaseController notifier,
  ) {
    return notifier.build(
      studyId,
    );
  }

  @override
  Override overrideWith(StudyBaseController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyBaseControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<StudyBaseController,
      StudyControllerBaseState> createElement() {
    return _StudyBaseControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyBaseControllerProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyBaseControllerRef
    on AutoDisposeNotifierProviderRef<StudyControllerBaseState> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyBaseControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyBaseController,
        StudyControllerBaseState> with StudyBaseControllerRef {
  _StudyBaseControllerProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyBaseControllerProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
