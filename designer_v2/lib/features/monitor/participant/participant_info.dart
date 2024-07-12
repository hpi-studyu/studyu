import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class ParticipantInfo extends ConsumerWidget {
  const ParticipantInfo({
    required this.participantId,
    required this.inviteCode,
    required this.startedAt,
    required this.lastActivityAt,
    super.key,
  });

  final String participantId;
  final String? inviteCode;
  final DateTime startedAt;
  final DateTime lastActivityAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider).languageCode;
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            tr.monitoring_table_column_participant_id,
            participantId,
          ),
          _buildInfoRow(
            tr.monitoring_table_column_invite_code,
            inviteCode ?? 'N/A',
          ),
          _buildInfoRow(
            tr.monitoring_table_column_enrolled,
            startedAt.toLocalizedString(locale: languageCode, showTime: false),
          ),
          _buildInfoRow(
            tr.monitoring_table_column_last_activity,
            lastActivityAt.toLocalizedString(locale: languageCode),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}
