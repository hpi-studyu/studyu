// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_credentials_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fitbitCredentialsFormViewModelHash() =>
    r'd975b7edada5bd981f787fc25f4cdbadada6a79d';

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

/// See also [fitbitCredentialsFormViewModel].
@ProviderFor(fitbitCredentialsFormViewModel)
const fitbitCredentialsFormViewModelProvider =
    FitbitCredentialsFormViewModelFamily();

/// See also [fitbitCredentialsFormViewModel].
class FitbitCredentialsFormViewModelFamily
    extends Family<FitbitCredentialsFormViewModel> {
  /// See also [fitbitCredentialsFormViewModel].
  const FitbitCredentialsFormViewModelFamily();

  /// See also [fitbitCredentialsFormViewModel].
  FitbitCredentialsFormViewModelProvider call(
    String studyId,
  ) {
    return FitbitCredentialsFormViewModelProvider(
      studyId,
    );
  }

  @override
  FitbitCredentialsFormViewModelProvider getProviderOverride(
    covariant FitbitCredentialsFormViewModelProvider provider,
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
  String? get name => r'fitbitCredentialsFormViewModelProvider';
}

/// See also [fitbitCredentialsFormViewModel].
class FitbitCredentialsFormViewModelProvider
    extends AutoDisposeProvider<FitbitCredentialsFormViewModel> {
  /// See also [fitbitCredentialsFormViewModel].
  FitbitCredentialsFormViewModelProvider(
    String studyId,
  ) : this._internal(
          (ref) => fitbitCredentialsFormViewModel(
            ref as FitbitCredentialsFormViewModelRef,
            studyId,
          ),
          from: fitbitCredentialsFormViewModelProvider,
          name: r'fitbitCredentialsFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fitbitCredentialsFormViewModelHash,
          dependencies: FitbitCredentialsFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              FitbitCredentialsFormViewModelFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  FitbitCredentialsFormViewModelProvider._internal(
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
    FitbitCredentialsFormViewModel Function(
            FitbitCredentialsFormViewModelRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FitbitCredentialsFormViewModelProvider._internal(
        (ref) => create(ref as FitbitCredentialsFormViewModelRef),
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
  AutoDisposeProviderElement<FitbitCredentialsFormViewModel> createElement() {
    return _FitbitCredentialsFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FitbitCredentialsFormViewModelProvider &&
        other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FitbitCredentialsFormViewModelRef
    on AutoDisposeProviderRef<FitbitCredentialsFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _FitbitCredentialsFormViewModelProviderElement
    extends AutoDisposeProviderElement<FitbitCredentialsFormViewModel>
    with FitbitCredentialsFormViewModelRef {
  _FitbitCredentialsFormViewModelProviderElement(super.provider);

  @override
  String get studyId =>
      (origin as FitbitCredentialsFormViewModelProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
