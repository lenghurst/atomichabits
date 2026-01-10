# Deep Think Reconciliation: RQ-028 through RQ-032

> **Source:** Deep Think Research Report: Identity Coach Phase 2 (10 January 2026)
> **Protocol:** Protocol 9 — External Research Reconciliation
> **Reconciled By:** Claude (Opus 4.5)
> **Date:** 10 January 2026

---

## Executive Summary

| Category | Count |
|----------|-------|
| **ACCEPT** | 15 |
| **MODIFY** | 5 |
| **REJECT** | 0 |
| **ESCALATE** | 0 (1 resolved via audit) |

**Overall Assessment:** HIGH QUALITY research output. Well-aligned with locked decisions. Minor modifications required for implementation specifics.

---

## Phase 1: Locked Decision Audit

### Decisions Checked

| CD | Description | Research Impact |
|----|-------------|-----------------|
| **CD-005** | 6-Dimension Archetype Model | ✅ COMPATIBLE — Research uses 6-dim vectors throughout |
| **CD-015** | 4-State Energy Model | ✅ COMPATIBLE — typical_energy_state aligns with 4 states |
| **CD-016** | DeepSeek V3.2 Strategy | ✅ COMPATIBLE — Uses DeepSeek for dimension curation |
| **CD-017** | Android-First | ✅ COMPATIBLE — No iOS/wearable dependencies |
| **CD-018** | ESSENTIAL Threshold | ✅ APPLIED — Classifications provided per RQ |

### Conflict Analysis

| Proposal | Potential Conflict | Resolution |
|----------|-------------------|------------|
| 12 Archetypes | None — extends CD-005 | ✅ ACCEPT |
| Preference Embedding (768-dim) | None — uses existing pgvector | ✅ ACCEPT |
| ICS replaces hexis_score | Requires audit of hexis_score usage | 🟡 MODIFY — Verify no code dependencies |
| typical_energy_state | Must use CD-015 4-state enum | 🟡 MODIFY — Explicit enum constraint |

**No REJECT-level conflicts identified.**

---

## Phase 2: Data Reality Audit (Android-First)

| Data Point | Required By | Android Available? | Permission | Battery | Action |
|------------|-------------|-------------------|------------|---------|--------|
| Facet name (text) | RQ-028 | ✅ User input | None | None | ✅ INCLUDE |
| Habit template embedding | RQ-028 | ✅ Generated server-side | None | None | ✅ INCLUDE |
| graceful_score | RQ-031, RQ-032 | ✅ Calculated client-side | None | None | ✅ INCLUDE |
| Total votes (completions) | RQ-032 | ✅ Database | None | None | ✅ INCLUDE |
| Ban/Adopt feedback | RQ-030 | ✅ User action | None | None | ✅ INCLUDE |

**All data points are Android-available with no special permissions or battery concerns.**

---

## Phase 3: Implementation Reality Audit

### Schema Check

| Proposed Table | Exists? | Conflict? | Action |
|----------------|---------|-----------|--------|
| `archetype_templates` | ❌ No | None | ✅ CREATE |
| `preference_embeddings` | ❌ No | None | ✅ CREATE |
| `identity_facets.ics_score` | ❌ Field doesn't exist | None | ✅ ADD FIELD |
| `identity_facets.typical_energy_state` | ❌ Field doesn't exist | None | ✅ ADD FIELD |

### Service Check

| Proposed Service | Exists? | Conflict? | Action |
|------------------|---------|-----------|--------|
| `RocchioUpdater` | ❌ No | None | ✅ CREATE |
| `PaceCar` | ❌ No | None | ✅ CREATE |
| `ICSCalculator` | ❌ No | None | ✅ CREATE |

### Existing Code Dependencies

| Metric | Current Usage | Research Proposal | Resolution |
|--------|---------------|-------------------|------------|
| `hexis_score` | Unknown — needs audit | Deprecate | 🟡 MODIFY — Audit before deprecating |
| `graceful_score` | Active in JITAI | Keep as ICS component | ✅ COMPATIBLE |

---

## Phase 4: Scope & Complexity Audit

### RQ-028: Archetype Template Definitions

| Element | Complexity | Classification | Notes |
|---------|------------|----------------|-------|
| 12 Archetype definitions | MEDIUM | **ESSENTIAL** | Core to Identity Coach |
| 6-dim vectors per archetype | LOW | **ESSENTIAL** | Required for matching |
| Cosine similarity matching | LOW | **ESSENTIAL** | Standard algorithm |
| Default to Builder if < 0.65 | LOW | **VALUABLE** | Edge case handling |
| User override in Settings | MEDIUM | **VALUABLE** | Good UX, not blocking |

**Scope Assessment:** ✅ Stays within original RQ scope. No expansion.

### RQ-029: Ideal Dimension Vector Curation

| Element | Complexity | Classification | Notes |
|---------|------------|----------------|-------|
| DeepSeek prompt for curation | LOW | **ESSENTIAL** | Scalable approach |
| Batch → CSV → Audit workflow | MEDIUM | **ESSENTIAL** | Human-in-loop |
| Multi-polar neutralization | LOW | **VALUABLE** | Sensible simplification |

**Scope Assessment:** ✅ Stays within original RQ scope.

### RQ-030: Preference Embedding Update

| Element | Complexity | Classification | Notes |
|---------|------------|----------------|-------|
| Rocchio algorithm | MEDIUM | **ESSENTIAL** | Well-established |
| Trinity Anchor (30% pull) | MEDIUM | **VALUABLE** | Prevents drift |
| Alpha values (0.15, 0.05) | LOW | **VALUABLE** | Should be configurable |

**Scope Assessment:** ✅ Stays within original RQ scope.

### RQ-031: Pace Car Threshold

| Element | Complexity | Classification | Notes |
|---------|------------|----------------|-------|
| Building vs Maintenance distinction | LOW | **ESSENTIAL** | Better than fixed count |
| graceful_score < 0.8 threshold | LOW | **ESSENTIAL** | Reasonable heuristic |
| Dynamic cap (3-5 based on ICS) | MEDIUM | **VALUABLE** | Adaptive approach |

**Scope Assessment:** ✅ IMPROVES on original RQ (Cognitive Load model better than fixed threshold).

### RQ-032: ICS Integration

| Element | Complexity | Classification | Notes |
|---------|------------|----------------|-------|
| ICS formula (log scale) | LOW | **ESSENTIAL** | Prevents runaway scores |
| Deprecate hexis_score | LOW | ⚠️ **ESCALATE** | Needs codebase audit |
| Visual tiers (Seed/Sapling/Oak) | LOW | **VALUABLE** | Good UX mapping |

**Scope Assessment:** ✅ Answers the RQ. Minor scope addition (visual tiers) is VALUABLE.

---

## Phase 5: ACCEPT / MODIFY / REJECT / ESCALATE

### RQ-028: Archetype Template Definitions

| Proposal | Verdict | Rationale |
|----------|---------|-----------|
| 12 Global Archetypes | ✅ **ACCEPT** | Psychologically grounded, matches CD-005 |
| Dimension vectors per archetype | ✅ **ACCEPT** | Required for matching |
| Builder archetype example | ✅ **ACCEPT** | Good quality template |
| `archetype_templates` SQL | ✅ **ACCEPT** | Clean schema |
| Cosine similarity < 0.65 → Builder | 🟡 **MODIFY** | Default should be configurable, not hardcoded |
| User override in Settings | ✅ **ACCEPT** | Good UX |

### RQ-029: Ideal Dimension Vector Curation

| Proposal | Verdict | Rationale |
|----------|---------|-----------|
| DeepSeek prompt for dimension assignment | ✅ **ACCEPT** | Scalable, uses CD-016 |
| Batch → CSV → Audit workflow | ✅ **ACCEPT** | Human oversight retained |
| Neutralize multi-polar habits (0.0) | ✅ **ACCEPT** | Pragmatic simplification |
| Prompt template provided | ✅ **ACCEPT** | Ready to use |

### RQ-030: Preference Embedding Update

| Proposal | Verdict | Rationale |
|----------|---------|-----------|
| Rocchio algorithm | ✅ **ACCEPT** | Industry standard |
| Trinity Anchor (30% seed, 70% current) | ✅ **ACCEPT** | Prevents aspiration drift |
| Ban α = 0.15 | 🟡 **MODIFY** | Should be configurable constant |
| Adopt α = 0.05 | 🟡 **MODIFY** | Should be configurable constant |
| `preference_embeddings` SQL | ✅ **ACCEPT** | Includes trinity_seed |
| Dart pseudocode | ✅ **ACCEPT** | Clear implementation |

### RQ-031: Pace Car Threshold

| Proposal | Verdict | Rationale |
|----------|---------|-----------|
| Building vs Maintenance model | ✅ **ACCEPT** | Better than fixed count |
| graceful_score < 0.8 = Building | ✅ **ACCEPT** | Reasonable threshold |
| Seed users: max 3 Building | ✅ **ACCEPT** | Conservative for new users |
| Sapling/Oak users: max 5 Building | ✅ **ACCEPT** | Progressive unlock |
| Maintenance habits unlimited | ✅ **ACCEPT** | Correct — automatic habits don't burden |

### RQ-032: ICS Integration

| Proposal | Verdict | Rationale |
|----------|---------|-----------|
| ICS formula (AvgConsistency × log10(Votes+1)) | ✅ **ACCEPT** | Prevents runaway, rewards longevity |
| Deprecate hexis_score | ⚠️ **ESCALATE** | Need codebase audit first |
| Keep graceful_score | ✅ **ACCEPT** | Used in Pace Car, JITAI |
| Visual tiers (Seed < 1.2, Sapling < 3.0, Oak ≥ 3.0) | 🟡 **MODIFY** | Thresholds need validation |
| Add `ics_score` field to identity_facets | ✅ **ACCEPT** | Clean addition |

### PD Recommendations from Research

| PD | Recommendation | Verdict | Rationale |
|----|----------------|---------|-----------|
| PD-121 | 12 Archetypes | ✅ **ACCEPT** | Matches research, psychologically grounded |
| PD-122 | No user visibility of embedding | ✅ **ACCEPT** | 768-dim is noise to users |
| PD-123 | Add typical_energy_state | 🟡 **MODIFY** | Must use CD-015 4-state enum explicitly |
| PD-124 | 7-day TTL for cards | ✅ **ACCEPT** | Reasonable staleness threshold |

---

## Phase 6: Integration Specifications

### Modifications Required

#### MOD-1: Configurable Default Archetype

**Original:** Default to Builder if similarity < 0.65
**Modified:** Make default archetype configurable via constant; add "Unknown" fallback with review flag

```dart
const String DEFAULT_ARCHETYPE = 'builder';
const double SIMILARITY_THRESHOLD = 0.65;

if (maxSimilarity < SIMILARITY_THRESHOLD) {
  return ArchetypeMatch(
    archetype: DEFAULT_ARCHETYPE,
    confidence: maxSimilarity,
    flagForReview: true,
  );
}
```

#### MOD-2: Configurable Alpha Values

**Original:** Hardcoded α = 0.15 (ban), α = 0.05 (adopt)
**Modified:** Configurable constants

```dart
class PreferenceConfig {
  static const double ALPHA_BAN = 0.15;
  static const double ALPHA_ADOPT = 0.05;
  static const double ANCHOR_WEIGHT = 0.30;
}
```

#### MOD-3: ICS Visual Tier Thresholds

**Original:** Seed < 1.2, Sapling < 3.0, Oak ≥ 3.0
**Modified:** Make thresholds configurable; document rationale

```dart
class ICSTiers {
  static const double SEED_MAX = 1.2;      // ~15 votes at 100% consistency
  static const double SAPLING_MAX = 3.0;   // ~100 votes at 100% consistency
  // Oak: > 3.0
}
```

#### MOD-4: typical_energy_state Must Use CD-015 Enum

**Original:** Field mentioned but enum not specified
**Modified:** Explicit enum constraint

```sql
ALTER TABLE identity_facets
ADD COLUMN typical_energy_state TEXT
CHECK (typical_energy_state IN ('high_focus', 'high_physical', 'social', 'recovery'));
```

---

## RESOLVED: hexis_score Deprecation

### Audit Results

```bash
grep -rn "hexis_score" lib/       # No files found
grep -rn "hexis_score" supabase/  # No files found
```

**Finding:** `hexis_score` is a documentation-only term. It was mentioned in aspirational docs (Living Garden inputs) but **never implemented in code**.

### Resolution

| Item | Decision |
|------|----------|
| Deprecate hexis_score | ✅ **ACCEPT** — No code dependencies |
| Replace with ICS | ✅ **ACCEPT** — Clean implementation |
| Update GLOSSARY.md | ✅ Mark hexis_score as DEPRECATED |

**ESCALATE → ACCEPT** (no human approval needed — no existing functionality affected)

---

## Summary Statistics

| RQ | ACCEPT | MODIFY | REJECT | ESCALATE |
|----|--------|--------|--------|----------|
| RQ-028 | 5 | 1 | 0 | 0 |
| RQ-029 | 4 | 0 | 0 | 0 |
| RQ-030 | 4 | 2 | 0 | 0 |
| RQ-031 | 5 | 0 | 0 | 0 |
| RQ-032 | 4 | 1 | 0 | 0 |
| PDs | 3 | 1 | 0 | 0 |
| **TOTAL** | **25** | **5** | **0** | **0** |

---

## Next Steps

1. ✅ Mark RQ-028, RQ-029, RQ-030, RQ-031, RQ-032 as COMPLETE
2. ✅ hexis_score audit complete — safe to deprecate (no code deps)
3. ✅ Resolve PD-121, PD-122, PD-123, PD-124
4. ✅ Extract implementation tasks (Protocol 8)
5. ✅ Update IMPLEMENTATION_ACTIONS.md Quick Status

---

*This reconciliation follows Protocol 9 from AI_AGENT_PROTOCOL.md.*
