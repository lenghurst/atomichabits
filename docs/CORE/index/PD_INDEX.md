# Pending Decisions Index

> **Purpose:** Quick reference table for all Pending Decisions
> **Last Updated:** 12 January 2026 (PD-119 RESOLVED, PD-133 READY via RQ-039/RQ-044)
> **Full Details:** See `../decisions/MANIFEST.md` for loading rules, domain files for details
> **Architecture:** Modular with Manifest — domain-isolated files with explicit loading rules

---

## Status Legend

| Status | Meaning | Location |
|--------|---------|----------|
| ✅ RESOLVED | Decision made, becomes CD | Domain file + `archive/PD_ARCHIVE_Q1_2026.md` |
| 🟢 READY | Research complete, awaiting human decision | Domain file (see table below) |
| 🟡 RESHAPED | Partially resolved, needs refinement | Domain file (see table below) |
| 🟡 DEFERRED | Deliberately delayed pending new research | Domain file (see table below) |
| 🔴 PENDING | Awaiting research or decision | Domain file (see table below) |
| 🔵 OPEN | New decision needing research | Domain file (see table below) |
| 🟢 CONFIRMED | Decision confirmed, not yet RESOLVED | Domain file (see table below) |

---

## Quick Reference

| PD# | Title | Status | Domain | Requires |
|-----|-------|--------|--------|----------|
| **PD-001** | Archetype Philosophy | ✅ RESOLVED → CD-005 | CORE | — |
| **PD-002** | Streaks vs Rolling Consistency | 🟢 READY | UX | RQ-033 ✅ |
| **PD-003** | Holy Trinity Validity | 🟢 READY | IDENTITY | RQ-037 ✅ |
| **PD-004** | Dev Mode Purpose | 🔴 PENDING | UX | — |
| **PD-101** | Sherlock Prompt Overhaul | 🟡 RESHAPED | IDENTITY | RQ-034, RQ-037 ✅ |
| **PD-102** | JITAI Hardcoded vs AI | 🔴 PENDING | JITAI | RQ-038 |
| **PD-103** | Sensitivity Detection | 🔴 PENDING | IDENTITY | RQ-035 |
| **PD-104** | LoadingInsightsScreen Personalization | 🔴 PENDING | UX | — |
| **PD-105** | Unified AI Coaching Architecture | 🟢 READY | IDENTITY | RQ-005,6,7 ✅ |
| **PD-106** | Multiple Identity Architecture | ✅ RESOLVED → CD-015 | CORE | RQ-011 |
| **PD-107** | Proactive Guidance System | 🟢 READY | IDENTITY | RQ-005,6,7 ✅ |
| **PD-108** | Constellation UX Migration | ✅ RESOLVED | UX | RQ-017 |
| **PD-109** | Council AI Activation Rules | ✅ RESOLVED | UX | RQ-016 |
| **PD-110** | Airlock Protocol User Control | ✅ RESOLVED | UX | RQ-018 |
| **PD-111** | Polymorphic Habit Attribution | ✅ RESOLVED | UX | RQ-015 |
| **PD-112** | Identity Priming Audio Strategy | ✅ RESOLVED | UX | RQ-018 |
| **PD-113** | Treaty Priority Hierarchy | ✅ RESOLVED | UX | RQ-020 |
| **PD-114** | Full Implementation Commitment | ✅ RESOLVED | CORE | — |
| **PD-115** | Treaty Creation UX | ✅ RESOLVED | UX | RQ-021 |
| **PD-116** | Population Learning Privacy | 🔴 PENDING | JITAI | RQ-023 |
| **PD-117** | ContextSnapshot Real-time Data | ✅ RESOLVED | JITAI | RQ-014 |
| **PD-118** | Treaty Modification UX | ✅ RESOLVED | UX | RQ-024 |
| **PD-119** | Summon Token Economy | ✅ RESOLVED | IDENTITY | RQ-039 ✅ |
| **PD-120** | The Chamber Visual Design | 🔴 PENDING | UX | RQ-036 |
| **PD-121** | Archetype Template Count | ✅ RESOLVED | IDENTITY | RQ-028 |
| **PD-122** | User Visibility of Preference Embedding | ✅ RESOLVED | IDENTITY | RQ-030 |
| **PD-123** | Facet Typical Energy State Field | ✅ RESOLVED | IDENTITY | — |
| **PD-124** | Recommendation Card Staleness | ✅ RESOLVED | IDENTITY | — |
| **PD-125** | Content Library Size at Launch | ✅ RESOLVED | IDENTITY | — |
| **PD-126** | Protocol Governance & Consolidation | 🔴 PENDING | CORE | — |
| **PD-130** | Witness App Access Model | 🔵 OPEN | WITNESS | RQ-041 |
| **PD-131** | Invitation Message Strategy | 🔵 OPEN | WITNESS | RQ-042 |
| **PD-132** | Invitation Timing (Commitment Ceremony) | 🟢 CONFIRMED | WITNESS | — |
| **PD-133** | Witness Stakes & Punishment | 🟢 READY | WITNESS | RQ-044 ✅ |
| **PD-134** | JITAI Witness Data Schema | 🔵 OPEN | WITNESS | RQ-045 |
| **PD-201** | URL Scheme Migration | 🔴 PENDING | UX | — |
| **PD-202** | Archive Documentation Handling | 🔴 PENDING | UX | — |

---

## Domain File Mapping

| Domain | File | Token Budget | Load When |
|--------|------|--------------|-----------|
| **CORE** | `../decisions/PD_CORE.md` | ~10k | Always (first) |
| **WITNESS** | `../decisions/PD_WITNESS.md` | ~12k | Witness features |
| **JITAI** | `../decisions/PD_JITAI.md` | ~10k | Intelligence layer |
| **IDENTITY** | `../decisions/PD_IDENTITY.md` | ~12k | Identity Coach |
| **UX** | `../decisions/PD_UX.md` | ~12k | Screens/Flows |

---

## Statistics

| Metric | Count |
|--------|-------|
| **Total PDs** | 37 |
| **✅ RESOLVED** | 16 (43%) |
| **🟢 READY** | 5 (14%) |
| **🟢 CONFIRMED** | 1 (3%) |
| **🟡 RESHAPED** | 1 (3%) |
| **🟡 DEFERRED** | 0 (0%) |
| **🔴 PENDING** | 10 (27%) |
| **🔵 OPEN** | 4 (11%) |

### By Domain

| Domain | Count | File |
|--------|-------|------|
| **CORE** | 2 PDs + 18 CDs | PD_CORE.md |
| **WITNESS** | 5 | PD_WITNESS.md |
| **JITAI** | 3 | PD_JITAI.md |
| **IDENTITY** | 11 | PD_IDENTITY.md |
| **UX** | 14 | PD_UX.md |

---

## Resolution Chain

```
RESOLVED (Archived):
├── PD-001 → CD-005 (Archetype Philosophy)
├── PD-106 → CD-015 (Multiple Identity)
├── PD-109 (Council AI Activation)
├── PD-113 (Treaty Priority)
├── PD-114 (Full Implementation)
├── PD-115 (Treaty Creation UX)
├── PD-121 → RQ-028 (12 Archetypes)
├── PD-122 → RQ-030 (Preference Embedding Hidden)
├── PD-123 (typical_energy_state field)
├── PD-124 (7-day TTL for cards)
└── PD-125 (Content Library Size → 50 with caveat)

UNBLOCKED BY RQ-005/006/007 (Ready for Decision):
├── PD-105 (Unified AI Coaching Architecture) ← Research complete
└── PD-107 (Proactive Guidance System) ← Research complete

UNBLOCKED BY RQ-028/029/030/031/032 (Resolved):
├── PD-121 ✅ RESOLVED (12 Archetypes)
├── PD-122 ✅ RESOLVED (Hidden preference embedding)
├── PD-123 ✅ RESOLVED (typical_energy_state)
└── PD-124 ✅ RESOLVED (7-day TTL)

UNBLOCKED BY RQ-017/018 (Resolved):
├── PD-108 ✅ RESOLVED (Big Bang with fallback)
├── PD-110 ✅ RESOLVED (Severity + Treaty hybrid)
└── PD-112 ✅ RESOLVED (Hybrid audio strategy)

UNBLOCKED BY RQ-024 (Resolved):
└── PD-118 ✅ RESOLVED (Constitutional Amendment Model)

UNBLOCKED BY RQ-037/RQ-033/RQ-025 (Ready for Decision):
├── PD-002 🟢 READY (Resilient Streak hybrid approach)
├── PD-003 🟢 READY (Holy Trinity → Shadow Cabinet validated)
└── PD-101 🟡 RESHAPED (RQ-037 complete, still needs RQ-034)

RESOLVED BY RQ-039/RQ-044 (12 Jan 2026):
├── PD-119 ✅ RESOLVED (Token Economy: Automatic base + optional bonus, soft cap, gain framing)
└── PD-133 🟢 READY (Stakes: Visibility-only + Encouragement allowed; Financial prohibited)

BLOCKED BY PRIOR RESEARCH:
├── PD-101 ← RQ-034 (Sherlock Architecture) — Partially unblocked
├── PD-102 ← RQ-038 (JITAI Component Allocation)
├── PD-103 ← RQ-035 (Sensitivity Detection)
├── PD-116 ← RQ-023 (Population Privacy)
└── PD-120 ← RQ-036 (Chamber Visual Design)

READY FOR DECISION (No blockers):
├── PD-002, PD-003, PD-119 (RQ-037/033/025 unblocked these) ← NEW
├── PD-004 (Dev Mode Purpose)
├── PD-104 (LoadingInsightsScreen)
├── PD-105, PD-107 (RQ-005/006/007 unblocked these)
└── PD-201, PD-202 (Technical housekeeping)

WITNESS INTELLIGENCE LAYER (New):
├── PD-130 🔵 OPEN (App Access Model) ← RQ-041
├── PD-131 🔵 OPEN (Invitation Message) ← RQ-042
├── PD-132 🟢 CONFIRMED (Commitment Ceremony timing)
├── PD-133 🟢 READY (Stakes & Punishment) ← RQ-044 ✅
└── PD-134 🔵 OPEN (JITAI Data Schema) ← RQ-045
```

---

*This index is auto-maintained. For full details, see domain files in `../decisions/`. See `../decisions/MANIFEST.md` for loading rules.*
