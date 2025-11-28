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
  - `interventionId`: (only if type="hardcoded") The specific intervention ID from ALL defined
    interventions in the study (NOT limited to selectedInterventions)
  - `choiceIndex`: (only if type="participantChoice") Index of participant's selection (0=A, 1=B,
    2=C, etc.) from selectedInterventions
- `duration`: Number of days (integer)

**Changes from current:**

- Replace `interventionIndex: int` with `interventionRef: InterventionReference` object
- Allows specifying either a hardcoded intervention OR a participant choice

**Important:** Hardcoded interventions can reference ANY intervention defined in the study, not just
those in `selectedInterventions`. This allows researchers to assign specific interventions that
participants don't choose themselves (e.g., control conditions, mandatory interventions).

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
  "randomization": {
    "enabled": false,
    "seed": null,
    "randomizePerCycle": false,
    "preventConsecutive": false
  },
  "balanceFirstIntervention": false,
  "balanceRatio": 0.5
}
```

**Fields:**

- `type`: Always "alternating"
- `cycleAmount`: Number of cycles through the sequence (integer)
- `interventionSequence`: Array of intervention assignments (one per position A, B, C, etc.)
    - Length determines number of interventions in rotation
    - Each element contains:
        - `interventionRef`: Object containing intervention reference (same structure as
          SingleIntervention)
            - `type`: Either "hardcoded" or "participantChoice"
          - `interventionId`: (only if type="hardcoded") Any intervention ID from ALL defined
            interventions (not limited to selectedInterventions)
          - `choiceIndex`: (only if type="participantChoice") Index into participant's selections (
            0=A, 1=B, 2=C, etc.)
        - `duration`: Number of days for this specific intervention (integer)
- `randomization`: (Optional) Randomization configuration
    - `enabled`: Boolean, if false uses fixed sequence A-B-C-A-B-C... (default: false)
    - `seed`: Integer or null, for reproducible randomization (default: null = truly random)
    - `randomizePerCycle`: Boolean, if true randomizes order every cycle; if false randomizes once
      at study start and repeats (default: false, only used when enabled=true)
    - `preventConsecutive`: Boolean, prevents same intervention appearing twice in a row across
      cycle boundaries (default: false, only used when enabled=true)
- `balanceFirstIntervention`: Boolean, whether to balance starting position (only meaningful with 2
  interventions in sequence AND randomization.enabled = false)
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

**Pattern Examples:**

**1. Deterministic (randomization.enabled = false):**
```
3 interventions, 2 cycles:
Cycle 1: [A:7 days] → [B:10 days] → [C:7 days]
Cycle 2: [A:7 days] → [B:10 days] → [C:7 days]
Total: 48 days
Pattern: Fixed A-B-C-A-B-C
Use Case: Classic alternating design, completely predictable
```

**2. Randomize Once (randomization.enabled = true, randomizePerCycle = false):**

```
3 interventions, 3 cycles:
Order determined at study start: C-A-B
Cycle 1: [C:7 days] → [A:7 days] → [B:10 days]
Cycle 2: [C:7 days] → [A:7 days] → [B:10 days]  (same order)
Cycle 3: [C:7 days] → [A:7 days] → [B:10 days]  (same order)
Total: 72 days
Pattern: Random order chosen once, then repeated
Use Case: Participant fairness with within-participant consistency
```

**3. Randomize Every Cycle (randomization.enabled = true, randomizePerCycle = true,
preventConsecutive = false):**

```
3 interventions, 3 cycles:
Cycle 1: [C:7 days] → [A:7 days] → [B:10 days]  (randomized)
Cycle 2: [B:10 days] → [C:7 days] → [A:7 days]  (randomized again)
Cycle 3: [A:7 days] → [B:10 days] → [C:7 days]  (randomized again)
Total: 72 days
Pattern: Different random order each cycle
Note: B-B could occur across cycle 1→2 boundary (ends B, starts B)
Use Case: Maximum unpredictability, testing order effects
```

**4. Randomize Every Cycle with Constraint (randomization.enabled = true, randomizePerCycle = true,
preventConsecutive = true):**

```
2 interventions, 4 cycles:
Cycle 1: [A:7 days] → [B:10 days]  (ends with B)
Cycle 2: [A:7 days] → [B:10 days]  (forced to start with A, not B)
Cycle 3: [B:10 days] → [A:7 days]  (ends with A)
Cycle 4: [B:10 days] → [A:7 days]  (forced to start with B, not A)
Total: 68 days
Pattern: Random per cycle but no consecutive duplicates across boundaries
Use Case: Unpredictable but avoid potential carryover confusion

Example with 3 interventions:
Cycle 1: [A:7] → [B:10] → [C:5]  (ends with C)
Cycle 2: [A:7] → [B:10] → [C:5]  (forced to not start with C)
Cycle 3: [B:10] → [C:5] → [A:7]  (ends with A)
Cycle 4: [C:5] → [B:10] → [A:7]  (forced to not start with A)
```

**Important:** When `randomization.enabled = false`, consecutive duplicates across cycle boundaries
are already impossible by design because the pattern is fixed (A-B-C-A-B-C never has duplicates).

**Note:** Counter-Balanced segments do NOT support randomization - their deterministic rotation
pattern is fundamental to counter-balancing design.

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

**Why No Randomization:**
Counter-balanced segments are designed to systematically control for order effects by ensuring each
intervention appears in each ordinal position an equal number of times. Adding randomization would
destroy this property and defeat the purpose of counter-balancing. If you need random sequencing,
use AlternatingScheduleSegment with `randomization.enabled = true`.

**Balancing Feature:**
The `balanceFirstIntervention` feature randomizes which rotation cycle a participant starts with (
e.g., 60% start with rotation 0, 40% start with rotation 1), not the rotation pattern itself. This
provides participant-level randomization while preserving the counter-balanced design.

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

## Randomization Use Cases

### Overview

The randomization feature in **AlternatingScheduleSegment** provides flexible control over
intervention sequencing. This section details all possible configurations and their use cases.

### Randomization Configuration Matrix

| `enabled` | `randomizePerCycle` | `preventConsecutive` | Behavior                                                           |
|-----------|---------------------|----------------------|--------------------------------------------------------------------|
| `false`   | N/A                 | N/A                  | Fixed sequence A-B-C-A-B-C (deterministic)                         |
| `true`    | `false`             | N/A                  | Randomize once at start, repeat same order all cycles              |
| `true`    | `true`              | `false`              | Randomize order every cycle, consecutive allowed across boundaries |
| `true`    | `true`              | `true`               | Randomize order every cycle, prevent consecutive across boundaries |

### Detailed Use Cases

#### **Use Case 1: Fixed Alternating (Classic Design)**

```json
{
  "type": "alternating",
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
  "randomization": {
    "enabled": false
  }
}
```

**Result:**

- Participant selects: [Exercise, Meditation]
- Schedule: Exercise-Meditation-Exercise-Meditation-Exercise-Meditation
- Total: 42 days (6 periods × 7 days)

**When to use:**

- Classic N-of-1 trial design
- Need predictable pattern for participant planning
- Comparing intervention order is not a concern

---

#### **Use Case 2: Randomize Once for Fairness**

```json
{
  "type": "alternating",
  "cycleAmount": 4,
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
    },
    {
      "interventionRef": {
        "type": "participantChoice",
        "choiceIndex": 2
      },
      "duration": 7
    }
  ],
  "randomization": {
    "enabled": true,
    "seed": null,
    "randomizePerCycle": false,
    "preventConsecutive": false
  }
}
```

**Result (example):**

- Participant selects: [Exercise, Meditation, Diet]
- Random order chosen: Meditation-Diet-Exercise
- Cycle 1: Meditation-Diet-Exercise
- Cycle 2: Meditation-Diet-Exercise
- Cycle 3: Meditation-Diet-Exercise
- Cycle 4: Meditation-Diet-Exercise
- Total: 84 days (12 periods × 7 days)

**When to use:**

- Avoid order bias across participants (some start with A, others with B)
- Want consistency within each participant's schedule
- Participant can learn and anticipate their pattern

---

#### **Use Case 3: Maximum Unpredictability**

```json
{
  "type": "alternating",
  "cycleAmount": 5,
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
  "randomization": {
    "enabled": true,
    "seed": null,
    "randomizePerCycle": true,
    "preventConsecutive": false
  }
}
```

**Result (example):**

- Participant selects: [Exercise, Meditation]
- Cycle 1: A-B
- Cycle 2: B-A  (ends with A)
- Cycle 3: A-B  (starts with A) ← Consecutive A-A across boundary
- Cycle 4: B-A
- Cycle 5: A-B
- Total: 70 days

**When to use:**

- Testing whether intervention order matters
- Preventing pattern learning/expectation effects
- Maximizing ecological validity (real life is unpredictable)

**Caveat:** Can produce consecutive same interventions across cycle boundaries

---

#### **Use Case 4: Unpredictable with Constraint**

```json
{
  "type": "alternating",
  "cycleAmount": 6,
  "interventionSequence": [
    {
      "interventionRef": {
        "type": "hardcoded",
        "interventionId": "control"
      },
      "duration": 5
    },
    {
      "interventionRef": {
        "type": "participantChoice",
        "choiceIndex": 0
      },
      "duration": 10
    }
  ],
  "randomization": {
    "enabled": true,
    "seed": 12345,
    "randomizePerCycle": true,
    "preventConsecutive": true
  }
}
```

**Result (example with seed):**

- Participant selects: [Exercise]
- Intervention mapping: A=Control, B=Exercise
- Cycle 1: A-B  (ends with B)
- Cycle 2: A-B  (forced to start with A)
- Cycle 3: B-A  (ends with A)
- Cycle 4: B-A  (forced to start with B)
- Cycle 5: A-B
- Cycle 6: A-B
- Total: 90 days

**When to use:**

- Need unpredictability but avoid confusion of back-to-back same interventions
- Minimize potential carryover effects appearing consecutive
- Reproducible results (seed = 12345)

---

#### **Use Case 5: Complex Multi-Intervention Randomization**

```json
{
  "type": "alternating",
  "cycleAmount": 3,
  "interventionSequence": [
    {
      "interventionRef": {
        "type": "hardcoded",
        "interventionId": "baseline_supplement"
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
      "duration": 10
    },
    {
      "interventionRef": {
        "type": "hardcoded",
        "interventionId": "washout"
      },
      "duration": 3
    }
  ],
  "randomization": {
    "enabled": true,
    "randomizePerCycle": true,
    "preventConsecutive": true
  }
}
```

**Result (example):**

- Participant selects: [Exercise, Diet]
- Intervention mapping: A=Baseline, B=Exercise, C=Diet, D=Washout
- Cycle 1: B-D-A-C (30 days)
- Cycle 2: C-A-D-B (30 days, prevented starting with C from cycle 1)
- Cycle 3: A-C-B-D (30 days, prevented starting with B from cycle 2)
- Total: 90 days

**When to use:**

- Complex protocols with mandatory elements (baseline, washout)
- Mix hardcoded and participant-selected interventions
- Want randomization but maintain logical constraints

---

### Comparison: Alternating vs Counter-Balanced

| Feature                           | Alternating (Random)             | Counter-Balanced                                 |
|-----------------------------------|----------------------------------|--------------------------------------------------|
| **Within-Participant Pattern**    | Can be randomized                | Always deterministic rotation                    |
| **Purpose**                       | Flexible sequencing              | Control position effects                         |
| **Order Control**                 | Each intervention once per cycle | Each intervention in each position across cycles |
| **Between-Participant Variation** | `randomization` settings         | `balanceFirstIntervention` only                  |
| **Use Case**                      | Unpredictability, fairness       | Systematic order effect control                  |

**Example showing the difference:**

**Alternating with randomization (3 interventions, 3 cycles):**

```
Participant 1: C-A-B, A-C-B, B-A-C (random per cycle)
Participant 2: B-C-A, C-B-A, A-B-C (different random per cycle)
```

Each participant gets different orders, A/B/C appear once per cycle.

**Counter-Balanced (3 interventions, 3 cycles):**

```
Participant 1 (starts cycle 0): A-B-C, B-C-A, C-A-B
Participant 2 (starts cycle 1): B-C-A, C-A-B, A-B-C
Participant 3 (starts cycle 2): C-A-B, A-B-C, B-C-A
```

Each participant follows deterministic rotation, different starting points ensure each intervention
appears in each position across the participant pool.

---

## Validation Rules

### Global Validation

1. `minInterventionsToSelect` ≥ 2
2. `maxInterventionsToSelect` ≥ `minInterventionsToSelect`
3. `selectedInterventions.length` ≥ 2
4. All `interventionId` references (hardcoded) must exist in study's FULL intervention pool (not
   just selectedInterventions)
5. All `choiceIndex` values (participant choice) must be < `selectedInterventions.length`
6. `selectedInterventions` must be a subset of all defined interventions

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
- If `randomization.enabled = false`: `randomizePerCycle` and `preventConsecutive` are ignored
- If `randomization.enabled = true` and `randomizePerCycle = false`: `preventConsecutive` is
  ignored (no consecutive possible when repeating same order)
- `seed` must be null or positive integer

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

**Form Layout:**

```
┌─────────────────────────────────────────────────┐
│ Intervention Choice                              │
│ ┌─────────────────────────────────────────────┐ │
│ │ [Dropdown: Select intervention...]          │ │
│ └─────────────────────────────────────────────┘ │
│                                                  │
│ Duration (days)                                  │
│ ┌─────────────────────────────────────────────┐ │
│ │ [14                                        ] │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

**Intervention Choice Dropdown Options:**

- **Section 1: Hardcoded Interventions** (All defined interventions in study)
    - "Exercise" → `{type: "hardcoded", interventionId: "exercise_id"}`
    - "Meditation" → `{type: "hardcoded", interventionId: "meditation_id"}`
    - "Diet" → `{type: "hardcoded", interventionId: "diet_id"}`
    - "Sleep" → `{type: "hardcoded", interventionId: "sleep_id"}`
    - ... (all interventions defined in study)
- **Divider**
- **Section 2: Participant Choices** (Based on selectedInterventions)
    - "Choice A (Participant's 1st selection)" → `{type: "participantChoice", choiceIndex: 0}`
    - "Choice B (Participant's 2nd selection)" → `{type: "participantChoice", choiceIndex: 1}`
    - "Choice C (Participant's 3rd selection)" → `{type: "participantChoice", choiceIndex: 2}`
    - ... (up to selectedInterventions.length)

**Key Point:** Hardcoded section shows ALL interventions defined in the study, NOT filtered by
selectedInterventions. This allows researchers to assign specific interventions (like controls) that
participants don't select.

---

### Alternating/Counter-Balanced Form

**Form Layout:**

```
┌─────────────────────────────────────────────────────────────────────┐
│ Cycle Amount                                                         │
│ ┌─────────────────────────────────────────────┐                     │
│ │ [2                                        ] │                     │
│ └─────────────────────────────────────────────┘                     │
│                                                                      │
│ Intervention Mapping                                                │
│ ┌───────────────────────────────────────────────────────────────┐  │
│ │ Position │ Intervention                      │ Duration (days) │  │
│ ├──────────┼───────────────────────────────────┼────────────────┤  │
│ │ A        │ [Dropdown: Select...]             │ [7           ] │  │
│ │ B        │ [Dropdown: Select...]             │ [10          ] │  │
│ │ C        │ [Dropdown: Select...]             │ [5           ] │  │
│ │ [+ Add Position]                                               │  │
│ └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│ [x] Balance first intervention (50% start A, 50% start B)          │
│                                                                      │
│ Balance Ratio                                                       │
│ 60% start with A, 40% start with B                                 │
│ ├────────●──────────────┤ 0.6                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Intervention Mapping Table:**

- **Dynamic Rows**: Researcher can add/remove positions (A, B, C, D, etc.)
    - Minimum: 2 positions
    - Maximum: No limit (but typically 2-5 for practical studies)
    - Each position becomes an entry in `interventionSequence[]`

**Intervention Dropdown per Row:**
Same structure as Single Intervention:

- **Section 1: Hardcoded Interventions** (ALL defined interventions)
    - Full list of all interventions in study
    - Not filtered by selectedInterventions
    - Allows assigning specific interventions (e.g., control, placebo)
- **Divider**
- **Section 2: Participant Choices**
    - "Choice A (Participant's 1st selection)"
    - "Choice B (Participant's 2nd selection)"
    - etc.

**Duration Field per Row:**

- Individual duration for each position
- Allows different intervention lengths (e.g., A:7 days, B:10 days, C:5 days)
- Total segment duration = cycleAmount × sum of all durations

**Add Position Button:**

- Adds a new row to the table
- New position gets next letter (D, E, F, etc.)
- Can be removed if not needed

**Balance Controls:**

- Only visible when exactly 2 positions defined
- Checkbox enables/disables balancing
- Slider appears when balancing enabled
- Controls starting position randomization ratio

---

### Example UI Interactions

**Scenario 1: Study with 5 defined interventions, 3 selected for participants**

**Study Setup:**

- All Interventions: [Exercise, Meditation, Diet, Sleep, Journaling]
- Selected for Participants: [Exercise, Meditation, Diet]

**Single Intervention Dropdown Shows:**

```
Hardcoded Interventions:
  └─ Exercise
  └─ Meditation  
  └─ Diet
  └─ Sleep
  └─ Journaling
─────────────────
Participant Choices:
  └─ Choice A (Participant's 1st selection)
  └─ Choice B (Participant's 2nd selection)
  └─ Choice C (Participant's 3rd selection)
```

**Researcher can:**

- Assign hardcoded "Sleep" even though participants don't select it
- Assign "Choice A" which will be resolved to participant's 1st selection at runtime
- Mix hardcoded and participant choices in alternating segments

**Scenario 2: Alternating segment with mixed assignment**

**Researcher Configures:**

```
Position A: Hardcoded "Sleep" - 7 days
Position B: Choice A - 10 days  
Position C: Choice B - 5 days
Cycles: 2
```

**JSON Output:**

```json
{
  "interventionSequence": [
    {
      "interventionRef": {"type": "hardcoded", "interventionId": "sleep_id"},
      "duration": 7
    },
    {
      "interventionRef": {"type": "participantChoice", "choiceIndex": 0},
      "duration": 10
    },
    {
      "interventionRef": {"type": "participantChoice", "choiceIndex": 1},
      "duration": 5
    }
  ],
  "cycleAmount": 2
}
```

**Participant Runtime:**

- Participant selects: [Exercise, Meditation, Diet]
- Resolved schedule:
    - Cycle 1: Sleep(7) → Exercise(10) → Meditation(5)
    - Cycle 2: Sleep(7) → Exercise(10) → Meditation(5)
- Total: 44 days

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

