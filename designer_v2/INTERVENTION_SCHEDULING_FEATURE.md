# Intervention Scheduling Feature Documentation

**Last Updated:** November 27, 2025  
**Version:** Current Implementation Status

## Table of Contents

1. [Overview](#overview)
2. [Participant Intervention Selection](#participant-intervention-selection)
3. [Schedule Segment Types](#schedule-segment-types)
4. [Implemented Features](#implemented-features)
5. [Missing Features / Limitations](#missing-features--limitations)
6. [Use Cases & Examples](#use-cases--examples)

---

## Overview

The intervention scheduling system allows researchers to define flexible study schedules where
participants can select their own interventions from a researcher-defined list. The system supports
multiple scheduling patterns with configurable parameters.

### Key Concepts

- **Intervention Pool**: All interventions defined by the researcher in the study
- **Selected Interventions**: Subset of interventions that participants can choose from
- **Participant Choices**: The specific interventions a participant selects at study start
- **Schedule Segments**: Time blocks with different intervention assignment patterns

---

## Participant Intervention Selection

### Configuration Options

#### 1. **Available Interventions (Filter Chips)**

- Researchers select which interventions from the pool are available for participant selection
- **Default Behavior**: All defined interventions are selected by default
- **UI**: Multi-select filter chips showing intervention names
- **Persistence**: Selections are saved with the study configuration

#### 2. **Min/Max Selection Constraints**

- **Minimum Interventions**: Minimum number of interventions participants must select
    - Default: 2
    - Range: 1 to number of selected interventions

- **Maximum Interventions**: Maximum number of interventions participants can select
    - Default: Total number of selected interventions
    - Range: Must be ≥ minimum

- **Validation**: Max cannot be less than Min; enforced in UI

#### 3. **Choice Placeholders**

- Interventions selected by participants are referenced as "Choice A", "Choice B", "Choice C", etc.
- Order is determined by participant selection order
- Used throughout schedule segments to reference participant-selected interventions

### Example Configurations

**Configuration 1: Fixed Selection**

```
Pool: [Exercise, Meditation, Diet, Sleep]
Selected: [Exercise, Meditation, Diet]
Min: 3, Max: 3
→ All participants must select all 3 interventions
```

**Configuration 2: Flexible Selection**

```
Pool: [Exercise, Meditation, Diet, Sleep, Journaling]
Selected: [Exercise, Meditation, Diet, Sleep]
Min: 2, Max: 4
→ Participants can select 2, 3, or 4 interventions from the 4 available
```

**Configuration 3: Minimal Selection**

```
Pool: [Treatment A, Treatment B, Treatment C]
Selected: [Treatment A, Treatment B]
Min: 2, Max: 2
→ Participants must select exactly 2 interventions
```

---

## Schedule Segment Types

### 1. **Baseline Segment**

**Purpose**: Observation period before interventions begin

**Configuration:**

- Duration (days)

**Behavior:**

- No intervention assignment
- Pure observation/data collection period

**Example:**

```
Duration: 7 days
→ Days 0-6: Baseline observation
```

---

### 2. **Single Intervention Segment**

**Purpose**: Assign one specific participant-selected intervention for a fixed period

**Configuration:**

- Participant Choice (dropdown): A, B, C, ... (based on number of selected interventions)
- Duration (days)

**Behavior:**

- Uses one of the participant's selected interventions
- Intervention is constant for entire duration
- **Note**: Only shows participant choices, NOT hardcoded intervention names

**Dropdown Options:**

- "Choice A (Participant's 1st selection)"
- "Choice B (Participant's 2nd selection)"
- "Choice C (Participant's 3rd selection)"
- ... (up to number of selected interventions)

**Example:**

```
Choice: B
Duration: 14 days
→ If participant selected [Exercise, Meditation, Diet] in that order:
   Days 0-13: Meditation (their 2nd choice)
```

**Limitations:**

- ❌ Cannot hardcode a specific intervention (e.g., always use "Exercise")
- ✅ Must use participant's choice placeholders

---

### 3. **Alternating Segment**

**Purpose**: Cycle through all participant-selected interventions in a fixed order (ABC...ABC...)

**Configuration:**

- Intervention Duration (days): Length of time for each intervention
- Cycle Amount: Number of complete cycles through all interventions
- Balance First Intervention (checkbox, only shown with 2 interventions)

**Behavior:**

- Interventions alternate in a fixed sequence: A → B → C → A → B → C ...
- Uses ALL interventions selected by participant
- Order is determined by participant's selection order
- Each intervention gets equal time (interventionDuration × cycleAmount)

**Pattern Examples:**

*3 Interventions, 2 Cycles:*

```
Duration: 7 days per intervention
Cycles: 2
→ A(7) → B(7) → C(7) → A(7) → B(7) → C(7)
Total: 42 days
```

*4 Interventions, 1 Cycle:*

```
Duration: 5 days per intervention
Cycles: 1
→ A(5) → B(5) → C(5) → D(5)
Total: 20 days
```

**Balancing Feature (2 Interventions Only):**

- **Enabled**: 50% of participants start with A, 50% start with B
    - Pattern for Group 1: A-B-A-B-A-B...
    - Pattern for Group 2: B-A-B-A-B-A...
- **Disabled** (default): All participants start with A
    - Pattern for All: A-B-A-B-A-B...

**Timeline Visualization:**

- Shows pattern with letter labels (A, B, C, D...)
- Each intervention shown with subtle color variation
- Tooltip shows full calculation and time allocation

**Limitations:**

- ❌ Cannot customize intervention order (always follows selection order)
- ❌ Cannot assign different durations to different interventions
- ❌ Balancing only works with exactly 2 interventions
- ✅ Supports any number of interventions

---

### 4. **Counter-Balanced Segment**

**Purpose**: Rotate intervention order each cycle to control for sequence effects

**Configuration:**

- Intervention Duration (days): Length of time for each intervention
- Cycle Amount: Number of complete cycles through all interventions
- Balance First Intervention (checkbox, only shown with 2 interventions)

**Behavior:**

- Intervention order changes (rotates) with each cycle
- Uses ALL interventions selected by participant
- Designed to minimize order/carryover effects
- Each intervention gets equal time (interventionDuration × cycleAmount)

**Pattern Examples:**

*2 Interventions, 3 Cycles:*

```
Duration: 7 days per intervention
Cycles: 3
→ Cycle 1: A(7) → B(7)
→ Cycle 2: B(7) → A(7)  [rotated]
→ Cycle 3: A(7) → B(7)  [rotated again]
Total: 42 days
```

*3 Interventions, 2 Cycles:*

```
Duration: 5 days per intervention
Cycles: 2
→ Cycle 1: A(5) → B(5) → C(5)
→ Cycle 2: B(5) → C(5) → A(5)  [rotated]
Total: 30 days
```

**Rotation Logic:**

- Cycle 0: A, B, C, D
- Cycle 1: B, C, D, A
- Cycle 2: C, D, A, B
- Cycle 3: D, A, B, C
- Pattern continues...

**Balancing Feature (2 Interventions Only):**

- **Enabled**: 50% of participants start with A, 50% start with B
    - Pattern for Group 1: A-B-B-A-A-B-B-A... (ABBA pattern)
    - Pattern for Group 2: B-A-A-B-B-A-A-B... (BAAB pattern)
- **Disabled** (default): All participants start with A
    - Pattern for All: A-B-B-A-A-B-B-A... (ABBA pattern)

**Timeline Visualization:**

- Shows rotated pattern with letter labels
- Visual indication of rotation through color variations
- Tooltip indicates "Order randomized each cycle"

**Limitations:**

- ❌ Rotation pattern is fixed (not truly random, just rotated)
- ❌ Cannot customize rotation logic
- ❌ Balancing only works with exactly 2 interventions
- ✅ Supports any number of interventions

---

### 5. **Thompson Sampling Segment**

**Purpose**: Adaptive intervention assignment based on performance metrics

**Configuration:**

- Intervention Duration (days): Length of time for each draw
- Intervention Draw Amount: Number of times to draw/assign interventions
- Survey (dropdown): Which observation to use for metrics
- Question (dropdown): Which question within survey to use

**Behavior:**

- Uses Bayesian optimization to select interventions
- Adapts based on participant responses
- Balances exploration vs. exploitation
- Uses ALL interventions selected by participant

**Pattern Example:**

```
Duration: 3 days per draw
Draws: 10
Survey: Daily Mood Survey
Question: "Rate your mood (1-10)"
→ 10 periods of 3 days each (30 days total)
→ Intervention for each period selected based on previous responses
```

**Limitations:**

- ❌ Cannot customize Thompson Sampling parameters (beta distribution, etc.)
- ❌ Requires numeric survey question
- ✅ Works with any number of interventions

---

## Implemented Features

### ✅ **Fully Implemented**

1. **Intervention Selection System**
    - Filter chips for selecting available interventions
    - Min/Max selection constraints
    - Default to all interventions selected
    - Validation of min ≤ max

2. **Single Intervention Segment**
    - Participant choice selection (A, B, C, ...)
    - Fixed duration
    - Only shows participant choices (no hardcoded interventions)

3. **Alternating Segment**
    - Fixed sequential pattern (A-B-C-A-B-C...)
    - Configurable intervention duration
    - Configurable cycle amount
    - Support for any number of interventions
    - 50/50 balancing for 2 interventions
    - Visual timeline with color coding

4. **Counter-Balanced Segment**
    - Rotating pattern per cycle
    - Configurable intervention duration
    - Configurable cycle amount
    - Support for any number of interventions
    - 50/50 balancing for 2 interventions
    - Visual timeline with rotation indication

5. **Timeline Visualization**
    - Shows full schedule with all segments
    - Color-coded segment types
    - Pattern visualization for alternating/counter-balanced
    - Tooltips with detailed calculations
    - Day markers

6. **Form Persistence**
    - All settings saved with study
    - Form controls properly wired to data models
    - Backward compatibility with default values

---

## Missing Features / Limitations

### ❌ **Not Implemented**

#### 1. **Custom Balancing Ratios**

- **Current**: Fixed 50/50 split for 2 interventions
- **Missing**:
    - Custom ratios (e.g., 60/40, 70/30)
    - Stratified randomization
    - Block randomization with custom block sizes

#### 2. **Balancing for 3+ Interventions**

- **Current**: Balancing only works with exactly 2 interventions
- **Missing**:
    - Balanced randomization for 3+ interventions
    - Latin square designs
    - Williams square designs
    - Custom permutations

#### 3. **True Randomization in Counter-Balanced**

- **Current**: Fixed rotation pattern (deterministic)
- **Missing**:
    - True random order per cycle
    - Configurable randomization seed
    - Constrained randomization (e.g., prevent same intervention twice in a row)

#### 4. **Custom Intervention Order**

- **Current**: Order follows participant selection order
- **Missing**:
    - Researcher-specified order for alternating/counter-balanced
    - Different orders for different participants
    - Conditional ordering based on participant characteristics

#### 5. **Variable Intervention Duration**

- **Current**: All interventions get equal time within a segment
- **Missing**:
    - Different durations for different interventions
    - Adaptive duration based on participant response
    - Minimum/maximum duration constraints

#### 6. **Hardcoded Intervention Assignment**

- **Current**: Single intervention can only use participant choices
- **Missing**:
    - Option to assign a specific intervention by name
    - Mix of hardcoded and participant-selected interventions
    - Conditional assignment (e.g., "If participant selected Exercise, always use it first")

#### 7. **Intervention Subset Selection**

- **Current**: Alternating/Counter-balanced use ALL participant selections
- **Missing**:
    - Use only a subset of participant selections
    - "Use 2 out of 3 selected interventions"
    - Manual intervention selection per segment (dropdowns for A/B positions)

#### 8. **Advanced Scheduling Features**

- **Missing**:
    - Washout periods between interventions
    - Crossover designs with specified sequences
    - Factorial designs (2×2, 3×3, etc.)
    - Adaptive trial designs beyond Thompson Sampling
    - Conditional segments (if/then logic)

#### 9. **Participant-Level Customization**

- **Missing**:
    - Allow participants to choose order
    - Mid-study intervention changes
    - Opt-out of specific interventions
    - Preference-based assignment

#### 10. **Visualization & Preview**

- **Missing**:
    - Preview of all possible schedules
    - Monte Carlo simulation of randomization
    - Export schedule as table/calendar
    - Participant-facing schedule view

---

## Use Cases & Examples

### ✅ **Supported Use Cases**

#### Use Case 1: Simple 2-Intervention Crossover (Balanced)

```
Scenario: Test Exercise vs. Meditation
Pool: [Exercise, Meditation]
Selected: [Exercise, Meditation]
Min: 2, Max: 2

Schedule:
- Baseline: 7 days
- Alternating: 7 days/intervention, 4 cycles, balancing enabled
  → 50% start Exercise, 50% start Meditation
  → Total: 56 days of interventions
```

**Status**: ✅ Fully Supported

---

#### Use Case 2: Multi-Intervention Rotating Schedule

```
Scenario: Test 4 different sleep interventions
Pool: [Sleep Hygiene, Meditation, Exercise, Light Therapy]
Selected: All 4
Min: 4, Max: 4

Schedule:
- Baseline: 14 days
- Counter-Balanced: 7 days/intervention, 3 cycles
  → Cycle 1: A-B-C-D
  → Cycle 2: B-C-D-A (rotated)
  → Cycle 3: C-D-A-B (rotated)
  → Total: 84 days
```

**Status**: ✅ Fully Supported

---

#### Use Case 3: Flexible Participant Choice with Fixed Periods

```
Scenario: Let participants choose 2-3 wellness interventions
Pool: [Yoga, Running, Swimming, Cycling, Walking]
Selected: All 5
Min: 2, Max: 3

Schedule:
- Baseline: 7 days
- Single Intervention (Choice A): 14 days
- Single Intervention (Choice B): 14 days
- Single Intervention (Choice C): 14 days [only if participant selected 3]
```

**Status**: ✅ Fully Supported (participants who select 2 interventions would end after Choice B)

---

#### Use Case 4: Adaptive Intervention Selection

```
Scenario: Use Thompson Sampling to find best intervention for mood
Pool: [CBT Exercises, Meditation, Exercise, Journaling]
Selected: All 4
Min: 2, Max: 4

Schedule:
- Baseline: 7 days
- Thompson Sampling: 3 days/draw, 20 draws
  → Survey: Daily Mood
  → Question: "Rate your mood (1-10)"
  → Algorithm adapts based on responses
```

**Status**: ✅ Fully Supported

---

### ⚠️ **Partially Supported Use Cases**

#### Use Case 5: Unbalanced Randomization

```
Scenario: 70% get Treatment A first, 30% get Treatment B first
Pool: [Treatment A, Treatment B]
Selected: Both
Min: 2, Max: 2

Schedule:
- Alternating: 14 days/intervention, 2 cycles, 70/30 balancing
```

**Status**: ❌ **NOT Supported** - Only 50/50 balancing available
**Workaround**: Use external randomization and assign participants to different studies

---

#### Use Case 6: Balanced Latin Square (3+ Interventions)

```
Scenario: Balance order effects for 4 interventions
Pool: [A, B, C, D]
Selected: All 4
Min: 4, Max: 4

Desired: Latin square design with all possible orders balanced
- Group 1: A-B-C-D
- Group 2: B-C-D-A
- Group 3: C-D-A-B
- Group 4: D-A-B-C
```

**Status**: ⚠️ **Partially Supported** - Counter-balanced rotates but doesn't ensure all
participants get different orders
**Limitation**: No true Latin square with distinct groups

---

### ❌ **Unsupported Use Cases**

#### Use Case 7: Subset Selection for Alternating

```
Scenario: Participant selects 3 interventions but alternate between only 2
Pool: [A, B, C, D, E]
Selected: All 5
Min: 3, Max: 3

Schedule:
- Participant selects: A, C, E
- Alternating: Use only A and C (not E)
```

**Status**: ❌ **NOT Supported** - Alternating always uses ALL selections
**Workaround**: None - Would need intervention assignment dropdowns

---

#### Use Case 8: Hardcoded Control Group

```
Scenario: Some participants get a specific control intervention
Pool: [Control, Treatment A, Treatment B]
Selected: [Control, Treatment A, Treatment B]
Min: 2, Max: 2

Schedule:
- Single Intervention: Always use "Control" (not participant choice)
- Then alternating between selected treatments
```

**Status**: ❌ **NOT Supported** - Cannot hardcode specific interventions
**Workaround**: Create separate study arms or use external assignment

---

#### Use Case 9: Different Intervention Durations

```
Scenario: Treatment needs longer washout than others
Pool: [Drug A, Drug B, Placebo]
Selected: All 3

Schedule:
- Drug A: 14 days
- Washout: 7 days
- Drug B: 14 days
- Washout: 7 days
- Placebo: 7 days
```

**Status**: ❌ **NOT Supported** - All interventions get same duration in
alternating/counter-balanced
**Workaround**: Use multiple Single Intervention segments with baseline segments as washout

---

#### Use Case 10: Conditional Sequencing

```
Scenario: If participant selects Exercise, always do it last
Pool: [Diet, Exercise, Meditation]
Selected: All 3

Schedule:
- If Exercise selected: Diet → Meditation → Exercise
- If Exercise not selected: Diet → Meditation
```

**Status**: ❌ **NOT Supported** - No conditional logic in scheduling
**Workaround**: None - Would require custom logic

---

## Data Model Reference

### Core Fields

**AdaptiveStudySchedule:**

```dart
{selectedInterventions: List<String>, // Intervention IDs available for selection
minInterventionsToSelect: int, // Minimum participant must select
maxInterventionsToSelect: int, // Maximum participant can select
segments: List<StudyScheduleSegment> // Schedule segments
}
```

**AlternatingScheduleSegment:**

```dart
{interventionDuration: int, // Days per intervention
cycleAmount: int, // Number of cycles
interventionIds: List<
String
>
?
, // Optional override (not used currently)
balanceFirstIntervention
:
bool // 50/50 balancing for 2 interventions
}
```

**CounterBalancedScheduleSegment:**

```dart
{interventionDuration: int, // Days per intervention
cycleAmount: int, // Number of cycles
interventionIds: List<
String
>
?
, // Optional override (not used currently)
balanceFirstIntervention
:
bool // 50/50 balancing for 2 interventions
}
```

**SingleInterventionScheduleSegment:**

```dart
{interventionIndex
:
int
, // Choice index (0=A, 1=B, 2=C, ...)
duration
:
int // Days
}
```

---

## Testing Checklist

### ✅ **Test These Scenarios**

- [ ] 2 interventions, min=2, max=2, alternating with balancing
- [ ] 2 interventions, min=2, max=2, counter-balanced with balancing
- [ ] 3 interventions, alternating (check A-B-C pattern)
- [ ] 4 interventions, counter-balanced (check rotation)
- [ ] 5 interventions, single intervention for each choice
- [ ] Min=2, max=4, flexible selection
- [ ] Thompson sampling with all interventions
- [ ] Timeline visualization renders correctly for all patterns
- [ ] Form persistence (save and reload study)
- [ ] Balancing checkbox only shows with 2 interventions
- [ ] Balancing checkbox hidden with 3+ interventions

### ⚠️ **Known Limitations to Document**

- [ ] Cannot balance 3+ interventions
- [ ] Cannot customize balancing ratio
- [ ] Cannot hardcode specific interventions in single intervention
- [ ] Cannot use subset of participant selections in alternating/counter-balanced
- [ ] Counter-balanced rotation is deterministic, not truly random
- [ ] No visual preview of all possible randomization outcomes

---

## Version History

**Current Version (November 2025)**

- Initial implementation of intervention selection system
- Support for unlimited interventions in alternating/counter-balanced
- 50/50 balancing for 2-intervention designs
- Participant choice-based single intervention segments
- Visual timeline with pattern display

**Future Enhancements Requested:**

- Custom balancing ratios
- Latin square designs for 3+ interventions
- True randomization options
- Intervention subset selection
- Hardcoded intervention options
- Advanced crossover designs

---

## Contact & Support

For questions about this feature or to request enhancements, contact the development team.

**Documentation Maintained By:** AI Assistant  
**Last Review:** November 27, 2025

