import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/study_info_validator.dart';
import 'package:test/test.dart';

Study _study({String? title, String? description}) {
  final s = Study('test-id', 'test-user');
  s.title = title;
  s.description = description;
  return s;
}

void main() {
  group('validateStudyInfo - draft', () {
    test('passes when title is present', () {
      final r = validateStudyInfo(_study(title: 'My Study'), ValidationLevel.draft);
      expect(r.valid, isTrue);
    });

    test('fails when title is null', () {
      final r = validateStudyInfo(_study(title: null), ValidationLevel.draft);
      expect(r.valid, isFalse);
      expect(r.errors.first.code, 'study_info.title_required');
      expect(r.errors.first.path, r'$.title');
    });
  });

  group('validateStudyInfo - publish', () {
    test('fails when description is null', () {
      final r = validateStudyInfo(
        _study(title: 'My Study', description: null),
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(r.errors.any((e) => e.code == 'study_info.description_required'), isTrue);
    });

    test('passes with all fields set', () {
      final s = _study(title: 'My Study', description: 'Desc');
      s.contact.email = 'a@b.com';
      s.contact.organization = 'Org';
      s.contact.institutionalReviewBoard = 'IRB';
      s.contact.institutionalReviewBoardNumber = '123';
      s.contact.researchers = 'Alice';
      s.contact.phone = '+1234';
      s.iconName = 'accountHeart';
      final r = validateStudyInfo(s, ValidationLevel.publish);
      expect(r.valid, isTrue);
    });
  });
}
