import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

typedef VoidAsyncValue = AsyncValue<String>;

extension AsyncValueUI on VoidAsyncValue {
  bool get isLoading => this is AsyncLoading<void>;

  void showResultUI(BuildContext context) =>
      whenOrNull(
        // success
        data: (successMessage) {
          if (successMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Success: $successMessage'.hardcoded)),
            );
          }
        },
        // error
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error'.hardcoded)),
          );
        },
      );
}