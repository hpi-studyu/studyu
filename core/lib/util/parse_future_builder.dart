import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studyou_core/util/retry_future_builder.dart';

typedef ParseQuery = Future<ParseResponse> Function();

class ParseListFutureBuilder<T> extends StatefulWidget {
  final ParseQuery queryFunction;
  final Widget Function(BuildContext context, List<T> results) builder;

  const ParseListFutureBuilder({Key key, @required this.queryFunction, @required this.builder}) : super(key: key);

  @override
  _ParseListFutureBuilderState<T> createState() => _ParseListFutureBuilderState<T>();
}

class _ParseListFutureBuilderState<T> extends State<ParseListFutureBuilder<T>> {
  ParseQuery _tryFunction;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void didUpdateWidget(ParseListFutureBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ATTENTION: This is based on the equality of functions. Not equal, if they are part of different instances
    if (widget.queryFunction != oldWidget.queryFunction) {
      reload();
    }
  }

  void reload() {
    setState(() {
      _tryFunction = () => _parseQuery();
    });
  }

  Future<ParseResponse> _parseQuery() async {
    final response = await widget.queryFunction();
    if (!response.success) throw response.error;
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return RetryFutureBuilder<ParseResponse>(
      key: widget.key,
      tryFunction: _tryFunction,
      successBuilder: (context, response) => widget.builder(context, List<T>.from(response.results ?? [])),
    );
  }
}

// Ideally we would check if T is a List or not and return a List or not.
// Seems not possible currently with dart, so we use a different class for FetchOne queries
class ParseFetchOneFutureBuilder<T> extends StatefulWidget {
  final ParseQuery queryFunction;
  final Widget Function(BuildContext context, T results) builder;

  const ParseFetchOneFutureBuilder({Key key, @required this.queryFunction, @required this.builder}) : super(key: key);

  @override
  _ParseFetchOneFutureBuilderState<T> createState() => _ParseFetchOneFutureBuilderState<T>();
}

class _ParseFetchOneFutureBuilderState<T> extends State<ParseFetchOneFutureBuilder<T>> {
  ParseQuery _tryFunction;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void didUpdateWidget(ParseFetchOneFutureBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ATTENTION: This is based on the equality of functions. Not equal, if they are part of different instances
    if (widget.queryFunction != oldWidget.queryFunction) {
      reload();
    }
  }

  void reload() {
    setState(() {
      _tryFunction = _parseQuery;
    });
  }

  Future<ParseResponse> _parseQuery() async {
    final response = await widget.queryFunction();
    if (!response.success) throw response.error;
    assert(response.count <= 1, 'Use ParseListFutureBuilder if fetching multiple elements.');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return RetryFutureBuilder<ParseResponse>(
        tryFunction: _tryFunction,
        successBuilder: (context, response) =>
            widget.builder(context, response.count == 1 ? response.results.first : null));
  }
}
