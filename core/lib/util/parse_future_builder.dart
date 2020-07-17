import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:studyou_core/util/retry_future_builder.dart';

typedef ParseQuery = Future<ParseResponse> Function();

class ParseFutureBuilder<T> extends StatelessWidget {
  final ParseQuery queryFunction;
  final Widget Function(BuildContext context, List<T> results) builder;

  const ParseFutureBuilder({Key key, @required this.queryFunction, @required this.builder}) : super(key: key);

  // throw error to be handled by RetryFutureBuilder
  Future<ParseResponse> parseQuery() async {
    final response = await queryFunction();
    if (!response.success) throw response.error;
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return RetryFutureBuilder<ParseResponse>(
      tryFunction: parseQuery,
      successBuilder: (context, response) => builder(context, List<T>.from(response.results ?? [])),
    );
  }
}
