import 'package:flutter/material.dart';
import 'package:studyu_designer/util/storage_helper.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:webviewx/webviewx.dart';

class JupyterAnalysisBoard extends StatelessWidget {
  final String studyId;
  final String notebook;

  const JupyterAnalysisBoard({
    @required this.studyId,
    @required this.notebook,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notebook.replaceAll(RegExp(r'\.\w*$'), '')),
      ),
      body: RetryFutureBuilder<String>(
        tryFunction: () => downloadFromStorage('$studyId/$notebook'),
        successBuilder: (context, notebookHtml) => WebViewX(
          initialContent: notebookHtml,
          initialSourceType: SourceType.HTML,
        ),
      ),
    );
  }
}
