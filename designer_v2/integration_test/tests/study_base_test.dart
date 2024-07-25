import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/app.dart';

import '../controller/robots/robots.dart';
import '../controller/study_integration_controller.dart';

abstract class StudyBaseTest extends StudyRobots {
  final bool randomTest = true;
  final Study Function() selectedMockupStudy;
  final StudyIntegrationController controller;

  StudyBaseTest.go(super.$, this.selectedMockupStudy)
      : controller = StudyIntegrationController($, selectedMockupStudy);

  Future<void> init() async {
    final email = randomTest
        ? '${DateTime.now().millisecondsSinceEpoch}@studyu.health'
        : 'test@studyu.health';
    const password = 'password';

    await super.$.pumpWidgetAndSettle(
          const ExcludeSemantics(child: ProviderScope(child: App())),
        );

    await execute(email, password);
    await finish();
  }

  Future<void> execute(String email, String password) async {}

  Future<void> finish() async {
    expect(await controller.validateFinal(), true);
    // todo navigate to sign out
    //await studiesRobot.tapSignOutButton();
  }
}
