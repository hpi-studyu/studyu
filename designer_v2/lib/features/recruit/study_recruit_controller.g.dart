// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_recruit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyRecruitControllerHash() =>
    r'812b93ecf573c34c3bbc46caba3536ed22957171';

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

abstract class _$StudyRecruitController
    extends BuildlessAutoDisposeNotifier<StudyRecruitControllerState> {
  late final StudyCreationArgs studyCreationArgs;

  StudyRecruitControllerState build(
    StudyCreationArgs studyCreationArgs,
  );
}

/// See also [StudyRecruitController].
@ProviderFor(StudyRecruitController)
const studyRecruitControllerProvider = StudyRecruitControllerFamily();

/// See also [StudyRecruitController].
class StudyRecruitControllerFamily extends Family<StudyRecruitControllerState> {
  /// See also [StudyRecruitController].
  const StudyRecruitControllerFamily();

  /// See also [StudyRecruitController].
  StudyRecruitControllerProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyRecruitControllerProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyRecruitControllerProvider getProviderOverride(
    covariant StudyRecruitControllerProvider provider,
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
  String? get name => r'studyRecruitControllerProvider';
}

/// See also [StudyRecruitController].
class StudyRecruitControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyRecruitController, StudyRecruitControllerState> {
  /// See also [StudyRecruitController].
  StudyRecruitControllerProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          () => StudyRecruitController()..studyCreationArgs = studyCreationArgs,
          from: studyRecruitControllerProvider,
          name: r'studyRecruitControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyRecruitControllerHash,
          dependencies: StudyRecruitControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyRecruitControllerFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyRecruitControllerProvider._internal(
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
  StudyRecruitControllerState runNotifierBuild(
    covariant StudyRecruitController notifier,
  ) {
    return notifier.build(
      studyCreationArgs,
    );
  }

  @override
  Override overrideWith(StudyRecruitController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyRecruitControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<StudyRecruitController,
      StudyRecruitControllerState> createElement() {
    return _StudyRecruitControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyRecruitControllerProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyRecruitControllerRef
    on AutoDisposeNotifierProviderRef<StudyRecruitControllerState> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyRecruitControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyRecruitController,
        StudyRecruitControllerState> with StudyRecruitControllerRef {
  _StudyRecruitControllerProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyRecruitControllerProvider).studyCreationArgs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
