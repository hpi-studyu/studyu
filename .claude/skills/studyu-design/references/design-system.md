# StudyU Design System

## Overview

**StudyU** is a fully-functional platform for personalized N-of-1 treatment advice. It enables researchers to design clinical studies and patients to participate in them - tracking interventions, logging outcomes, and receiving personalized recommendations based on their own data.

### Products / Surfaces
1. **Mobile App** (`app/`) - Flutter mobile app for study participants (iOS & Android). Patients browse studies, enroll, complete daily tasks, and track their journey.
2. **Designer / Dashboard** (`designer_v2/`) - Flutter Web app for researchers to design, monitor, and analyze studies.
3. **Marketing Site** (`studyu.health`) - Docusaurus-based documentation + marketing site.
4. **Email** - Transactional notifications (not yet fully templated in repo).

### Sources
- GitHub: https://github.com/hpi-studyu/studyu (branch: `dev`)
- Website: https://studyu.health/
- Logo: provided as PNG (assets/studyulogo.png)

---

## CONTENT FUNDAMENTALS

- **Voice**: Clear, empathetic, science-grounded. Speaks to both researchers (precise, technical) and patients (friendly, encouraging).
- **Tone**: Calm and trustworthy. Never alarmist. Avoids jargon where possible in patient-facing copy.
- **Person**: Second person ("you", "your") - e.g. "Your Journey", "Today's tasks".
- **Casing**: Title Case for screen headings ("Your Journey", "Please select a study."); Sentence case for body/supporting copy.
- **Emoji**: Not used anywhere in the UI - icon-first approach.
- **CTAs**: Action-oriented, imperative - "Get started", "Accept", "Decline", "Next", "Back".
- **Link style**: Blue underlined inline links, used for contextual help ("Why?").
- **Numbers/dates**: DD-MM-YYYY format used in journey timeline.

---

## VISUAL FOUNDATIONS

### Colors
- **Primary**: `#2196F3` (Material Blue 500) - app bars, interactive elements, CTAs
- **Accent / Secondary**: `#FF9800` (Material Orange 500) - active state indicators, checkboxes, current-step circles
- **Logo gradient**: Cyan `#00E5CC` to Blue `#2196F3` (left to right)
- **Link**: `#00B0FF` (light blue)
- **Surface**: `#FFFFFF`
- **Background**: very light blue tint (`primaryContainer` at about 15% opacity, approximately `#EBF4FD`)
- **Error**: Material Red `#F44336`
- **On-surface text**: near-black at 90% opacity; secondary text at 65-80%

### Typography
- **Primary font**: Work Sans variable (`fonts/WorkSans-VariableFont_wght.ttf`), loaded locally with `@font-face`.
- **Scale** (from designer_v2 theme): 14px body, 15px titleLarge (bold), 18px headlineSmall (bold), 22px headlineMedium (bold), 26px displaySmall (bold), 36px displayMedium (bold), 48px displayLarge (bold)
- **Line height**: 1.35 for body text
- **Heading color**: `onSurfaceVariant` (muted dark, not pure black)

### Spacing & Layout
- Min content width: 600px; Max: 1264px (designer)
- Border radius: 8px (cards, list tiles, buttons); 5px (inputs); 2px (tooltips)
- Content padding: 16px (inputs), 14px (dropdown inputs)

### Cards
- Elevation: 0 (flat, border-only or background-differentiated)
- Shape: 8px rounded rectangle
- Clip: antiAlias
- Background: white or very light blue

### Backgrounds
- App: near-white light blue tint
- Designer: `primaryContainer` at 15% opacity (subtle wash)
- No full-bleed images, no repeating patterns, no gradients in UI (gradient only in logo)

### Animation
- Web (designer): fade in/out transitions (opacity ease-in, both old and new routes)
- Mobile (app): platform-native (Cupertino on iOS, FadeUpwards on Android)
- No bounces, no spring animations in web

### Hover / Interaction States
- Hover: 70% opacity fade (`kHoverFadeFactor = 0.7`)
- Mute: 80% opacity (`kMuteFadeFactor = 0.8`)
- Press: platform ripple (Material)

### Borders & Dividers
- Dividers: 0.5px, `onPrimaryContainer` at 15% opacity (very subtle)
- Input borders: outlined, `surfaceContainerHighest` at 80% opacity; primary color when focused
- Checkbox border: secondary at 20% opacity when unselected

### Shadows
- App bar: elevation 2, primaryContainer shadow at 30% opacity
- Tooltip: layered shadows (primaryContainer + secondary)
- Cards: no shadow (elevation 0)

### Icons
- System: **Material Icons** (filled style)
- Size: 17px in UI; larger (48-64px) for consent/info grid tiles
- Opacity: 80% default
- Color: onSurface (dark) or primary blue for interactive

### Corner Radii
- Cards / list tiles / buttons: 8px
- Inputs: 5px
- Tooltips: 2px

---

## ICONOGRAPHY

Material Icons (filled) are the primary icon system, used throughout both the app and designer. They are loaded via CDN in web contexts. The app uses Flutter's built-in Material Icons font.

No custom icon font or SVG sprite exists - all icons are standard Material Icons references.
Emoji are **never** used as icons.
Unicode characters are not used as icons.

Key icon usage patterns:
- Navigation/action icons in app bars (chart icon for analytics, person icon for account)
- Category icons in study lists (stethoscope, stomach, etc. - sourced from Material Icons)
- Consent tile icons (search, barrier, database, clock, gavel, binoculars)
- Task-type icons (checklist for "Rate your day")
- Timeline node icons (flag for results, minus for baseline)

## MATERIAL DESIGN 3

StudyU uses **Material Design 3** throughout both the mobile app and the designer dashboard. Key implementation details:

- **Color system**: `material_color_utilities` package - `SchemeFidelity` + `Blend.harmonize()` generates the full M3 tonal palette from seed color `#2196F3` (app) / `#0061A4` (designer M3 primary)
- **Type scale**: M3 naming (`displayLarge` to `labelSmall`). The app uses a compressed custom scale (14-48px); the M3 standard scale (12-57sp) is documented in CSS vars
- **Shape system**: M3 shape tokens (`extraSmall: 4dp` to `extraLarge: 28dp`) - the app uses `small (8dp)` for cards/list tiles. Inputs use a custom `5px` not from the M3 spec
- **Elevation**: M3 surface tint model (no drop shadows on cards). App bar uses a light shadow as an exception (`designer_v2` keeps `elevation: 2` on AppBar)
- **State layers**: M3 spec (`hover: 8%`, `focus: 12%`, `press: 12%`, `drag: 16%` opacity over role color)
- **Components**: `CardTheme` with `elevation: 0`, `RoundedRectangleBorder(8dp)`. `InputDecorationTheme` filled + outlined. `SwitchTheme`, `CheckboxTheme`, `RadioTheme` all wired to `ColorScheme.primary`
- **Transitions**: Web uses fade-in/fade-out; mobile uses platform-native (Cupertino on iOS)
- **Icons**: Material Symbols / Material Icons (filled) - referenced by name in Flutter, loaded via CDN in web

---

## FILE INDEX

```
references/design-system.md     - This file
SKILL.md                        - Skill trigger and workflow
copilot.instructions.md         - Shared Copilot custom instructions
colors_and_type.css             - CSS variables: colors, type, spacing
assets/
  studyulogo.png                - Official StudyU logo (PNG)
fonts/
  WorkSans-VariableFont_wght.ttf - Work Sans variable font, weights 100-900
preview/
  colors-primary.html           - Primary & accent palette
  colors-semantic.html          - Semantic colors (surface, bg, error, text)
  type-scale.html               - Typography scale specimen
  spacing-tokens.html           - Spacing, radius, elevation tokens
  components-buttons.html       - Button variants
  components-inputs.html        - Form inputs
  components-cards.html         - Card & list tile patterns
  components-badges.html        - Status badges & chips
  brand-logo.html               - Logo & gradient usage
ui_kits/
  app/index.html                - Mobile app UI kit (participant)
  designer/index.html           - Designer/dashboard UI kit (researcher)
```
