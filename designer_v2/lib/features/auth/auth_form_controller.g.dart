// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authFormControllerHash() =>
    r'536f61faf22e316334e07415d09389bff1c76b45';

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

abstract class _$AuthFormController
    extends BuildlessAutoDisposeNotifier<AsyncValue<void>> {
  late final AuthFormKey formKey;

  AsyncValue<void> build(
    AuthFormKey formKey,
  );
}

/// See also [AuthFormController].
@ProviderFor(AuthFormController)
const authFormControllerProvider = AuthFormControllerFamily();

/// See also [AuthFormController].
class AuthFormControllerFamily extends Family<AsyncValue<void>> {
  /// See also [AuthFormController].
  const AuthFormControllerFamily();

  /// See also [AuthFormController].
  AuthFormControllerProvider call(
    AuthFormKey formKey,
  ) {
    return AuthFormControllerProvider(
      formKey,
    );
  }

  @override
  AuthFormControllerProvider getProviderOverride(
    covariant AuthFormControllerProvider provider,
  ) {
    return call(
      provider.formKey,
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
  String? get name => r'authFormControllerProvider';
}

/// See also [AuthFormController].
class AuthFormControllerProvider extends AutoDisposeNotifierProviderImpl<
    AuthFormController, AsyncValue<void>> {
  /// See also [AuthFormController].
  AuthFormControllerProvider(
    AuthFormKey formKey,
  ) : this._internal(
          () => AuthFormController()..formKey = formKey,
          from: authFormControllerProvider,
          name: r'authFormControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$authFormControllerHash,
          dependencies: AuthFormControllerFamily._dependencies,
          allTransitiveDependencies:
              AuthFormControllerFamily._allTransitiveDependencies,
          formKey: formKey,
        );

  AuthFormControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.formKey,
  }) : super.internal();

  final AuthFormKey formKey;

  @override
  AsyncValue<void> runNotifierBuild(
    covariant AuthFormController notifier,
  ) {
    return notifier.build(
      formKey,
    );
  }

  @override
  Override overrideWith(AuthFormController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AuthFormControllerProvider._internal(
        () => create()..formKey = formKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        formKey: formKey,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AuthFormController, AsyncValue<void>>
      createElement() {
    return _AuthFormControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthFormControllerProvider && other.formKey == formKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, formKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AuthFormControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<void>> {
  /// The parameter `formKey` of this provider.
  AuthFormKey get formKey;
}

class _AuthFormControllerProviderElement
    extends AutoDisposeNotifierProviderElement<AuthFormController,
        AsyncValue<void>> with AuthFormControllerRef {
  _AuthFormControllerProviderElement(super.provider);

  @override
  AuthFormKey get formKey => (origin as AuthFormControllerProvider).formKey;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
