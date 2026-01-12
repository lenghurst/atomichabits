# Core Decisions — Foundational & Locked

> **Domain:** CORE
> **Token Budget:** <10k
> **Load:** ALWAYS (every session)
> **Purpose:** CDs that constrain all other decisions

---

## Quick Reference

| CD# | Decision | Status |
|-----|----------|--------|
| CD-001 | App Name: "The Pact" | LOCKED |
| CD-002 | AI as Default Witness | LOCKED |
| CD-003 | Sherlock Before Payment | LOCKED |
| CD-004 | Conversational CLI (rejected) | LOCKED |
| CD-005 | 6-Dimension Archetype Model | LOCKED |
| CD-006 | GPS Permission Usage | LOCKED |
| CD-007 | 6+1 Dimension Model (Phase B) | LOCKED |
| CD-008 | Identity Development Coach | LOCKED |
| CD-009 | Content Library | LOCKED |
| CD-010 | Retention Tracking (No Dark Patterns) | LOCKED |
| CD-011 | Architecture Ramifications | LOCKED |
| CD-012 | Git Workflow Protocol | LOCKED |
| CD-013 | UI Logic Separation | LOCKED |
| CD-014 | Core File Guardrails | LOCKED |
| CD-015 | psyOS Architecture (4-state energy) | LOCKED |
| CD-016 | AI Model Strategy (DeepSeek) | LOCKED |
| CD-017 | Android-First Development | LOCKED |
| CD-018 | Engineering Threshold Framework | LOCKED |

---

## CD-001: App Name & Branding

| Field | Value |
|-------|-------|
| **Decision** | App is "The Pact", not "AtomicHabits" |
| **Status** | LOCKED |
| **Rationale** | Brand differentiation, domain ownership (thepact.co) |

---

## CD-002: AI as Default Witness

| Field | Value |
|-------|-------|
| **Decision** | The Pact AI is ALWAYS the witness; human witness is ADDITIVE |
| **Status** | LOCKED |
| **Rationale** | "Go Solo" implies AI isn't accountable — wrong framing |
| **Implication** | Human witnesses are optional but incentivized |

---

## CD-003: Sherlock Before Payment

| Field | Value |
|-------|-------|
| **Decision** | Keep Sherlock voice session BEFORE payment gate for MVP |
| **Status** | LOCKED (subject to conversion data) |
| **Rationale** | The "magic" of Sherlock IS the value proposition |

---

## CD-004: Conversational CLI — Rejected

| Field | Value |
|-------|-------|
| **Decision** | Do NOT implement command-line interface for users |
| **Status** | LOCKED |
| **Rationale** | Developer-style interface incongruent with consumer wellness app |

---

## CD-005: 6-Dimension Archetype Model

| Field | Value |
|-------|-------|
| **Decision** | Use 6-dimension continuous model with 4 UI clusters |
| **Status** | LOCKED |
| **Research** | RQ-001 (Complete) |

**The 6 Dimensions:**
1. Regulatory Focus (Promotion ↔ Prevention)
2. Autonomy/Reactance (Rebel ↔ Conformist)
3. Action-State Orientation (Executor ↔ Overthinker)
4. Temporal Discounting (Future ↔ Present)
5. Perfectionistic Reactivity (Adaptive ↔ Maladaptive)
6. Social Rhythmicity (Stable ↔ Chaotic)

---

## CD-006: GPS Permission Usage

| Field | Value |
|-------|-------|
| **Decision** | Use full GPS for schedule entropy calculation |
| **Status** | LOCKED |
| **Action** | Add "time-only" option in Settings for privacy-conscious users |

---

## CD-007: 6+1 Dimension Model

| Field | Value |
|-------|-------|
| **Decision** | 6 dimensions NOW; 7th (Social Sensitivity) AFTER social features |
| **Status** | LOCKED (Two-Phase) |

---

## CD-008: Identity Development Coach

| Field | Value |
|-------|-------|
| **Decision** | Build AI-driven Identity Development Coach |
| **Status** | LOCKED — ELEVATED PRIORITY |
| **Spec** | See `IDENTITY_COACH_SPEC.md` |

**Critical Distinction:**
- JITAI = WHEN to intervene (reactive timing)
- Content Library = WHAT to say in interventions
- Identity Coach = WHO to become + HOW to get there

---

## CD-009: Content Library

| Field | Value |
|-------|-------|
| **Decision** | Content Library supports BOTH JITAI and Identity Coach |
| **Status** | LOCKED |
| **Requirements** | 153+ content pieces (see IDENTITY_COACH_SPEC.md) |

---

## CD-010: Retention Tracking Philosophy

| Field | Value |
|-------|-------|
| **Decision** | Track retention from DUAL perspectives (App + User) |
| **Status** | LOCKED |
| **Constraint** | NO DARK PATTERNS — User success > App engagement |
| **Key Metric** | "Graduation rate" is positive (user achieved goal) |

---

## CD-011: Architecture Ramifications

| Field | Value |
|-------|-------|
| **Decision** | Identity Coach changes onboarding, dashboard, and widgets |
| **Status** | LOCKED |
| **Impact** | Sherlock extracts Aspirational Identity (not just Holy Trinity) |

---

## CD-012: Git Workflow Protocol

| Field | Value |
|-------|-------|
| **Decision** | All AI agents push directly to main (linear workflow) |
| **Status** | LOCKED |
| **Safeguards** | Pre-commit checks, atomic commits, human oversight |

---

## CD-013: UI Logic Separation

| Field | Value |
|-------|-------|
| **Decision** | UI files contain ONLY presentation; logic in services/providers |
| **Status** | LOCKED |
| **Research** | RQ-008 (Complete) |

---

## CD-014: Core File Guardrails

| Field | Value |
|-------|-------|
| **Decision** | Protect core governance files from accidental modification |
| **Status** | LOCKED |
| **Protected Files** | CLAUDE.md, AI_AGENT_PROTOCOL.md, index/*.md |

---

## CD-015: psyOS Architecture

| Field | Value |
|-------|-------|
| **Decision** | Parliament of Selves, Identity Facets, Council AI |
| **Status** | LOCKED |
| **Research** | RQ-012 (Complete) |
| **Constraint** | 4-state energy model (high_focus, high_physical, social, recovery) — NOT 5-state |

---

## CD-016: AI Model Strategy

| Field | Value |
|-------|-------|
| **Decision** | DeepSeek V3.2 (analyst), R1 Distilled (reasoning) |
| **Status** | LOCKED |
| **Rationale** | Cost-effective, sufficient quality for use cases |

---

## CD-017: Android-First Development

| Field | Value |
|-------|-------|
| **Decision** | All features must work on Android without iOS-specific APIs |
| **Status** | LOCKED |
| **Phase 1** | Android mobile MVP |
| **Phase 2** | Android-dominant wearables (Wear OS, Samsung) |
| **Constraint** | No iMessage-style deep integration; use cross-platform channels |

---

## CD-018: Engineering Threshold Framework

| Field | Value |
|-------|-------|
| **Decision** | Apply ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED classification |
| **Status** | LOCKED |
| **Rule** | Complex referral/MLM mechanics = OVER-ENGINEERED |

---

## Foundational PDs (Resolved)

### PD-114: Full Implementation Commitment

| Field | Value |
|-------|-------|
| **Phase** | — |
| **Decision** | Commit to full psyOS implementation (no half-measures) |
| **Status** | RESOLVED |

---

## Pending Core PDs

### PD-126: Protocol Governance & Consolidation

| Field | Value |
|-------|-------|
| **Phase** | — |
| **Question** | How should AI agent protocols be governed and updated? |
| **Status** | PENDING |

---

*Core decisions constrain all downstream work. These are LOCKED and require human approval to change.*
