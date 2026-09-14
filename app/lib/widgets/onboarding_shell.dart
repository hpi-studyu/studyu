import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/loading_overlay.dart';

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
  final String? loadingMessage;

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
    this.loadingMessage,
  });

  BottomOnboardingNavigation build() => BottomOnboardingNavigation(
    onBack: onBack,
    onNext: onNext,
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
  );

  OnboardingNavConfig disabled() => OnboardingNavConfig(
    backLabel: backLabel,
    nextLabel: nextLabel,
    hideNext: hideNext,
    hideBack: hideBack,
    backEnabled: false,
    nextIcon: nextIcon,
    backIcon: backIcon,
    progress: progress,
    backButtonKey: backButtonKey,
    nextButtonKey: nextButtonKey,
  );
}

class _OnboardingNavController extends ChangeNotifier {
  String routePath;
  OnboardingNavConfig? config;
  Object? _owner;
  bool _disposed = false;

  _OnboardingNavController(this.routePath);

  void activateRoute(String routePath) {
    if (this.routePath == routePath) return;
    this.routePath = routePath;
    _owner = null;
    config = config?.disabled();
  }

  bool claim(Object owner, String routePath) {
    if (_disposed || this.routePath != routePath) return false;
    _owner = owner;
    return true;
  }

  void update(Object owner, String routePath, OnboardingNavConfig config) {
    if (_disposed || this.routePath != routePath || !identical(_owner, owner)) {
      return;
    }
    this.config = config;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class OnboardingNavNotifier extends InheritedWidget {
  final _OnboardingNavController _controller;

  const OnboardingNavNotifier({
    required _OnboardingNavController controller,
    required super.child,
  }) : _controller = controller;

  static OnboardingNavNotifier? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<OnboardingNavNotifier>();

  void register(Object owner, String routePath, OnboardingNavConfig config) {
    if (!_controller.claim(owner, routePath)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.update(owner, routePath, config);
    });
  }

  @override
  bool updateShouldNotify(OnboardingNavNotifier oldWidget) => false;
}

class OnboardingShell extends StatefulWidget {
  final String routePath;
  final Widget child;

  const OnboardingShell({
    required this.routePath,
    required this.child,
    super.key,
  });

  @override
  State<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends State<OnboardingShell> {
  late final _controller = _OnboardingNavController(widget.routePath);

  @override
  void didUpdateWidget(OnboardingShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.activateRoute(widget.routePath);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingNavNotifier(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final config = _controller.config;
          return Stack(
            children: [
              Scaffold(
                body: widget.child,
                bottomNavigationBar:
                    config?.build() ??
                    const BottomOnboardingNavigation(
                      hideBack: true,
                      hideNext: true,
                    ),
              ),
              if (config?.loadingMessage != null)
                Positioned.fill(
                  child: LoadingOverlay(message: config!.loadingMessage!),
                ),
            ],
          );
        },
      ),
    );
  }
}
