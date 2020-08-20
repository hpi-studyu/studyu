import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'localization.dart';

Future<void> pdfDownload(BuildContext context, String title, List<pw.Widget> content) async {
  final doc = pw.Document();
  final _logo = PdfImage.file(
    doc.document,
    bytes: (await rootBundle.load('assets/images/icon_wide.png')).buffer.asUint8List(),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Image(_logo, height: 30),
      ),
      build: (context) => content,
    ),
  );

  // TODO maybe replace discontinued DownloadsPathProvider
  final dir =
      Platform.isIOS ? await getApplicationDocumentsDirectory() : await DownloadsPathProvider.downloadsDirectory;

  File('${dir.path}/${title.replaceAll(' ', '_')}.pdf').writeAsBytesSync(doc.save());
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            elevation: 24,
            title: Text(Nof1Localizations.of(context).translate('download_finished')),
            content: Text(Nof1Localizations.of(context).translate('download_finished_description')),
          ));
}
