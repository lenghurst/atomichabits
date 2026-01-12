# UX Decisions — Screens, Flows & Visual Design

> **Domain:** UX
> **Token Budget:** <12k
> **Load:** When working on screens, onboarding, visual design, user flows
> **Dependencies:** PD_CORE.md (always load first)
> **Related RQs:** RQ-016-018, RQ-021, RQ-024, RQ-033, RQ-036

---

## Quick Reference

| PD# | Decision | Phase | Status | Blocking RQ |
|-----|----------|-------|--------|-------------|
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

## PD-002: Streaks vs Rolling Consistency 🟢 READY

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Question** | Should we show traditional streaks or rolling consistency metrics? |
| **Status** | READY (Research complete) |
| **Research** | RQ-033 ✅ COMPLETE |

### Research Finding

RQ-033 recommends **Resilient Streak** hybrid approach:
- Streak count with "grace days" built in
- Focus on "votes cast" rather than "unbroken chain"
- De-emphasize streak breaking as catastrophic

### Recommendation

Implement Resilient Streak:
- "You've voted for The Writer 23 of the last 30 days"
- Grace period before streak "breaks"
- Recovery messaging for missed days

---

## PD-004: Dev Mode Purpose

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Question** | What should Dev Mode contain and who is it for? |
| **Status** | PENDING |

### Current State

Dev Mode exists but purpose unclear:
- Testing tools?
- Admin functions?
- Debug information?

### Options

| Option | Audience | Content |
|--------|----------|---------|
| **A: Debug Only** | Developers | Logs, state inspection |
| **B: Admin Tools** | Product team | User simulation, content preview |
| **C: Power User** | Advanced users | Hidden settings, shortcuts |
| **D: Remove** | — | Not needed for MVP |

---

## PD-104: LoadingInsightsScreen Personalization

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Question** | How should the loading screen personalize based on user data? |
| **Status** | PENDING |

### Current State

Generic loading messages. Opportunity for personalization:
- Reference user's identity goal
- Mention recent progress
- Tease upcoming recommendations

---

## PD-108: Constellation UX Migration ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Decision** | "Big Bang" migration with Skill Tree fallback |
| **Status** | RESOLVED |
| **Research** | RQ-017 |

### Decision

Replace current dashboard with Constellation visualization:
- Solar system metaphor for identity facets
- Orbit distance = Identity Coherence Score (ICS)
- Fallback to Skill Tree if performance issues

---

## PD-109: Council AI Activation Rules ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | C, D |
| **Decision** | Treaty-centric activation with emergency override |
| **Status** | RESOLVED |
| **Research** | RQ-016 |

### Rules

1. Council convenes for treaty negotiation
2. Council reconvenes for treaty breach
3. Emergency summon via Summon Tokens
4. Cool-down period between sessions

---

## PD-110: Airlock Protocol User Control ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Decision** | Severity + Treaty hybrid control model |
| **Status** | RESOLVED |
| **Research** | RQ-018 |

### Airlock Triggers

| Trigger | User Control |
|---------|--------------|
| Treaty breach | Automatic |
| Context transition | User can skip |
| Identity priming | Configurable |
| Emergency | Always shows |

---

## PD-111: Polymorphic Habit Attribution ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Habits can belong to multiple identity facets |
| **Status** | RESOLVED |
| **Research** | RQ-015 |

### Implementation

- Many-to-many relationship: habits ↔ identity_facets
- Attribution weight per facet
- UI shows primary facet with secondary indicators

---

## PD-112: Identity Priming Audio Strategy ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Decision** | Hybrid audio strategy (stock + generative) |
| **Status** | RESOLVED |
| **Research** | RQ-018 |

### Strategy

- **Stock audio:** Background ambience, transitions
- **Generative:** Personalized affirmations (future phase)
- **Current state:** 0-byte placeholder files (needs real audio)

---

## PD-113: Treaty Priority Hierarchy ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Treaties ordered by activation time, user can reorder |
| **Status** | RESOLVED |
| **Research** | RQ-020 |

---

## PD-115: Treaty Creation UX ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Council-mediated creation with visual ceremony |
| **Status** | RESOLVED |
| **Research** | RQ-021 |

### Flow

1. User expresses intent
2. Council convenes to negotiate terms
3. Treaty terms presented
4. Ratification ceremony (3-second hold)
5. Treaty activated

---

## PD-118: Treaty Modification UX ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Constitutional Amendment Model |
| **Status** | RESOLVED |
| **Research** | RQ-024 |

### Modification Types

| Type | Process | Council |
|------|---------|---------|
| **Minor amendment** | In-app editor | No |
| **Major amendment** | Re-ratification | Yes |
| **Pause** | Modal + date picker | No |
| **Repeal** | Type-to-confirm | Optional |

---

## PD-120: The Chamber Visual Design

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Question** | How should The Chamber (Council meeting space) be visualized? |
| **Status** | PENDING |
| **Blocking RQ** | RQ-036 (Chamber Visual Design Patterns) |

### Considerations

- Parliament of Selves metaphor
- Council members as visual personas
- Negotiation table representation
- Turn-taking visualization

---

## PD-201: URL Scheme Migration

| Field | Value |
|-------|-------|
| **Phase** | — |
| **Question** | How to migrate from `atomichabits://` to `thepact://`? |
| **Status** | PENDING |

### Tasks

- Update URL scheme in AndroidManifest
- Handle legacy deep links
- Update documentation

---

## PD-202: Archive Documentation Handling

| Field | Value |
|-------|-------|
| **Phase** | — |
| **Question** | How should archived documentation be managed? |
| **Status** | PENDING |

### Considerations

- Archive file naming conventions
- Quarterly vs monthly archiving
- Cross-reference maintenance

---

## Related Research Questions

| RQ# | Title | Status | Blocks |
|-----|-------|--------|--------|
| RQ-016 | Council AI (Roundtable Simulation) | COMPLETE | PD-109 |
| RQ-017 | Constellation UX | COMPLETE | PD-108 |
| RQ-018 | Airlock Protocol | COMPLETE | PD-110, PD-112 |
| RQ-021 | Treaty Lifecycle & UX | COMPLETE | PD-115 |
| RQ-024 | Treaty Modification | COMPLETE | PD-118 |
| RQ-033 | Streak Philosophy | COMPLETE | PD-002 |
| RQ-036 | Chamber Visual Design | NEEDS RESEARCH | PD-120 |

---

*UX decisions define how users experience The Pact's interface and flows.*
