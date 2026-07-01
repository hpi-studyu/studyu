/// Canonical scope rules mapping Dart classes to their documentation page paths.
///
/// Each entry specifies: the class name, the output markdown path relative to
/// `core/docs/study-data/`, and optional flags like `generatedFields`.
library;

/// A single entry in the page scope map.
class PageScopeEntry {
  final String className;
  final String pagePath;

  /// When false, the GENERATED:FIELDS block is omitted. Use for classes with
  /// hand-written fromJson (e.g. StudyUQuestionnaire).
  final bool generatedFields;

  /// Note text appended inside a generated comment block at the top of the page.
  final String? note;

  const PageScopeEntry({
    required this.className,
    required this.pagePath,
    this.generatedFields = true,
    this.note,
  });
}

/// The canonical page scope: maps class names to page paths and metadata.
///
/// Classes not listed here are excluded from generated docs.
const List<PageScopeEntry> kPageScope = [
  // ── Core study definition ──────────────────────────────────────────────────
  PageScopeEntry(className: 'Study', pagePath: 'study/index.md'),
  PageScopeEntry(className: 'Contact', pagePath: 'study/contact.md'),
  PageScopeEntry(
    className: 'EligibilityCriterion',
    pagePath: 'study/eligibility.md',
  ),
  PageScopeEntry(className: 'ConsentItem', pagePath: 'study/consent.md'),

  // ── Questionnaire ──────────────────────────────────────────────────────────
  PageScopeEntry(
    className: 'StudyUQuestionnaire',
    pagePath: 'questionnaire/index.md',
    generatedFields: false,
  ),
  PageScopeEntry(
    className: 'Question',
    pagePath: 'questionnaire/question.md',
    generatedFields: false,
  ),
  PageScopeEntry(
    className: 'BooleanQuestion',
    pagePath: 'questionnaire/question-types/boolean.md',
  ),
  PageScopeEntry(
    className: 'ChoiceQuestion',
    pagePath: 'questionnaire/question-types/choice.md',
  ),
  PageScopeEntry(
    className: 'ScaleQuestion',
    pagePath: 'questionnaire/question-types/scale.md',
  ),
  PageScopeEntry(
    className: 'AnnotatedScaleQuestion',
    pagePath: 'questionnaire/question-types/annotated-scale.md',
  ),
  PageScopeEntry(
    className: 'VisualAnalogueQuestion',
    pagePath: 'questionnaire/question-types/visual-analogue.md',
  ),
  PageScopeEntry(
    className: 'ImageCapturingQuestion',
    pagePath: 'questionnaire/question-types/image-capturing.md',
  ),
  PageScopeEntry(
    className: 'AudioRecordingQuestion',
    pagePath: 'questionnaire/question-types/audio-recording.md',
  ),
  PageScopeEntry(
    className: 'DateQuestion',
    pagePath: 'questionnaire/question-types/date.md',
  ),
  PageScopeEntry(
    className: 'FreeTextQuestion',
    pagePath: 'questionnaire/question-types/free-text.md',
  ),
  PageScopeEntry(
    className: 'FitbitQuestion',
    pagePath: 'questionnaire/question-types/fitbit.md',
  ),
  PageScopeEntry(
    className: 'PainQuestion',
    pagePath: 'questionnaire/question-types/pain.md',
  ),
  PageScopeEntry(
    className: 'QuestionnaireTask',
    pagePath: 'observations/questionnaire-task.md',
  ),

  // ── Body pain models ───────────────────────────────────────────────────────
  PageScopeEntry(
    className: 'BodyPain',
    pagePath: 'questionnaire/question-types/body-pain.md',
  ),
  PageScopeEntry(
    className: 'BodyPart',
    pagePath: 'questionnaire/question-types/body-pain.md',
  ),
  PageScopeEntry(
    className: 'Body',
    pagePath: 'questionnaire/question-types/body-pain.md',
  ),
  PageScopeEntry(
    className: 'PainType',
    pagePath: 'questionnaire/question-types/body-pain.md',
  ),

  // ── Interventions ──────────────────────────────────────────────────────────
  PageScopeEntry(
    className: 'Intervention',
    pagePath: 'interventions/intervention.md',
  ),
  PageScopeEntry(
    className: 'CheckmarkTask',
    pagePath: 'interventions/checkmark-task.md',
  ),

  // ── Schedules ─────────────────────────────────────────────────────────────
  PageScopeEntry(className: 'Schedule', pagePath: 'schedules/task-schedule.md'),
  PageScopeEntry(
    className: 'StudySchedule',
    pagePath: 'schedules/study-schedule.md',
  ),

  // ── Invites ───────────────────────────────────────────────────────────────
  PageScopeEntry(className: 'StudyInvite', pagePath: 'invites/study-invite.md'),

  // ── Participants (runtime-only Supabase rows) ──────────────────────────────
  PageScopeEntry(
    className: 'StudySubject',
    pagePath: 'participants/study-subject.md',
    note:
        'These are Supabase join rows, not portable study-definition fields. '
        'Do not include them in study JSON exported from the designer.',
  ),
  PageScopeEntry(
    className: 'SubjectProgress',
    pagePath: 'participants/subject-progress.md',
    note:
        'These are Supabase join rows, not portable study-definition fields. '
        'Do not include them in study JSON exported from the designer.',
  ),

  // ── Reports ───────────────────────────────────────────────────────────────
  PageScopeEntry(
    className: 'ReportSpecification',
    pagePath: 'reports/report-specification.md',
  ),
  PageScopeEntry(
    className: 'AverageSection',
    pagePath: 'reports/sections/average.md',
  ),
  PageScopeEntry(
    className: 'LinearRegressionSection',
    pagePath: 'reports/sections/linear-regression.md',
  ),
  PageScopeEntry(
    className: 'TextualSummarySection',
    pagePath: 'reports/sections/textual-summary.md',
  ),
  PageScopeEntry(
    className: 'GaugeComparisonSection',
    pagePath: 'reports/sections/gauge-comparison.md',
  ),
  PageScopeEntry(
    className: 'DescriptiveStatsSection',
    pagePath: 'reports/sections/descriptive-stats.md',
  ),

  // ── Results ───────────────────────────────────────────────────────────────
  PageScopeEntry(
    className: 'InterventionResult',
    pagePath: 'results/intervention-result.md',
  ),
  PageScopeEntry(
    className: 'NumericResult',
    pagePath: 'results/numeric-result.md',
  ),

  // ── Shared ────────────────────────────────────────────────────────────────
  PageScopeEntry(
    className: 'DataReference',
    pagePath: 'shared/data-reference.md',
  ),
  PageScopeEntry(
    className: 'Expression',
    pagePath: 'shared/expressions.md',
    generatedFields: false,
  ),
  PageScopeEntry(
    className: 'BooleanExpression',
    pagePath: 'shared/expressions.md',
  ),
  PageScopeEntry(
    className: 'ChoiceExpression',
    pagePath: 'shared/expressions.md',
  ),
  PageScopeEntry(
    className: 'NumericExpression',
    pagePath: 'shared/expressions.md',
  ),
  PageScopeEntry(
    className: 'TextExpression',
    pagePath: 'shared/expressions.md',
  ),
  PageScopeEntry(
    className: 'CompositeExpression',
    pagePath: 'shared/expressions.md',
    note:
        'Not dispatchable via Expression.fromJson. Do not use in study JSON '
        'until the dispatcher bug is fixed.',
  ),
  PageScopeEntry(className: 'NotExpression', pagePath: 'shared/expressions.md'),
];

/// Returns the [PageScopeEntry] for [className], or null if excluded.
PageScopeEntry? scopeFor(String className) {
  for (final entry in kPageScope) {
    if (entry.className == className) return entry;
  }
  return null;
}

/// Returns all scope entries whose page path matches [pagePath].
List<PageScopeEntry> entriesForPage(String pagePath) =>
    kPageScope.where((e) => e.pagePath == pagePath).toList();

/// The set of all canonical page paths (deduplicated).
Set<String> get allPagePaths => kPageScope.map((e) => e.pagePath).toSet();
