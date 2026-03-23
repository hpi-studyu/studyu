import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/qr_code_downloader.dart';

class QrCodePreviewDialog extends StatelessWidget {
  const QrCodePreviewDialog({
    required this.data,
    required this.filename,
    this.title,
    super.key,
  });

  final String data;
  final String filename;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return StandardDialog(
      titleText: title ?? tr.action_qr_code_show,
      minHeight: 400,
      body: FutureBuilder<Widget>(
        future: QrCodeDownloader.generateQrWidget(data: data),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: snapshot.data,
            ),
          );
        },
      ),
      actionButtons: [
        PrimaryButton(
          text: tr.action_qr_code_download,
          icon: Icons.download,
          onPressed: () async {
            await QrCodeDownloader.downloadQrCode(
              data: data,
              filename: filename,
            );
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
