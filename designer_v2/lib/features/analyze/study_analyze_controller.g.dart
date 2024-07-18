// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_analyze_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyAnalyzeControllerHash() =>
    r'0e5869baece418f4dba380541da07b6c3ea457e5';

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
  late final StudyCreationArgs studyCreationArgs;

  StudyAnalyzeControllerState build(
    StudyCreationArgs studyCreationArgs,
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
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyAnalyzeControllerProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyAnalyzeControllerProvider getProviderOverride(
    covariant StudyAnalyzeControllerProvider provider,
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
  String? get name => r'studyAnalyzeControllerProvider';
}

/// See also [StudyAnalyzeController].
class StudyAnalyzeControllerProvider extends AutoDisposeNotifierProviderImpl<
    StudyAnalyzeController, StudyAnalyzeControllerState> {
  /// See also [StudyAnalyzeController].
  StudyAnalyzeControllerProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          () => StudyAnalyzeController()..studyCreationArgs = studyCreationArgs,
          from: studyAnalyzeControllerProvider,
          name: r'studyAnalyzeControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyAnalyzeControllerHash,
          dependencies: StudyAnalyzeControllerFamily._dependencies,
          allTransitiveDependencies:
              StudyAnalyzeControllerFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyAnalyzeControllerProvider._internal(
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
  StudyAnalyzeControllerState runNotifierBuild(
    covariant StudyAnalyzeController notifier,
  ) {
    return notifier.build(
      studyCreationArgs,
    );
  }

  @override
  Override overrideWith(StudyAnalyzeController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudyAnalyzeControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<StudyAnalyzeController,
      StudyAnalyzeControllerState> createElement() {
    return _StudyAnalyzeControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyAnalyzeControllerProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyAnalyzeControllerRef
    on AutoDisposeNotifierProviderRef<StudyAnalyzeControllerState> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyAnalyzeControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StudyAnalyzeController,
        StudyAnalyzeControllerState> with StudyAnalyzeControllerRef {
  _StudyAnalyzeControllerProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyAnalyzeControllerProvider).studyCreationArgs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
