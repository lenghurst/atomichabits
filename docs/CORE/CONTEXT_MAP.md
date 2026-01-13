# CONTEXT_MAP.md — Decision & Research Dependencies

> **Purpose:** Machine-readable dependency graph for context loading optimization
> **Created:** 13 January 2026
> **Usage:** Agents use this to auto-discover related context when loading one file

---

## Decision Dependencies

### Core Decisions (CDs) — Dependency Chain

```
CD-015 (psyOS Architecture)
├── requires: CD-012 (Git Workflow)
├── requires: CD-013 (UI Logic Separation)
└── enables: [CD-016, CD-017, CD-018]

CD-016 (AI Model Strategy)
├── requires: CD-015 (psyOS)
└── enables: [PD_JITAI, PD_IDENTITY]

CD-017 (Android-First)
├── requires: CD-015 (psyOS)
└── constrains: [All mobile features]

CD-018 (Threshold Framework)
├── requires: [CD-015, CD-016, CD-017]
└── enables: [Feature prioritization]
```

### Product Decisions (PDs) — Cross-Domain Links

| PD | Primary Domain | Also Affects | Load Together |
|----|----------------|--------------|---------------|
| PD-105 | IDENTITY | JITAI | PD_IDENTITY + PD_JITAI |
| PD-134 | WITNESS | JITAI | PD_WITNESS + PD_JITAI |
| PD-101 | IDENTITY | UX | PD_IDENTITY + PD_UX |
| PD-133 | WITNESS | UX | PD_WITNESS + PD_UX |
| PD-119 | IDENTITY | JITAI | PD_IDENTITY + PD_JITAI |

---

## Research Dependencies

### Blocking Chains

```
FOUNDATIONAL (No dependencies):
├── RQ-001 (Archetype Taxonomy) ✅
│   └── unblocks: RQ-002, RQ-003, RQ-004
│
├── RQ-012 (Fractal Trinity) ✅
│   └── unblocks: RQ-013 through RQ-020
│
└── RQ-005 (Recommendations) ✅
    └── unblocks: RQ-006, RQ-007, RQ-028-032

WITNESS INTELLIGENCE (RQ-040 series):
├── RQ-040 (Viral Growth Strategy)
│   └── sub-RQs: 040a through 040g
└── RQ-041 through RQ-045

AI ORCHESTRATION (RQ-047 series):
└── RQ-047 (AI Orchestration)
    └── sub-RQs: 047a through 047e
```

---

## Keyword → Context Mapping

### Task Keywords → Files to Load

| Keyword | Primary File | Secondary Files |
|---------|--------------|-----------------|
| `witness` | PD_WITNESS.md | RQ-040 series |
| `invitation` | PD_WITNESS.md | RQ-042 |
| `viral` | PD_WITNESS.md | RQ-040 |
| `stakes` | PD_WITNESS.md | RQ-044 |
| `jitai` | PD_JITAI.md | RQ-038 |
| `intervention` | PD_JITAI.md | CD-015 |
| `trigger` | PD_JITAI.md | — |
| `context` | PD_JITAI.md | ContextSnapshot |
| `identity` | PD_IDENTITY.md | CD-015 |
| `archetype` | PD_IDENTITY.md | RQ-001, RQ-028 |
| `facet` | PD_IDENTITY.md | RQ-012 |
| `sherlock` | PD_IDENTITY.md | RQ-034, PD-101 |
| `dimension` | PD_IDENTITY.md | CD-005, CD-007 |
| `screen` | PD_UX.md | — |
| `ui` | PD_UX.md | — |
| `flow` | PD_UX.md | USER_JOURNEY_MAP.md |
| `constellation` | PD_UX.md | RQ-017, PD-108 |
| `airlock` | PD_UX.md | RQ-018, PD-110 |
| `treaty` | PD_UX.md | RQ-020, RQ-021, PD-115 |
| `council` | PD_IDENTITY.md | RQ-016, CD-015 |
| `token economy` | PD_IDENTITY.md | RQ-039, PD-119 |
| `audio` | PD_UX.md | H-13, RQ-026 |
| `wearable` | PD_JITAI.md | RQ-046, CD-017 |
| `orchestration` | — | RQ-047 |

---

## Phase → Domain Mapping

| Phase | Description | Primary Domain | Secondary |
|-------|-------------|----------------|-----------|
| A | Schema Foundation | CORE | — |
| B | Intelligence Layer | JITAI | WITNESS |
| C | Council AI | IDENTITY | — |
| D | UX/Frontend | UX | All |
| E | Polish/Advanced | UX | JITAI |
| F | Identity Coach (Phase 1) | IDENTITY | — |
| G | Identity Coach (Phase 2) | IDENTITY | JITAI |
| H | Constellation/Airlock | UX | IDENTITY |

---

## Blocked Tasks → Missing Dependencies

| Blocked Task | Waiting For | Domain |
|--------------|-------------|--------|
| Phase H tasks | `identity_facets` table | CORE (Schema) |
| Phase H tasks | `identity_topology` table | CORE (Schema) |
| H-13 (Audio) | External audio files | External |
| RQ-034 | RQ-037 completion | IDENTITY |
| PD-119 | RQ-039 (7 sub-RQs) | IDENTITY |

---

## Usage Guide

### When Loading Context for a Task

```
1. Identify keywords in task description
2. Look up keywords in "Keyword → Context Mapping"
3. Load primary file + any secondary files listed
4. Check "Decision Dependencies" for upstream requirements
5. Check "Blocked Tasks" to verify task isn't blocked
```

### When Creating New PD/RQ

```
1. Identify primary domain
2. Add to appropriate domain file (PD_WITNESS, etc.)
3. Update this CONTEXT_MAP.md with:
   - Any new keyword triggers
   - Any new dependencies
   - Any new blocking relationships
4. Update MANIFEST.md if new file created
```

---

*This map is maintained by AI agents. Update when dependencies change.*
