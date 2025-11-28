# Intervention Scheduling JSON Model Definition

## Overview

This document defines the JSON structure for the enhanced intervention scheduling system that
supports:

- Subset intervention selection for participants
- Intervention mapping (hardcoded interventions OR participant choices)
- Individual durations per intervention in alternating/counter-balanced segments

---

## Core Data Structures

### 1. AdaptiveStudySchedule (Root Model)

```json
{
  "selectedInterventions": [
    "intervention_id_1",
    "intervention_id_2",
    "intervention_id_3"
  ],
  "minInterventionsToSelect": 2,
  "maxInterventionsToSelect": 3,
  "segments": [
    // Array of segment objects (see below)
  ]
}
```

**Fields:**

- `selectedInterventions`: Array of intervention IDs that participants can choose from
- `minInterventionsToSelect`: Minimum number of interventions participants must select (≥ 2)
- `maxInterventionsToSelect`: Maximum number of interventions participants can select (≥ min)
- `segments`: Array of schedule segment objects

---

## Segment Types

### 2. ObservationScheduleSegment

```json
{
  "type": "observation",
  "duration": 7
}
```

**Fields:**

- `type`: Always "observation"
- `duration`: Number of days (integer)

**Purpose:**

- **Baseline**:
    - Typically at study start
    - No prior intervention exposure
    - Establishes participant's normal state
    - Used for pre/post comparisons

- **Washout**:
    - Between or after interventions
    - Allows intervention effects to clear
    - Prevents carryover effects
    - Monitors dissipation of previous intervention

**Benefits of Generic Type:**

1. Single segment type handles both use cases
3. Easier timeline visualization (same structure, different labels/colors)
4. Flexible for future observation purposes (e.g., "followup", "monitoring")
5. Simpler model with clear intent

**Changes from current:**

- Rename `BaselineScheduleSegment` to `ObservationScheduleSegment`

---

### 3. SingleInterventionScheduleSegment (UPDATED)

```json
{
  "type": "singleIntervention",
  "interventionRef": {
    "type": "hardcoded",
    "interventionId": "intervention_xyz"
  },
  "duration": 14
}
```

OR

```json
{
  "type": "singleIntervention",
  "interventionRef": {
    "type": "participantChoice",
    "choiceIndex": 0
  },
  "duration": 14
}
```

**Fields:**

- `type`: Always "singleIntervention"
- `interventionRef`: Object containing intervention reference
    - `type`: Either "hardcoded" or "participantChoice"
    - `interventionId`: (only if type="hardcoded") The specific intervention ID to use
    - `choiceIndex`: (only if type="participantChoice") Index of participant's selection (0=A, 1=B,
      2=C, etc.)
- `duration`: Number of days (integer)

**Changes from current:**

- Replace `interventionIndex: int` with `interventionRef: InterventionReference` object
- Allows specifying either a hardcoded intervention OR a participant choice

---

### 4. AlternatingScheduleSegment (UPDATED)

```json
{
  "type": "alternating",
  "cycleAmount": 2,
  "interventionSequence": [
    {
      "interventionRef": {
        "type": "hardcoded",
        "interventionId": "intervention_123"
      },
      "duration": 7
    },
    {
      "interventionRef": {
        "type": "participantChoice",
        "choiceIndex": 0
      },
      "duration": 10
    },
    {
      "interventionRef": {
        "type": "participantChoice",
        "choiceIndex": 1
      },
      "duration": 7
    }
  ],
  "balanceFirstIntervention": false,
  "balanceRatio": 0.5
}
```

**Fields:**

- `type`: Always "alternating"
- `cycleAmount`: Number of cycles through the sequence (integer)
- `interventionSequence`: Array of intervention assignments (one per position A, B, C, etc.)
    - Each element contains:
        - `interventionRef`: Object containing intervention reference (same structure as
          SingleIntervention)
            - `type`: Either "hardcoded" or "participantChoice"
            - `interventionId`: (only if type="hardcoded")
            - `choiceIndex`: (only if type="participantChoice")
        - `duration`: Number of days for this specific intervention (integer)
- `balanceFirstIntervention`: Boolean, whether to balance (only meaningful with 2 interventions)
- `balanceRatio`: Double (0.0 to 1.0), ratio for first group (default 0.5 = 50/50)

**Changes from current:**

- Remove `interventionDuration: int` (now per-intervention in sequence)
- Remove `interventionIds: List<String>?` (replaced by interventionSequence)
- Add `interventionSequence: List<InterventionAssignment>` with per-intervention durations
- Keep `balanceFirstIntervention` and `balanceRatio` for 2-intervention case

**Total Duration Calculation:**

```
totalDuration = cycleAmount × sum(interventionSequence[i].duration for all i)
```

**Pattern Example (3 interventions, 2 cycles):**

```
Cycle 1: [A:7 days] → [B:10 days] → [C:7 days]
Cycle 2: [A:7 days] → [B:10 days] → [C:7 days]
Total: 48 days
```

---

### 5. CounterBalancedScheduleSegment (UPDATED)

```json
{
  "type": "counterBalanced",
  "cycleAmount": 3,
  "interventionSequence": [
    {
      "interventionRef": {
        "type": "participantChoice",
        "choiceIndex": 0
      },
      "duration": 7
    },
    {
      "interventionRef": {
        "type": "participantChoice",
        "choiceIndex": 1
      },
      "duration": 7
    }
  ],
  "balanceFirstIntervention": true,
  "balanceRatio": 0.6
}
```

**Fields:**

- `type`: Always "counterBalanced"
- `cycleAmount`: Number of cycles through rotated sequences (integer)
- `interventionSequence`: Array of intervention assignments (one per position A, B, C, etc.)
    - Same structure as AlternatingScheduleSegment
- `balanceFirstIntervention`: Boolean, whether to balance starting position
- `balanceRatio`: Double (0.0 to 1.0), ratio for first group

**Changes from current:**

- Same changes as AlternatingScheduleSegment

**Rotation Logic:**

- Cycle 0: A, B, C
- Cycle 1: B, C, A (rotated by 1)
- Cycle 2: C, A, B (rotated by 2)
- Each intervention keeps its own duration across cycles

---

### 6. ThompsonSamplingScheduleSegment

```json
{
  "type": "thompsonSampling",
  "interventionDuration": 3,
  "interventionDrawAmount": 10,
  "observationId": "observation_123",
  "questionId": "question_456"
}
```

**No changes needed - already implemented**

---

## Supporting Types

### InterventionReference (New Type)

```typescript
type InterventionReference = 
  | HardcodedInterventionReference
  | ParticipantChoiceReference;

interface HardcodedInterventionReference {
  type: "hardcoded";
  interventionId: string;
}

interface ParticipantChoiceReference {
  type: "participantChoice";
  choiceIndex: number; // 0=A, 1=B, 2=C, etc.
}
```

**Used in:**

- SingleInterventionScheduleSegment.interventionRef
- InterventionAssignment.interventionRef

---

### InterventionAssignment (New Type)

```typescript
interface InterventionAssignment {
  interventionRef: InterventionReference;
  duration: number; // days
}
```

**Used in:**

- AlternatingScheduleSegment.interventionSequence
- CounterBalancedScheduleSegment.interventionSequence

---

## Complete Example Study

```json
{
  "selectedInterventions": [
    "exercise_intervention",
    "meditation_intervention",
    "diet_intervention",
    "sleep_intervention"
  ],
  "minInterventionsToSelect": 2,
  "maxInterventionsToSelect": 3,
  "segments": [
    {
      "type": "baseline",
      "duration": 7
    },
    {
      "type": "singleIntervention",
      "interventionRef": {
        "type": "hardcoded",
        "interventionId": "exercise_intervention"
      },
      "duration": 14
    },
    {
      "type": "washout",
      "duration": 3
    },
    {
      "type": "alternating",
      "cycleAmount": 2,
      "interventionSequence": [
        {
          "interventionRef": {
            "type": "participantChoice",
            "choiceIndex": 0
          },
          "duration": 7
        },
        {
          "interventionRef": {
            "type": "participantChoice",
            "choiceIndex": 1
          },
          "duration": 10
        },
        {
          "interventionRef": {
            "type": "hardcoded",
            "interventionId": "sleep_intervention"
          },
          "duration": 5
        }
      ],
      "balanceFirstIntervention": false,
      "balanceRatio": 0.5
    },
    {
      "type": "washout",
      "duration": 5
    },
    {
      "type": "counterBalanced",
      "cycleAmount": 2,
      "interventionSequence": [
        {
          "interventionRef": {
            "type": "participantChoice",
            "choiceIndex": 0
          },
          "duration": 7
        },
        {
          "interventionRef": {
            "type": "participantChoice",
            "choiceIndex": 1
          },
          "duration": 7
        }
      ],
      "balanceFirstIntervention": true,
      "balanceRatio": 0.7
    },
    {
      "type": "washout",
      "duration": 3
    },
    {
      "type": "thompsonSampling",
      "interventionDuration": 3,
      "interventionDrawAmount": 10,
      "observationId": "daily_survey",
      "questionId": "mood_rating"
    }
  ]
}
```

**Study Flow:**

1. **Baseline** (7 days): Pre-study observation
2. **Single Intervention** (14 days): Hardcoded exercise
3. **Washout** (3 days): Clear exercise effects
4. **Alternating** (44 days): 3 interventions × 2 cycles
5. **Washout** (5 days): Clear alternating effects
6. **Counter-Balanced** (28 days): 2 interventions × 2 cycles
7. **Washout** (3 days): Clear counter-balanced effects
8. **Thompson Sampling** (30 days): Adaptive selection

**Total Duration:** 134 days

---

## Validation Rules

### Global Validation

1. `minInterventionsToSelect` ≥ 2
2. `maxInterventionsToSelect` ≥ `minInterventionsToSelect`
3. `selectedInterventions.length` ≥ 2
4. All interventionId references must exist in study's intervention pool
5. All choiceIndex values must be < `selectedInterventions.length`

### Segment-Specific Validation

**SingleInterventionScheduleSegment:**

- `duration` > 0
- If `type="hardcoded"`: `interventionId` must exist
- If `type="participantChoice"`: `choiceIndex` must be valid

**AlternatingScheduleSegment:**

- `cycleAmount` > 0
- `interventionSequence.length` ≥ 2
- Each `duration` > 0
- `balanceRatio` must be between 0.0 and 1.0
- All interventionRef references must be valid

**CounterBalancedScheduleSegment:**

- Same as AlternatingScheduleSegment

---

## Migration from Current Model

### Current → New Mapping

**SingleInterventionScheduleSegment:**

```dart
// OLD
{
"interventionIndex": 0, // Always referred to participant choice
"duration": 14
}

// NEW (equivalent)
    {
"interventionRef": {
"type": "participantChoice",
"choiceIndex": 0
},
"duration": 14
}
```

**AlternatingScheduleSegment:**

```dart
// OLD
{
"interventionDuration": 7,
"cycleAmount": 2,
"interventionIds": null // Used all interventions
}

// NEW (equivalent - use first 2 participant choices)
    {
"cycleAmount": 2,
"interventionSequence": [
{
"interventionRef": {"type": "participantChoice", "choiceIndex": 0},
"duration": 7
},
{
"interventionRef": {"type": "participantChoice", "choiceIndex": 1},
"duration": 7
}
]
}
```

---

## UI Form Field Mappings

### Single Intervention Form

- **Intervention Dropdown**: Maps to `interventionRef`
    - Options: All defined interventions (hardcoded) + All participant choices
    - Value: Either `{type: "hardcoded", interventionId: "..."}` or
      `{type: "participantChoice", choiceIndex: N}`
- **Duration Field**: Maps to `duration`

### Alternating/Counter-Balanced Form

- **Cycle Amount Field**: Maps to `cycleAmount`
- **Intervention Mapping Table**: Maps to `interventionSequence[]`
    - Rows: One per selected intervention (A, B, C, ...)
    - Columns:
        - Position Label (A, B, C, ...)
        - Intervention Dropdown (hardcoded + choices)
        - Duration Field (days)
- **Balance Checkbox**: Maps to `balanceFirstIntervention` (only visible with 2 interventions)
- **Balance Ratio Slider**: Maps to `balanceRatio` (only visible when balancing enabled)

---

## Backend/Runtime Interpretation

### Participant Study Instance Resolution

When a participant starts the study:

1. Participant selects N interventions from `selectedInterventions` (where N is between min and max)
2. These become "Choice A", "Choice B", "Choice C", etc. based on selection order
3. For each segment, resolve `interventionRef`:
    - If `type="hardcoded"`: Use the specified `interventionId` directly
    - If `type="participantChoice"`: Use `participant.selectedInterventions[choiceIndex]`

**Example:**

```json
// Study Definition
{
  "selectedInterventions": [
    "ex1",
    "ex2",
    "ex3",
    "ex4"
  ],
  "segment": {
    "interventionSequence": [
      {
        "interventionRef": {
          "type": "hardcoded",
          "interventionId": "ex1"
        },
        "duration": 7
      },
      {
        "interventionRef": {
          "type": "participantChoice",
          "choiceIndex": 0
        },
        "duration": 10
      },
      {
        "interventionRef": {
          "type": "participantChoice",
          "choiceIndex": 1
        },
        "duration": 7
      }
    ]
  }
}

// Participant selects: ["ex3", "ex4", "ex2"]
// Resolved sequence:
// Position A: ex1 (hardcoded) - 7 days
// Position B: ex3 (participant's choice 0) - 10 days  
// Position C: ex4 (participant's choice 1) - 7 days
```

---

## Implementation Checklist

### Dart Models (core package)

- [ ] Create `InterventionReference` abstract class
- [ ] Create `HardcodedInterventionReference` extends `InterventionReference`
- [ ] Create `ParticipantChoiceReference` extends `InterventionReference`
- [ ] Create `InterventionAssignment` class
- [ ] Update `SingleInterventionScheduleSegment` to use `InterventionReference`
- [ ] Update `AlternatingScheduleSegment` to use `interventionSequence`
- [ ] Update `CounterBalancedScheduleSegment` to use `interventionSequence`
- [ ] Add JSON serialization for all new types
- [ ] Update `getDuration()` calculations
- [ ] (Optional) Create `WashoutScheduleSegment` as distinct from `BaselineScheduleSegment`

### Form Controllers (designer_v2)

- [ ] Update form group creation methods
- [ ] Add `interventionSequence` form array handling
- [ ] Update segment-to-form and form-to-segment conversions
- [ ] Add validation logic
- [ ] (Optional) Add washout segment form handling

### UI Components (designer_v2)

- [ ] Create intervention mapping table widget
- [ ] Update single intervention controls
- [ ] Update alternating controls with table
- [ ] Update counter-balanced controls with table
- [ ] Update timeline visualization
- [ ] (Optional) Add washout segment to "Add Schedule Block" menu with distinct styling

---

**End of Model Definition**

