/// The type definition for a JSON-serializable
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

typedef VoidCallback = void Function();
typedef VoidCallbackOn<T> = void Function(T target);

typedef FutureFactory<T> = Future<T> Function();
