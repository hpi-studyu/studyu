import 'package:studyu_validator/studyu_validator.dart';
import 'package:test/test.dart';

// A minimal valid study JSON that can deserialize
const _baseStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": "CLI Section Test Study",
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Org", "email": "test@example.com", "website": "", "phone": "+1234"},
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

const _emptyConsentStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": "No Consent Study",
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Org", "email": "test@example.com", "website": "", "phone": "+1234"},
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

const _dupObsStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": "Dup Obs Study",
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Org", "email": "test@example.com", "website": "", "phone": "+1234"},
  "icon_name": "",
  "published": false,
  "questionnaire": [],
  "eligibility_criteria": [],
  "consent": [],
  "interventions": [],
  "observations": [
    {"id": "obs-dup-id", "type": "questionnaire", "title": "Obs1", "schedule": {"completionPeriods": [], "reminders": []}, "questions": []},
    {"id": "obs-dup-id", "type": "questionnaire", "title": "Obs2", "schedule": {"completionPeriods": [], "reminders": []}, "questions": []}
  ],
  "schedule": {"phaseDuration": 7, "numberOfCycles": 2, "includeBaseline": false, "sequence": "alternating", "sequenceCustom": "ABAB"},
  "report_specification": {"secondary": []},
  "results": []
}
''';

const _schemaInvalidStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": "Schema Invalid",
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Org", "email": "test@example.com", "website": "", "phone": "+1234"},
  "icon_name": "accountHeart",
  "published": false,
  "questionnaire": [],
  "eligibility_criteria": [],
  "consent": [],
  "interventions": [],
  "observations": [],
  "schedule": {"phaseDuration": 7, "numberOfCycles": 2, "includeBaseline": false, "sequence": "alternating", "sequenceCustom": "ABAB"},
  "report_specification": {"secondary": []},
  "results": [],
  "unexpected_extra_key": true
}
''';

void main() {
  group('validateSection', () {
    test('section=study_info runs only study info checks', () {
      final r = validateSection(
        _baseStudyJson,
        'study_info',
        ValidationLevel.draft,
      );
      expect(r, isNotNull);
      // title is set in the JSON, so should pass
      expect(
        r!.errors.where((e) => e.code == 'study_info.title_required'),
        isEmpty,
      );
    });

    test(
      'section=consent at publish with empty consent -> consent.no_items',
      () {
        final r = validateSection(
          _emptyConsentStudyJson,
          'consent',
          ValidationLevel.publish,
        );
        expect(r, isNotNull);
        expect(r!.valid, isFalse);
        expect(r.errors.any((e) => e.code == 'consent.no_items'), isTrue);
      },
    );

    test(
      'section=observations with duplicate IDs -> observations.duplicate_observation_id',
      () {
        final r = validateSection(
          _dupObsStudyJson,
          'observations',
          ValidationLevel.draft,
        );
        expect(r, isNotNull);
        expect(r!.valid, isFalse);
        expect(
          r.errors.any(
            (e) => e.code == 'observations.duplicate_observation_id',
          ),
          isTrue,
        );
      },
    );

    test('unknown section string returns null from validateSection', () {
      final r = validateSection(
        _baseStudyJson,
        'unknown_section',
        ValidationLevel.draft,
      );
      expect(r, isNull);
    });

    test('section=interventions passes for empty interventions at draft', () {
      final r = validateSection(
        _baseStudyJson,
        'interventions',
        ValidationLevel.draft,
      );
      expect(r, isNotNull);
      expect(r!.valid, isTrue);
    });

    test('section=schedule passes for valid schedule', () {
      final r = validateSection(
        _baseStudyJson,
        'schedule',
        ValidationLevel.draft,
      );
      expect(r, isNotNull);
      expect(r!.valid, isTrue);
    });

    test('section=questionnaire passes for empty questionnaire', () {
      final r = validateSection(
        _baseStudyJson,
        'questionnaire',
        ValidationLevel.draft,
      );
      expect(r, isNotNull);
      expect(r!.valid, isTrue);
    });

    test('section=report passes for empty report', () {
      final r = validateSection(
        _baseStudyJson,
        'report',
        ValidationLevel.draft,
      );
      expect(r, isNotNull);
      expect(r!.valid, isTrue);
    });

    test('section=eligibility passes for empty eligibility', () {
      final r = validateSection(
        _baseStudyJson,
        'eligibility',
        ValidationLevel.draft,
      );
      expect(r, isNotNull);
      expect(r!.valid, isTrue);
    });
    test('validateSection returns SCHEMA_ERROR for schema-invalid json', () {
      final r = validateSection(
        _schemaInvalidStudyJson,
        'study_info',
        ValidationLevel.draft,
      );
      expect(r, isNotNull);
      expect(r!.errors, isNotEmpty);
      expect(r.errors.first.code, 'SCHEMA_ERROR');
    });
  });
}
