import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/utils/qr_code_downloader.dart';

class QrCodePreviewDialog extends ConsumerStatefulWidget {
  const QrCodePreviewDialog({
    required this.data,
    required this.filename,
    this.title,
    this.inviteCode,
    super.key,
  });

  final String data;
  final String filename;
  final String? title;
  final String? inviteCode;

  @override
  ConsumerState<QrCodePreviewDialog> createState() =>
      _QrCodePreviewDialogState();
}

class _QrCodePreviewDialogState extends ConsumerState<QrCodePreviewDialog> {
  late Future<Widget> _qrWidgetFuture;

  @override
  void initState() {
    super.initState();
    _qrWidgetFuture = QrCodeDownloader.generateQrWidget(data: widget.data);
  }

  @override
  void didUpdateWidget(QrCodePreviewDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _qrWidgetFuture = QrCodeDownloader.generateQrWidget(data: widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    const dialogWidth = 450.0;
    final theme = Theme.of(context);

    return ScaffoldMessenger(
      child: Builder(
        builder: (dialogContext) {
          Future<void> copyLink() async {
            await ref.read(clipboardServiceProvider).copy(widget.data);
            if (!dialogContext.mounted) return;

            ScaffoldMessenger.of(dialogContext).showSnackBar(
              SnackBar(
                content: Text(
                  tr.notification_invite_link_copied,
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                width: dialogWidth,
                duration: const Duration(milliseconds: 2500),
                persist: false,
                padding: const EdgeInsets.fromLTRB(40.0, 16.0, 24.0, 16.0),
                behavior: SnackBarBehavior.floating,
                showCloseIcon: true,
                closeIconColor: theme.colorScheme.onPrimary,
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Positioned.fill(
                  child: ModalBarrier(
                    color: Colors.transparent,
                    semanticsLabel: MaterialLocalizations.of(
                      dialogContext,
                    ).modalBarrierDismissLabel,
                    onDismiss: () => Navigator.of(dialogContext).maybePop(),
                  ),
                ),
                StandardDialog(
                  titleText: widget.title ?? tr.action_qr_code_show,
                  width: dialogWidth,
                  minHeight: 400,
                  body: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tr.dialog_qr_code_description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (widget.inviteCode != null) ...[
                        const SizedBox(height: 16.0),
                        Text(
                          '${tr.form_field_code}: ${widget.inviteCode}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      FutureBuilder<Widget>(
                        future: _qrWidgetFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
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
                                    widget.data,
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
                          data: widget.data,
                          filename: widget.filename,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
