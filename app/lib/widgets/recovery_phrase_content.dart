import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/util/recovery_file_utils.dart';

class RecoveryPhraseContent extends StatefulWidget {
  final bool useGridLayout;
  final List<String>? initialPhrase;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChanged;

  const RecoveryPhraseContent({
    super.key,
    this.useGridLayout = true,
    this.initialPhrase,
    this.isChecked = false,
    this.onCheckedChanged,
  });

  @override
  State<RecoveryPhraseContent> createState() => RecoveryPhraseContentState();
}

class RecoveryPhraseContentState extends State<RecoveryPhraseContent> {
  late List<String>? _phrase = widget.initialPhrase;
  late bool _isLoading = widget.initialPhrase == null;
  String? _error;

  List<String>? get phrase => _phrase;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhrase == null) loadPhrase();
  }

  Future<void> loadPhrase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final phrase = await RestoreAccountService.getRecoveryPhrase();
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

  Future<void> _downloadText() async {
    if (_phrase == null) return;
    try {
      await RecoveryFileUtils.downloadRecoveryText(_phrase!);
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
        Text(
          AppLocalizations.of(context)!.recovery_phrase_list_header,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.recovery_phrase_list_helper,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (widget.useGridLayout) _buildPhraseGrid() else _buildPhraseChips(),
        const SizedBox(height: 16),
        _buildActionButtons(),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: Text(
            AppLocalizations.of(context)!.recovery_phrase_saved_confirmation,
          ),
          value: widget.isChecked,
          onChanged: widget.onCheckedChanged,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildPhraseGrid() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const rowHeight = 36.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                for (var index = 0; index < _phrase!.length; index++)
                  SizedBox(
                    height: rowHeight,
                    width: 28,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final word in _phrase!)
                      SizedBox(
                        height: rowHeight,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            word,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.copy_outlined),
            label: Text(AppLocalizations.of(context)!.copy_btn),
            onPressed: _copyToClipboard,
          ),
          TextButton.icon(
            icon: const Icon(Icons.download_outlined),
            label: Text(AppLocalizations.of(context)!.download_btn),
            onPressed: _downloadText,
          ),
        ],
      );
    } else {
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
          OutlinedButton.icon(
            onPressed: _downloadText,
            icon: const Icon(Icons.download),
            label: Text(AppLocalizations.of(context)!.download_btn),
          ),
        ],
      );
    }
  }
}
