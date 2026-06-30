import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

// Contact requires organization, email, website, phone fields.
const validStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": "CLI Test Study",
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Test Org", "email": "test@example.com", "website": "", "phone": ""},
  "icon_name": "accountHeart",
  "published": false,
  "questionnaire": [],
  "eligibility_criteria": [],
  "consent": [],
  "interventions": [],
  "observations": [],
  "schedule": {"phaseDuration": 7, "numberOfCycles": 2, "includeBaseline": false, "sequence": "alternating", "sequenceCustom": "ABAB"},
  "report_specification": {"secondary": []},
  "results": []
}
''';

const invalidStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": null,
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Test Org", "email": "test@example.com", "website": "", "phone": ""},
  "icon_name": "",
  "published": false,
  "questionnaire": [],
  "eligibility_criteria": [],
  "consent": [],
  "interventions": [],
  "observations": [],
  "schedule": {"phaseDuration": 7, "numberOfCycles": 2, "includeBaseline": false, "sequence": "alternating", "sequenceCustom": "ABAB"},
  "report_specification": {"secondary": []},
  "results": []
}
''';

void main() {
  test('validate subcommand exits 0 for valid study via temp file', () async {
    final tmp = await File('/tmp/test_study_valid.json').create();
    await tmp.writeAsString(validStudyJson);

    final workdir =
        Directory.current.path.endsWith('studyu_validator')
            ? Directory.current.path
            : '${Directory.current.path}/studyu_validator';

    final result = await Process.run(
      'dart',
      ['run', 'bin/studyu_validator.dart', 'validate', tmp.path],
      workingDirectory: workdir,
    );

    expect(result.exitCode, 0, reason: 'stderr: ${result.stderr}');
    final output = jsonDecode(result.stdout as String) as Map;
    expect(output['valid'], isTrue);
  });

  test('validate subcommand exits 1 for invalid study via temp file', () async {
    final tmp = await File('/tmp/test_study_invalid.json').create();
    await tmp.writeAsString(invalidStudyJson);

    final workdir =
        Directory.current.path.endsWith('studyu_validator')
            ? Directory.current.path
            : '${Directory.current.path}/studyu_validator';

    final result = await Process.run(
      'dart',
      ['run', 'bin/studyu_validator.dart', 'validate', tmp.path],
      workingDirectory: workdir,
    );

    expect(result.exitCode, 1, reason: 'stderr: ${result.stderr}');
    final output = jsonDecode(result.stdout as String) as Map;
    expect(output['valid'], isFalse);
  });
}
