// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Main controller that's bound to the top-level application widget's state

@ProviderFor(AppController)
final appControllerProvider = AppControllerProvider._();

/// Main controller that's bound to the top-level application widget's state
final class AppControllerProvider
    extends $StreamNotifierProvider<AppController, AppControllerState> {
  /// Main controller that's bound to the top-level application widget's state
  AppControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appControllerHash();

  @$internal
  @override
  AppController create() => AppController();
}

String _$appControllerHash() => r'4ece292fc998deb62caccfa3e5684cc14d5e86a7';

/// Main controller that's bound to the top-level application widget's state

abstract class _$AppController extends $StreamNotifier<AppControllerState> {
  Stream<AppControllerState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AppControllerState>, AppControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppControllerState>, AppControllerState>,
              AsyncValue<AppControllerState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
