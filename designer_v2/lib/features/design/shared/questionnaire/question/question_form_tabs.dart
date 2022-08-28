import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

abstract class IQuestionTypeFormWidget {
  Widget? content(BuildContext context);
  Widget? customize(BuildContext context);
  Widget? logic(BuildContext context);
}

abstract class QuestionFormTabsViewModel {
  bool get isDesignTabEnabled;
  bool get isDesignTabVisible;
  bool get isLogicTabEnabled;
  bool get isLogicTabVisible;
}

class QuestionFormTabs {
  static final tabs = (BuildContext context, IQuestionTypeFormWidget widget) => [
    content(enabled: widget.content(context) != null),
    customize(enabled: widget.customize(context) != null),
    logic(enabled: widget.logic(context) != null),
  ];

  static final content = ({enabled = true}) => NavbarTab(
    index: 0,
    title: "Content".hardcoded,
    enabled: enabled,
  );
  static final customize = ({enabled = true}) => NavbarTab(
    index: 1,
    title: "Visuals".hardcoded,
    enabled: enabled,
  );
  static final logic = ({enabled = true}) => NavbarTab(
    index: 2,
    title: "Logic".hardcoded,
    enabled: enabled,
  );
}
