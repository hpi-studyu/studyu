import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> savePDF(BuildContext context, String title, List<pw.Widget> content) async {
  if (kIsWeb) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 24,
        title: Text(AppLocalizations.of(context).save_not_supported),
        content: Text(AppLocalizations.of(context).save_not_supported_description),
      ),
    );
    return;
  }

  final doc = pw.Document();
  final _logo = pw.MemoryImage((await rootBundle.load('assets/images/icon_wide.png')).buffer.asUint8List());
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Image(_logo, height: 30),
      ),
      build: (context) => content,
    ),
  );

  try {
    final savedDoc = await doc.save();

    final pdfFileName = '${title.replaceAll(' ', '_')}.pdf';

    final params = SaveFileDialogParams(data: savedDoc, fileName: pdfFileName);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    print('$pdfFileName was saved under $filePath.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppLocalizations.of(context).was_saved_to}${filePath.split(':')[1]}.'),
      ),
    );
  } catch (e) {
    print('Error saving file with FileDialog ${e.toString()}');
  }
}
