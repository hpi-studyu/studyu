enum AppErrorTypes {
  network,
  unknown,
}

class AppError {
  final AppErrorTypes type;
  final String message;

  AppError(this.type, this.message);
}
