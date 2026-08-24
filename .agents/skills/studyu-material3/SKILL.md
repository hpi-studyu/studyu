---
name: studyu-material3
description: Use when designing or implementing any UI change in StudyU (participant app or Study Designer). Routes Material 3 guidance from generated m3.material.io references, maps it to correct Flutter widgets and theme lookups, and enforces consistency with existing StudyU patterns. Covers layout, spacing, hierarchy, grouping, primary vs secondary actions, positioning, responsive/adaptive behavior, accessibility, interaction, typography, color, shape, motion, Material component selection, Flutter implementation, UI wording, and consistency with neighboring StudyU screens. Triggers on UI tasks, Material 3 guidance questions, screen reviews, auth/form redesigns, theme or token changes.
argument-hint: "[screen/file to review]"
---

# StudyU Material 3 UI skill

StudyU ships two Flutter apps on one Melos workspace: the participant-facing `app` and the Study
Designer `designer_v2`. Both run Material 3 widgets, but only `designer_v2` has a real M3 theme
(`ColorScheme.fromSeed`, dynamic color, per-component themes). This skill makes a UI change
conform to **Material 3 guidance** AND to **StudyU's existing patterns**, whichever applies first.

## Workflow — follow this for every StudyU UI task

### Step 1 — Inspect the affected UI (do NOT code yet)

- Open the complete affected screen, not just the ticket's lines.
- Open neighboring screens and equivalent flows elsewhere in StudyU (same form elsewhere? same
  component used elsewhere?).
- Note the shared layout/components the screen already uses.
- Note current theme/token state: `Theme.of(context)` in `designer_v2` reads the full
  `ThemeProvider` system; the participant `app` has a minimal theme — do not assume parity.

### Step 2 — Identify the UI problem semantically

State in one line each: primary user goal, primary action, secondary actions, navigation actions,
content groups, information hierarchy, form relationships (if a form), responsive requirements.

### Step 3 — Consult relevant Material guidance (route, don't read everything)

| Need | Route to |
|---|---|
| Spacing / grouping / alignment | `references/material/layout.md` + `references/material/foundations.md` + `references/flutter/layout-mapping.md` |
| Forms / login / register / input | `references/material/components/input.md` + `references/material/components/buttons.md` + `references/material/interaction.md` + `references/material/layout.md` |
| Buttons / action emphasis | `references/material/components/buttons.md` + `references/flutter/material-mapping.md` + `references/studyu/existing-patterns.md` (StudyU uses `PrimaryButton`) |
| Navigation | `references/material/components/navigation.md` + `references/flutter/adaptive-mapping.md` |
| Typography | `references/material/typography.md` + `references/material/tokens.md` + `references/flutter/theming.md` |
| Color | `references/material/color.md` + `references/material/tokens.md` + `references/flutter/theming.md` |
| Shape / radii | `references/material/shape.md` + `references/material/tokens.md` |
| Motion | `references/material/motion.md` + `references/material/tokens.md` + `references/flutter/motion-mapping.md` |
| Accessibility | `references/material/accessibility.md` + `references/material/interaction.md` + `references/flutter/accessibility-mapping.md` |
| Any exact number | `references/material/tokens.md` and `references/material/component-tokens.md` FIRST — never from memory |
| Does StudyU already do this? | `references/studyu/existing-patterns.md` + `references/studyu/deviations.md` |
| Which UI drift do lints catch? | `references/studyu/lints.md` |
| Flutter widget exists for this? | `references/flutter/material-mapping.md` + `references/flutter/limitations.md` |

### Step 4 — Compare against StudyU precedent

Priority order (highest wins):

1. **Explicit task/design requirement** — the ticket or the user says so.
2. **Intentional existing StudyU pattern** — in `references/studyu/existing-patterns.md`, or visible
   in the codebase used consistently across equivalent screens. Reuse it as-is.
3. **Material 3 guidance** — from the generated references (never from memory).
4. **Flutter implementation conventions** — from `references/flutter/`.
5. **New design decision** — make it explicit, never present it as a Material requirement.

If you invent anything not in StudyU or M3, say so: *"From M3: … · My design decision (not in
M3): …"* — the split is mandatory for any value or pattern M3 does not specify.

### Step 5 — Implement in Flutter

- Reuse existing StudyU abstractions when they represent the same pattern (`PrimaryButton`,
  `SecondaryButton`, `FormScaffold`, `TwoColumnLayout`, `Hyperlink`, `EmailTextField`).
- Otherwise use official Flutter Material components (FilledButton, NavigationBar, TextField, …).
- Read color/type/spacing from the current theme — never hardcode. In `designer_v2`:
  `Theme.of(context).colorScheme.*`, `.textTheme.*`. In the participant `app`, the theme is
  minimal — either extend the theme or use the app's existing conventions; do not silently assume
  `designer_v2` tokens exist there.
- Check `references/studyu/deviations.md` for known traps before you reproduce them.

### Step 6 — Review the ENTIRE screen (not just touched lines)

Run the review checklist (§ Review checklist). The review must cover the whole affected screen and
its consistency with neighboring StudyU screens.

## Decision hierarchy (source of truth order)

```
task/design requirement
  > intentional existing StudyU pattern
    > Material 3 guidance (generated refs)
      > Flutter conventions
        > new design decision (labelled as such)
```

A Material 3 rule never overrides an intentional StudyU pattern, and a StudyU pattern never
overrides an explicit design requirement. Document which level you chose.

## StudyU context you should already know

- Auth lives ONLY in `designer_v2/lib/features/auth/` (Login, Signup, PasswordForgot,
  PasswordRecovery). The participant `app` has onboarding, not auth.
- Primary action = `PrimaryButton` (wraps `ElevatedButton` today — see deviations; M3 would use
  `FilledButton`). Secondary = `SecondaryButton` (OutlinedButton). This pair is the StudyU
  convention — do not replace it casually.
- Forms use `FormScaffold`/`StandardDialog` + `FormTableLayout`. See deviations for the
  `FormTableLayout` a11y caveat.
- All UI strings go through l10n (`tr.*`, en + de). Never hardcode UI text.
- Responsive: `designer_v2` uses `TwoColumnLayout` + `LayoutBuilder` breakpoints (e.g.
  `AuthScaffold` 1000px); participant `app` uses bare Scaffolds.

## Review checklist (final screen review)

For the whole affected screen:

- [ ] **Hierarchy**: primary action is visually strongest; one clear primary CTA per task.
- [ ] **Grouping**: related content grouped; spacing between groups > spacing within groups.
- [ ] **Wording**: consistent with equivalent StudyU flows; verbs match across entry points
      ("Sign in" CTA vs "Sign in" link collision — see deviations); strings via `tr.*`.
- [ ] **Alignment**: consistent within screen and with neighboring screens; not mixed.
- [ ] **Spacing rhythm**: on the 8dp grid; no arbitrary `SizedBox` values; spacing tokens if any.
- [ ] **Action prominence**: primary > secondary > tertiary; destructive actions not primary.
- [ ] **Typography**: from `textTheme`, not raw `TextStyle(fontSize:)`.
- [ ] **Colors**: from `colorScheme`, not raw `Colors.*`/`Color(0x…)`.
- [ ] **Shape**: from theme shape, not raw `BorderRadius.circular(...)`.
- [ ] **Component selection**: correct M3 component → Flutter widget (see material-mapping).
- [ ] **Adaptive**: layout handles compact/medium/expanded without breakage.
- [ ] **Accessibility**: labels on icon buttons, focusable controls, semantics for custom widgets,
      keyboard navigation, autofill on forms.
- [ ] **Consistency**: neighboring StudyU screens use the same pattern.

## Common StudyU mistakes to avoid

| Mistake | Correct |
|---|---|
| Raw `Colors.blue`/`Colors.white` in widgets | `Theme.of(context).colorScheme.*` |
| `TextStyle(fontSize: 14, ...)` at call sites | reuse `theme.textTheme.*` |
| `BorderRadius.circular(5)` inline | theme shape / shape tokens |
| `ElevatedButton` for the primary action | M3 primary = `FilledButton`; StudyU = `PrimaryButton` |
| `BottomNavigationBar` | M3 = `NavigationBar` |
| `Divider(height: 1)` | M3 divider default vertical padding |
| `Table` for non-tabular forms (`FormTableLayout`) | column of labeled fields |
| Unlabeled `InkWell` for password visibility toggle | labeled `IconButton` (semantics + focus + tooltip) |
| Wording diverging between equivalent flows | match the existing flow's phrasing (see deviations) |
| Inline `TextStyle` on hyperlinks | use `Hyperlink` / theme link style |

## Refresh (maintenance)

Regenerate Material references when M3 ships an update — from the skill root:

```bash
node scripts/refresh-m3.js pages .build/m3-pages      # scrape (vendored)
node scripts/refresh-material-refs.js                 # consolidate into references/material/
node scripts/refresh-component-tokens.js              # regenerate token geometry
git diff                                              # review before committing
```

Generated pages carry a source attribution header (`<!-- Source: … -->`); `tokens.md` and
`component-tokens.md` carry their own provenance note (m3.material.io + AOSP Compose tokens). The M3 site
is an Angular SPA — do not fetch guideline URLs directly; use the scripts. Flutter mappings
(`references/flutter/`) are handwritten and must be re-validated against current Flutter APIs
(`scripts/refresh-flutter.js`) when the SDK bumps.
