import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<String?> savePDF(
    BuildContext context, String title, List<pw.Widget> content) async {
  final doc = pw.Document();
  final logo = pw.MemoryImage(
      (await rootBundle.load('assets/icon/logo.png')).buffer.asUint8List());
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Image(logo, height: 30),
      ),
      build: (context) => content,
    ),
  );

  try {
    final savedDoc = await doc.save();

    final pdfFileName = '${title.replaceAll(' ', '_')}.pdf';

    final params = SaveFileDialogParams(data: savedDoc, fileName: pdfFileName);
    final filePath = (await FlutterFileDialog.saveFile(params: params))!;
    print('$pdfFileName was saved under $filePath.');

    return filePath.split(':')[1];
  } catch (e) {
    print('Error saving file with FileDialog $e');
    return null;
  }
}
