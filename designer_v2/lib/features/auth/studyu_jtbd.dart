import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyUJobsToBeDone extends StatelessWidget {
  const StudyUJobsToBeDone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0 * 48.0),
            child: Text(
              tr.navlink_learn,
              style: theme.textTheme.headline1
                  ?.copyWith(color: Colors.white.withOpacity(1.5 * 0.04)),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1 * 48.0),
            child: Text(
              tr.navlink_study_design,
              style: theme.textTheme.headline1
                  ?.copyWith(color: Colors.white.withOpacity(4 * 0.04)),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2 * 48.0),
            child: Text(
              tr.navlink_study_test,
              style: theme.textTheme.headline1
                  ?.copyWith(color: Colors.white.withOpacity(3 * 0.04)),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3 * 48.0),
            child: Text(
              tr.navlink_study_monitor,
              style: theme.textTheme.headline1
                  ?.copyWith(color: Colors.white.withOpacity(2 * 0.04)),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4 * 48.0),
            child: Text(
              tr.navlink_study_analyze,
              style: theme.textTheme.headline1
                  ?.copyWith(color: Colors.white.withOpacity(4 * 0.04)),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5 * 48.0),
            child: Text(
              tr.navlink_share,
              style: theme.textTheme.headline1
                  ?.copyWith(color: Colors.white.withOpacity(3 * 0.04)),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}
