import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/loading_overlay.dart';

/// Immutable configuration for the persistent onboarding bottom-nav bar.
///
/// Built by each onboarding page and pushed to [OnboardingNavNotifier] when
/// the page is hosted inside an [OnboardingShell]. Pages that are used
/// outside the shell (e.g. direct widget tests) ignore this entirely and
/// render their own [BottomOnboardingNavigation] as before.
class OnboardingNavConfig {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? backLabel;
  final String? nextLabel;
  final bool hideNext;
  final bool hideBack;
  final bool backEnabled;
  final Icon? nextIcon;
  final Icon? backIcon;
  final Widget? progress;
  final Key? backButtonKey;
  final Key? nextButtonKey;

  /// When true the shell overlays a full-screen [LoadingOverlay] and disables
  /// the nav buttons, matching the scrim behaviour of the old per-screen Stack.
  final bool isLoading;
  final String loadingMessage;

  const OnboardingNavConfig({
    this.onBack,
    this.onNext,
    this.backLabel,
    this.nextLabel,
    this.hideNext = false,
    this.hideBack = false,
    this.backEnabled = true,
    this.nextIcon,
    this.backIcon,
    this.progress,
    this.backButtonKey,
    this.nextButtonKey,
    this.isLoading = false,
    this.loadingMessage = '',
  });

  /// Derives a config from a [BottomOnboardingNavigation] widget so callers
  /// do not have to duplicate their parameter lists.
  factory OnboardingNavConfig.fromNav(BottomOnboardingNavigation nav) =>
      OnboardingNavConfig(
        onBack: nav.onBack,
        onNext: nav.onNext,
        backLabel: nav.backLabel,
        nextLabel: nav.nextLabel,
        hideNext: nav.hideNext,
        hideBack: nav.hideBack,
        backEnabled: nav.backEnabled,
        nextIcon: nav.nextIcon,
        backIcon: nav.backIcon,
        progress: nav.progress,
        backButtonKey: nav.backButtonKey,
        nextButtonKey: nav.nextButtonKey,
      );

  OnboardingNavConfig copyWith({
    bool? isLoading,
    String? loadingMessage,
    VoidCallback? onNext,
    VoidCallback? onBack,
  }) => OnboardingNavConfig(
    onBack: onBack ?? this.onBack,
    onNext: onNext ?? this.onNext,
    backLabel: backLabel,
    nextLabel: nextLabel,
    hideNext: hideNext,
    hideBack: hideBack,
    backEnabled: backEnabled,
    nextIcon: nextIcon,
    backIcon: backIcon,
    progress: progress,
    backButtonKey: backButtonKey,
    nextButtonKey: nextButtonKey,
    isLoading: isLoading ?? this.isLoading,
    loadingMessage: loadingMessage ?? this.loadingMessage,
  );
}

/// Holds the [OnboardingNavConfig] for the currently active onboarding page.
///
/// Lives inside [OnboardingShell]. Child pages call [setConfig] (via
/// [WidgetsBinding.addPostFrameCallback]) to push their nav config up. The
/// shell reads the config and renders [BottomOnboardingNavigation].
class OnboardingNavNotifier extends ChangeNotifier {
  // Start with all buttons hidden until the first child page registers.
  OnboardingNavConfig _config = const OnboardingNavConfig(
    hideBack: true,
    hideNext: true,
  );

  OnboardingNavConfig get config => _config;

  /// Updates the nav bar for the active page.
  /// Safe to call from [WidgetsBinding.addPostFrameCallback].
  void setConfig(OnboardingNavConfig config) {
    _config = config;
    notifyListeners();
  }

  /// Returns the [OnboardingNavNotifier] if [context] is inside an
  /// [OnboardingShell], otherwise null (e.g. in isolated widget tests).
  static OnboardingNavNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OnboardingShellScope>()
        ?.notifier;
  }
}

/// Persistent scaffold shell for the study-onboarding flow.
///
/// [BottomOnboardingNavigation] is mounted here and stays alive while the
/// GoRouter child page changes via [ShellRoute]. Each child page pushes its
/// own [OnboardingNavConfig] via [OnboardingNavNotifier] so the shell can
/// render the correct back/next callbacks and progress widget.
///
/// Pages used outside this shell (direct widget tests, standalone routes)
/// fall back to rendering their own [BottomOnboardingNavigation] when
/// [OnboardingNavNotifier.maybeOf] returns null.
class OnboardingShell extends StatefulWidget {
  final Widget child;

  const OnboardingShell({required this.child, super.key});

  @override
  State<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends State<OnboardingShell> {
  late final OnboardingNavNotifier _navNotifier;

  @override
  void initState() {
    super.initState();
    _navNotifier = OnboardingNavNotifier();
  }

  @override
  void dispose() {
    _navNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingShellScope(
      notifier: _navNotifier,
      // Pass widget.child as the stable `child` arg so ListenableBuilder does
      // not rebuild the page subtree when only the nav config changes.
      child: ListenableBuilder(
        listenable: _navNotifier,
        child: widget.child,
        builder: (context, child) {
          final c = _navNotifier.config;
          return Stack(
            children: [
              Scaffold(
                body: child,
                bottomNavigationBar: BottomOnboardingNavigation(
                  onBack: c.isLoading ? null : c.onBack,
                  onNext: c.isLoading ? null : c.onNext,
                  backLabel: c.backLabel,
                  nextLabel: c.nextLabel,
                  hideNext: c.hideNext,
                  hideBack: c.hideBack,
                  backEnabled: !c.isLoading && c.backEnabled,
                  nextIcon: c.nextIcon,
                  backIcon: c.backIcon,
                  progress: c.progress,
                  backButtonKey: c.backButtonKey,
                  nextButtonKey: c.nextButtonKey,
                ),
              ),
              // Full-screen overlay: covers AppBar and bottom nav, which a
              // child-Scaffold-level Stack cannot do.
              if (c.isLoading) LoadingOverlay(message: c.loadingMessage),
            ],
          );
        },
      ),
    );
  }
}

/// InheritedWidget that makes [OnboardingNavNotifier] discoverable via
/// [OnboardingNavNotifier.maybeOf] without requiring Provider.
class _OnboardingShellScope extends InheritedWidget {
  final OnboardingNavNotifier notifier;

  const _OnboardingShellScope({
    required this.notifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(_OnboardingShellScope old) =>
      old.notifier != notifier;
}
