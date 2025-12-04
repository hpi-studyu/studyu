import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

class AppErrorScreen extends StatefulWidget {
  final String? selectedSubjectId;

  const AppErrorScreen({super.key, this.selectedSubjectId});

  @override
  State<AppErrorScreen> createState() => _AppErrorScreenState();
}

class _AppErrorScreenState extends State<AppErrorScreen> {
  String? cachedUserData;
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadCachedUserData();
  }

  Future<void> _loadCachedUserData() async {
    try {
      final data = await Cache.getCachedUserData();
      setState(() {
        cachedUserData = data;
        isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        cachedUserData = 'Error loading cached data: $e';
        isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                const Image(
                  image: AssetImage('assets/icon/logo.png'),
                  height: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  loc.loading_error_title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.loading_error_description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Debug information section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(MdiIcons.informationOutline),
                            const SizedBox(width: 8),
                            Text(
                              'Debug Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isLoadingData)
                          const Center(child: CircularProgressIndicator())
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              cachedUserData ?? 'No data available',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(MdiIcons.emailOutline),
                        onPressed: () => _contactSupport(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        label: Text(loc.contact_support),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(MdiIcons.deleteOutline),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => _showDeleteDataDialog(context),
                        label: Text(loc.delete_data),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
    StudyULogger.info("User chose to contact support from AppErrorScreen");

    const emailSubject = 'StudyU Support Request - Loading Error';

    // Get the base email body from localization
    String emailBody = AppLocalizations.of(
      context,
    )!.support_email_body(widget.selectedSubjectId ?? '');

    // Append cached user data to the email body
    if (cachedUserData != null && cachedUserData!.isNotEmpty) {
      emailBody += '\n\n--- Debug Information ---\n$cachedUserData';
    } else {
      emailBody += '\n\n--- Debug Information ---\nNo cached data available';
    }

    // Get contact email with fallback to developer email
    String? contactEmail;
    try {
      final appContact = await AppConfig.getAppContact();
      contactEmail = appContact.email;
    } catch (e) {
      StudyULogger.warning(
        'Failed to get app contact, using developer email fallback: $e',
      );
      contactEmail = developerEmail;
    }

    if (contactEmail == null || contactEmail.isEmpty) {
      StudyULogger.error('No contact email available.');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.no_contact_email)),
      );
      return;
    }

    final uriString =
        'mailto:$contactEmail?subject=${Uri.encodeComponent(emailSubject)}&body=${Uri.encodeComponent(emailBody)}';
    final emailUri = Uri.parse(uriString);
    await launchUrl(emailUri);

    // Show non dismissible dialog to inform the user that support has been contacted
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.support_email_sent),
          content: Text(
            AppLocalizations.of(context)!.support_email_sent_description,
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDataDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete_all_data),
          content: Text(
            AppLocalizations.of(context)!.delete_all_data_description,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => context.pop(true),
              child: Text(AppLocalizations.of(context)!.reset_app),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Delete all secure storage data
      StudyULogger.info("Deleting all secure storage data");
      if (!context.mounted) return;
      await cancelNotifications(context);
      await SecureStorage.deleteAll();
      StudyULogger.info("Secure storage data deleted");
    }
    StudyULogger.info("User chose not to delete secure storage data.");
  }
}
