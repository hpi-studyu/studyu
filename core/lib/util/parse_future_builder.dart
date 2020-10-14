import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studyou_core/util/retry_future_builder.dart';

typedef ParseQuery = Future<ParseResponse> Function();

class ParseListFutureBuilder<T> extends StatelessWidget {
  final ParseQuery queryFunction;
  final Widget Function(BuildContext context, List<T> results) builder;

  const ParseListFutureBuilder({Key key, @required this.queryFunction, @required this.builder}) : super(key: key);

  Future<ParseResponse> _parseQuery() async {
    final response = await queryFunction();
    if (!response.success) throw response.error;
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return RetryFutureBuilder<ParseResponse>(
      tryFunction: () => _parseQuery(),
      successBuilder: (context, response) => builder(context, List<T>.from(response.results ?? [])),
    );
  }
}

// Ideally we would check if T is a List or not and return a List or not.
// Seems not possible currently with dart, so we use a different class for FetchOne queries
class ParseFetchOneFutureBuilder<T> extends StatelessWidget {
  final ParseQuery queryFunction;
  final Widget Function(BuildContext context, T results) builder;

  const ParseFetchOneFutureBuilder({Key key, @required this.queryFunction, @required this.builder}) : super(key: key);

  // throw error to be handled by RetryFutureBuilder
  Future<ParseResponse> parseQuery() async {
    final response = await queryFunction();
    if (!response.success) throw response.error;
    assert(response.count <= 1, 'Use ParseListFutureBuilder if fetching multiple elements.');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return RetryFutureBuilder<ParseResponse>(
        tryFunction: parseQuery,
        successBuilder: (context, response) => builder(context, response.count == 1 ? response.results.first : null));
  }
}
