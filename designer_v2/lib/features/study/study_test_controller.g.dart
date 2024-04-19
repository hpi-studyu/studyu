// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_test_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyTestPlatformControllerHash() =>
    r'c09a0c6ecb0040703fa5fe35c927aa40c6a47a84';

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

/// See also [studyTestPlatformController].
@ProviderFor(studyTestPlatformController)
const studyTestPlatformControllerProvider = StudyTestPlatformControllerFamily();

/// See also [studyTestPlatformController].
class StudyTestPlatformControllerFamily extends Family<PlatformController> {
  /// See also [studyTestPlatformController].
  const StudyTestPlatformControllerFamily();

  /// See also [studyTestPlatformController].
  StudyTestPlatformControllerProvider call(
    String studyId,
  ) {
    return StudyTestPlatformControllerProvider(
      studyId,
    );
  }

  @override
  StudyTestPlatformControllerProvider getProviderOverride(
    covariant StudyTestPlatformControllerProvider provider,
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
  String? get name => r'studyTestPlatformControllerProvider';
}

/// See also [studyTestPlatformController].
class StudyTestPlatformControllerProvider
    extends AutoDisposeProvider<PlatformController> {
  /// See also [studyTestPlatformController].
  StudyTestPlatformControllerProvider(
    String studyId,
  ) : this._internal(
          (ref) => studyTestPlatformController(
            ref as StudyTestPlatformControllerRef,
            studyId,
          ),
          from: studyTestPlatformControllerProvider,
          name: r'studyTestPlatformControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyTestPlatformControllerHash,
          dependencies: StudyTestPlatformControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyTestPlatformControllerFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  StudyTestPlatformControllerProvider._internal(
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
  Override overrideWith(
    PlatformController Function(StudyTestPlatformControllerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudyTestPlatformControllerProvider._internal(
        (ref) => create(ref as StudyTestPlatformControllerRef),
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
  AutoDisposeProviderElement<PlatformController> createElement() {
    return _StudyTestPlatformControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyTestPlatformControllerProvider &&
        other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyTestPlatformControllerRef
    on AutoDisposeProviderRef<PlatformController> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyTestPlatformControllerProviderElement
    extends AutoDisposeProviderElement<PlatformController>
    with StudyTestPlatformControllerRef {
  _StudyTestPlatformControllerProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyTestPlatformControllerProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
