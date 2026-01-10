# Pending Decisions Index

> **Purpose:** Quick reference table for all Pending Decisions
> **Last Updated:** 10 January 2026
> **Full Details:** See `archive/` for RESOLVED items, `../PRODUCT_DECISIONS.md` for pending items

---

## Status Legend

| Status | Meaning | Location |
|--------|---------|----------|
| ✅ RESOLVED | Decision made, becomes CD | `archive/PD_ARCHIVE_Q1_2026.md` |
| 🟡 RESHAPED | Partially resolved, needs refinement | `../PRODUCT_DECISIONS.md` |
| 🔴 PENDING | Awaiting research or decision | `../PRODUCT_DECISIONS.md` |

---

## Quick Reference

| PD# | Title | Status | Requires | Archive |
|-----|-------|--------|----------|---------|
| **PD-001** | Archetype Philosophy | ✅ RESOLVED → CD-005 | — | Q1-2026 |
| **PD-002** | Streaks vs Rolling Consistency | 🔴 PENDING | — | — |
| **PD-003** | Holy Trinity Validity | 🔴 PENDING | — | — |
| **PD-004** | Dev Mode Purpose | 🔴 PENDING | — | — |
| **PD-101** | Sherlock Prompt Overhaul | 🔴 PENDING | — | — |
| **PD-102** | JITAI Hardcoded vs AI | 🔴 PENDING | — | — |
| **PD-103** | Sensitivity Detection | 🔴 PENDING | — | — |
| **PD-104** | LoadingInsightsScreen Personalization | 🔴 PENDING | — | — |
| **PD-105** | Unified AI Coaching Architecture | 🟢 READY | RQ-005,6,7 ✅ | — |
| **PD-106** | Multiple Identity Architecture | ✅ RESOLVED → CD-015 | RQ-011 | Q1-2026 |
| **PD-107** | Proactive Guidance System | 🟢 READY | RQ-005,6,7 ✅ | — |
| **PD-108** | Constellation UX Migration | 🔴 PENDING | RQ-017 | — |
| **PD-109** | Council AI Activation Rules | ✅ RESOLVED | RQ-016 | Q1-2026 |
| **PD-110** | Airlock Protocol User Control | 🔴 PENDING | RQ-018 | — |
| **PD-111** | Polymorphic Habit Attribution | ✅ RESOLVED | RQ-015 | Q1-2026 |
| **PD-112** | Identity Priming Audio Strategy | 🔴 PENDING | RQ-018 | — |
| **PD-113** | Treaty Priority Hierarchy | ✅ RESOLVED | RQ-020 | Q1-2026 |
| **PD-114** | Full Implementation Commitment | ✅ RESOLVED | — | Q1-2026 |
| **PD-115** | Treaty Creation UX | ✅ RESOLVED | RQ-021 | Q1-2026 |
| **PD-116** | Population Learning Privacy | 🔴 PENDING | RQ-023 | — |
| **PD-117** | ContextSnapshot Real-time Data | ✅ RESOLVED | RQ-014 | Q1-2026 |
| **PD-118** | Treaty Modification UX | 🔴 PENDING | RQ-024 | — |
| **PD-119** | Summon Token Economy | 🔴 PENDING | RQ-025 | — |
| **PD-120** | The Chamber Visual Design | 🔴 PENDING | Design session | — |
| **PD-201** | URL Scheme Migration | 🔴 PENDING | — | — |
| **PD-202** | Archive Documentation Handling | 🔴 PENDING | — | — |
| **PD-121** | Archetype Template Count | 🔴 PENDING | RQ-028 | — |
| **PD-122** | User Visibility of Preference Embedding | 🔴 PENDING | RQ-030 | — |
| **PD-123** | Facet Typical Energy State Field | 🔴 PENDING | — | — |
| **PD-124** | Recommendation Card Staleness | 🔴 PENDING | — | — |
| **PD-125** | Content Library Size at Launch | ✅ RESOLVED | — | Q1-2026 |

---

## Statistics

| Metric | Count |
|--------|-------|
| **Total PDs** | 31 |
| **✅ RESOLVED** | 7 (23%) |
| **🟢 READY** | 2 (6%) |
| **🔴 PENDING** | 22 (71%) |

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
└── PD-125 (Content Library Size → 50 with caveat)

UNBLOCKED BY RQ-005/006/007 (Ready for Decision):
├── PD-105 (Unified AI Coaching Architecture) ← Research complete
└── PD-107 (Proactive Guidance System) ← Research complete

BLOCKED BY NEW RESEARCH (from RQ-005/006/007):
├── PD-121 ← RQ-028 (Archetype Definitions)
├── PD-122 ← RQ-030 (Preference Embedding)
└── PD-123, PD-124 ← Architectural (no research needed)

BLOCKED BY PRIOR RESEARCH:
├── PD-108 ← RQ-017
├── PD-110, PD-112 ← RQ-018
├── PD-116 ← RQ-023
├── PD-118 ← RQ-024
└── PD-119 ← RQ-025

READY FOR DECISION (No blockers):
├── PD-002, PD-003, PD-004
├── PD-101, PD-102, PD-103, PD-104
├── PD-105, PD-107 (NEW — RQ-005/006/007 unblocked these)
├── PD-120 (needs design session)
├── PD-123, PD-124 (NEW — no research required)
└── PD-201, PD-202
```

---

*This index is auto-maintained. For full details, see archived or active decision files.*
