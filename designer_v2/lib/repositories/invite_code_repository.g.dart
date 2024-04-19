// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inviteCodeRepositoryHash() =>
    r'6e64d53ba64268495919cd6dc28d55ee5fa1e5e8';

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

/// See also [inviteCodeRepository].
@ProviderFor(inviteCodeRepository)
const inviteCodeRepositoryProvider = InviteCodeRepositoryFamily();

/// See also [inviteCodeRepository].
class InviteCodeRepositoryFamily extends Family<InviteCodeRepository> {
  /// See also [inviteCodeRepository].
  const InviteCodeRepositoryFamily();

  /// See also [inviteCodeRepository].
  InviteCodeRepositoryProvider call(
    String studyId,
  ) {
    return InviteCodeRepositoryProvider(
      studyId,
    );
  }

  @override
  InviteCodeRepositoryProvider getProviderOverride(
    covariant InviteCodeRepositoryProvider provider,
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
  String? get name => r'inviteCodeRepositoryProvider';
}

/// See also [inviteCodeRepository].
class InviteCodeRepositoryProvider
    extends AutoDisposeProvider<InviteCodeRepository> {
  /// See also [inviteCodeRepository].
  InviteCodeRepositoryProvider(
    String studyId,
  ) : this._internal(
          (ref) => inviteCodeRepository(
            ref as InviteCodeRepositoryRef,
            studyId,
          ),
          from: inviteCodeRepositoryProvider,
          name: r'inviteCodeRepositoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inviteCodeRepositoryHash,
          dependencies: InviteCodeRepositoryFamily._dependencies,
          allTransitiveDependencies:
              InviteCodeRepositoryFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  InviteCodeRepositoryProvider._internal(
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
    InviteCodeRepository Function(InviteCodeRepositoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InviteCodeRepositoryProvider._internal(
        (ref) => create(ref as InviteCodeRepositoryRef),
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
  AutoDisposeProviderElement<InviteCodeRepository> createElement() {
    return _InviteCodeRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InviteCodeRepositoryProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InviteCodeRepositoryRef on AutoDisposeProviderRef<InviteCodeRepository> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _InviteCodeRepositoryProviderElement
    extends AutoDisposeProviderElement<InviteCodeRepository>
    with InviteCodeRepositoryRef {
  _InviteCodeRepositoryProviderElement(super.provider);

  @override
  String get studyId => (origin as InviteCodeRepositoryProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
