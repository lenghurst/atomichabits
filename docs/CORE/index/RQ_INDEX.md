# Research Questions Index

> **Purpose:** Quick reference table for all Research Questions
> **Last Updated:** 06 January 2026 (RQ-005/006/007 Identity Coach Complete)
> **Full Details:** See `archive/` for COMPLETE items, `../RESEARCH_QUESTIONS.md` for active items

---

## Status Legend

| Status | Meaning | Location |
|--------|---------|----------|
| ✅ COMPLETE | Research done, findings integrated | `archive/RQ_ARCHIVE_Q1_2026.md` |
| 🔴 NEEDS RESEARCH | Not yet started | `../RESEARCH_QUESTIONS.md` |
| 🟡 IN PROGRESS | Currently being researched | `../RESEARCH_QUESTIONS.md` |

---

## Quick Reference

| RQ# | Title | Status | Blocking | Archive |
|-----|-------|--------|----------|---------|
| **RQ-001** | Minimum Viable Archetype Taxonomy | ✅ COMPLETE | PD-001 | Q1-2026 |
| **RQ-002** | Intervention Effectiveness Measurement | ✅ COMPLETE | RQ-001 | Q1-2026 |
| **RQ-003** | Dimension-to-Implementation Mapping | ✅ COMPLETE | — | Q1-2026 |
| **RQ-004** | Archetype Migration Strategy | ✅ COMPLETE | RQ-001,2,3 | Q1-2026 |
| **RQ-005** | Proactive Recommendation Algorithms | ✅ COMPLETE | — | Q1-2026 |
| **RQ-006** | Content Library for Recommendations | ✅ COMPLETE | RQ-005 | Q1-2026 |
| **RQ-007** | Identity Roadmap Architecture | ✅ COMPLETE* | RQ-005,6 | Q1-2026 |
| **RQ-008** | UI Logic Separation | 🔴 NEEDS RESEARCH | — | — |
| **RQ-009** | Optimal LLM Coding Approach | 🔴 NEEDS RESEARCH | — | — |
| **RQ-010** | Permission Data Philosophy | 🔴 NEEDS RESEARCH | — | — |
| **RQ-011** | Multiple Identity Architecture | ✅ COMPLETE | — | Q1-2026 |
| **RQ-012** | Fractal Trinity Architecture | ✅ COMPLETE | CD-015 | Q1-2026 |
| **RQ-013** | Identity Topology & Graph Modeling | ✅ COMPLETE | RQ-012 | Q1-2026 |
| **RQ-014** | State Economics & Bio-Energetic Conflicts | ✅ COMPLETE | RQ-012 | Q1-2026 |
| **RQ-015** | Polymorphic Habits Implementation | ✅ COMPLETE | RQ-012 | Q1-2026 |
| **RQ-016** | Council AI (Roundtable Simulation) | ✅ COMPLETE | CD-015, RQ-012 | Q1-2026 |
| **RQ-017** | Constellation UX (Solar System Visualization) | 🔴 NEEDS RESEARCH | RQ-012 | — |
| **RQ-018** | Airlock Protocol & Identity Priming | 🔴 NEEDS RESEARCH | RQ-012 | — |
| **RQ-019** | pgvector Implementation Strategy | ✅ COMPLETE | RQ-012 | Q1-2026 |
| **RQ-020** | Treaty-JITAI Integration Architecture | ✅ COMPLETE | RQ-012, RQ-016 | Q1-2026 |
| **RQ-021** | Treaty Lifecycle & UX | ✅ COMPLETE | RQ-020 | Q1-2026 |
| **RQ-022** | Council Script Generation Prompts | ✅ COMPLETE | RQ-016, RQ-021 | Q1-2026 |
| **RQ-023** | Population Learning Privacy Framework | 🔴 NEEDS RESEARCH | RQ-019 | — |
| **RQ-024** | Treaty Modification & Renegotiation Flow | 🔴 NEEDS RESEARCH | RQ-021 | — |
| **RQ-025** | Summon Token Economy | 🔴 NEEDS RESEARCH | RQ-016 | — |
| **RQ-026** | Sound Design & Haptic Specification | 🔴 NEEDS RESEARCH | — | — |
| **RQ-027** | Treaty Template Versioning Strategy | 🔴 NEEDS RESEARCH | RQ-021 | — |

---

## Statistics

| Metric | Count |
|--------|-------|
| **Total RQs** | 27 |
| **✅ COMPLETE** | 18 (67%) |
| **🔴 NEEDS RESEARCH** | 9 (33%) |

**Note:** *RQ-007 has 2 ESCALATE items pending human decision (Visualization: Tree vs Constellation, Archetype count: 8 vs 12). See reconciliation document.*

---

## Dependency Chain

```
FOUNDATIONAL (No dependencies):
├── RQ-001 (Archetype Taxonomy) ✅
│   ├── RQ-002 (Effectiveness) ✅
│   ├── RQ-003 (Tracking) ✅
│   └── RQ-004 (Migration) ✅
│
├── RQ-005 (Recommendations) ✅
│   └── RQ-006 (Content) ✅
│       └── RQ-007 (Roadmap) ✅*
│
├── RQ-008 (UI Logic) 🔴
├── RQ-009 (LLM Coding) 🔴
├── RQ-010 (Permission Data) 🔴
└── RQ-011 (Multiple Identity) ✅

PSYOS ARCHITECTURE (CD-015):
├── RQ-012 (Fractal Trinity) ✅
│   ├── RQ-013 (Identity Topology) ✅
│   ├── RQ-014 (State Economics) ✅
│   ├── RQ-015 (Polymorphic Habits) ✅
│   ├── RQ-016 (Council AI) ✅
│   │   ├── RQ-021 (Treaty Lifecycle) ✅
│   │   │   ├── RQ-024 (Treaty Modification) 🔴
│   │   │   └── RQ-027 (Template Versioning) 🔴
│   │   ├── RQ-022 (Council Scripts) ✅
│   │   └── RQ-025 (Summon Tokens) 🔴
│   ├── RQ-017 (Constellation UX) 🔴 ← Pending ESCALATE-1 (Tree vs Constellation)
│   ├── RQ-018 (Airlock Protocol) 🔴
│   ├── RQ-019 (pgvector) ✅
│   │   └── RQ-023 (Privacy Framework) 🔴
│   └── RQ-020 (Treaty-JITAI) ✅
└── RQ-026 (Sound Design) 🔴
```

---

*This index is auto-maintained. For full details, see archived or active research files.*
