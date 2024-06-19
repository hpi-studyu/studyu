// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyControllerHash() => r'b9e7f58e87636a2ef0278725a4bf9e0572252fb4';

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
  late final String studyId;

  StudyControllerState build(
    String studyId,
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
    String studyId,
  ) {
    return StudyControllerProvider(
      studyId,
    );
  }

  @override
  StudyControllerProvider getProviderOverride(
    covariant StudyControllerProvider provider,
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
  String? get name => r'studyControllerProvider';
}

/// See also [StudyController].
class StudyControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyController, StudyControllerState> {
  /// See also [StudyController].
  StudyControllerProvider(
    String studyId,
  ) : this._internal(
          () => StudyController()..studyId = studyId,
          from: studyControllerProvider,
          name: r'studyControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyControllerHash,
          dependencies: StudyControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyControllerFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  StudyControllerProvider._internal(
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
  StudyControllerState runNotifierBuild(
    covariant StudyController notifier,
  ) {
    return notifier.build(
      studyId,
    );
  }

  @override
  Override overrideWith(StudyController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<StudyController, StudyControllerState>
      createElement() {
    return _StudyControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyControllerProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyControllerRef
    on AutoDisposeNotifierProviderRef<StudyControllerState> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyController,
        StudyControllerState> with StudyControllerRef {
  _StudyControllerProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyControllerProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
