// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_test_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyTestPlatformControllerHash() =>
    r'969d96c554912ced48541b9e2c90102f10c17c32';

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

/// Provide a controller parametrized by [StudyID]
///
/// Copied from [studyTestPlatformController].
@ProviderFor(studyTestPlatformController)
const studyTestPlatformControllerProvider = StudyTestPlatformControllerFamily();

/// Provide a controller parametrized by [StudyID]
///
/// Copied from [studyTestPlatformController].
class StudyTestPlatformControllerFamily extends Family<PlatformController> {
  /// Provide a controller parametrized by [StudyID]
  ///
  /// Copied from [studyTestPlatformController].
  const StudyTestPlatformControllerFamily();

  /// Provide a controller parametrized by [StudyID]
  ///
  /// Copied from [studyTestPlatformController].
  StudyTestPlatformControllerProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyTestPlatformControllerProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyTestPlatformControllerProvider getProviderOverride(
    covariant StudyTestPlatformControllerProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
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

/// Provide a controller parametrized by [StudyID]
///
/// Copied from [studyTestPlatformController].
class StudyTestPlatformControllerProvider
    extends AutoDisposeProvider<PlatformController> {
  /// Provide a controller parametrized by [StudyID]
  ///
  /// Copied from [studyTestPlatformController].
  StudyTestPlatformControllerProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => studyTestPlatformController(
            ref as StudyTestPlatformControllerRef,
            studyCreationArgs,
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
          studyCreationArgs: studyCreationArgs,
        );

  StudyTestPlatformControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

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
        studyCreationArgs: studyCreationArgs,
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
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyTestPlatformControllerRef
    on AutoDisposeProviderRef<PlatformController> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyTestPlatformControllerProviderElement
    extends AutoDisposeProviderElement<PlatformController>
    with StudyTestPlatformControllerRef {
  _StudyTestPlatformControllerProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyTestPlatformControllerProvider).studyCreationArgs;
}

String _$studyTestControllerHash() =>
    r'0843da6b9aac68eb9e7fe1a9cd78862722d0d42c';

abstract class _$StudyTestController
    extends BuildlessAutoDisposeNotifier<StudyTestControllerState> {
  late final StudyCreationArgs studyCreationArgs;

  StudyTestControllerState build(
    StudyCreationArgs studyCreationArgs,
  );
}

/// See also [StudyTestController].
@ProviderFor(StudyTestController)
const studyTestControllerProvider = StudyTestControllerFamily();

/// See also [StudyTestController].
class StudyTestControllerFamily extends Family<StudyTestControllerState> {
  /// See also [StudyTestController].
  const StudyTestControllerFamily();

  /// See also [StudyTestController].
  StudyTestControllerProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyTestControllerProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyTestControllerProvider getProviderOverride(
    covariant StudyTestControllerProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
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
  String? get name => r'studyTestControllerProvider';
}

/// See also [StudyTestController].
class StudyTestControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyTestController, StudyTestControllerState> {
  /// See also [StudyTestController].
  StudyTestControllerProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          () => StudyTestController()..studyCreationArgs = studyCreationArgs,
          from: studyTestControllerProvider,
          name: r'studyTestControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyTestControllerHash,
          dependencies: StudyTestControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyTestControllerFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyTestControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

  @override
  StudyTestControllerState runNotifierBuild(
    covariant StudyTestController notifier,
  ) {
    return notifier.build(
      studyCreationArgs,
    );
  }

  @override
  Override overrideWith(StudyTestController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyTestControllerProvider._internal(
        () => create()..studyCreationArgs = studyCreationArgs,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyCreationArgs: studyCreationArgs,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<StudyTestController,
      StudyTestControllerState> createElement() {
    return _StudyTestControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyTestControllerProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyTestControllerRef
    on AutoDisposeNotifierProviderRef<StudyTestControllerState> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyTestControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyTestController,
        StudyTestControllerState> with StudyTestControllerRef {
  _StudyTestControllerProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyTestControllerProvider).studyCreationArgs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
