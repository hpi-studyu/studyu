// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inviteCodeFormViewModelHash() =>
    r'a7e83058dad45cd50142d9430f3c8907b5653c99';

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

/// Provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [inviteCodeFormViewModel].
@ProviderFor(inviteCodeFormViewModel)
const inviteCodeFormViewModelProvider = InviteCodeFormViewModelFamily();

/// Provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [inviteCodeFormViewModel].
class InviteCodeFormViewModelFamily extends Family<InviteCodeFormViewModel> {
  /// Provide a controller parametrized by [StudyID]
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [inviteCodeFormViewModel].
  const InviteCodeFormViewModelFamily();

  /// Provide a controller parametrized by [StudyID]
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [inviteCodeFormViewModel].
  InviteCodeFormViewModelProvider call(
    String studyId,
  ) {
    return InviteCodeFormViewModelProvider(
      studyId,
    );
  }

  @override
  InviteCodeFormViewModelProvider getProviderOverride(
    covariant InviteCodeFormViewModelProvider provider,
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
  String? get name => r'inviteCodeFormViewModelProvider';
}

/// Provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
///
/// Copied from [inviteCodeFormViewModel].
class InviteCodeFormViewModelProvider
    extends AutoDisposeProvider<InviteCodeFormViewModel> {
  /// Provide a controller parametrized by [StudyID]
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  ///
  /// Copied from [inviteCodeFormViewModel].
  InviteCodeFormViewModelProvider(
    String studyId,
  ) : this._internal(
          (ref) => inviteCodeFormViewModel(
            ref as InviteCodeFormViewModelRef,
            studyId,
          ),
          from: inviteCodeFormViewModelProvider,
          name: r'inviteCodeFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inviteCodeFormViewModelHash,
          dependencies: InviteCodeFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              InviteCodeFormViewModelFamily._allTransitiveDependencies,
          studyId: studyId,
        );

  InviteCodeFormViewModelProvider._internal(
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
    InviteCodeFormViewModel Function(InviteCodeFormViewModelRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InviteCodeFormViewModelProvider._internal(
        (ref) => create(ref as InviteCodeFormViewModelRef),
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
  AutoDisposeProviderElement<InviteCodeFormViewModel> createElement() {
    return _InviteCodeFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InviteCodeFormViewModelProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InviteCodeFormViewModelRef
    on AutoDisposeProviderRef<InviteCodeFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _InviteCodeFormViewModelProviderElement
    extends AutoDisposeProviderElement<InviteCodeFormViewModel>
    with InviteCodeFormViewModelRef {
  _InviteCodeFormViewModelProviderElement(super.provider);

  @override
  String get studyId => (origin as InviteCodeFormViewModelProvider).studyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
