import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:web/web.dart' as web;

class QrCodeDownloader {
  QrCodeDownloader._();

  static Future<void> downloadQrCode({
    required String data,
    required String filename,
    int size = 512,
  }) async {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    final qrImage = QrImage(qrCode);

    final logoBytes = await rootBundle.load('assets/icon/icon.png');
    final logoData = logoBytes.buffer.asUint8List();

    final qrImageBytes = await qrImage.toImageAsBytes(
      size: size,
      decoration: PrettyQrDecoration(
        background: Colors.white,
        image: PrettyQrDecorationImage(image: MemoryImage(logoData)),
      ),
    );

    if (qrImageBytes == null) {
      throw Exception('Failed to generate QR code image');
    }

    final blob = web.Blob(
      [qrImageBytes.buffer.asUint8List().toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = '$filename.png';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
