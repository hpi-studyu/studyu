import 'package:equatable/equatable.dart';

enum AppStatus { initializing, initialized }

class AppControllerState extends Equatable {
  const AppControllerState({
    this.status = AppStatus.initializing,
  });

  final AppStatus status;

  get isInitialized => status == AppStatus.initialized;

  @override
  List<Object?> get props => [status];
}
