// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyFormViewModelHash() =>
    r'd4b4a58fa4ac4175e7be5ed20ae7da305618c0e5';

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

/// Provides the [FormViewModel] that is responsible for displaying and
/// editing the study design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [studyFormViewModel].
@ProviderFor(studyFormViewModel)
const studyFormViewModelProvider = StudyFormViewModelFamily();

/// Provides the [FormViewModel] that is responsible for displaying and
/// editing the study design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [studyFormViewModel].
class StudyFormViewModelFamily extends Family<StudyFormViewModel> {
  /// Provides the [FormViewModel] that is responsible for displaying and
  /// editing the study design form.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [studyFormViewModel].
  const StudyFormViewModelFamily();

  /// Provides the [FormViewModel] that is responsible for displaying and
  /// editing the study design form.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [studyFormViewModel].
  StudyFormViewModelProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyFormViewModelProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyFormViewModelProvider getProviderOverride(
    covariant StudyFormViewModelProvider provider,
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
  String? get name => r'studyFormViewModelProvider';
}

/// Provides the [FormViewModel] that is responsible for displaying and
/// editing the study design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [studyFormViewModel].
class StudyFormViewModelProvider
    extends AutoDisposeProvider<StudyFormViewModel> {
  /// Provides the [FormViewModel] that is responsible for displaying and
  /// editing the study design form.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [studyFormViewModel].
  StudyFormViewModelProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => studyFormViewModel(
            ref as StudyFormViewModelRef,
            studyCreationArgs,
          ),
          from: studyFormViewModelProvider,
          name: r'studyFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyFormViewModelHash,
          dependencies: StudyFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              StudyFormViewModelFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyFormViewModelProvider._internal(
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
    StudyFormViewModel Function(StudyFormViewModelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudyFormViewModelProvider._internal(
        (ref) => create(ref as StudyFormViewModelRef),
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
  AutoDisposeProviderElement<StudyFormViewModel> createElement() {
    return _StudyFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyFormViewModelProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyFormViewModelRef on AutoDisposeProviderRef<StudyFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyFormViewModelProviderElement
    extends AutoDisposeProviderElement<StudyFormViewModel>
    with StudyFormViewModelRef {
  _StudyFormViewModelProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyFormViewModelProvider).studyCreationArgs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
