import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saving an invite code marks the form baseline as clean', () {
    final source = File(
      'lib/features/recruit/invite_code_form_controller.dart',
    ).readAsStringSync();
    final saveStart = source.indexOf('Future<StudyInvite> save');
    final saveEnd = source.indexOf('\n  }', saveStart);

    expect(saveStart, isNonNegative);
    expect(saveEnd, isNonNegative);

    final saveSource = source.substring(saveStart, saveEnd);

    expect(
      saveSource,
      contains('finalizeInitializationBaseline'),
      reason:
          'InviteCodeFormViewModel.save() bypasses FormViewModel.save(), so it '
          'must mark the current form values as clean before the sidesheet save '
          'button asks Navigator.maybePop() to close.',
    );
  });
}
