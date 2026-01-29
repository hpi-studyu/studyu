import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:studyu_core/core.dart' as core;
import 'package:studyu_core/core.dart';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:qr/qr.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class RecoveryQrUtils {
  static String get deepLinkDomain => core.deepLinkDomain ?? 'app.studyu.health';
  static const String deepLinkPath = '/recover';
  static const String customScheme = 'studyu';

  static String generateDeepLink(List<String> phrase) {
    final phraseString = phrase.join('+');
    return 'https://$deepLinkDomain$deepLinkPath?phrase=$phraseString';
  }

  static String generateCustomSchemeLink(List<String> phrase) {
    final phraseString = phrase.join('+');
    return '$customScheme://recover?phrase=$phraseString';
  }

  static List<String>? parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url);

      final isHttpsLink =
          uri.scheme == 'https' &&
          uri.host == deepLinkDomain &&
          uri.path == deepLinkPath;
      final isCustomScheme =
          uri.scheme == customScheme && uri.host == 'recover';

      if (!isHttpsLink && !isCustomScheme) {
        return null;
      }

      final phraseParam = uri.queryParameters['phrase'];
      if (phraseParam == null || phraseParam.isEmpty) {
        return null;
      }

      final words = phraseParam
          .split(RegExp(r'[\s+]'))
          .where((word) => word.isNotEmpty)
          .toList();

      if (words.length != RecoveryConstants.totalWordCount) {
        return null;
      }

      return words;
    } catch (e) {
      return null;
    }
  }

  static QrCode buildQrCode(String data) {
    final qrCode = QrCode(8, QrErrorCorrectLevel.M);
    qrCode.addData(data);
    return qrCode;
  }

  static Widget renderQrWidget(
    QrCode qrCode, {
    double size = 280.0,
    Color foregroundColor = Colors.black,
    Color backgroundColor = Colors.white,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: _QrPainter(
        qrCode: qrCode,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static Uint8List qrCodeToImage(
    QrCode qrCode, {
    int size = 512,
    int foregroundColor = 0xFF000000,
    int backgroundColor = 0xFFFFFFFF,
  }) {
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;
    final pixelSize = size ~/ moduleCount;
    final actualSize = pixelSize * moduleCount;

    final image = img.Image(width: actualSize, height: actualSize);

    img.fill(
      image,
      color: img.ColorRgba8(
        (backgroundColor >> 16) & 0xFF,
        (backgroundColor >> 8) & 0xFF,
        backgroundColor & 0xFF,
        (backgroundColor >> 24) & 0xFF,
      ),
    );

    for (var y = 0; y < moduleCount; y++) {
      for (var x = 0; x < moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          final startX = x * pixelSize;
          final startY = y * pixelSize;

          img.fillRect(
            image,
            x1: startX,
            y1: startY,
            x2: startX + pixelSize,
            y2: startY + pixelSize,
            color: img.ColorRgba8(
              (foregroundColor >> 16) & 0xFF,
              (foregroundColor >> 8) & 0xFF,
              foregroundColor & 0xFF,
              (foregroundColor >> 24) & 0xFF,
            ),
          );
        }
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  static Future<void> shareRecoveryText(List<String> phrase) async {
    final text = phrase.join(' ');
    final params = ShareParams(text: text, subject: 'StudyU Recovery Phrase');
    await SharePlus.instance.share(params);
  }

  static Future<void> shareRecoveryQr(List<String> phrase) async {
    try {
      final deepLink = generateDeepLink(phrase);
      final qrCode = buildQrCode(deepLink);
      final imageData = qrCodeToImage(qrCode);

      if (kIsWeb) {
        final xFile = XFile.fromData(
          imageData,
          mimeType: 'image/png',
          name: 'recovery_qr.png',
        );

        final params = ShareParams(
          files: [xFile],
          subject: 'StudyU Recovery QR Code',
        );
        await SharePlus.instance.share(params);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/recovery_qr.png');
      await tempFile.writeAsBytes(imageData);
      final xFile = XFile(tempFile.path);
      final params = ShareParams(
        files: [xFile],
        subject: 'StudyU Recovery QR Code',
      );
      await SharePlus.instance.share(params);

      Future.delayed(const Duration(seconds: 5), () {
        if (tempFile.existsSync()) {
          tempFile.delete();
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> downloadRecoveryText(List<String> phrase) async {
    try {
      final text = phrase.join(' ');
      final bytes = Uint8List.fromList(text.codeUnits);

      if (kIsWeb) {
        await _downloadFileWeb(
          bytes,
          'studyu_recovery_phrase.txt',
          'text/plain',
        );
        return;
      }

      final params = SaveFileDialogParams(
        data: bytes,
        fileName: 'studyu_recovery_phrase.txt',
        mimeTypesFilter: ['text/plain'],
      );

      await FlutterFileDialog.saveFile(params: params);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> downloadRecoveryQr(List<String> phrase) async {
    try {
      final deepLink = generateDeepLink(phrase);
      final qrCode = buildQrCode(deepLink);
      final imageData = qrCodeToImage(qrCode);

      if (kIsWeb) {
        await _downloadFileWeb(
          imageData,
          'studyu_recovery_qr.png',
          'image/png',
        );
        return;
      }

      final params = SaveFileDialogParams(
        data: imageData,
        fileName: 'studyu_recovery_qr.png',
        mimeTypesFilter: ['image/png'],
      );

      await FlutterFileDialog.saveFile(params: params);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _downloadFileWeb(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    final blob = html.Blob([bytes], mimeType);

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    anchor.remove();
  }
}

class _QrPainter extends CustomPainter {
  final QrCode qrCode;
  final Color foregroundColor;
  final Color backgroundColor;

  _QrPainter({
    required this.qrCode,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;
    final pixelSize = size.width / moduleCount;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    final paint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;

    for (var y = 0; y < moduleCount; y++) {
      for (var x = 0; x < moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          final rect = Rect.fromLTWH(
            x * pixelSize,
            y * pixelSize,
            pixelSize,
            pixelSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.qrCode != qrCode ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
