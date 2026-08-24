# Notices and attributions

The StudyU Material 3 skill mixes original StudyU-authored content with material derived from
Google's Material Design documentation and from the Android Open Source Project. Pieces are under
different licenses; this file records which is which.

## StudyU original work

- `SKILL.md`, the router/workflow/checklist
- `references/flutter/*`, the Material→Flutter mapping layer
- `references/studyu/*`, the StudyU codebase patterns and deviations
- `scripts/refresh-material-refs.js` (the consolidation wrapper)

## Scripts vendored from abhixv/m3-expressive-design-skill (MIT)

`scripts/refresh-m3.js` and `scripts/refresh-component-tokens.js` are adapted from
<https://github.com/abhixv/m3-expressive-design-skill> (MIT License, © 2026 abhixv). Each file
references the license in its header; the full MIT text ships as `vendor-m3-expressive.LICENSE`.
The selection, organization, and authored prose approach for the Material references derive from
that repository.

## Material Design guidelines (© Google LLC, CC BY 4.0)

The design guidance, placement rules, component behavior, and do/don'ts in `references/material/*`
are derived from Material Design 3 documentation published at <https://m3.material.io>. Material
Design documentation is published by Google under the
[Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/)
(code samples under Apache 2.0), per the site's terms. This material is reproduced and summarized
here **with attribution to Google LLC** and remains under its original license.

## AndroidX / Compose Material 3 tokens (Apache License 2.0)

`references/material/component-tokens.md` contains dp, sp, shape, and elevation values extracted
from the generated `androidx.compose.material3.tokens` sources.

> Copyright (C) The Android Open Source Project
> Licensed under the Apache License, Version 2.0 (the "License").
> http://www.apache.org/licenses/LICENSE-2.0

If you redistribute this skill or build on it, keep this attribution intact.
