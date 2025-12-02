import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/utils/recovery_qr_utils.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  final BigInt? userId;

  const RecoveryPhraseScreen({super.key, this.userId});

  @override
  State<RecoveryPhraseScreen> createState() => _RecoveryPhraseScreenState();
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  late List<String> _phrase;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _generatePhrase();
  }

  void _generatePhrase() {
    final user = Supabase.instance.client.auth.currentUser;
    final id =
        widget.userId ??
        (user != null
            ? BigInt.parse(user.id.replaceAll('-', ''), radix: 16)
            : BigInt.parse(const Uuid().v4().replaceAll('-', ''), radix: 16));

    _phrase = encode(id);
  }

  void _copyToClipboard() {
    final text = _phrase.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copied_to_clipboard),
      ),
    );
  }

  Future<void> _shareText() async {
    try {
      await RecoveryQrUtils.shareRecoveryText(_phrase);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _shareQr() async {
    try {
      await RecoveryQrUtils.shareRecoveryQr(_phrase);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _downloadText() async {
    try {
      await RecoveryQrUtils.downloadRecoveryText(_phrase);
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
    try {
      await RecoveryQrUtils.downloadRecoveryQr(_phrase);
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
                  RecoveryQrUtils.generateDeepLink(_phrase),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recovery_phrase_setup_title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.recovery_phrase_header,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.recovery_phrase_save_hint,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 32),
                        _buildPhraseGrid(),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
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
      itemCount: _phrase.length,
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
                  text: _phrase[index],
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

  Widget _buildActionButtons() {
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
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value ?? false;
              });
            },
            title: Text(
              AppLocalizations.of(context)!.recovery_phrase_saved_confirmation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isChecked
                ? () {
                    Navigator.pushNamed(context, Routes.studySelection);
                  }
                : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.continue_to_study),
          ),
        ],
      ),
    );
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
