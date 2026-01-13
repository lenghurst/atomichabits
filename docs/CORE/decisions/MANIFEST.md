# Decision Manifest — Agent Navigation Hub

> **Purpose:** Guide agents to load the RIGHT context at the RIGHT time
> **Created:** 12 January 2026
> **Updated:** 13 January 2026 (added token estimates + triggers)
> **Model:** Modular with Manifest (Alternative E)
> **Token Budget:** <15k per domain file, <25k total loaded context

---

## Quick Reference: Token Estimates & Triggers

| File | Lines | Est. Tokens | Load Strategy | Keyword Triggers |
|------|-------|-------------|---------------|------------------|
| **CLAUDE.md** | 74 | ~1.5k | Always | — |
| **AI_HANDOVER.md** | 142 | ~2.5k | Always | — |
| **MANIFEST.md** | 300 | ~5k | Always | — |
| **PD_CORE.md** | 256 | ~5k | Always | — |
| **PD_WITNESS.md** | 265 | ~5k | On-demand | `witness`, `invitation`, `viral`, `stakes` |
| **PD_JITAI.md** | 165 | ~3k | On-demand | `jitai`, `intervention`, `trigger`, `context` |
| **PD_IDENTITY.md** | 280 | ~5.5k | On-demand | `identity`, `archetype`, `facet`, `sherlock`, `dimension` |
| **PD_UX.md** | 304 | ~6k | On-demand | `screen`, `ui`, `flow`, `constellation`, `airlock` |
| **RQ_INDEX.md** | 228 | ~4k | Always | — |
| **PD_INDEX.md** | 170 | ~3k | Always | — |
| **CD_INDEX.md** | 81 | ~1.5k | Always | — |

**Total "Always Load":** ~22k tokens (fits in any context window)
**With One Domain:** ~27k tokens (still safe)
**With Two Domains:** ~32k tokens (monitor carefully)

---

## Trigger-Based Loading

When a task description contains these keywords, auto-load the corresponding domain:

```
"witness" OR "invitation" OR "viral" → PD_WITNESS.md
"jitai" OR "intervention" OR "trigger" → PD_JITAI.md
"identity" OR "archetype" OR "facet" OR "sherlock" → PD_IDENTITY.md
"screen" OR "ui" OR "flow" OR "constellation" → PD_UX.md
```

**Cross-Domain Tasks:** If task contains keywords from 2+ domains, load both.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DECISION ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MANIFEST.md (this file)                                                    │
│  └── Loading rules, relationships, phase mapping                            │
│                                                                             │
│  DOMAIN FILES (load by context):                                            │
│  ├── PD_CORE.md      — CDs + foundational decisions (always load first)    │
│  ├── PD_WITNESS.md   — Witness Intelligence Layer                          │
│  ├── PD_JITAI.md     — JITAI + Intelligence                                │
│  ├── PD_IDENTITY.md  — Identity Coach, Archetypes, Dimensions              │
│  └── PD_UX.md        — Screens, Flows, Onboarding                          │
│                                                                             │
│  INDEX FILES (quick lookup):                                                │
│  ├── ../index/CD_INDEX.md  — All CDs at a glance                           │
│  ├── ../index/PD_INDEX.md  — All PDs at a glance                           │
│  └── ../index/RQ_INDEX.md  — All RQs at a glance                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Context Loading Rules

### Rule 1: Always Load Core First

```
EVERY SESSION:
1. CLAUDE.md (project root)
2. decisions/PD_CORE.md (foundational CDs)
3. THEN domain-specific file based on task
```

### Rule 2: Load by Task Domain

| If Working On... | Load These Files | Token Budget |
|------------------|------------------|--------------|
| **Any task** | PD_CORE.md | ~10k |
| **Witness features** | + PD_WITNESS.md | +12k |
| **JITAI/Intelligence** | + PD_JITAI.md | +10k |
| **Identity Coach** | + PD_IDENTITY.md | +12k |
| **UX/Screens** | + PD_UX.md | +12k |
| **Cross-domain** | Load multiple domains as needed | Monitor total |

### Rule 3: Never Exceed 25k Total

If approaching limit:
1. Load indexes only (CD_INDEX, PD_INDEX)
2. Fetch specific PD content on demand
3. Do NOT load entire domain files

---

## Phase → Domain Mapping

Each PD is tagged with implementation phase(s) for task sequencing:

| Phase | Description | Primary Domain | Secondary Domain |
|-------|-------------|----------------|------------------|
| **A** | Schema/Database | CORE | WITNESS, IDENTITY |
| **B** | Intelligence/Backend | JITAI | WITNESS |
| **C** | Council AI | IDENTITY | — |
| **D** | UX/Frontend | UX | WITNESS, IDENTITY |
| **E** | Polish/Advanced | UX | JITAI |
| **F** | Identity Coach (Phase 1) | IDENTITY | — |
| **G** | Identity Coach (Phase 2) | IDENTITY | JITAI |
| **H** | Constellation/Airlock | UX | IDENTITY |

---

## Domain → PD Mapping

### CORE Domain (PD_CORE.md)

**Contains:** All CDs (locked decisions) + foundational PDs

| PD/CD | Title | Phase | Status |
|-------|-------|-------|--------|
| CD-001 | App Name & Branding | — | LOCKED |
| CD-002 | AI as Default Witness | — | LOCKED |
| CD-003 | Sherlock Before Payment | — | LOCKED |
| CD-004 | Conversational CLI (rejected) | — | LOCKED |
| CD-005 | 6-Dimension Model | — | LOCKED |
| CD-006 | GPS Permission Usage | — | LOCKED |
| CD-007 | 6+1 Dimension Model | — | LOCKED |
| CD-008 | Identity Development Coach | — | LOCKED |
| CD-009 | Content Library | — | LOCKED |
| CD-010 | Retention Tracking | — | LOCKED |
| CD-011 | Architecture Ramifications | — | LOCKED |
| CD-012 | Git Workflow Protocol | — | LOCKED |
| CD-013 | UI Logic Separation | — | LOCKED |
| CD-014 | Core File Guardrails | — | LOCKED |
| CD-015 | psyOS Architecture | — | LOCKED |
| CD-016 | AI Model Strategy (DeepSeek) | — | LOCKED |
| CD-017 | Android-First Development | — | LOCKED |
| CD-018 | Engineering Threshold Framework | — | LOCKED |
| PD-114 | Full Implementation Commitment | — | RESOLVED |
| PD-126 | Protocol Governance | — | PENDING |

### WITNESS Domain (PD_WITNESS.md)

**Contains:** Witness Intelligence Layer (WIL) decisions

| PD | Title | Phase | Status | Blocking RQ |
|----|-------|-------|--------|-------------|
| PD-130 | Witness App Access Model | A, D | OPEN | RQ-041 |
| PD-131 | Invitation Message Strategy | D | OPEN | RQ-042 |
| PD-132 | Invitation Timing (Commitment Ceremony) | D | CONFIRMED | — |
| PD-133 | Witness Stakes & Punishment | B, D | OPEN | RQ-044 |
| PD-134 | JITAI Witness Data Schema | A, B | OPEN | RQ-045 |

### JITAI Domain (PD_JITAI.md)

**Contains:** Intelligence layer, timing, interventions

| PD | Title | Phase | Status | Blocking RQ |
|----|-------|-------|--------|-------------|
| PD-102 | JITAI Hardcoded vs AI | B | PENDING | RQ-038 |
| PD-116 | Population Learning Privacy | B | PENDING | RQ-023 |
| PD-117 | ContextSnapshot Real-time | B | RESOLVED | — |

### IDENTITY Domain (PD_IDENTITY.md)

**Contains:** Identity Coach, archetypes, dimensions, Sherlock

| PD | Title | Phase | Status | Blocking RQ |
|----|-------|-------|--------|-------------|
| PD-003 | Holy Trinity Validity | F | READY | RQ-037 ✅ |
| PD-101 | Sherlock Prompt Overhaul | F | RESHAPED | RQ-034 |
| PD-103 | Sensitivity Detection | F | PENDING | RQ-035 |
| PD-105 | Unified AI Coaching Architecture | F, G | READY | RQ-005,6,7 ✅ |
| PD-107 | Proactive Guidance System | F, G | READY | RQ-005,6,7 ✅ |
| PD-119 | Summon Token Economy | G | DEFERRED | RQ-039 |
| PD-121 | Archetype Template Count | G | RESOLVED | — |
| PD-122 | User Visibility of Preference Embedding | G | RESOLVED | — |
| PD-123 | Facet Typical Energy State | G | RESOLVED | — |
| PD-124 | Recommendation Card Staleness | G | RESOLVED | — |
| PD-125 | Content Library Size at Launch | F | RESOLVED | — |

### UX Domain (PD_UX.md)

**Contains:** Screens, flows, onboarding, visual design

| PD | Title | Phase | Status | Blocking RQ |
|----|-------|-------|--------|-------------|
| PD-002 | Streaks vs Rolling Consistency | D | READY | RQ-033 ✅ |
| PD-004 | Dev Mode Purpose | D | PENDING | — |
| PD-104 | LoadingInsightsScreen Personalization | D | PENDING | — |
| PD-108 | Constellation UX Migration | H | RESOLVED | — |
| PD-109 | Council AI Activation Rules | C, D | RESOLVED | — |
| PD-110 | Airlock Protocol User Control | H | RESOLVED | — |
| PD-111 | Polymorphic Habit Attribution | D | RESOLVED | — |
| PD-112 | Identity Priming Audio Strategy | H | RESOLVED | — |
| PD-113 | Treaty Priority Hierarchy | D | RESOLVED | — |
| PD-115 | Treaty Creation UX | D | RESOLVED | — |
| PD-118 | Treaty Modification UX | D | RESOLVED | — |
| PD-120 | The Chamber Visual Design | H | PENDING | RQ-036 |
| PD-201 | URL Scheme Migration | — | PENDING | — |
| PD-202 | Archive Documentation Handling | — | PENDING | — |

---

## Cross-Cutting Decisions

Some PDs affect multiple domains. Load all relevant files when working on these:

| PD | Domains Affected | Load Files |
|----|------------------|------------|
| PD-105 (Unified AI Coaching) | IDENTITY + JITAI | PD_IDENTITY + PD_JITAI |
| PD-134 (Witness Data Schema) | WITNESS + JITAI | PD_WITNESS + PD_JITAI |
| PD-101 (Sherlock Prompt) | IDENTITY + UX | PD_IDENTITY + PD_UX |
| PD-133 (Stakes/Punishment) | WITNESS + UX | PD_WITNESS + PD_UX |

---

## Agent-Agent Knowledge Transfer Protocol

### When Starting a New Session

```
1. Read CLAUDE.md (always)
2. Read AI_HANDOVER.md (previous session context)
3. Read this MANIFEST.md
4. Identify task domain from handover
5. Load PD_CORE.md + domain-specific file
6. Check PD_INDEX.md for any new decisions since handover
```

### When Ending a Session

```
1. Update AI_HANDOVER.md with:
   - What was accomplished
   - What domain files were modified
   - Any new PDs created
   - Recommended next task domain
2. Commit changes to domain files
3. Update PD_INDEX.md if new PDs added
```

### When Creating New PDs

```
1. Assign PD number (next available in sequence)
2. Identify primary domain
3. Add to appropriate domain file (PD_WITNESS, PD_IDENTITY, etc.)
4. Add phase tag(s)
5. Update PD_INDEX.md
6. Update this MANIFEST.md (Domain → PD Mapping section)
```

---

## Integrity Verification

### PD Count by Domain

| Domain | Expected | File |
|--------|----------|------|
| CORE | 20 (18 CDs + 2 PDs) | PD_CORE.md |
| WITNESS | 5 | PD_WITNESS.md |
| JITAI | 3 | PD_JITAI.md |
| IDENTITY | 11 | PD_IDENTITY.md |
| UX | 14 | PD_UX.md |
| **TOTAL** | **53** | — |

### Verification Command

```bash
# Count PDs in each file
grep -c "^## PD-\|^## CD-" docs/CORE/decisions/*.md
```

---

## Migration Notes

**Migrated From:** `PRODUCT_DECISIONS.md` (31k tokens → deprecated)
**Migration Date:** 12 January 2026
**Migration Reason:** Token limit exceeded; "lost in the middle" effect

### What Changed

| Before | After |
|--------|-------|
| Single 31k token file | 5 domain files (<15k each) |
| No loading guidance | MANIFEST.md with explicit rules |
| No phase tagging | Every PD tagged with phase(s) |
| Flat structure | Matrix model (domain × phase) |

### Backward Compatibility

- `PRODUCT_DECISIONS.md` now redirects to this structure
- All PD numbers preserved
- All content preserved (reorganized, not lost)

---

*This manifest enables agent-agent knowledge transfer by providing explicit loading rules, domain mapping, and integrity verification. Updated: 12 January 2026.*
