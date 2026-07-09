---
name: StudyU
description: N-of-1 clinical trial platform for researchers and participants
colors:
  primary: "#0066CC"
  primary-container: "#D6E8FF"
  secondary: "#FF6B00"
  secondary-container: "#FFEDD8"
  surface: "#FFFFFF"
  surface-container: "#F3F3F7"
  surface-container-low: "#F8F8FB"
  on-surface: "#1A1C1E"
  on-surface-muted: "#44474A"
  on-primary: "#FFFFFF"
  error: "#BA1A1A"
  divider: "#E0E2E6"
typography:
  display:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "48px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.01em"
  headline:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "36px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "normal"
  title:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.3
    letterSpacing: "normal"
  title-small:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "15px"
    fontWeight: 700
    lineHeight: 1.35
    letterSpacing: "normal"
  body:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.35
    letterSpacing: "normal"
  label:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.35
    letterSpacing: "0.01em"
rounded:
  xs: "2px"
  sm: "5px"
  md: "8px"
  lg: "12px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.sm}"
    padding: "12px 24px"
    typography: "{typography.label}"
  button-primary-hover:
    backgroundColor: "#0052A3"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.sm}"
    padding: "12px 24px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.primary}"
    rounded: "{rounded.sm}"
    padding: "12px 24px"
  card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.md}"
    padding: "{spacing.lg}"
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.sm}"
    padding: "16px"
  input-focused:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.sm}"
    padding: "16px"
---

# Design System: StudyU

## 1. Overview

**Creative North Star: "The Clinical Protocol"**

StudyU's visual language is built on the logic of a well-structured clinical protocol: every element earns its place by communicating information or reducing ambiguity. Layout is generous but never loose; hierarchy is clear without being loud; density serves experts without excluding participants. The system operates in the register of scientific instruments — precise, trustworthy, and calm.

The platform serves two fundamentally different users through one coherent visual identity. The Designer gives researchers an expert-grade environment with confident density; the App offers participants a guided, low-overhead experience. Both share the same typographic system, color vocabulary, and interaction principles. The brand personality is **precise, credible, empowering** — the tone of a thoughtful clinician-researcher.

This system explicitly rejects the aesthetics of fitness and wellness apps (gamified color, motivational tone, consumer chrome), tech-startup SaaS surfaces (Vercel-style dark mode, neon accents, glass effects), and health advocacy campaigns (emotional urgency, large photography, campaign-poster layouts). StudyU is an operational tool for rigorous science, and every pixel should communicate that.

**Key Characteristics:**
- Material Design 3 foundation with dynamic color seeded from Research Teal-Blue
- Light mode first; dark mode supported via the Material `ThemeProvider` dynamic system
- Flat-by-default surfaces with structural shadow only on elevation changes (AppBar, modals)
- Consistent 14px body type across both apps — dense enough for researchers, readable for participants
- Orange secondary accent used sparingly as a call-to-action signal, never decoratively

## 2. Colors

A restrained dual-accent palette anchored by Research Teal-Blue primary and structured neutrals, with orange reserved exclusively for primary calls to action.

### Primary
- **Research Teal-Blue** (#0066CC / derived dynamically via `ColorScheme.fromSeed`): The institutional anchor. Used for primary interactive controls (buttons, tabs, focused inputs, links), primary text on colored containers, and the navigation active state. Its Material 3 dynamic derivation means it harmonizes across light and dark schemes automatically.
- **Primary Container** (#D6E8FF): Low-emphasis primary backgrounds — selected row tints, highlighted sections, the scaffold background tint (`primaryContainer.withOpacity(0.15)`). Never used for text.

### Secondary
- **Protocol Orange** (#FF6B00): The call-to-action signal. Reserved for primary action buttons in the participant App and key conversion moments. Its rarity is the point — when orange appears, it means "act here". Never used for status indicators, decoration, or layout chrome. In the Designer, orange is the secondary action accent (`colorScheme.secondary`).
- **Secondary Container** (#FFEDD8): Soft orange for tag/chip backgrounds, highlight states tied to the secondary action. Used at very low coverage.

### Neutral
- **Protocol White** (#FFFFFF): Input fields, card surfaces, modal overlays. The surface of active work.
- **Surface Container Low** (#F8F8FB): Page scaffolding background. The slight tint separates content regions from the scroll surface without imposing a color.
- **Surface Container** (#F3F3F7): Secondary containers, hover tints, chip backgrounds. Never pure gray — always carries the primary hue faintly.
- **Ink** (#1A1C1E): Primary text, headings, icons at full opacity.
- **Ink Muted** (#44474A / `onSurface.withOpacity(0.8–0.9)`): Body copy, form labels. High enough contrast to pass WCAG AA at 14px.
- **Ink Background** (`onSurface.withOpacity(0.25)`): Placeholder text, disabled indicators.
- **Protocol Divider** (#E0E2E6 / `onPrimaryContainer.withOpacity(0.15)`): Thin (0.5px) horizontal separators. Never used as vertical stripes.
- **Error Red** (#BA1A1A): Form validation errors, destructive action confirmation. Not used for warnings.

### Named Rules
**The One Orange Rule.** The secondary/orange accent covers ≤10% of any given screen. When it appears, it means "this is the primary action." Using it for decoration, status, or layout chrome voids its signal value.

**The No-Warm-Tint Rule.** Background surfaces are tinted toward the primary blue hue — never toward warmth. There is no cream, sand, paper, or parchment in this system. "Clinical" is carried by the hue, not by warmth.

## 3. Typography

**Body Font:** System UI stack (`system-ui, -apple-system, Roboto, sans-serif`)

The system uses a platform-native sans-serif family, inheriting from the OS. This is an intentional choice for a clinical tool: familiarity reduces cognitive load, rendering is optimal per platform, and the system avoids the "designed for designers" feel of editorial font pairings.

**Character:** Neutral, precise, and highly readable. The stack prioritizes legibility and authority over personality. Typographic hierarchy is carried by weight and size, not by font pairing.

### Hierarchy
- **Display** (700 weight, 48px, 1.15 line-height): Reserved for major modal headlines or app-level introductions. Rarely used in the Designer; may appear in participant App onboarding moments.
- **Headline** (700 weight, 36px, 1.2 line-height): Section headings on major pages. `headlineMedium` in Material terms.
- **Title** (700 weight, 22px, 1.3 line-height): Card headers, page section titles, sidebar section names. The primary heading level inside content.
- **Title Small** (700 weight, 15px, 1.35 line-height): `titleLarge` in Material terms. Used for sub-section headers, dialog titles, and table column groups.
- **Body** (400 weight, 14px, 1.35 line-height): All running prose, form field content, table cell content. The primary reading size for both apps. Maximum line length: 65–75ch.
- **Label** (500 weight, 14px, 1.35 line-height): Form labels, button text, chip labels, icon labels, navigation items. Slightly elevated weight for scan-ability.

### Named Rules
**The 14px Floor Rule.** No text in production UI renders below 14px. The participant App serves users who may be elderly or cognitively taxed. Smaller text is prohibited regardless of perceived elegance.

**The Single-Family Rule.** One font family across both apps. Visual rhythm is created through weight and size, not through pairing. Introducing a display font for "personality" is forbidden.

## 4. Elevation

StudyU uses a **flat-by-default with structural shadow** strategy, consistent with Material 3's tonal elevation approach. Surfaces are flat at rest; shadow appears only in response to structural hierarchy (AppBar above content, modal above backdrop, tooltip above context).

The AppBar carries a subtle elevation-2 shadow (`primaryContainer.withOpacity(0.3)`) to separate the navigation layer from the scrolling content layer. This is structural: it signals layer, not interactivity. Cards have `elevation: 0` — they are defined by their background tint and shape, not by shadow. Modals and dialogs use a modal barrier color (`secondary.withOpacity(0.4)`) to create depth through overlay, not shadow.

### Shadow Vocabulary
- **AppBar structural shadow** (`boxShadow: 0 2px 4px rgba(primaryContainer, 0.3)`): Separates the fixed navigation layer from scroll content. Used only on the AppBar.
- **Tooltip shadow** (`boxShadow: 0 1px 4px rgba(secondary, 0.3)`): Light ambient shadow on tooltip popups. The tooltip background itself is `secondary.withOpacity(0.9)`.
- **Snackbar elevation** (elevation 1): Snackbars use Material's default elevation to float above content. Color is `primary` background with `onPrimary` text.

### Named Rules
**The Flat Card Rule.** Cards are `elevation: 0`. If a card needs to announce itself, use a background tint (surface-container) and shape (8px radius), not shadow. Elevation is reserved for layer hierarchy, not visual emphasis within a layer.

## 5. Components

### Buttons
The button system is precise and restrained — confident at rest, state-responsive on interaction. No gradients, no rounded-pill shapes.

- **Shape:** Gently rounded (5px radius — `BorderRadius.circular(5)`)
- **Primary:** Research Teal-Blue fill, white foreground text. 12px × 24px padding. White text foreground is explicitly enforced via `ElevatedButtonThemeData.foregroundColor`. The Designer primary button is `colorScheme.primary`; the participant App primary is often protocol orange where the action is a participant commitment.
- **Hover / Focus:** Color darkens toward primary-deep (~#0052A3); no outline ring, no scale transform. Transitions are fade-based (`WebTransitionBuilder` crossfade on web, no bounce/elastic).
- **Ghost / Tertiary:** Transparent background, primary text color, same padding and radius. Used for secondary actions in dialogs and destructive confirmations.
- **Disabled:** `onSurface.withOpacity(0.5)` fill or text. No faux-3D depressed state.

### Cards / Containers
Cards are the primary structural container in the Designer. They define regions, not individual items.

- **Corner Style:** Gently curved (8px radius via `shapeMedium = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))`)
- **Background:** Protocol White (`surface`). Never tinted in light mode.
- **Shadow Strategy:** Flat (elevation: 0). Background tint and containment define the card boundary.
- **Border:** None by default. A thin divider (`Protocol Divider`) may be used inside a card to separate sections.
- **Internal Padding:** 24px (`spacing.lg`) standard. 16px (`spacing.md`) in compact list contexts.
- **Clip:** `Clip.antiAlias` — content never overflows rounded corners.

### Inputs / Fields
Inputs are filled with white, outlined in a neutral border, and signal focus with a primary-colored border only.

- **Style:** White fill (`Colors.white`), outlined with `surfaceContainerHighest.withOpacity(0.8)`, 5px radius. `isDense: true`. Content padding `16px` all sides.
- **Focus:** Border shifts to `colorScheme.primary`. No shadow ring, no fill change.
- **Disabled:** Border fades to `surfaceContainerHighest.withOpacity(0.6)`, text fades to `onSurface.withOpacity(0.5)`.
- **Error:** Border becomes `colorScheme.error` (#BA1A1A). No background change.
- **Hover:** Fill color holds at white (`hoverColor: Colors.white`).

### Navigation
The Designer uses a top AppBar with `backgroundColor: Colors.white`, `foregroundColor: onSurface`, and subtle structural shadow. The participant App uses a bottom navigation bar on mobile (`surfaceContainerHighest` background, `onSurface` selected, `onSurfaceVariant` unselected) and a drawer for extended navigation.

- **AppBar:** White background, surface tint color overridden to white (`surfaceTintColor: Colors.white`) to prevent Material 3's default tonal tinting on scroll.
- **Bottom Nav (App):** Fixed type, `surfaceContainerHighest` background, selected item in `onSurface`, `elevation: 0`.
- **Navigation Rail (Designer):** Uses Material defaults.
- **Tabs:** Primary-colored active indicator — a 2px bottom border in `colorScheme.primary`. Unselected labels use `onSurfaceVariant`.

### Tooltips
Tooltips are distinctive and carry brand warmth through the orange secondary.

- **Background:** `secondary.withOpacity(0.9)` — a soft protocol orange.
- **Text:** `onPrimary` (white) at 14px body style.
- **Shape:** 2px radius — nearly square, deliberately precise.
- **Padding:** `7px × 11px` — tighter than default Material for information density.

### Chips / Tags
Used for study status indicators, filter pills, and selection states in the Designer.

- **Selected state:** Primary fill with `onPrimary` text.
- **Unselected:** Surface Container background with `onSurface` text, subtle border.
- **Shape:** 8px radius, consistent with cards.

### Signature Component: Study Design Scaffold
The Designer's study form scaffold (`StudyFormScaffold`) is the platform's primary workspace. It uses a split layout with a navigation sidebar and a main content well.

- **Sidebar background:** `scaffoldBackgroundColor.withOpacity(0.15)` (very faint, nearly transparent).
- **Content well:** Full surface white.
- **Max content width:** 1264px (`kMaxContentWidth`), centering content at wide viewports.
- **Min content width:** 600px (`kMinContentWidth`), preserving usable layout at tablet widths.

## 6. Do's and Don'ts

### Do:
- **Do** use `colorScheme.primary` (Research Teal-Blue) for all primary interactive affordances: active buttons, focused inputs, selected tabs, active nav items.
- **Do** use `secondary` / protocol orange for primary participant calls to action — the single most important action on a participant screen. One per screen maximum.
- **Do** use flat cards (elevation: 0, 8px radius, white fill) as the structural containers in the Designer. Tint (`primaryContainer.withOpacity(0.15)`) the scaffold background, not the cards.
- **Do** size all interactive touch targets to at least 48×48dp in the participant App (Material `VisualDensity.adaptivePlatformDensity` is not sufficient alone — verify targets manually).
- **Do** enforce 14px as the minimum text size. No exceptions for "secondary" or "helper" text.
- **Do** apply `prefers-reduced-motion` alternatives to all transitions. The platform's `WebTransitionBuilder` crossfade already complies; custom animations must too.
- **Do** use weight and size to create typographic hierarchy. The system has one font family; bold (700) and regular (400) are the primary levers.
- **Do** ensure color is never the sole carrier of status information. Error states require an error icon in addition to the error red border.

### Don't:
- **Don't** use fitness/wellness aesthetic conventions (MyFitnessPal, Headspace, Noom): no gamification, progress rings for motivation, motivational copy, or saturated lifestyle color. StudyU is not a consumer wellness product.
- **Don't** use tech-startup SaaS visual conventions (Stripe, Vercel, Linear): no dark mode with gradient accents, no glassmorphism (`backdrop-filter` blur used decoratively), no neon primary colors, no hero-metric dashboard layouts.
- **Don't** use health advocacy campaign conventions (awareness pages, patient-advocacy layouts): no large emotional photography as background, no campaign-poster hierarchy, no urgency-driven color.
- **Don't** use `border-left` or `border-right` greater than 1px as a colored accent stripe on cards, list items, or callouts. Rewrite with a background tint or icon.
- **Don't** use gradient text (`background-clip: text` with a gradient). Use a single solid color.
- **Don't** use warm-tinted backgrounds (cream, sand, paper, parchment, bone, linen). The system's neutrals tint toward the primary blue hue, not warmth.
- **Don't** use orange (protocol orange / secondary) for status indicators, tags, decorative dividers, or layout chrome. Its meaning is "primary participant action." Diluting it destroys the signal.
- **Don't** use shadows on cards. Cards are flat. If you're reaching for `elevation > 0` on a card, reconsider the layout instead.
- **Don't** nest cards. If content inside a card needs a container, use an inner tint region (`containerColor = secondaryContainer.withOpacity(0.3)`), not a nested card.
- **Don't** render text below 14px. Not for helper text, not for timestamps, not for "secondary" information.
- **Don't** use uppercase tracked eyebrow text above every section heading. It reads as AI-generated scaffold. If a kicker is needed, use a colored chip or a small icon label.
