# Pending Decisions Index

> **Purpose:** Quick reference table for all Pending Decisions
> **Last Updated:** 11 January 2026 (PD-002, PD-003, PD-119 now RESOLVABLE via RQ-037, RQ-033, RQ-025)
> **Full Details:** See `archive/` for RESOLVED items, `../PRODUCT_DECISIONS.md` for pending items

---

## Status Legend

| Status | Meaning | Location |
|--------|---------|----------|
| ✅ RESOLVED | Decision made, becomes CD | `archive/PD_ARCHIVE_Q1_2026.md` |
| 🟢 READY | Research complete, awaiting human decision | `../PRODUCT_DECISIONS.md` |
| 🟡 RESHAPED | Partially resolved, needs refinement | `../PRODUCT_DECISIONS.md` |
| 🔴 PENDING | Awaiting research or decision | `../PRODUCT_DECISIONS.md` |

---

## Quick Reference

| PD# | Title | Status | Requires | Archive |
|-----|-------|--------|----------|---------|
| **PD-001** | Archetype Philosophy | ✅ RESOLVED → CD-005 | — | Q1-2026 |
| **PD-002** | Streaks vs Rolling Consistency | 🟢 READY | RQ-033 ✅ | — |
| **PD-003** | Holy Trinity Validity | 🟢 READY | RQ-037 ✅ | — |
| **PD-004** | Dev Mode Purpose | 🔴 PENDING | — | — |
| **PD-101** | Sherlock Prompt Overhaul | 🟡 RESHAPED | RQ-034, RQ-037 ✅ | — |
| **PD-102** | JITAI Hardcoded vs AI | 🔴 PENDING | RQ-038 | — |
| **PD-103** | Sensitivity Detection | 🔴 PENDING | RQ-035 | — |
| **PD-104** | LoadingInsightsScreen Personalization | 🔴 PENDING | — | — |
| **PD-105** | Unified AI Coaching Architecture | 🟢 READY | RQ-005,6,7 ✅ | — |
| **PD-106** | Multiple Identity Architecture | ✅ RESOLVED → CD-015 | RQ-011 | Q1-2026 |
| **PD-107** | Proactive Guidance System | 🟢 READY | RQ-005,6,7 ✅ | — |
| **PD-108** | Constellation UX Migration | ✅ RESOLVED | RQ-017 | Q1-2026 |
| **PD-109** | Council AI Activation Rules | ✅ RESOLVED | RQ-016 | Q1-2026 |
| **PD-110** | Airlock Protocol User Control | ✅ RESOLVED | RQ-018 | Q1-2026 |
| **PD-111** | Polymorphic Habit Attribution | ✅ RESOLVED | RQ-015 | Q1-2026 |
| **PD-112** | Identity Priming Audio Strategy | ✅ RESOLVED | RQ-018 | Q1-2026 |
| **PD-113** | Treaty Priority Hierarchy | ✅ RESOLVED | RQ-020 | Q1-2026 |
| **PD-114** | Full Implementation Commitment | ✅ RESOLVED | — | Q1-2026 |
| **PD-115** | Treaty Creation UX | ✅ RESOLVED | RQ-021 | Q1-2026 |
| **PD-116** | Population Learning Privacy | 🔴 PENDING | RQ-023 | — |
| **PD-117** | ContextSnapshot Real-time Data | ✅ RESOLVED | RQ-014 | Q1-2026 |
| **PD-118** | Treaty Modification UX | ✅ RESOLVED | RQ-024 | Q1-2026 |
| **PD-119** | Summon Token Economy | 🟢 READY | RQ-025 ✅ | — |
| **PD-120** | The Chamber Visual Design | 🔴 PENDING | RQ-036 | — |
| **PD-201** | URL Scheme Migration | 🔴 PENDING | — | — |
| **PD-202** | Archive Documentation Handling | 🔴 PENDING | — | — |
| **PD-121** | Archetype Template Count | ✅ RESOLVED | RQ-028 | Q1-2026 |
| **PD-122** | User Visibility of Preference Embedding | ✅ RESOLVED | RQ-030 | Q1-2026 |
| **PD-123** | Facet Typical Energy State Field | ✅ RESOLVED | — | Q1-2026 |
| **PD-124** | Recommendation Card Staleness | ✅ RESOLVED | — | Q1-2026 |
| **PD-125** | Content Library Size at Launch | ✅ RESOLVED | — | Q1-2026 |

---

## Statistics

| Metric | Count |
|--------|-------|
| **Total PDs** | 31 |
| **✅ RESOLVED** | 15 (48%) |
| **🟢 READY** | 5 (16%) |
| **🟡 RESHAPED** | 1 (3%) |
| **🔴 PENDING** | 10 (32%) |

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
├── PD-119 🟢 READY (Council Seals economy defined)
└── PD-101 🟡 RESHAPED (RQ-037 complete, still needs RQ-034)

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
```

---

*This index is auto-maintained. For full details, see archived or active decision files.*
