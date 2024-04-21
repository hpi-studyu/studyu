// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_recruit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyRecruitControllerHash() =>
    r'8dc8092f83dbab107eadaa274ad0cdfc09d79e38';

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
  late final String studyId;

  StudyRecruitControllerState build(
    String studyId,
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
    String studyId,
  ) {
    return StudyRecruitControllerProvider(
      studyId,
    );
  }

  @override
  StudyRecruitControllerProvider getProviderOverride(
    covariant StudyRecruitControllerProvider provider,
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
  String? get name => r'studyRecruitControllerProvider';
}

/// See also [StudyRecruitController].
class StudyRecruitControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyRecruitController, StudyRecruitControllerState> {
  /// See also [StudyRecruitController].
  StudyRecruitControllerProvider(
    String studyId,
  ) : this._internal(
          () => StudyRecruitController()..studyId = studyId,
          from: studyRecruitControllerProvider,
          name: r'studyRecruitControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyRecruitControllerHash,
          dependencies: StudyRecruitControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyRecruitControllerFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  StudyRecruitControllerProvider._internal(
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
  StudyRecruitControllerState runNotifierBuild(
    covariant StudyRecruitController notifier,
  ) {
    return notifier.build(
      studyId,
    );
  }

  @override
  Override overrideWith(StudyRecruitController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyRecruitControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<StudyRecruitController,
      StudyRecruitControllerState> createElement() {
    return _StudyRecruitControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyRecruitControllerProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyRecruitControllerRef
    on AutoDisposeNotifierProviderRef<StudyRecruitControllerState> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyRecruitControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyRecruitController,
        StudyRecruitControllerState> with StudyRecruitControllerRef {
  _StudyRecruitControllerProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyRecruitControllerProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
