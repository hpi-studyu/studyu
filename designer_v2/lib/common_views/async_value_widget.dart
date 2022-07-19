import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Simple wrapper around [AsyncValue] to render standardized loading
/// and error widgets
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({super.key, required this.value,
    required this.data, this.error, this.loading});

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function(Object, StackTrace?)? error;
  final Widget Function()? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: error ?? _defaultError,
      loading: loading ?? _defaultLoad,
    );
  }

  Widget _defaultError(e, st) {
    return Center(child: Text(e.toString()));
  }

  Widget _defaultLoad() {
    return const Center(child: CircularProgressIndicator());
  }
}
