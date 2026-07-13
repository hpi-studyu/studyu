import 'package:studyu_core/core.dart';

enum InviteCodesSortColumn { code, enrolled, createdAt, updatedAt }

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
    this.createdFrom,
    this.createdTo,
    this.updatedFrom,
    this.updatedTo,
  });

  final InviteCodeEnrolledFilter enrolled;
  final int? enrolledMin;
  final int? enrolledMax;
  final InviteCodeInterventionFilter intervention;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final DateTime? updatedFrom;
  final DateTime? updatedTo;

  bool get isEmpty =>
      enrolled == InviteCodeEnrolledFilter.all &&
      enrolledMin == null &&
      enrolledMax == null &&
      intervention == InviteCodeInterventionFilter.all &&
      createdFrom == null &&
      createdTo == null &&
      updatedFrom == null &&
      updatedTo == null;

  int get activeCount =>
      (enrolled != InviteCodeEnrolledFilter.all ? 1 : 0) +
      (enrolledMin != null ? 1 : 0) +
      (enrolledMax != null ? 1 : 0) +
      (intervention != InviteCodeInterventionFilter.all ? 1 : 0) +
      (createdFrom != null ? 1 : 0) +
      (createdTo != null ? 1 : 0) +
      (updatedFrom != null ? 1 : 0) +
      (updatedTo != null ? 1 : 0);

  InviteCodeFilters copyWith({
    InviteCodeEnrolledFilter? enrolled,
    int? enrolledMin,
    bool clearEnrolledMin = false,
    int? enrolledMax,
    bool clearEnrolledMax = false,
    InviteCodeInterventionFilter? intervention,
    DateTime? createdFrom,
    bool clearCreatedFrom = false,
    DateTime? createdTo,
    bool clearCreatedTo = false,
    DateTime? updatedFrom,
    bool clearUpdatedFrom = false,
    DateTime? updatedTo,
    bool clearUpdatedTo = false,
  }) {
    return InviteCodeFilters(
      enrolled: enrolled ?? this.enrolled,
      enrolledMin: clearEnrolledMin ? null : enrolledMin ?? this.enrolledMin,
      enrolledMax: clearEnrolledMax ? null : enrolledMax ?? this.enrolledMax,
      intervention: intervention ?? this.intervention,
      createdFrom: clearCreatedFrom ? null : createdFrom ?? this.createdFrom,
      createdTo: clearCreatedTo ? null : createdTo ?? this.createdTo,
      updatedFrom: clearUpdatedFrom ? null : updatedFrom ?? this.updatedFrom,
      updatedTo: clearUpdatedTo ? null : updatedTo ?? this.updatedTo,
    );
  }

  InviteCodeFilters normalized() {
    final normalizedCreatedFrom = _dateOnly(createdFrom);
    final normalizedCreatedTo = _dateOnly(createdTo);
    final normalizedUpdatedFrom = _dateOnly(updatedFrom);
    final normalizedUpdatedTo = _dateOnly(updatedTo);

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
      createdFrom: normalizedCreatedFrom,
      createdTo: normalizedCreatedTo,
      updatedFrom: normalizedUpdatedFrom,
      updatedTo: normalizedUpdatedTo,
    );
  }

  static DateTime? _dateOnly(DateTime? value) {
    if (value == null) return null;
    return DateTime(value.year, value.month, value.day);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InviteCodeFilters &&
        other.enrolled == enrolled &&
        other.enrolledMin == enrolledMin &&
        other.enrolledMax == enrolledMax &&
        other.intervention == intervention &&
        other.createdFrom == createdFrom &&
        other.createdTo == createdTo &&
        other.updatedFrom == updatedFrom &&
        other.updatedTo == updatedTo;
  }

  @override
  int get hashCode => Object.hash(
    enrolled,
    enrolledMin,
    enrolledMax,
    intervention,
    createdFrom,
    createdTo,
    updatedFrom,
    updatedTo,
  );
}

extension StudyInviteX on StudyInvite {
  bool get hasPreconfiguredSchedule =>
      preselectedInterventionIds != null &&
      preselectedInterventionIds!.isNotEmpty;
}
