/*
MIT License

Copyright (c) 2020 Tom Beckmann <tom@4ed1.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import 'package:flutter/material.dart';

typedef CustomErrorWidgetBuilder = dynamic Function(BuildContext context, dynamic error);

class RetryableFutureBuilder<T> extends StatefulWidget {
  static RetryableFutureBuilderState of(BuildContext context) =>
      context.findAncestorStateOfType<RetryableFutureBuilderState>();

  final Future<T> Function() tryFunction;
  final Widget Function(BuildContext, T) onSuccess;

  /// a value to show immediately, before evaluating [tryFunction]
  final T initialData;
  final Widget Function(BuildContext) loadingBuilder;

  /// error handler function that gets to handle the error
  /// and return a widget to be displayed instead.
  /// return [null] to revert to default behavior
  final CustomErrorWidgetBuilder errorWidgetBuilder;
  final List<Widget> extraWidgets;

  RetryableFutureBuilder({
    Key key,
    @required this.tryFunction,
    @required this.onSuccess,
    this.initialData,
    this.loadingBuilder,
    this.errorWidgetBuilder,
    this.extraWidgets = const [],
  }) : super(key: key);

  @override
  State<RetryableFutureBuilder<T>> createState() => RetryableFutureBuilderState<T>();
}

class RetryableFutureBuilderState<T> extends State<RetryableFutureBuilder<T>> {
  Future<T> _future;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    setState(() {
      _future = widget.tryFunction();
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
        key: widget.key,
        initialData: widget.initialData,
        future: _future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasError) {
                if (widget.errorWidgetBuilder != null) {
                  final errorWidget = widget.errorWidgetBuilder(context, snapshot.error);
                  if (errorWidget != null) return errorWidget;
                }
                return buildErrorView(snapshot.error);
              }
              return widget.onSuccess(context, snapshot.data);
            default:
              return widget.loadingBuilder != null
                  ? widget.loadingBuilder(context)
                  : Center(child: CircularProgressIndicator());
          }
        },
      );

  Widget buildErrorView(Object error) => ErrorPage(error: error, detailTextAlign: TextAlign.center, extraWidgets: [
        Container(
          child: QuerdenkerTheme.roundedOutlineButton(
            context,
            color: Colors.white,
            onPressed: () => setState(() {
              _future = (widget.tryFunction)();
            }),
            label: 'Erneut versuchen',
          ),
          width: double.infinity,
        ),
        ...widget.extraWidgets
      ]);
}
