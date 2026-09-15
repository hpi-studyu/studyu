import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/utils/qr_code_downloader.dart';

class QrCodePreviewDialog extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Future<void> copyLink() async {
      await ref.read(clipboardServiceProvider).copy(data);
    }

    return StandardDialog(
      titleText: title ?? tr.action_qr_code_show,
      width: 450,
      minHeight: 400,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<Widget>(
            future: QrCodeDownloader.generateQrWidget(data: data),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: theme.colorScheme.error),
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
          const SizedBox(height: 16.0),
          Text(
            tr.dialog_qr_code_description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16.0),
          Material(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              mouseCursor: SystemMouseCursors.click,
              onTap: copyLink,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Tooltip(
                      message: tr.action_copy_link,
                      preferBelow: true,
                      child: Icon(
                        Icons.copy_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actionButtons: [
        DismissButton(text: tr.dialog_close),
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
