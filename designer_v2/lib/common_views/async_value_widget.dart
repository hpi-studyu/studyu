import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple wrapper around [AsyncValue] to render standardized
/// widgets for different states (loading, error, empty)
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({super.key, required this.value,
    required this.data, this.error, this.loading, this.empty});

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function(Object, StackTrace?)? error;
  final Widget Function()? loading;
  final Widget Function()? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: _buildDataOrEmptyWidget,
      error: error ?? _defaultError,
      loading: loading ?? _defaultLoad,
    );
  }

  /// Renders the [data] widget, or falls back to the [empty] widget
  /// (if any & needed)
  Widget _buildDataOrEmptyWidget(T unwrappedData) {
    if (empty == null) {
      // Always render data widget if no empty state specified
      return data(unwrappedData);
    }
    if (unwrappedData == null ||
        (unwrappedData is List && unwrappedData.isEmpty)) {
      return empty!();
    }
    return data(unwrappedData);
  }

  Widget _defaultError(e, st) {
    return Center(child: Text(e.toString()));
  }

  Widget _defaultLoad() {
    return const Center(child: CircularProgressIndicator());
  }
}
