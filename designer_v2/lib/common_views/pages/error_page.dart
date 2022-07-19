import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/navigation_service.dart';

class ErrorPage extends ConsumerWidget {
  final Exception? error;

  const ErrorPage({required this.error, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.read(navigationServiceProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText(error.toString()),
          TextButton(
            onPressed: () => navigationService.goToDashboard(),
            child: Text('Go back home'.hardcoded),
          ),
        ],
      ),
    );
  }
}
