/// StudyU Design System Spacing Scale
///
/// 4px base grid, aligned with CSS design tokens in colors_and_type.css.
/// Use these constants instead of hardcoded numeric values for consistent
/// padding, margin, and spacing across the app.
///
/// ```dart
/// // Preferred
/// padding: EdgeInsets.all(StudyUSpacing.space4),
/// SizedBox(height: StudyUSpacing.space2),
///
/// // Avoid
/// padding: EdgeInsets.all(16),
/// SizedBox(height: 8),
/// ```
class StudyUSpacing {
  StudyUSpacing._();

  // Core spacing scale
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  // Semantic aliases for common usage patterns
  /// Standard screen horizontal padding
  static const double screenHorizontal = space4;

  /// Standard card padding
  static const double cardPadding = space4;

  /// Compact spacing within card/list tile content
  static const double cardCompact = space2;

  /// Vertical gap between sections
  static const double sectionGap = space6;

  /// Smallest visible gap (between inline elements)
  static const double inlineGap = space1;

  /// Standard gap between related items
  static const double itemGap = space2;

  /// Gap between unrelated items/groups
  static const double groupGap = space4;
}
