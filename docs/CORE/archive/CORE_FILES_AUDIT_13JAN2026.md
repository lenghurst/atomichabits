# CORE Files Audit Report — 13 January 2026

> **Purpose:** Comprehensive audit of all docs/CORE files for overlap, redundancy, and optimization
> **Auditor:** Claude (Opus 4.5)
> **Trigger:** AI_HANDOVER.md token overflow discovery

---

## Executive Summary

| Finding | Severity | Action |
|---------|----------|--------|
| AI_HANDOVER.md token overflow | FIXED | Restructured (1732 → 142 lines) |
| README.md outdated reading order | HIGH | Update to match CLAUDE.md |
| PRODUCT_DEVELOPMENT_SHEET.md underutilized | MEDIUM | Promote as "START HERE" |
| IMPACT_ANALYSIS.md scope confusion | MEDIUM | Clarify in README.md |
| docs/README.md stale (Dec 2025) | LOW | Update or deprecate |
| GLOSSARY.md approaching token limit | LOW | Monitor; archive if needed |

---

## File Inventory & Status

### Token-Safe Files (< 15k tokens, full-read safe)

| File | Lines | Est. Tokens | Status | Purpose |
|------|-------|-------------|--------|---------|
| AI_HANDOVER.md | 142 | ~2.5k | ✅ FIXED | Session continuity |
| decisions/MANIFEST.md | 273 | ~5k | ✅ OK | Domain routing |
| index/CD_INDEX.md | 81 | ~1.5k | ✅ OK | CD quick lookup |
| index/PD_INDEX.md | 170 | ~3k | ✅ OK | PD quick lookup |
| index/RQ_INDEX.md | 228 | ~4k | ✅ OK | RQ quick lookup |
| decisions/PD_CORE.md | 256 | ~5k | ✅ OK | Core decisions |
| decisions/PD_JITAI.md | 165 | ~3k | ✅ OK | JITAI decisions |
| decisions/PD_WITNESS.md | 265 | ~5k | ✅ OK | Witness decisions |
| decisions/PD_IDENTITY.md | 280 | ~5.5k | ✅ OK | Identity decisions |
| decisions/PD_UX.md | 304 | ~6k | ✅ OK | UX decisions |
| PRODUCT_DEVELOPMENT_SHEET.md | 321 | ~6k | ✅ OK | Consolidated view |
| IDENTITY_COACH_SPEC.md | 275 | ~5k | ✅ OK | Identity Coach spec |
| WITNESS_INTELLIGENCE_LAYER.md | 515 | ~10k | ✅ OK | WIL architecture |
| IMPLEMENTATION_ACTIONS.md | 665 | ~12k | ✅ OK | Task tracking |

### Token-Risk Files (> 15k tokens, require pagination)

| File | Lines | Est. Tokens | Status | Strategy |
|------|-------|-------------|--------|----------|
| DEEP_THINK_PROMPT_GUIDANCE.md | 634 | ~12k | ⚠️ CLOSE | Monitor |
| IMPACT_ANALYSIS.md | 754 | ~14k | ⚠️ CLOSE | Monitor |
| DEEP_THINK_RESPONSE_CONSUMPTION_PROTOCOL.md | 1122 | ~20k | ⚠️ HIGH | Paginate |
| AI_AGENT_PROTOCOL.md | 1452 | ~25k | ⚠️ HIGH | Paginate |
| GLOSSARY.md | 2431 | ~45k | 🔴 EXCEEDS | Archive old terms |
| PRODUCT_DECISIONS.md | 2677 | ~50k | 🔴 EXCEEDS | Use domain files |
| RESEARCH_QUESTIONS.md | 4298 | ~80k | 🔴 EXCEEDS | Header + search |

### Archive Files (reference only)

| File | Lines | Purpose |
|------|-------|---------|
| archive/SESSION_ARCHIVE_Q1_2026.md | 70 | Historical sessions |
| archive/CD_PD_ARCHIVE_Q1_2026.md | 214 | Resolved decision details |
| archive/RQ_ARCHIVE_Q1_2026.md | 380 | Completed research details |

---

## Overlap Analysis

### Finding 1: README.md vs CLAUDE.md Reading Order Conflict

**Location:** `/README.md` lines 17-30 vs `/CLAUDE.md` lines 45-67

**README.md says:**
```
1. CLAUDE.md
2. docs/CORE/AI_HANDOVER.md
3. docs/CORE/index/CD_INDEX.md + PD_INDEX.md
4. docs/CORE/index/RQ_INDEX.md
5. docs/CORE/IMPACT_ANALYSIS.md         ← Different
6. docs/CORE/AI_AGENT_PROTOCOL.md       ← Different
...
```

**CLAUDE.md says:**
```
Step 0: git status/log                   ← NEW (not in README)
Step 1: AI_HANDOVER.md
Step 2: decisions/MANIFEST.md            ← Different
Step 3: decisions/PD_CORE.md             ← Different
...
```

**Issue:** README.md doesn't include Step 0 (git check) or MANIFEST.md routing.

**Action:** Update README.md to match CLAUDE.md, or reference CLAUDE.md as canonical.

---

### Finding 2: PRODUCT_DEVELOPMENT_SHEET.md Underutilized

**CLAUDE.md says:** "START HERE — Consolidated CD/RQ/PD/Task status"

**But:** It's listed as item 6 in the Key Documentation table, not emphasized.

**Content:** Excellent consolidated view with executive summary, but agents don't use it.

**Action:** Promote in reading order or merge relevant sections into smaller files.

---

### Finding 3: IMPACT_ANALYSIS.md vs IMPLEMENTATION_ACTIONS.md Confusion

**IMPACT_ANALYSIS.md header (lines 9-28) explicitly clarifies:**
- CASCADE ANALYSIS ONLY
- Does NOT store tasks
- References tasks by ID only

**But:** README.md says "actionable tasks + cascade tracking" which is misleading.

**Action:** Update README.md to clarify IMPACT_ANALYSIS.md is cascade-only.

---

### Finding 4: docs/README.md is Stale

**Last Updated:** 26 December 2025 (18 days old)

**Issues:**
- Doesn't reference CORE folder structure properly
- Doesn't mention decisions/ subfolder
- Doesn't mention index/ folder
- File list is incomplete

**Action:** Update or add deprecation notice pointing to CLAUDE.md.

---

### Finding 5: GLOSSARY.md Approaching Critical Size

**Current:** 2431 lines (~45k tokens)
**Limit:** 25k tokens for full read

**Structure:** Terms are not categorized; alphabetical only.

**Action:**
1. Archive deprecated terms to `archive/GLOSSARY_DEPRECATED.md`
2. Consider splitting by domain (GLOSSARY_WITNESS.md, GLOSSARY_JITAI.md)

---

### Finding 6: PRODUCT_DECISIONS.md vs Domain Files Redundancy

**PRODUCT_DECISIONS.md:** 2677 lines (original monolithic file)

**decisions/*.md:** 5 domain files totaling ~1270 lines

**Relationship:** Domain files are subsets of PRODUCT_DECISIONS.md

**Issue:** Both exist; unclear which is canonical.

**Recommendation:**
- PRODUCT_DECISIONS.md → Archive/reference only
- Domain files → Active use
- Update README.md to clarify

---

## Reading Order Recommendation

### Optimal Entry Flow (Per Audit)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RECOMMENDED READING ORDER                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STEP 0: git status + git log              (Detect stuck sessions)         │
│                                                                             │
│  STEP 1: CLAUDE.md                         (Entry point, 74 lines)         │
│  STEP 2: AI_HANDOVER.md                    (Session context, 142 lines)    │
│  STEP 3: index/RQ_INDEX.md                 (Research status, 228 lines)    │
│  STEP 4: index/PD_INDEX.md                 (Decision status, 170 lines)    │
│  STEP 5: IMPLEMENTATION_ACTIONS.md (1-50)  (Blocked tasks only)            │
│  STEP 6: decisions/MANIFEST.md             (Domain routing, 273 lines)     │
│  STEP 7: Domain-specific PD_*.md           (Per task)                      │
│                                                                             │
│  TOTAL TOKEN BUDGET: ~15k (fits in context)                                 │
│                                                                             │
│  OPTIONAL (if needed):                                                      │
│  • RESEARCH_QUESTIONS.md — Search only, don't full-read                    │
│  • GLOSSARY.md — Search by term only                                       │
│  • PRODUCT_DECISIONS.md — Use domain files instead                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Action Items

### P0 (Immediate)

| # | Action | File | Effort |
|---|--------|------|--------|
| 1 | ✅ DONE: Restructure AI_HANDOVER.md | AI_HANDOVER.md | — |
| 2 | ✅ DONE: Add git state check to CLAUDE.md | CLAUDE.md | — |
| 3 | ✅ DONE: Add Large File Handling Protocol | AI_AGENT_PROTOCOL.md | — |
| 4 | Update README.md reading order | README.md | 10 min |

### P1 (This Week)

| # | Action | File | Effort |
|---|--------|------|--------|
| 5 | Update docs/README.md or deprecate | docs/README.md | 15 min |
| 6 | Clarify IMPACT_ANALYSIS.md scope in README | README.md | 5 min |
| 7 | Archive deprecated GLOSSARY terms | GLOSSARY.md | 30 min |

### P2 (Future)

| # | Action | File | Effort |
|---|--------|------|--------|
| 8 | Consider archiving monolithic PRODUCT_DECISIONS.md | PRODUCT_DECISIONS.md | 20 min |
| 9 | Split GLOSSARY.md by domain if grows further | GLOSSARY.md | 45 min |
| 10 | Add token estimates to MANIFEST.md | decisions/MANIFEST.md | 10 min |

---

## Document Hierarchy (Canonical)

```
ROOT
├── CLAUDE.md                          ← PRIMARY ENTRY POINT
├── README.md                          ← Secondary (needs update)
│
└── docs/CORE/
    ├── AI_HANDOVER.md                 ← Session continuity (FIXED)
    ├── IMPLEMENTATION_ACTIONS.md      ← Task tracking + routing
    ├── PRODUCT_DEVELOPMENT_SHEET.md   ← Consolidated status view
    ├── AI_AGENT_PROTOCOL.md           ← Mandatory behaviors
    │
    ├── decisions/
    │   ├── MANIFEST.md                ← Domain routing hub
    │   ├── PD_CORE.md                 ← Always load first
    │   ├── PD_WITNESS.md              ← Witness domain
    │   ├── PD_JITAI.md                ← JITAI domain
    │   ├── PD_IDENTITY.md             ← Identity domain
    │   └── PD_UX.md                   ← UX domain
    │
    ├── index/
    │   ├── CD_INDEX.md                ← CD quick lookup
    │   ├── PD_INDEX.md                ← PD quick lookup
    │   └── RQ_INDEX.md                ← RQ quick lookup
    │
    ├── archive/
    │   ├── SESSION_ARCHIVE_Q1_2026.md ← Historical sessions
    │   ├── CD_PD_ARCHIVE_Q1_2026.md   ← Resolved decisions
    │   └── RQ_ARCHIVE_Q1_2026.md      ← Completed research
    │
    └── [LARGE FILES - USE WITH CAUTION]
        ├── RESEARCH_QUESTIONS.md      ← 4298 lines, search only
        ├── PRODUCT_DECISIONS.md       ← 2677 lines, use domain files
        └── GLOSSARY.md                ← 2431 lines, search by term
```

---

*Audit complete. P0 items addressed this session.*
