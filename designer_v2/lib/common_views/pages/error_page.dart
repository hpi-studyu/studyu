import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class ErrorPage extends ConsumerWidget {
  final Exception? error;

  const ErrorPage({required this.error, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText(error.toString()),
          TextButton(
            onPressed: () => ref.read(routerProvider).dispatch(
                RoutingIntents.studies),
            child: Text('Go back home'.hardcoded),
          ),
        ],
      ),
    );
  }
}
