// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyControllerHash() => r'9121d1f12358954a91e34c91522de768cb8b02b3';

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

abstract class _$StudyController
    extends BuildlessAutoDisposeNotifier<StudyControllerState> {
  late final StudyCreationArgs studyCreationArgs;

  StudyControllerState build(
    StudyCreationArgs studyCreationArgs,
  );
}

/// See also [StudyController].
@ProviderFor(StudyController)
const studyControllerProvider = StudyControllerFamily();

/// See also [StudyController].
class StudyControllerFamily extends Family<StudyControllerState> {
  /// See also [StudyController].
  const StudyControllerFamily();

  /// See also [StudyController].
  StudyControllerProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyControllerProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyControllerProvider getProviderOverride(
    covariant StudyControllerProvider provider,
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
  String? get name => r'studyControllerProvider';
}

/// See also [StudyController].
class StudyControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyController, StudyControllerState> {
  /// See also [StudyController].
  StudyControllerProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          () => StudyController()..studyCreationArgs = studyCreationArgs,
          from: studyControllerProvider,
          name: r'studyControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyControllerHash,
          dependencies: StudyControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyControllerFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyControllerProvider._internal(
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
  StudyControllerState runNotifierBuild(
    covariant StudyController notifier,
  ) {
    return notifier.build(
      studyCreationArgs,
    );
  }

  @override
  Override overrideWith(StudyController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<StudyController, StudyControllerState>
      createElement() {
    return _StudyControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyControllerProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyControllerRef
    on AutoDisposeNotifierProviderRef<StudyControllerState> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyController,
        StudyControllerState> with StudyControllerRef {
  _StudyControllerProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyControllerProvider).studyCreationArgs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
