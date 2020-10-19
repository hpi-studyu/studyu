import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:studyou_core/util/localization.dart';

Future<void> savePDF(BuildContext context, String title, List<pw.Widget> content) async {
  if (kIsWeb) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              elevation: 24,
              title: Text(Nof1Localizations.of(context).translate('save_not_supported')),
              content: Text(Nof1Localizations.of(context).translate('save_not_supported_description')),
            ));
    return;
  }

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

  final dirPath = Platform.isIOS
      ? (await getApplicationDocumentsDirectory()).path
      : await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
  ;

  // TODO: Android, ask for file permissions to save
  try {
    File('$dirPath/${title.replaceAll(' ', '_')}.pdf').writeAsBytesSync(doc.save());
  } on FileSystemException catch (e) {
    print('Probably no file storage permissions ${e.toString()}');
  }

  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            elevation: 24,
            title: Text(Nof1Localizations.of(context).translate('save_finished')),
            content: Platform.isIOS
                ? Text(Nof1Localizations.of(context).translate('save_finished_description_ios'))
                : Text(Nof1Localizations.of(context).translate('save_finished_description')),
          ));
}
