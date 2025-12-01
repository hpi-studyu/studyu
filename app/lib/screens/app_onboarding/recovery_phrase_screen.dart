import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:studyu_core/src/util/recovery.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  final BigInt?
  userId; // Optional, if not provided, we might generate one or handle error
  // Actually, we usually have the user ID from the auth state or passed in.
  // For now, let's assume it's passed or we can get it.

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recovery_phrase_setup_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.recovery_phrase_header,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _phrase
                        .map((word) => Chip(label: Text(word)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyToClipboard,
                    tooltip: AppLocalizations.of(context)!.copy_to_clipboard,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.recovery_phrase_purpose_header,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.recovery_phrase_purpose_1),
            Text(AppLocalizations.of(context)!.recovery_phrase_purpose_2),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.recovery_phrase_save_hint),
            const SizedBox(height: 24),

            // TODO: Share and Email buttons
            CheckboxListTile(
              value: _isChecked,
              onChanged: (value) {
                setState(() {
                  _isChecked = value ?? false;
                });
              },
              title: Text(
                AppLocalizations.of(
                  context,
                )!.recovery_phrase_saved_confirmation,
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isChecked
                  ? () {
                      Navigator.pushNamed(context, Routes.studySelection);
                    }
                  : null,
              child: Text(AppLocalizations.of(context)!.continue_to_study),
            ),
          ],
        ),
      ),
    );
  }
}
