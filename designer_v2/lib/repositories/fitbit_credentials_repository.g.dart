// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_credentials_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fitbitCredentialsRepositoryHash() =>
    r'b8531fc750bbd629e6b2ad8feab93da7082b0ca7';

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

/// See also [fitbitCredentialsRepository].
@ProviderFor(fitbitCredentialsRepository)
const fitbitCredentialsRepositoryProvider = FitbitCredentialsRepositoryFamily();

/// See also [fitbitCredentialsRepository].
class FitbitCredentialsRepositoryFamily
    extends Family<FitbitCredentialsRepository> {
  /// See also [fitbitCredentialsRepository].
  const FitbitCredentialsRepositoryFamily();

  /// See also [fitbitCredentialsRepository].
  FitbitCredentialsRepositoryProvider call(String studyId) {
    return FitbitCredentialsRepositoryProvider(studyId);
  }

  @override
  FitbitCredentialsRepositoryProvider getProviderOverride(
    covariant FitbitCredentialsRepositoryProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fitbitCredentialsRepositoryProvider';
}

/// See also [fitbitCredentialsRepository].
class FitbitCredentialsRepositoryProvider
    extends AutoDisposeProvider<FitbitCredentialsRepository> {
  /// See also [fitbitCredentialsRepository].
  FitbitCredentialsRepositoryProvider(String studyId)
    : this._internal(
        (ref) => fitbitCredentialsRepository(
          ref as FitbitCredentialsRepositoryRef,
          studyId,
        ),
        from: fitbitCredentialsRepositoryProvider,
        name: r'fitbitCredentialsRepositoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fitbitCredentialsRepositoryHash,
        dependencies: FitbitCredentialsRepositoryFamily._dependencies,
        allTransitiveDependencies:
            FitbitCredentialsRepositoryFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  FitbitCredentialsRepositoryProvider._internal(
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
    FitbitCredentialsRepository Function(
      FitbitCredentialsRepositoryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FitbitCredentialsRepositoryProvider._internal(
        (ref) => create(ref as FitbitCredentialsRepositoryRef),
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
  AutoDisposeProviderElement<FitbitCredentialsRepository> createElement() {
    return _FitbitCredentialsRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FitbitCredentialsRepositoryProvider &&
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
mixin FitbitCredentialsRepositoryRef
    on AutoDisposeProviderRef<FitbitCredentialsRepository> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _FitbitCredentialsRepositoryProviderElement
    extends AutoDisposeProviderElement<FitbitCredentialsRepository>
    with FitbitCredentialsRepositoryRef {
  _FitbitCredentialsRepositoryProviderElement(super.provider);

  @override
  String get studyId => (origin as FitbitCredentialsRepositoryProvider).studyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
