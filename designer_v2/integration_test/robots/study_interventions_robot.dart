import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyInterventionsRobot {
  const StudyInterventionsRobot(this.$);

  final PatrolTester $;

  Future<void> tapAddInterventionButton() async {
    await $(tr.form_array_interventions_new).tap();
  }

  Future<void> tapAddInterventionTaskButton() async {
    await $(tr.form_array_intervention_tasks_new).tap();
  }

  Future<void> tapSaveInterventionButton() async {
    await $(tr.dialog_save).tap();
  }

  Future<void> tapSaveInterventionTaskButton() async {
    await $(tr.dialog_save).tap();
  }

  Future<void> enterInterventionName(String interventionName) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_intervention_title,
        )
        .scrollTo()
        .enterText(interventionName);
  }

  Future<void> enterInterventionDesciption(
      String interventionDescription) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! ==
                  tr.form_field_intervention_description_hint,
        )
        .scrollTo()
        .enterText(interventionDescription);
  }

  Future<void> enterInterventionTaskName(String taskName) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! ==
                  tr.form_field_intervention_task_title,
        )
        .scrollTo()
        .enterText(taskName);
  }

  Future<void> enterInterventionTaskDescription(String taskDescription) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! ==
                  tr.form_field_intervention_task_description_hint,
        )
        .scrollTo()
        .enterText(taskDescription);
  }
}
