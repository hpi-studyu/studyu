---
name: studyu-design
description: Create, review, or update StudyU-branded interfaces, assets, copy, and production UI across the participant mobile app, researcher designer dashboard, marketing/docs site, and prototypes. Use when work involves StudyU visual design, Material 3 styling, brand colors, Work Sans typography, logos, UI kits, Flutter UI, HTML mockups, CSS tokens, or design-system consistency.
---

# StudyU Design

Use the bundled design system before producing StudyU UI, prototypes, visual assets, or design-system changes.

## Workflow

1. Read `references/design-system.md` for brand, voice, colors, typography, shape, icon, and component guidance.
2. Use `colors_and_type.css` for concrete CSS variables and token values when building HTML/CSS artifacts.
3. Inspect only the relevant preview or UI kit files:
   - `preview/*.html` for token and component specimens.
   - `ui_kits/app/index.html` for participant mobile app patterns.
   - `ui_kits/designer/index.html` for researcher dashboard patterns.
4. Reuse assets from `assets/` and `fonts/` when making mockups, previews, or production assets.
5. For production code, adapt the guidance to the repository's existing Flutter, Docusaurus, or web patterns instead of copying throwaway HTML directly.

## Quick Facts

- Primary: #2196F3 (Material Blue)
- Accent: #FF9800 (Material Orange)
- Logo gradient: #00E5CC to #2196F3
- Font: Work Sans (`fonts/WorkSans-VariableFont_wght.ttf`) loaded with `@font-face`
- Icons: Material Icons (filled)
- Card radius: 8px; input radius: 5px; elevation: flat (shadow-sm only)
- Background: #EBF4FD (light blue tint)
- CSS vars: colors_and_type.css
- Mobile UI kit: ui_kits/app/index.html
- Designer UI kit: ui_kits/designer/index.html

## Guardrails

- Keep StudyU UI calm, trustworthy, clear, and science-grounded.
- Use Material Design 3 conventions and the repository's existing component patterns.
- Avoid emoji in UI; prefer Material Icons.
- Use title case for screen headings and sentence case for body/supporting copy.
- Keep cards and controls restrained: 8px radius for cards/list tiles/buttons, 5px for inputs, minimal shadows.
