// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_settings_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studySettingsFormViewModelHash() =>
    r'499d2fa25006ac8781e60bcd208a2cb6c05cacb9';

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
    String studyId,
  ) {
    return StudySettingsFormViewModelProvider(
      studyId,
    );
  }

  @override
  StudySettingsFormViewModelProvider getProviderOverride(
    covariant StudySettingsFormViewModelProvider provider,
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
    String studyId,
  ) : this._internal(
          (ref) => studySettingsFormViewModel(
            ref as StudySettingsFormViewModelRef,
            studyId,
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
          studyId: studyId,
        );

  StudySettingsFormViewModelProvider._internal(
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
        studyId: studyId,
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
        other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudySettingsFormViewModelRef
    on AutoDisposeProviderRef<StudySettingsFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudySettingsFormViewModelProviderElement
    extends AutoDisposeProviderElement<StudySettingsFormViewModel>
    with StudySettingsFormViewModelRef {
  _StudySettingsFormViewModelProviderElement(super.provider);

  @override
  String get studyId => (origin as StudySettingsFormViewModelProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
