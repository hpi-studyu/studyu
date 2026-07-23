import 'package:studyu_core/core.dart';

enum InviteCodesSortColumn { code, enrolled }

enum InviteCodeEnrolledFilter { all, unused, used }

enum InviteCodeInterventionFilter {
  all,
  defaultAssignment,
  interventionA,
  interventionB,
}

class InviteCodeFilters {
  const InviteCodeFilters({
    this.enrolled = InviteCodeEnrolledFilter.all,
    this.enrolledMin,
    this.enrolledMax,
    this.intervention = InviteCodeInterventionFilter.all,
  });

  final InviteCodeEnrolledFilter enrolled;
  final int? enrolledMin;
  final int? enrolledMax;
  final InviteCodeInterventionFilter intervention;

  bool get isEmpty =>
      enrolled == InviteCodeEnrolledFilter.all &&
      enrolledMin == null &&
      enrolledMax == null &&
      intervention == InviteCodeInterventionFilter.all;

  int get activeCount =>
      (enrolled != InviteCodeEnrolledFilter.all ? 1 : 0) +
      (enrolledMin != null ? 1 : 0) +
      (enrolledMax != null ? 1 : 0) +
      (intervention != InviteCodeInterventionFilter.all ? 1 : 0);

  InviteCodeFilters copyWith({
    InviteCodeEnrolledFilter? enrolled,
    int? enrolledMin,
    bool clearEnrolledMin = false,
    int? enrolledMax,
    bool clearEnrolledMax = false,
    InviteCodeInterventionFilter? intervention,
  }) {
    return InviteCodeFilters(
      enrolled: enrolled ?? this.enrolled,
      enrolledMin: clearEnrolledMin ? null : enrolledMin ?? this.enrolledMin,
      enrolledMax: clearEnrolledMax ? null : enrolledMax ?? this.enrolledMax,
      intervention: intervention ?? this.intervention,
    );
  }

  InviteCodeFilters normalized() {
    final normalizedMin = enrolledMin != null && enrolledMin! < 0
        ? 0
        : enrolledMin;
    final normalizedMax = enrolledMax != null && enrolledMax! < 0
        ? 0
        : enrolledMax;

    return InviteCodeFilters(
      enrolled: enrolled,
      enrolledMin: normalizedMin,
      enrolledMax: normalizedMax,
      intervention: intervention,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InviteCodeFilters &&
        other.enrolled == enrolled &&
        other.enrolledMin == enrolledMin &&
        other.enrolledMax == enrolledMax &&
        other.intervention == intervention;
  }

  @override
  int get hashCode =>
      Object.hash(enrolled, enrolledMin, enrolledMax, intervention);
}

extension StudyInviteX on StudyInvite {
  bool get hasPreconfiguredSchedule =>
      preselectedInterventionIds != null &&
      preselectedInterventionIds!.isNotEmpty;
}
