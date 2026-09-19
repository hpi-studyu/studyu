# BfArM medication data

## Legal decision status

StudyU uses the BfArM reference delivery as the source for medication product data. Section 31b SGB V requires electronic public access to the reference data and updates at least every two weeks. The BfArM FAQ directs commercial users to `Referenzdaten@bfarm.de`. The BfArM copyright notice states that supplied texts and tables must not be reproduced or distributed without prior consent.

These sources do not settle StudyU's redistribution rights. StudyU must obtain a written BfArM answer before production activation. The answer must cover each intended use:

- receipt at `bfarm@studyu.health`;
- storage in StudyU Supabase;
- normalization;
- serving to authenticated StudyU users, including participants and researcher or Designer accounts;
- persistence of selected snapshots in research answers and researcher exports;
- retention of one rollback release;
- required attribution;
- charges;
- territory;
- term and termination.

The decision record must contain the actual answer, approver, approval date, evidence reference, expiry, and approved uses. The core approved uses are `store`, `transform`, `serve_authenticated_studyu_users`, and `persist_in_research_answers`. Wider results also require `share_results_beyond_study_editors`.

An owner records a decision with `private.bfarm_add_approval`. The function demotes the current decision and inserts a new current decision in one transaction. Operators must not call it from a migration, production automation, or the importer.

Public accessibility is not a licence grant. StudyU must not activate production medication data until the written decision is recorded and reviewed.

## Data-protection decision

A selected medication and quantity are participant health data. The study controller and StudyU processor must define the lawful basis, consent wording, privacy notice, retention period, deletion process, researcher export rules, and Designer preview rules before release.

The selected product is stored as a snapshot in the research answer. Later catalog changes do not change historical answers. Researcher exports must retain the source release date and product provenance.

Barcode decoding happens on the device. StudyU never logs raw barcode payloads, serial numbers, batches, mailbox contents, or participant searches. The importer reports sanitized status and error metadata only.

Medication studies remain `result_sharing = 'private'` until wider sharing is approved. The database trigger enforces this rule for running studies.

## Data provenance

The source is the BfArM reference delivery from `referenzdaten@bfarm.de`. StudyU expects version 1.02 DSV data with these files:

- `YYYYMMDD-REFERENCE_MEDICINAL_PRODUCT.dsv`;
- `YYYYMMDD-REFERENCE_PHARMACEUTICAL_PRODUCT.dsv`;
- `YYYYMMDD-REFERENCE_SUBSTANCE.dsv`.

The importer preserves source strings. It maps the RMP file to `private.bfarm_medicinal_product`, the RPP file to `private.bfarm_pharmaceutical_product`, and the RSE file to `private.bfarm_substance`. Empty optional cells become SQL null.

`RMP_COUNT_SUBSTANCE` is stored as `rmp_count_substance`. StudyU does not equate this declared count with the number of component substance rows. Combination products can contain multiple components, each with its own active ingredients.

## API contract

The participant API exposes two authenticated RPCs:

- `lookup_bfarm_medication(p_pzn text)` returns one product or `null`. The PZN must contain exactly eight ASCII digits and pass the BfArM mod-11 check. Invalid input raises `bfarm_invalid_pzn`.
- `search_bfarm_medications(p_query text, p_limit integer = 20, p_offset integer = 0)` searches the normalized official name. A normalized query shorter than two characters raises `bfarm_query_too_short`. The limit is clamped to 1..50. The offset is clamped to zero or greater. German `ä`, `ö`, `ü`, and `ß` normalize to `ae`, `oe`, `ue`, and `ss`. Punctuation is removed and whitespace is collapsed. Search uses literal substring and trigram matching. Results order by exact match, prefix match, trigram similarity, official name, and PZN.

Both RPCs re-check the current approval and raise `bfarm_approval_missing` when the approval is missing, denied, revoked, or expired. Both functions project only the active release.

Each product object has exactly this shape:

```json
{
  "pzn": "03752864",
  "officialName": "Ibuprofen Test",
  "activeIngredientCount": 1,
  "dosageForm": {
    "patientFriendlyShort": "Tablet",
    "patientFriendlyLong": null,
    "bfarmName": "Tablette",
    "bfarmTermId": "T1"
  },
  "components": [
    {
      "key": "rpp-1",
      "number": 1,
      "dosageForm": {
        "patientFriendlyShort": "Tablet",
        "patientFriendlyLong": null,
        "bfarmName": "Tablette",
        "bfarmTermId": "T1"
      },
      "description": null,
      "activeIngredients": [
        {
          "key": "rse-1",
          "name": "Ibuprofen",
          "strength": "400 mg",
          "bfarmSubstanceId": null,
          "rank": 1
        }
      ]
    }
  ],
  "source": {
    "name": "BfArM Referenzdatenbank gemäß § 31b SGB V",
    "releaseDate": "2026-09-15"
  }
}
```

BfArM is the source. StudyU provides no prescribing advice. The active source publication date is returned with every product. Historical answers remain snapshots when the active catalog changes.

## Operations runbook

The intended UTC schedule is `17 7 1-3,15-17 * *`. The first days of each delivery window poll for the matching delivery. A missing delivery during the opening days reports `no_delivery` and exits successfully. A missing delivery after the window reports `delivery_overdue` and fails. A sender-matching message that fails authentication or validation reports `blocking_invalid_delivery`; the importer never activates a newer delivery past that message.

The importer is in effect from PR 3. It uses these secrets and variables:

- `BFARM_IMAP_HOST`, `BFARM_IMAP_PORT`, `BFARM_IMAP_USERNAME`, `BFARM_IMAP_PASSWORD`;
- `BFARM_ALLOWED_SENDER`, `BFARM_TRUSTED_AUTHSERV_ID`;
- `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`;
- `BFARM_PRODUCTION_ENABLED`, `BFARM_SCHEDULE_ENABLED`.

Scheduled runs require trusted-MTA verification. The importer checks the exact parsed sender address and the configured `Authentication-Results` authserv-id with `dmarc=pass` and `header.d=bfarm.de`. IMAPS and an exact sender address alone do not authenticate a scheduled delivery.

Manual dispatch accepts `allow_large_drop`, `allow_same_date_correction`, `corrects_release_id`, and `expected_attachment_sha256`. Large-drop and same-date-correction overrides require operator review. Scheduled runs never set either override.

The importer uses a content hash and message identity. It stages rows in chunks of at most 500, reads the active status after activation, and acknowledges the mailbox message only after the read-back confirms that the candidate is active. If the acknowledgement or response is lost, the next run uses the same identity and acknowledges the existing active release without reactivation. The importer never deletes, moves, or expunges mail.

Release metadata and transition history are retained. `prune_bfarm_releases(2)` removes content rows only from old non-pointer releases. It never removes the active release or the rollback pointer. The owner-only `private.bfarm_rollback_catalog(target, reason)` function requires the target to be the current rollback pointer and requires a current core approval.

Use these failure codes for triage:

- `no_delivery`: the current opening window has no valid matching delivery;
- `delivery_overdue`: the active release predates the expected window;
- `blocking_invalid_delivery`: the oldest matching-sender delivery failed authentication or validation;
- `bfarm_approval_missing`: activation or participant reads lack the required approval;
- `bfarm_large_drop`: a table count dropped below 90 percent without the protected override;
- `bfarm_same_date_conflict`: a same-date hash differs and requires manual correction;
- `bfarm_reference_integrity`: required release joins or component rows are incomplete.

Rotate the mailbox and Supabase credentials through the protected environment. Do not place secrets in the repository or in client environment files.

Before production activation, confirm all of the following:

1. Written BfArM approval covers every intended use.
2. Data-protection review covers structured health data, retention, deletion, exports, and previews.
3. The `bfarm-production` environment is protected and branch restricted.
4. Trusted-MTA authentication is configured and verified.
5. Importer secrets exist in the protected environment.
6. `app_config.app_min_version` is raised before any medication study runs. The version gate compares major and minor versions, so a patch-only change is insufficient.
7. A manual workflow run succeeds against the real mailbox and produces a sanitized report.
8. Only after this check passes, set `BFARM_PRODUCTION_ENABLED=true`, run a manual import, then enable the schedule.

Do not activate production medication data if BfArM does not permit storage, transformed serving, or answer snapshots. Do not replace the source with scraped AMIce data or expose mailbox contents.
