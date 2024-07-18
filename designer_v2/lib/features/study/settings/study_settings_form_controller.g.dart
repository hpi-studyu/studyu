// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_settings_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studySettingsFormViewModelHash() =>
    r'49bf4787baf59f2130a9dac7d635c86868b3db72';

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

/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [studySettingsFormViewModel].
@ProviderFor(studySettingsFormViewModel)
const studySettingsFormViewModelProvider = StudySettingsFormViewModelFamily();

/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [studySettingsFormViewModel].
class StudySettingsFormViewModelFamily
    extends Family<StudySettingsFormViewModel> {
  /// Provides the [FormViewModel] responsible for managing the study settings.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [studySettingsFormViewModel].
  const StudySettingsFormViewModelFamily();

  /// Provides the [FormViewModel] responsible for managing the study settings.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [studySettingsFormViewModel].
  StudySettingsFormViewModelProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudySettingsFormViewModelProvider(
      studyCreationArgs,
    );
  }

  @override
  StudySettingsFormViewModelProvider getProviderOverride(
    covariant StudySettingsFormViewModelProvider provider,
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
  String? get name => r'studySettingsFormViewModelProvider';
}

/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [studySettingsFormViewModel].
class StudySettingsFormViewModelProvider
    extends AutoDisposeProvider<StudySettingsFormViewModel> {
  /// Provides the [FormViewModel] responsible for managing the study settings.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [studySettingsFormViewModel].
  StudySettingsFormViewModelProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => studySettingsFormViewModel(
            ref as StudySettingsFormViewModelRef,
            studyCreationArgs,
          ),
          from: studySettingsFormViewModelProvider,
          name: r'studySettingsFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studySettingsFormViewModelHash,
          dependencies: StudySettingsFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              StudySettingsFormViewModelFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudySettingsFormViewModelProvider._internal(
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
    StudySettingsFormViewModel Function(StudySettingsFormViewModelRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudySettingsFormViewModelProvider._internal(
        (ref) => create(ref as StudySettingsFormViewModelRef),
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
  AutoDisposeProviderElement<StudySettingsFormViewModel> createElement() {
    return _StudySettingsFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudySettingsFormViewModelProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudySettingsFormViewModelRef
    on AutoDisposeProviderRef<StudySettingsFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudySettingsFormViewModelProviderElement
    extends AutoDisposeProviderElement<StudySettingsFormViewModel>
    with StudySettingsFormViewModelRef {
  _StudySettingsFormViewModelProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudySettingsFormViewModelProvider).studyCreationArgs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
