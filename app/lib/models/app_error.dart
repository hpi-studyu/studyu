enum AppErrorTypes {
  retrieveSubject,
  storeSubject,
  network,
  notification,
  unknown,
}

class ErrorAction {
  final String actionText;
  final String? actionDescription;
  final Future<void> Function() callback;

  ErrorAction(this.actionText, this.callback, {this.actionDescription});
}

class AppError {
  final AppErrorTypes type;
  final String message;
  final List<ErrorAction>? actions;

  AppError(this.type, this.message, {this.actions});

  @override
  String toString() {
    return '$message, type: $type';
  }
}
