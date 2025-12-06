import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';

part 'filter_draft_controller.g.dart';

class FilterDraft {
  final String? loadedPresetId;

  final StudyStatus? status;
  final FilterOperator statusOp;

  final Participation? participation;
  final FilterOperator participationOp;

  final ResultSharing? resultSharing;
  final FilterOperator resultSharingOp;

  final bool? registryPublished;
  final FilterOperator registryPublishedOp;

  final bool? isOwner;
  final FilterOperator isOwnerOp;

  final String title;
  final FilterOperator titleOp;

  final String participantCount;
  final FilterOperator participantCountOp;

  final String activeSubjectCount;
  final FilterOperator activeSubjectCountOp;

  final String endedCount;
  final FilterOperator endedCountOp;

  final DateTime? createdAfter;
  final DateTime? createdBefore;

  final Set<String> expandedFields;

  const FilterDraft({
    this.loadedPresetId,
    this.status,
    this.statusOp = FilterOperator.equals,
    this.participation,
    this.participationOp = FilterOperator.equals,
    this.resultSharing,
    this.resultSharingOp = FilterOperator.equals,
    this.registryPublished,
    this.registryPublishedOp = FilterOperator.equals,
    this.isOwner,
    this.isOwnerOp = FilterOperator.equals,
    this.title = '',
    this.titleOp = FilterOperator.contains,
    this.participantCount = '',
    this.participantCountOp = FilterOperator.greaterThanOrEqual,
    this.activeSubjectCount = '',
    this.activeSubjectCountOp = FilterOperator.greaterThanOrEqual,
    this.endedCount = '',
    this.endedCountOp = FilterOperator.greaterThanOrEqual,
    this.createdAfter,
    this.createdBefore,
    this.expandedFields = const {},
  });

  FilterDraft copyWith({
    String? loadedPresetId,
    bool setLoadedPresetIdToNull = false,
    StudyStatus? status,
    bool setStatusToNull = false,
    FilterOperator? statusOp,
    Participation? participation,
    bool setParticipationToNull = false,
    FilterOperator? participationOp,
    ResultSharing? resultSharing,
    bool setResultSharingToNull = false,
    FilterOperator? resultSharingOp,
    bool? registryPublished,
    bool setRegistryPublishedToNull = false,
    FilterOperator? registryPublishedOp,
    bool? isOwner,
    bool setIsOwnerToNull = false,
    FilterOperator? isOwnerOp,
    String? title,
    FilterOperator? titleOp,
    String? participantCount,
    FilterOperator? participantCountOp,
    String? activeSubjectCount,
    FilterOperator? activeSubjectCountOp,
    String? endedCount,
    FilterOperator? endedCountOp,
    DateTime? createdAfter,
    bool setCreatedAfterToNull = false,
    DateTime? createdBefore,
    bool setCreatedBeforeToNull = false,
    Set<String>? expandedFields,
  }) {
    return FilterDraft(
      loadedPresetId: setLoadedPresetIdToNull
          ? null
          : loadedPresetId ?? this.loadedPresetId,
      status: setStatusToNull ? null : status ?? this.status,
      statusOp: statusOp ?? this.statusOp,
      participation: setParticipationToNull
          ? null
          : participation ?? this.participation,
      participationOp: participationOp ?? this.participationOp,
      resultSharing: setResultSharingToNull
          ? null
          : resultSharing ?? this.resultSharing,
      resultSharingOp: resultSharingOp ?? this.resultSharingOp,
      registryPublished: setRegistryPublishedToNull
          ? null
          : registryPublished ?? this.registryPublished,
      registryPublishedOp: registryPublishedOp ?? this.registryPublishedOp,
      isOwner: setIsOwnerToNull ? null : isOwner ?? this.isOwner,
      isOwnerOp: isOwnerOp ?? this.isOwnerOp,
      title: title ?? this.title,
      titleOp: titleOp ?? this.titleOp,
      participantCount: participantCount ?? this.participantCount,
      participantCountOp: participantCountOp ?? this.participantCountOp,
      activeSubjectCount: activeSubjectCount ?? this.activeSubjectCount,
      activeSubjectCountOp: activeSubjectCountOp ?? this.activeSubjectCountOp,
      endedCount: endedCount ?? this.endedCount,
      endedCountOp: endedCountOp ?? this.endedCountOp,
      createdAfter: setCreatedAfterToNull
          ? null
          : createdAfter ?? this.createdAfter,
      createdBefore: setCreatedBeforeToNull
          ? null
          : createdBefore ?? this.createdBefore,
      expandedFields: expandedFields ?? this.expandedFields,
    );
  }

  FilterGroup get toFilterGroup {
    final List<FilterCondition> conditions = [];

    if (status != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.status,
          operator: statusOp,
          value: status!.name,
        ),
      );
    }
    if (participation != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.participation,
          operator: participationOp,
          value: participation!.name,
        ),
      );
    }
    if (resultSharing != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.resultSharing,
          operator: resultSharingOp,
          value: resultSharing!.name,
        ),
      );
    }
    if (registryPublished != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.registryPublished,
          operator: registryPublishedOp,
          value: registryPublished,
        ),
      );
    }
    if (isOwner != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.owner,
          operator: isOwnerOp,
          value: isOwner,
        ),
      );
    }

    if (title.isNotEmpty) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.title,
          operator: titleOp,
          value: title,
        ),
      );
    }

    if (participantCount.isNotEmpty) {
      final val = int.tryParse(participantCount);
      if (val != null) {
        conditions.add(
          FilterCondition(
            property: StudyProperty.participantCount,
            operator: participantCountOp,
            value: val,
          ),
        );
      }
    }
    if (activeSubjectCount.isNotEmpty) {
      final val = int.tryParse(activeSubjectCount);
      if (val != null) {
        conditions.add(
          FilterCondition(
            property: StudyProperty.activeSubjectCount,
            operator: activeSubjectCountOp,
            value: val,
          ),
        );
      }
    }
    if (endedCount.isNotEmpty) {
      final val = int.tryParse(endedCount);
      if (val != null) {
        conditions.add(
          FilterCondition(
            property: StudyProperty.endedCount,
            operator: endedCountOp,
            value: val,
          ),
        );
      }
    }

    if (createdAfter != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.createdAt,
          operator: FilterOperator.greaterThanOrEqual,
          value: createdAfter,
        ),
      );
    }
    if (createdBefore != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.createdAt,
          operator: FilterOperator.lessThanOrEqual,
          value: createdBefore,
        ),
      );
    }

    return FilterGroup(children: conditions);
  }
}

@riverpod
class FilterDraftController extends _$FilterDraftController {
  @override
  FilterDraft build() {
    return const FilterDraft();
  }

  // Using separate controllers for text fields in UI, syncing via listeners or onChanged
  // But to be pure state, we should expose values.
  // The UI will likely need TextEditingControllers.
  // We can let the UI manage TECs and push changes here,
  // OR we keep TECs here. Keeping TECs in Notifier is bad practice (they are UI state).
  // So we will stick to String in state, and UI updates state on change.

  void updateLoadedPreset(String? id) {
    state = state.copyWith(
      loadedPresetId: id,
      setLoadedPresetIdToNull: id == null,
    );
  }

  void updateStatus(StudyStatus? value) {
    state = state.copyWith(status: value, setStatusToNull: value == null);
  }

  void updateStatusOp(FilterOperator op) {
    state = state.copyWith(statusOp: op);
  }

  void updateParticipation(Participation? value) {
    state = state.copyWith(
      participation: value,
      setParticipationToNull: value == null,
    );
  }

  void updateParticipationOp(FilterOperator op) {
    state = state.copyWith(participationOp: op);
  }

  void updateResultSharing(ResultSharing? value) {
    state = state.copyWith(
      resultSharing: value,
      setResultSharingToNull: value == null,
    );
  }

  void updateResultSharingOp(FilterOperator op) {
    state = state.copyWith(resultSharingOp: op);
  }

  void updateRegistryPublished(bool? value) {
    state = state.copyWith(
      registryPublished: value,
      setRegistryPublishedToNull: value == null,
    );
  }

  void updateRegistryPublishedOp(FilterOperator op) {
    state = state.copyWith(registryPublishedOp: op);
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateTitleOp(FilterOperator op) {
    state = state.copyWith(titleOp: op);
  }

  void updateParticipantCount(String value) {
    state = state.copyWith(participantCount: value);
  }

  void updateParticipantCountOp(FilterOperator op) {
    state = state.copyWith(participantCountOp: op);
  }

  void updateActiveSubjectCount(String value) {
    state = state.copyWith(activeSubjectCount: value);
  }

  void updateActiveSubjectCountOp(FilterOperator op) {
    state = state.copyWith(activeSubjectCountOp: op);
  }

  void updateEndedCount(String value) {
    state = state.copyWith(endedCount: value);
  }

  void updateEndedCountOp(FilterOperator op) {
    state = state.copyWith(endedCountOp: op);
  }

  void updateCreatedAfter(DateTime? value) {
    state = state.copyWith(
      createdAfter: value,
      setCreatedAfterToNull: value == null,
    );
  }

  void updateCreatedBefore(DateTime? value) {
    state = state.copyWith(
      createdBefore: value,
      setCreatedBeforeToNull: value == null,
    );
  }

  void toggleExpansion(String key, bool isExpanded) {
    final newSet = Set<String>.from(state.expandedFields);
    if (isExpanded) {
      newSet.add(key);
    } else {
      newSet.remove(key);
    }
    state = state.copyWith(expandedFields: newSet);
  }

  void resetAll({bool resetPresetId = true}) {
    state = FilterDraft(
      loadedPresetId: resetPresetId ? null : state.loadedPresetId,
    );
  }

  void initFromFilter(FilterGroup group, {String? presetId}) {
    // Start fresh but preserve IDs if needed
    var newState = const FilterDraft();
    if (presetId != null) {
      newState = newState.copyWith(loadedPresetId: presetId);
    }

    for (final child in group.children) {
      if (child is FilterCondition) {
        switch (child.property) {
          case StudyProperty.status:
            if (child.value is String) {
              newState = newState.copyWith(
                status: StudyStatus.values.asNameMap()[child.value],
                statusOp: child.operator,
              );
            }

          case StudyProperty.participation:
            if (child.value is String) {
              newState = newState.copyWith(
                participation: Participation.values.asNameMap()[child.value],
                participationOp: child.operator,
              );
            }

          case StudyProperty.resultSharing:
            if (child.value is String) {
              newState = newState.copyWith(
                resultSharing: ResultSharing.values.asNameMap()[child.value],
                resultSharingOp: child.operator,
              );
            }

          case StudyProperty.registryPublished:
            newState = newState.copyWith(
              registryPublished: child.value as bool?,
              registryPublishedOp: child.operator,
            );

          case StudyProperty.owner:
            newState = newState.copyWith(
              isOwner: child.value as bool?,
              isOwnerOp: child.operator,
            );

          case StudyProperty.title:
            newState = newState.copyWith(
              title: child.value as String? ?? '',
              titleOp: child.operator,
            );

          case StudyProperty.participantCount:
            newState = newState.copyWith(
              participantCount: child.value?.toString() ?? '',
              participantCountOp: child.operator,
            );

          case StudyProperty.activeSubjectCount:
            newState = newState.copyWith(
              activeSubjectCount: child.value?.toString() ?? '',
              activeSubjectCountOp: child.operator,
            );

          case StudyProperty.endedCount:
            newState = newState.copyWith(
              endedCount: child.value?.toString() ?? '',
              endedCountOp: child.operator,
            );

          case StudyProperty.createdAt:
            if (child.operator == FilterOperator.greaterThanOrEqual ||
                child.operator == FilterOperator.greaterThan) {
              newState = newState.copyWith(
                createdAfter: child.value as DateTime?,
              );
            } else if (child.operator == FilterOperator.lessThanOrEqual ||
                child.operator == FilterOperator.lessThan) {
              newState = newState.copyWith(
                createdBefore: child.value as DateTime?,
              );
            }

          default:
        }
      }
    }
    state = newState;
  }
}
