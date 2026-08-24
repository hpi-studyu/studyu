# StudyU Material 3 UI Skill — Research Assessment

Date: 2026-08-24 · Branch: `feat/studyu-material3-skill` · Repo: `/opt/studyu` (Melos workspace: `app`, `designer_v2`, `core`, `flutter_common`)

This document is the research assessment required before implementing the StudyU Material 3 UI skill. It answers the eleven deliverables from the brief, then defines what will be built.

---

## 1. Current StudyU UI architecture

Two apps, two theming philosophies, one shared codebase.

### Participant app (`app/`)
- `app/lib/theme.dart` (24 lines): `ThemeData(brightness: light, primaryColor: Colors.blue, colorScheme: ...copyWith(primary: Colors.blue, secondary: Colors.orange))`, one `elevatedButtonTheme`. No `ColorScheme.fromSeed`, no `TextTheme`, no dynamic color, no dark theme. `useMaterial3` unset (default true on current Flutter, so M3 widgets render — but with an almost-empty scheme).
- UI: onboarding + study screens, bare `Scaffold`s, no shared layout components, custom `SelectableButton`, questionnaire widgets.
- Verdict: **M3 by accident of Flutter defaults, not by design.** Raw brand colors as de-facto tokens.

### Study Designer (`designer_v2/`)
- `designer_v2/lib/theme.dart` (~470 lines): a real design system. `ThemeProvider` (InheritedWidget), `ThemeSettings{sourceColor, themeMode}`, light/dark `ColorScheme.fromSeed`, dynamic color via `material_color_utilities` (`SchemeFidelity` + `MaterialDynamicColors.primary`), full per-component themes (card, listTile, appBar, bottomNav, tabBar, switch, checkbox, radio, input, tooltip, snackbar, divider, icon), page-transitions theme, content-width constants (`kMinContentWidth=600`, `kMaxContentWidth=1264`).
- `common_views/` (~40 files): real, reusable widget layer — `PrimaryButton`, `SecondaryButton`, `TwoColumnLayout`, `FormScaffold`, `FormTableLayout`, `Hyperlink`, `TextParagraph`, dialogs, banners, etc.
- Verdict: **structurally M3-aligned** (fromSeed, role-based colors, `WidgetState` APIs) but with **heavy hand-tuned drift away from the M3 spec** (see §2).

### Shared package (`flutter_common/`)
- 7 files, all utils (`env_loader`, `storage`, `localization`, `retry_future_builder`, `mdi_icons_helper`, `user`). **No shared UI widgets** — the "shared UI" layer lives inside `designer_v2`. There is **no custom-widgets-for-the-sake-of-it problem** here; the custom layer is justified and mostly wraps Material.

## 2. Concrete current inconsistencies / risks

Quantified (designer_v2 + app, excluding theme files):
- **261** `const SizedBox(width|height: <n>)` literals — no spacing token layer, no 8dp-grid discipline.
- **220** raw `Colors.*` references outside theme files.
- **67** raw `fontSize:` literals outside theme (many repeat the theme's own 14/15/18/22 values — text styles re-invented at call sites).
- **26** `Color(0x…)` literals outside theme.
- **23** `BorderRadius.circular(...)` outside theme.
- No central tokens file in either app (`app/lib/constants.dart` holds only fitbit URLs; `designer_v2/lib/constants.dart` holds route names + `Config`).

Specific M3 mismatches:
1. **Non-M3 TextTheme**: `bodyLarge/bodyMedium/titleMedium` all 14 (M3: 16/14/16), `labelLarge` 14 (M3: 14 — ok), `displaySmall` 26 (M3: 36), `displayMedium` 36 (M3: 45), `displayLarge` 48 (M3: 57). Open `TODO: migrate to 2021 term set` at `theme.dart:337`. Font weights forced bold on display/headline (M3 display is normal weight).
2. **Hardcoded radii**: input border 5, `shapeMedium` 8, tooltip 2 — M3 shape scale is 0/4/8/12/16/28 (full circle).
3. **`AppBarTheme.backgroundColor: Colors.white`** + `surfaceTintColor: Colors.white` — pinned literal, defeats the surface-tint / `surface` role (theme.dart:221-224).
4. **`BottomNavigationBar` (legacy) instead of M3 `NavigationBar`** (theme.dart:258-267). `NavigationRailThemeData()` is empty.
5. **`PrimaryButton` wraps `ElevatedButton` with `elevation: 0`** (primary_button.dart) — M3 primary-emphasis is **`FilledButton`**. It also injects per-call-site `innerPadding` instead of relying on `FilledButtonThemeData` + 40/48dp min height.
6. **Password visibility toggle is an `InkWell`+`Icon` with `FocusNode(skipTraversal: true)`** created inside `build` (auth_form_fields.dart:97-107) — not focusable, unlabeled, no tooltip. Should be a labeled `IconButton`.
7. **`FormTableLayout` renders forms via `Table`** (form_table_layout.dart:148) — semantically wrong for non-tabular forms app-wide; screen readers interpret rows as data.
8. **`Divider(height: 1)`** in all four auth forms — bypasses M3 divider's 16px vertical padding.
9. **Auth wording inconsistency** (see §4) and **`Hyperlink` raw link colors** `0xFF0000EE`/`0xFF551A8B` (browser defaults) vs the theme's own `linkColor` `0xFF00B0FF` — three sources of truth for link color.
10. **Participant `app` theme bypasses M3 seed color entirely** — two apps, two theming philosophies, nothing shared.

## 3. Assessment of the existing `m3-expressive-design-skill` extraction approach

Investigated `github.com/abhixv/m3-expressive-design-skill` (cloned at `/tmp/m3-expressive`).

**Verdict: strong reuse candidate — the extraction infrastructure is real, mature, and network-verified.**

- `scripts/refresh-m3.js` (MIT): re-scrapes m3.material.io by following the Angular SPA's own data path — reads the hashed main bundle for `carbonVersion` + route table, then fetches `/_dsm/content/m3/<version>/<uuid>.json` per page and converts to markdown. **Verified working live on 2026-08-24**: `carbonVersion=2026-08-19_06-10-14`, all 91 routes resolved, `wrote 91 pages, 0 failed`. Page inventory: 38 components, 27 foundations, 16 styles, 5 develop.
- `scripts/refresh-component-tokens.js` (MIT): fetches AndroidX Compose M3 `*Tokens.kt` from `androidx-main` for the dp/sp/shape/elevation values m3.material.io only publishes inside images.
- Generated references: ~9.4k lines across 21 files (`tokens.md`, `component-tokens.md` — 916 values/104 groups, `components/*.md` — 7 files 40+ components with sibling-choice rules, plus color/typography/layout/interaction/motion/shape/foundations). Text+scripts ≈ 800KB, no images needed for rule content.
- **License**: MIT for scripts + skill structure + authored prose; Material Design content remains CC-BY 4.0 (Google), AndroidX tokens Apache-2.0. `NOTICE.md` documents the split. Reuse requires keeping attribution.
- **m3.material.io is NOT directly fetchable** (Angular SPA, empty shell on HTML GET) — this is exactly why the bundle-following script exists. A naive scraper will fail; the abhixv approach is the correct one.

`hamen/material-3-skill` (local `/opt/material-3-skill`): handwritten references, Compose-first, Flutter secondary, no refresh infra. **Useful as an audit cross-check, but it is precisely the "manually maintained copy" the brief says not to build.** Not vendored as source of truth.

## 4. Proposed skill architecture

```
/opt/studyu/.agents/skills/studyu-material3/
├── SKILL.md                        # small router + workflow + decision hierarchy + review checklist
├── references/
│   ├── material/                   # GENERATED from m3.material.io (vendor abhixv approach)
│   │   ├── foundations.md
│   │   ├── layout.md
│   │   ├── interaction.md
│   │   ├── accessibility.md
│   │   ├── color.md
│   │   ├── typography.md
│   │   ├── shape.md
│   │   ├── motion.md
│   │   ├── tokens.md               # numeric bedrock (type scale, radii, elevation, contrast)
│   │   ├── component-tokens.md     # per-component dp geometry
│   │   └── components/             # buttons, input, navigation, containment, feedback, bars, fabs
│   ├── flutter/                    # HANDWRITTEN (the non-generatable part)
│   │   ├── material-mapping.md     # M3 component → Flutter widget (direct)
│   │   ├── theming.md              # M3 token → Theme.of(context).colorScheme/textTheme
│   │   ├── layout-mapping.md       # layout guidance → composition
│   │   ├── adaptive-mapping.md     # breakpoint/size guidance → LayoutBuilder/MediaQuery/components
│   │   ├── accessibility-mapping.md# semantics, focus, gestures, autofill
│   │   └── limitations.md          # where Flutter has no 1:1 mapping
│   └── studyu/                     # HANDWRITTEN (repo-derived)
│       ├── existing-patterns.md    # what StudyU already does well / consistently
│       └── deviations.md           # the concrete drift + migration targets
└── scripts/
    ├── refresh-m3.js               # vendored+adapted (MIT, abhixv)
    ├── refresh-component-tokens.js # vendored (MIT, abhixv)
    └── refresh-flutter.js          # NEW: validates/augments Flutter mapping refs against api.flutter.dev
```

Plus repo-level wiring:
- `/opt/studyu/.claude/skills/studyu-material3/SKILL.md` → symlink to `.agents/skills/studyu-material3/SKILL.md` (matches existing `pull-request` convention).
- `.omc-research/` reports are reference material, not committed into the skill.

## 5. Generated vs handwritten

| Layer | Approach | Why |
|---|---|---|
| `references/material/` | **Generated** by vendored `refresh-m3.js` + `refresh-component-tokens.js` | M3 is a live spec; numeric values (type scale, radii, dp) must come from source, not memory. Scripts already work. |
| `references/flutter/` | **Handwritten** | The M3→Flutter mapping is judgment (which widget maps to which role, which themes to read) and is not derivable from a single source. Written once, maintained by review. |
| `references/studyu/` | **Handwritten** | Repo-derived; reflects StudyU's actual code and intentional deviations. |
| `SKILL.md` | **Handwritten** | Router + workflow + checklist; small by design. |
| `refresh-flutter.js` | **Handwritten (NEW)** | Optional validator: fetches `api.flutter.dev/flutter/material/index.html` (verified scrapeable, 783KB) and checks that every Flutter class named in `material-mapping.md` still exists. Guards against API drift with minimal logic. |

## 6. How Material guidance maps to Flutter

Four mapping kinds, documented separately (mirrors the brief):

1. **Direct component mapping** — M3 component → Flutter widget:
   `Filled button → FilledButton` · `Navigation bar → NavigationBar` · `Text field → TextField` (via `ReactiveTextField` in StudyU).
2. **Theme/token mapping** — M3 role → theme lookup:
   `primary → Theme.of(context).colorScheme.primary` · `body-large → Theme.of(context).textTheme.bodyLarge`.
3. **Layout mapping** — guidance → composition:
   `group related content → Column/Row/Padding/ConstrainedBox` (no single widget).
4. **Adaptive + accessibility mapping** — `window-size → LayoutBuilder/MediaQuery/NavigationBar/breakpoints`; `label + focus → Semantics, IconButton, AutofillGroup, TextInputAction`.

Explicit principle (from abhixv SKILL.md, adopted): **"From M3: … My design decision (not in M3): …"** — every value stated either comes from the generated references or is labelled a design decision. No invented numbers presented as Material.

## 7. How StudyU-specific conventions are represented

- `references/studyu/existing-patterns.md`: the good stuff to preserve — `PrimaryButton`/`SecondaryButton` pair, `FormScaffold`/`StandardDialog`+`buildFormButtons` shell, `TwoColumnLayout` responsive shell, all strings via l10n (en+de), consistent footer, centered primary CTA, `ThemeProvider` dynamic color.
- `references/studyu/deviations.md`: the intentional and the accidental — documented drift (§2) plus migration targets: spacing tokens, `FilledButton`, `NavigationBar`, `TextTheme` term-set migration, link color single-source, focusable password toggle, `FormTableLayout`→`Column` of labeled fields.
- Decision hierarchy in `SKILL.md`: (1) explicit task/design requirement → (2) intentional existing StudyU pattern → (3) Material 3 guidance → (4) Flutter convention → (5) new design decision (made explicit, never dressed as Material).

## 8. How the skill routes UI tasks to references

`SKILL.md` holds a routing table (the "Where to look" pattern from abhixv, adapted):

| Need | Route to |
|---|---|
| Spacing / grouping / alignment | `material/layout.md` + `material/foundations.md` + `flutter/layout-mapping.md` |
| Forms / login / register | `material/components/input.md` + `components/buttons.md` + `material/interaction.md` + `material/layout.md` |
| Navigation | `material/components/navigation.md` + `flutter/adaptive-mapping.md` |
| Typography | `material/typography.md` + `material/tokens.md` + `flutter/theming.md` |
| Color | `material/color.md` + `material/tokens.md` + `flutter/theming.md` |
| Accessibility | `material/accessibility.md` + `material/interaction.md` + `flutter/accessibility-mapping.md` |
| Any exact number | `material/tokens.md` + `material/component-tokens.md` first |
| StudyU precedent | `studyu/existing-patterns.md` + `studyu/deviations.md` |

Workflow is six steps (inspect affected UI → identify semantics → consult routed refs → compare StudyU precedent → implement → review whole screen).

## 9. Maintenance / update strategy

```
m3.material.io update → node scripts/refresh-m3.js pages refs → git diff → reviewable PR
androidx token update → node scripts/refresh-component-tokens.js → git diff → PR
Flutter SDK update  → node scripts/refresh-flutter.js (validate class names) → git diff → PR
```

- **Scheduled GitHub Action: not added now.** Justification against: the refresh scripts are deterministic and run in ~1-2 min, but the diff needs human review (Material's carbonVersion bumps are infrequent, and auto-committing generated content without review can break the skill silently). Instead: a `scripts/` Makefile-style wrapper + documented manual refresh, and the reviewer checklist notes "run refresh before any M3-spec change". Revisit a scheduled action only if M3 content churn proves to be high.
- The refresh scripts print `carbonVersion` so every regeneration is traceable to a source snapshot.

## 10. Lint / static-analysis opportunities to objectively catch UI drift

No UI-drift lints exist today (`analysis_options.yaml` = `package:lint/strict.yaml` + minor overrides; `designer_v2` adds `riverpod_lint`, `app` adds `custom_lint`).

Recommended, low-risk, additive rules:

1. **`custom_lint` rules** (app already uses custom_lint):
   - Flag raw `Colors.*` in widget code outside theme files (warn: use `colorScheme`).
   - Flag `TextStyle(fontSize: ...)` / bare `TextStyle` outside theme files (warn: reuse `textTheme`).
   - Flag `BorderRadius.circular(...)` outside theme (warn: use theme shape).
   - Flag `Divider(height: 1)` (warn: M3 default vertical padding).
   - Flag `ElevatedButton` where a `FilledButton` is semantically the primary action (informational).
   - Flag `BottomNavigationBar` (legacy; suggest `NavigationBar`).
2. **`.jscpd` duplication threshold** is already `0` — the `Hyperlink` vs fitbit inline-links and repeated ToS wrap composition are jscpd-visible.
3. These are **warning-level and additive** — they must not break `pre-commit-check` until StudyU chooses to adopt the migration. Deliverable: a `studyu_lints` package or `custom_lint` rules committed alongside the skill, gated as informational first.

**Scope note:** the lint rules are proposed and implemented in minimal form (one or two demonstrative rules + doc), not force-applied across the repo. The brief asks for opportunities; the skill's job is to make them visible, not to migrate StudyU unilaterally.

## 11. Files to add or modify

**Add** (skill):
- `.agents/skills/studyu-material3/SKILL.md`
- `.agents/skills/studyu-material3/references/material/*` (generated: foundations, layout, interaction, accessibility, color, typography, shape, motion, tokens, component-tokens, components/*)
- `.agents/skills/studyu-material3/references/flutter/*` (material-mapping, theming, layout-mapping, adaptive-mapping, accessibility-mapping, limitations)
- `.agents/skills/studyu-material3/references/studyu/*` (existing-patterns, deviations)
- `.agents/skills/studyu-material3/scripts/refresh-m3.js`, `refresh-component-tokens.js`, `refresh-flutter.js`
- `.agents/skills/studyu-material3/NOTICE.md` (MIT + CC-BY attribution for vendored material)
- `.claude/skills/studyu-material3/SKILL.md` (symlink to `.agents/...`)

**Add** (support):
- `specs/studyu-material3-skill-assessment.md` (this file)
- Optional: `designer_v2/lib/studyu_lints/` or a `studyu_lints` custom_lint plugin with the two demonstrative rules.

**Modify**:
- Nothing in existing StudyU source. The skill is advisory; it does not change app code. (Auth-screen fixes are follow-up tickets, not part of the skill itself.)

---

## Implementation plan (what gets built next)

1. Vendor `scripts/refresh-m3.js` + `refresh-component-tokens.js` (MIT, attribution kept), run them to generate `references/material/` (~91 pages → consolidated refs).
2. Write `references/flutter/*` by hand (6 files).
3. Write `references/studyu/*` from the two `.omc-research/` audits + this assessment (2 files).
4. Write `SKILL.md` (router + workflow + decision hierarchy + checklist, auth case study as worked example).
5. Add `refresh-flutter.js` validator + `NOTICE.md`.
6. Wire `.claude/skills` symlink; add demonstrative `custom_lint` rules.
7. Run `scripts/pre-commit-check`, review with `code-reviewer`, commit per Conventional Commits.
