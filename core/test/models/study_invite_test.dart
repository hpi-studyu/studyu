import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('fromJson keeps computed participant count from api payload', () {
    final invite = StudyInvite.fromJson(<String, dynamic>{
      'code': 'invite-code',
      'study_id': 'study-id',
      'study_invite_participant_count': 3,
    });

    expect(invite.participantCount, 3);
  });

  test('fromJson defaults computed participant count to zero when absent', () {
    final invite = StudyInvite.fromJson(<String, dynamic>{
      'code': 'invite-code',
      'study_id': 'study-id',
    });

    expect(invite.participantCount, 0);
  });

  test('toJson excludes computed participant count from save payload', () {
    final invite = StudyInvite('invite-code', 'study-id', participantCount: 3);

    expect(
      invite.toJson().containsKey(StudyInvite.participantCountJsonKey),
      isFalse,
    );
  });
}
