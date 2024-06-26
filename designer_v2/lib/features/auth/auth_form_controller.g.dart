// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authFormControllerHash() =>
    r'b3695b285937d7ae904911290a737e97d3e9553d';

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
  late final AuthFormKey formKeyArg;

  AsyncValue<void> build(
    AuthFormKey formKeyArg,
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
    AuthFormKey formKeyArg,
  ) {
    return AuthFormControllerProvider(
      formKeyArg,
    );
  }

  @override
  AuthFormControllerProvider getProviderOverride(
    covariant AuthFormControllerProvider provider,
  ) {
    return call(
      provider.formKeyArg,
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
    AuthFormKey formKeyArg,
  ) : this._internal(
          () => AuthFormController()..formKeyArg = formKeyArg,
          from: authFormControllerProvider,
          name: r'authFormControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$authFormControllerHash,
          dependencies: AuthFormControllerFamily._dependencies,
          allTransitiveDependencies:
              AuthFormControllerFamily._allTransitiveDependencies,
          formKeyArg: formKeyArg,
        );

  AuthFormControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.formKeyArg,
  }) : super.internal();

  final AuthFormKey formKeyArg;

  @override
  AsyncValue<void> runNotifierBuild(
    covariant AuthFormController notifier,
  ) {
    return notifier.build(
      formKeyArg,
    );
  }

  @override
  Override overrideWith(AuthFormController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AuthFormControllerProvider._internal(
        () => create()..formKeyArg = formKeyArg,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        formKeyArg: formKeyArg,
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
    return other is AuthFormControllerProvider &&
        other.formKeyArg == formKeyArg;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, formKeyArg.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AuthFormControllerRef
    on AutoDisposeNotifierProviderRef<AsyncValue<void>> {
  /// The parameter `formKeyArg` of this provider.
  AuthFormKey get formKeyArg;
}

class _AuthFormControllerProviderElement
    extends AutoDisposeNotifierProviderElement<AuthFormController,
        AsyncValue<void>> with AuthFormControllerRef {
  _AuthFormControllerProviderElement(super.provider);

  @override
  AuthFormKey get formKeyArg =>
      (origin as AuthFormControllerProvider).formKeyArg;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
