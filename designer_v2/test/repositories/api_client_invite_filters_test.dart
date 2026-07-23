import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'invite intervention filters distinguish first and second assignment',
    () {
      final packageRootFile = File('lib/repositories/api_client.dart');
      final repoRootFile = File('designer_v2/lib/repositories/api_client.dart');
      final source = packageRootFile.existsSync()
          ? packageRootFile.readAsStringSync()
          : repoRootFile.readAsStringSync();

      expect(
        source,
        contains("case InviteCodeInterventionFilter.interventionA:"),
      );
      expect(
        source,
        contains("case InviteCodeInterventionFilter.interventionB:"),
      );
      expect(source, contains("'preselected_intervention_ids->0'"));
      expect(source, contains("'preselected_intervention_ids->1'"));

      final interventionAIndex = source.indexOf(
        "case InviteCodeInterventionFilter.interventionA:",
      );
      final interventionBIndex = source.indexOf(
        "case InviteCodeInterventionFilter.interventionB:",
      );

      expect(interventionAIndex, isNonNegative);
      expect(interventionBIndex, isNonNegative);
      expect(interventionAIndex, lessThan(interventionBIndex));
    },
  );
}
