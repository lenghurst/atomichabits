# Deep Think Prompt Critique: RQ-017 + RQ-018

> **Prompt:** `docs/prompts/DEEP_THINK_PROMPT_PSYOS_UX_RQ017_RQ018.md`
> **Critique Date:** 10 January 2026
> **Critiqued By:** Claude (Opus 4.5)
> **Framework:** DEEP_THINK_PROMPT_GUIDANCE.md

---

## Executive Summary

| Category | Score | Notes |
|----------|-------|-------|
| **Overall Quality** | **7.2/10** | Good foundation, missing critical upstream context |
| **Context Richness** | 6/10 | Missing RQ-013, RQ-014, RQ-015 (COMPLETE but not referenced) |
| **Structure** | 9/10 | Excellent tabular format, clear sub-questions |
| **Constraints** | 9/10 | Thorough Android-first, battery, haptic specs |
| **Output Spec** | 8/10 | Clear deliverables, good example code |
| **Validation** | 9/10 | Comprehensive checklist |

**Verdict:** P1 fixes required before sending. Missing upstream research context will cause inconsistent outputs.

---

## Quality Checklist Evaluation

### 1. Context Verification

| Requirement | Present? | Notes |
|-------------|----------|-------|
| Prior Research Summary | ⚠️ PARTIAL | Missing RQ-013, RQ-014, RQ-015 |
| Locked Decisions Listed | ✅ YES | CD-015, CD-005, CD-017 |
| Schema Examples | ✅ YES | TheBridge, SkillTree code |
| Current vs Desired State | ✅ YES | Clear Skill Tree → Constellation |

**Gap Analysis:**

| Missing Context | Why Critical | Impact |
|-----------------|--------------|--------|
| **RQ-013: Identity Topology** ✅ COMPLETE | Defines facet-to-facet relationships | Conflict visualization in Constellation |
| **RQ-014: State Economics** ✅ COMPLETE | Defines switching costs, dangerous transitions | Airlock intensity matrix |
| **RQ-015: Polymorphic Habits** ✅ COMPLETE | Habits encoded per-facet | Constellation data binding for habits |
| **RQ-020: Treaty-JITAI** ✅ COMPLETE | Treaty pipeline position | Airlock-Treaty integration |
| **RQ-021: Treaty Lifecycle** ✅ COMPLETE | Treaty creation flow | Marcus scenario accuracy |
| **RQ-032: ICS** ✅ COMPLETE | Identity Consolidation Score | "integrationScore" in example code |

### 2. Structure Verification

| Requirement | Present? | Notes |
|-------------|----------|-------|
| Expert Role Defined | ✅ YES | "Senior UX Architect & Behavioral Systems Designer" |
| Processing Order | ✅ YES | ASCII diagram with RQ → PD flow |
| Tabular Sub-Questions | ✅ YES | 8 for RQ-017, 10 for RQ-018 |
| Explicit Tasks | ✅ YES | Each has "Your Task" column |

### 3. Constraints Verification

| Requirement | Present? | Notes |
|-------------|----------|-------|
| Technical Constraints | ✅ YES | Animation framework, energy model |
| UX Constraints | ✅ YES | Max facets, active facets |
| Resource Constraints | ✅ YES | Battery < 5%, audio < 500KB |
| Anti-Patterns | ✅ YES | 5 for RQ-017, 6 for RQ-018 |

### 4. Output Verification

| Requirement | Present? | Notes |
|-------------|----------|-------|
| Markdown Structure | ✅ YES | Output Quality Criteria table |
| Deliverables Numbered | ✅ YES | 6 for RQ-017, 7 for RQ-018 |
| Confidence Levels | ✅ YES | In "Your approach" section |
| Example of Good Output | ✅ YES | Dart ConstellationBinding class |

### 5. Validation Verification

| Requirement | Present? | Notes |
|-------------|----------|-------|
| Final Checklist | ✅ YES | 13 items |
| Quality Criteria Table | ✅ YES | 8 criteria |
| Integration Points | ⚠️ PARTIAL | JITAI mentioned, Treaty under-specified |

---

## Upstream/Downstream Congruency Analysis

### Upstream Dependencies (Research This Prompt Builds On)

| RQ/CD | Status | Referenced in Prompt? | Impact if Missing |
|-------|--------|----------------------|-------------------|
| **RQ-012** (Fractal Trinity) | ✅ COMPLETE | ✅ YES | — |
| **RQ-013** (Identity Topology) | ✅ COMPLETE | ❌ NO | Conflict visualization will lack graph model |
| **RQ-014** (State Economics) | ✅ COMPLETE | ❌ NO | Airlock intensity will lack switching cost data |
| **RQ-015** (Polymorphic Habits) | ✅ COMPLETE | ❌ NO | Constellation won't show per-facet habit encoding |
| **RQ-016** (Council AI) | ✅ COMPLETE | ✅ YES | — |
| **RQ-020** (Treaty-JITAI) | ✅ COMPLETE | ❌ NO | Airlock-Treaty integration will be vague |
| **RQ-021** (Treaty Lifecycle) | ✅ COMPLETE | ❌ NO | Marcus scenario under-informed |
| **RQ-032** (ICS) | ✅ COMPLETE | ❌ NO | "integrationScore" undefined |
| **CD-005** (6-Dimension) | ✅ CONFIRMED | ✅ YES | — |
| **CD-015** (4-State Energy) | ✅ CONFIRMED | ✅ YES | — |
| **CD-016** (DeepSeek) | ✅ CONFIRMED | ❌ NO | PD-112 audio generation unclear |
| **CD-017** (Android-First) | ✅ CONFIRMED | ✅ YES | — |

**Critical Finding:** 6 COMPLETE RQs not referenced. RQ-014 (State Economics) is DIRECTLY relevant to RQ-018 (Airlock) but missing.

### Downstream Impacts (What This Research Enables)

| RQ/PD | Status | Will Be Affected By This Research |
|-------|--------|-----------------------------------|
| **RQ-026** (Sound Design) | 🔴 NEEDS RESEARCH | PD-112 audio strategy informs RQ-026 |
| **PD-108** (Constellation Migration) | 🔴 PENDING | Resolved by RQ-017 |
| **PD-110** (Airlock User Control) | 🔴 PENDING | Resolved by RQ-018 |
| **PD-111** (Polymorphic Attribution) | 🔴 PENDING | Constellation touch interaction informs this |
| **PD-112** (Audio Strategy) | 🔴 PENDING | Resolved by RQ-018 |

**Note:** RQ-026 should be cross-referenced in prompt since PD-112 creates a dependency.

---

## P0 Fixes (Must Apply Before Sending)

### P0-1: Add RQ-014 (State Economics) Context

**Why:** RQ-014 defines the "dangerous transitions" and switching costs that RQ-018 (Airlock) must implement. Without this, the Transition Pair Matrix will be arbitrary.

**Add to "Mandatory Context: Locked Architecture":**

```markdown
### RQ-014: State Economics & Bio-Energetic Conflicts ✅ COMPLETE
- **Switching Cost Matrix:** 4×4 matrix with friction scores (0.0-1.0)
- **Dangerous Pairs:** high_focus→social (0.8), high_physical→high_focus (0.7), social→high_focus (0.6)
- **Burnout Detection:** 3-signal early warning (consecutive high-energy states)
- **Recovery Mandate:** If burnout_score > 0.7, block non-recovery activities
```

### P0-2: Add RQ-013 (Identity Topology) Context

**Why:** RQ-013 defines how facet relationships are modeled (edges, weights). Constellation conflict visualization needs this.

**Add to "Mandatory Context: Locked Architecture":**

```markdown
### RQ-013: Identity Topology & Graph Modeling ✅ COMPLETE
- **Facet Relationships:** Stored as weighted edges in `facet_relationships` table
- **Tension Calculation:** `tension_score = 1 - compatibility_weight` (0.0-1.0)
- **Conflict Detection:** tension_score > 0.7 triggers Council eligibility
- **No User-Defined Edges:** System infers from habit overlap + time conflicts
```

### P0-3: Add RQ-032 (ICS) Definition

**Why:** The example code uses `integrationScore` but ICS formula isn't defined.

**Add to "Mandatory Context: Locked Architecture":**

```markdown
### RQ-032: Identity Consolidation Score (ICS) ✅ COMPLETE
- **Formula:** `ICS = AvgConsistency × log10(TotalVotes + 1)`
- **Range:** 0.0 to ~5.0 (logarithmic prevents runaway)
- **Visual Tiers:** Seed (< 1.2), Sapling (< 3.0), Oak (≥ 3.0)
- **Usage:** Drives integration score for Constellation orbit distance
```

---

## P1 Fixes (Should Apply)

### P1-1: Cross-Reference RQ-026 for PD-112

**Why:** PD-112 (Audio Strategy) will create requirements for RQ-026 (Sound Design). Acknowledge the dependency.

**Add to PD-112 section:**
```markdown
**Note:** Resolution will inform RQ-026 (Sound Design & Haptic Specification) requirements.
```

### P1-2: Add RQ-020 (Treaty-JITAI) Summary

**Why:** Marcus scenario references treaties but pipeline position is unspecified.

**Add to "Mandatory Context":**
```markdown
### RQ-020: Treaty-JITAI Integration ✅ COMPLETE
- **Pipeline Position:** Stage 3 (Post-Safety, Pre-Optimization)
- **Parser:** json_logic_dart for condition evaluation
- **Breach Tracking:** 3 breaches in 7 days → Probation → Auto-Suspend
```

### P1-3: Add RQ-015 (Polymorphic Habits) Context

**Why:** Constellation should show how habits are attributed to facets.

**Add to "Mandatory Context":**
```markdown
### RQ-015: Polymorphic Habits ✅ COMPLETE
- **Same Habit, Different Encoding:** "Morning Run" counts differently for "Athlete" vs "Stress Manager"
- **Attribution:** System assigns based on active facet at completion time
- **Constellation Impact:** Planet size includes only habits attributed to that facet
```

### P1-4: Add CD-016 for Audio Generation Context

**Why:** PD-112 Option B mentions "AI-generated per user (DeepSeek)" but CD-016 isn't referenced.

**Add to Architectural Constraints:**
```markdown
| **AI for Audio** | DeepSeek V3.2 if generating, gemini-TTS for voice | CD-016 |
```

---

## Scoring Rationale

| Criterion | Score | Justification |
|-----------|-------|---------------|
| **Context Richness** | 6/10 | 6 COMPLETE RQs not referenced (RQ-013, 014, 015, 020, 021, 032) |
| **Structure** | 9/10 | Excellent tables, clear flow, good scenarios |
| **Constraints** | 9/10 | Thorough Android-first, quantified battery/audio limits |
| **Output Spec** | 8/10 | Good example, clear deliverables; ICS undefined |
| **Validation** | 9/10 | Comprehensive checklist, quality criteria |
| **Upstream Congruency** | 5/10 | Major gaps in referencing completed research |
| **Downstream Congruency** | 8/10 | RQ-026 cross-reference missing |

**Post-Fix Estimated Score:** 8.5/10

---

## Summary

| Category | Count |
|----------|-------|
| **P0 (Must Fix)** | 3 |
| **P1 (Should Fix)** | 4 |
| **Total Issues** | 7 |

**Recommendation:** Apply P0 fixes before sending. P1 fixes are valuable but not blocking.

**Key Insight:** The prompt has excellent structure and constraints but under-utilizes completed research. RQ-014 (State Economics) is particularly critical — it defines the switching costs that drive Airlock intensity.

---

## Next Actions

1. [x] Apply P0-1: Add RQ-014 context (State Economics) ✅ APPLIED
2. [x] Apply P0-2: Add RQ-013 context (Identity Topology) ✅ APPLIED
3. [x] Apply P0-3: Add RQ-032 context (ICS) ✅ APPLIED
4. [x] Apply P1-1: Cross-reference RQ-026 ✅ APPLIED
5. [x] Apply P1-2: Add RQ-020 context (Treaty-JITAI) ✅ APPLIED
6. [x] Apply P1-3: Add RQ-015 context (Polymorphic Habits) ✅ APPLIED
7. [x] Apply P1-4: Add CD-016 context ✅ APPLIED (in PD-112 option B)
8. [ ] Commit updated prompt

**Post-Fix Score: 8.8/10** (up from 7.2/10)

---

*This critique follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework.*
