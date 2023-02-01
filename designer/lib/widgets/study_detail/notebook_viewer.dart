import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_designer/util/storage_helper.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NotebookViewer extends StatelessWidget {
  final String studyId;
  final String notebook;

  const NotebookViewer({
    @required this.studyId,
    @required this.notebook,
    Key key,
  }) : super(key: key);

  Future<void> _loadHTML(WebViewController con, String html) async {
    con.loadUrl(
      Uri.dataFromString(
        html,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ).toString(),
    );
  }

  Widget _buildWebView(String html) {
    return WebView(
      onWebViewCreated: (WebViewController webViewController) {
        _loadHTML(webViewController, html);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  leading: const BackButton(),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(MdiIcons.notebook, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        notebook.replaceAll(RegExp(r'\.\w*$'), ''),
                        style: theme.textTheme.titleLarge.copyWith(color: theme.colorScheme.secondary),
                      ),
                      // VerticalDivider(indent: 8, endIndent: 8),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: RetryFutureBuilder<String>(
                tryFunction: () => downloadFromStorage('$studyId/$notebook'),
                successBuilder: (context, notebookHtml) => LayoutBuilder(
                  builder: (context, constraints) => _buildWebView(notebookHtml),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
