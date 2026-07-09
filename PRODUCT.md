# Product

## Register

product

## Users

**Designer** — researchers, clinicians, and digital health enthusiasts who design and manage N-of-1 clinical trials. They are domain experts working on desktop browsers; their primary workflow is configuring study parameters, defining interventions and measurements, setting eligibility criteria, and monitoring live studies. They expect software that matches their precision and respects their time.

**Participant App** — individuals actively enrolled in an N-of-1 trial. They may have limited technical skill and are interacting on smartphones during their daily life. Their primary task is logging observations, completing scheduled measurements, and receiving personalized treatment feedback. They require clarity, low cognitive overhead, and a sense of guided safety.

## Product Purpose

StudyU is a platform for designing and conducting digital N-of-1 trials — the gold standard for determining which intervention works best *for a specific individual*. It bridges rigorous personalized research methods with digital convenience, empowering both researchers to run large-scale trials and individuals to actively discover what improves their own health outcomes. Success means a researcher can take a trial from design to published results without switching tools, and a participant can complete their protocol without confusion or drop-off.

## Brand Personality

Precise, credible, empowering.

Voice is calm and authoritative without being cold — the tone of a thoughtful clinician-researcher explaining a protocol clearly. It never oversimplifies for participants, never condescends to experts. Emotional goal for participants: *quiet confidence that they are doing something meaningful*. Emotional goal for researchers: *expert-grade capability that respects their domain knowledge*.

## Anti-references

- **Fitness / wellness apps** (MyFitnessPal, Headspace, Noom): commercial polish, gamification, motivational color, lifestyle aesthetic. StudyU is not a consumer wellness product.
- **Tech-startup SaaS aesthetic** (Stripe, Linear, Vercel): sleek but cold; the startup-growth-tool register loses health credibility and signals the wrong priorities to clinical stakeholders.
- **Health advocacy campaigns** (awareness pages, patient-advocacy non-profits): emotional urgency, large photography, campaign-poster layout. StudyU is an operational tool, not a campaign.

## Design Principles

1. **Precision over decoration.** Every visual element earns its place by communicating information or reducing ambiguity. Decorative chrome, gradients, and ornamental color are noise in a clinical-research context.
2. **Dual register, one voice.** The Designer and the App serve fundamentally different users and workflows. Components and layouts should be tuned for each — but the brand personality, color identity, and typographic tone must read as one coherent platform.
3. **Trust through consistency.** Users in health contexts form trust through predictability. Interactions, hierarchy, and feedback patterns must be consistent within and across screens. Surprise is a liability.
4. **Accessibility is not optional.** The participant app serves individuals who may be elderly, anxious, or cognitively taxed by their health situation. WCAG 2.1 AA is the floor for both apps; the participant app should target AAA contrast ratios where feasible.
5. **Expert density, accessible clarity.** The Designer can afford density and power-user affordances; the App demands progressive disclosure and minimal cognitive load. Neither should sacrifice the other's needs.

## Accessibility & Inclusion

- Target: **WCAG 2.1 AA** across both apps
- Participant App should pursue AAA contrast ratios where feasible, given the audience may include elderly or clinically vulnerable users
- Support reduced motion (`prefers-reduced-motion`) for all transitions
- Ensure color is never the sole carrier of information (critical for color-blind users in data visualizations and status indicators)
- All interactive controls must meet minimum touch target size (48×48dp) in the participant app
