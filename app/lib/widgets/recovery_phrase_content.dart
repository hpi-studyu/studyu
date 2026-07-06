import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/rejoin_study_service.dart';
import 'package:studyu_app/util/recovery_qr_utils.dart';

class RecoveryPhraseContent extends StatefulWidget {
  final bool useGridLayout;

  const RecoveryPhraseContent({super.key, this.useGridLayout = true});

  @override
  State<RecoveryPhraseContent> createState() => RecoveryPhraseContentState();
}

class RecoveryPhraseContentState extends State<RecoveryPhraseContent> {
  List<String>? _phrase;
  bool _isLoading = true;
  String? _error;

  List<String>? get phrase => _phrase;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  @override
  void initState() {
    super.initState();
    loadPhrase();
  }

  Future<void> loadPhrase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final phrase = await RejoinStudyService.getRecoveryPhrase();
      if (mounted) {
        setState(() {
          _phrase = phrase;
          _isLoading = false;
          _error = phrase == null
              ? AppLocalizations.of(context)!.recovery_phrase_load_error
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = AppLocalizations.of(context)!.share_error(e.toString());
        });
      }
    }
  }

  void _copyToClipboard() {
    if (_phrase == null) return;
    final text = _phrase!.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copied_to_clipboard),
      ),
    );
  }

  Future<void> _shareText() async {
    if (_phrase == null) return;
    try {
      await RecoveryQrUtils.shareRecoveryText(_phrase!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.share_error(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareQr() async {
    if (_phrase == null) return;
    try {
      await RecoveryQrUtils.shareRecoveryQr(_phrase!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.share_error(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _downloadText() async {
    if (_phrase == null) return;
    try {
      await RecoveryQrUtils.downloadRecoveryText(_phrase!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.file_saved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.file_save_error),
          ),
        );
      }
    }
  }

  Future<void> _downloadQr() async {
    if (_phrase == null) return;
    try {
      await RecoveryQrUtils.downloadRecoveryQr(_phrase!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.file_saved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.file_save_error),
          ),
        );
      }
    }
  }

  void _showQrCodeDialog() {
    if (_phrase == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.qr_code_btn,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              RecoveryQrUtils.renderQrWidget(
                RecoveryQrUtils.buildQrCode(
                  RecoveryQrUtils.generateDeepLink(_phrase!),
                ),
                size: 240,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.share,
                    label: AppLocalizations.of(context)!.share_as_qr,
                    onTap: _shareQr,
                  ),
                  _ActionButton(
                    icon: Icons.download,
                    label: AppLocalizations.of(context)!.download_as_qr,
                    onTap: _downloadQr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.useGridLayout) _buildPhraseGrid() else _buildPhraseChips(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPhraseGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _phrase?.length ?? 0,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${index + 1}. ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                TextSpan(
                  text: _phrase![index],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhraseChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _phrase!.map((word) => Chip(label: Text(word))).toList(),
    );
  }

  Widget _buildActionButtons() {
    if (widget.useGridLayout) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.share_outlined,
            label: AppLocalizations.of(context)!.share_btn,
            onTap: _shareText,
          ),
          _ActionButton(
            icon: Icons.copy_outlined,
            label: AppLocalizations.of(context)!.copy_btn,
            onTap: _copyToClipboard,
          ),
          _ActionButton(
            icon: Icons.download_outlined,
            label: AppLocalizations.of(context)!.download_btn,
            onTap: _downloadText,
          ),
          _ActionButton(
            icon: Icons.qr_code_2,
            label: AppLocalizations.of(context)!.qr_code_btn,
            onTap: _showQrCodeDialog,
          ),
        ],
      );
    } else {
      final theme = Theme.of(context);
      return Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            label: Text(AppLocalizations.of(context)!.copy_to_clipboard),
          ),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              foregroundColor: theme.primaryColor,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            icon: const Icon(Icons.qr_code),
            onPressed: _downloadQr,
            label: Text(AppLocalizations.of(context)!.download_as_qr_btn),
          ),
          OutlinedButton.icon(
            onPressed: _shareText,
            icon: const Icon(Icons.share),
            label: Text(AppLocalizations.of(context)!.share_recovery_text_btn),
          ),
        ],
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
