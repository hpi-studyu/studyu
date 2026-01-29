// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocaleStateNotifier)
final localeStateProvider = LocaleStateNotifierProvider._();

final class LocaleStateNotifierProvider
    extends $NotifierProvider<LocaleStateNotifier, LocaleState> {
  LocaleStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeStateNotifierHash();

  @$internal
  @override
  LocaleStateNotifier create() => LocaleStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocaleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocaleState>(value),
    );
  }
}

String _$localeStateNotifierHash() =>
    r'b46bc9c75e031b5fb7fea260827e94ca4522bd2f';

abstract class _$LocaleStateNotifier extends $Notifier<LocaleState> {
  LocaleState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LocaleState, LocaleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocaleState, LocaleState>,
              LocaleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
