import 'package:flutter/material.dart';
import 'package:postgrest/postgrest.dart';
import 'package:studyou_core/util/retry_future_builder.dart';

typedef SupabaseQuery = Future<PostgrestResponse> Function();

class SupabaseListFutureBuilder<T> extends StatefulWidget {
  final SupabaseQuery queryFunction;
  final Widget Function(BuildContext context, List<T> results) builder;
  final List<T> Function(List<Map<String, dynamic>> jsonList) fromJsonConverter;

  const SupabaseListFutureBuilder({
    Key key,
    @required this.queryFunction,
    @required this.builder,
    @required this.fromJsonConverter,
  }) : super(key: key);

  @override
  _SupabaseListFutureBuilderState<T> createState() => _SupabaseListFutureBuilderState<T>();
}

class _SupabaseListFutureBuilderState<T> extends State<SupabaseListFutureBuilder<T>> {
  SupabaseQuery _tryFunction;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void didUpdateWidget(SupabaseListFutureBuilder<T> oldWidget) {
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

  Future<PostgrestResponse> _parseQuery() async {
    final response = await widget.queryFunction();
    // ignore: only_throw_errors
    if (response.error != null) throw response.error.message;
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return RetryFutureBuilder<PostgrestResponse>(
      key: widget.key,
      tryFunction: _tryFunction,
      successBuilder: (context, response) =>
          widget.builder(context, widget.fromJsonConverter(List<Map<String, dynamic>>.from(response.data as List))),
    );
  }
}
