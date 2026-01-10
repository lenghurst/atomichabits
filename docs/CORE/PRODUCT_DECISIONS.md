# PRODUCT_DECISIONS.md — Product Philosophy & Pending Decisions

> **Last Updated:** 06 January 2026 (Archiving strategy implemented)
> **Purpose:** Central source of truth for product decisions and open questions
> **Owner:** Product Team (Oliver)

---

## Quick Navigation

| Resource | Purpose | Location |
|----------|---------|----------|
| **CD Quick Reference** | All Confirmed Decisions at a glance (start here) | `index/CD_INDEX.md` |
| **PD Quick Reference** | All Pending Decisions at a glance (start here) | `index/PD_INDEX.md` |
| **Archived Decisions** | Full rationale for CONFIRMED/RESOLVED items | `archive/CD_PD_ARCHIVE_Q1_2026.md` |
| **Active Decisions** | Full details for pending items | This file (Pending Decisions section) |

**Workflow:** Check index first → Read archive for resolved items → This file for pending decision details.

---

## What This Document Is

This document captures:
1. **Confirmed Decisions** — Locked choices that should not be revisited without explicit approval
2. **Pending Decisions** — Open questions requiring human input before implementation
3. **Proposed Approaches** — Suggested solutions awaiting validation
4. **Rejected Options** — Approaches we've considered and ruled out (with rationale)

---

## Decision Hierarchy

Decisions are not equal. Some are **foundational** — they must be resolved before dependent decisions can be made.

```
FOUNDATIONAL DECISIONS (Tier 1)
    ↓ Must be resolved first
DEPENDENT DECISIONS (Tier 2)
    ↓ Can only be resolved after Tier 1
IMPLEMENTATION DETAILS (Tier 3)
    ↓ Can only be resolved after Tier 2
```

---

## RQ/PD Relationship

**Key Principle:** Not all PDs require RQs, but all RQs should generate PDs if implementation decisions are needed.

```
RQ (Research Question)
├── Open investigation — "What should we do?"
├── Generates findings and recommendations
└── If decision needed → Creates PD

PD (Product Decision - Pending)
├── Awaiting human input — "Which option?"
├── May or may not have RQ behind it
└── Once resolved → Becomes CD

CD (Confirmed Decision)
├── Locked choice — implementation can proceed
└── Rationale documented for future reference
```

**Terminology:**
- **RQ** = Research Question (investigation)
- **PD** = Product Decision (pending choice)
- **CD** = Confirmed Decision (locked choice)

**Examples:**
- **RQ → PD:** RQ-011 (Multiple Identity research) → PD-106 (Multiple Identity decision)
- **PD without RQ:** PD-004 (Dev Mode Purpose) — straightforward product choice, no research needed
- **PD with multiple RQs:** PD-107 → requires RQ-005, RQ-006, RQ-007

**Rule:** If a question is complex enough to need research, create an RQ first. If it's a straightforward choice between known options, create a PD directly.

---

## Confirmed Decisions

### Decision Dependency Map

**Tier Logic Explanation:**
- **Tiers are organized by DEPENDENCY, not IMPORTANCE**
- A Tier 0 decision has NO dependencies (can be made independently)
- A Tier 3 decision DEPENDS on Tiers 0-2 being decided first
- Lower tier ≠ Less important; Lower tier = Fewer blockers

**All confirmed decisions organized by dependency tier:**

```
TIER 0: FOUNDATIONAL (No dependencies — can be decided independently)
├── CD-001: App Name & Branding [LOW importance]
├── CD-002: AI as Default Witness [MEDIUM importance]
├── CD-012: Git Workflow Protocol [LOW importance — process]
├── CD-013: UI Logic Separation Principle [MEDIUM importance — code quality]
└── CD-014: Core File Creation Guardrails [**CRITICAL** importance — agent context]

TIER 1: CORE ARCHITECTURE (Blocks most product decisions)
├── CD-005: 6-Dimension Archetype Model [CRITICAL importance]
│   └── Blocks: CD-006, CD-007, CD-008, CD-010
└── CD-015: psyOS Architecture [**CRITICAL** — foundational philosophy]
    └── Blocks: ALL downstream (PD-108 through PD-112)

TIER 2: ARCHITECTURE EXTENSIONS (Depend on Tier 1)
├── CD-006: GPS Permission Usage → Depends on CD-005 [MEDIUM]
├── CD-007: 6+1 Dimension Model → Extends CD-005 [MEDIUM]
└── CD-008: Identity Development Coach → Uses CD-005 [CRITICAL — VALUE PROP]
    └── Blocks: CD-009, CD-011

TIER 3: SUPPORTING SYSTEMS (Depend on Tier 2)
├── CD-009: Content Library → Supports CD-008 [HIGH — enables CD-008]
├── CD-010: Retention Tracking → Uses CD-005 [MEDIUM]
└── CD-011: Architecture Ramifications → Implements CD-008 [HIGH]

TIER 4: UX/ONBOARDING (Depends on Sherlock design)
└── CD-003: Sherlock Before Payment [HIGH — conversion]

TIER 5: DEPRIORITIZED
└── CD-004: Conversational CLI (rejected) [NONE]
```

**Critical Path (Most Important Decisions):**
```
CD-005 (Dimensions) → CD-008 (Identity Coach) → CD-009 (Content) → CD-011 (Implementation)
```
These four decisions form the core value proposition chain.

**Reading Order:** Read by IMPORTANCE, not tier:
1. CD-005 (6-Dimension Model) — Core architecture
2. CD-008 (Identity Coach) — Value proposition
3. CD-009 (Content Library) — What enables the coach
4. CD-011 (Architecture Ramifications) — How it's implemented

### Quick Reference Table

| CD# | Decision | Tier | Depends On | Blocks | Impact |
|-----|----------|------|------------|--------|--------|
| **CD-001** | App Name & Branding | 0 | — | Branding everywhere | LOW (cosmetic) |
| **CD-002** | AI as Default Witness | 0 | — | Witness UX | MEDIUM |
| **CD-003** | Sherlock Before Payment | 4 | Sherlock design | Onboarding flow | HIGH (conversion) |
| **CD-004** | Conversational CLI | 5 | — | — | NONE (rejected) |
| **CD-005** | 6-Dimension Model | 1 | — | CD-006,7,8,10,15 | **CRITICAL** (core) |
| **CD-006** | GPS Permission Usage | 2 | CD-005 | Social Rhythmicity | MEDIUM |
| **CD-007** | 6+1 Dimension Model | 2 | CD-005 | Social features | MEDIUM |
| **CD-008** | Identity Development Coach | 2 | CD-005,15 | CD-009,11 | **CRITICAL** (value prop) |
| **CD-009** | Content Library | 3 | CD-008,15 | JITAI effectiveness | HIGH |
| **CD-010** | Retention Tracking | 3 | CD-005 | Analytics | MEDIUM |
| **CD-011** | Architecture Ramifications | 3 | CD-008,15 | Onboarding, Dashboard | HIGH |
| **CD-012** | Git Workflow Protocol | 0 | — | — | LOW (process) |
| **CD-013** | UI Logic Separation | 0 | — | — | MEDIUM (code quality) |
| **CD-014** | Core File Guardrails | 0 | — | — | **CRITICAL** (agent context) |
| **CD-015** | psyOS Architecture | 1 | CD-005, RQ-011 | ALL | **CRITICAL** (foundational) — CONFIRMED |
| **CD-016** | AI Model Strategy (DeepSeek V3.2) | 1 | CD-015 | All AI routing | **CRITICAL** (cost/quality) — CONFIRMED |
| **PD-105** | Unified AI Coaching Architecture | 1 | CD-005, CD-015 | CD-008,9,11 | **CRITICAL** (architecture) — SUPERSEDED by PD-107 |
| **PD-106** | Multiple Identity Architecture | 1 | RQ-011, CD-015 | Phase 1,2,3 | **CRITICAL** (data model) — RESOLVED via CD-015 |
| **PD-107** | Proactive Guidance System | 1 | RQ-005,6,7, CD-015 | Gap Analysis, Recommendations | **CRITICAL** (intelligence) — NEEDS RESEARCH |

**Impact Legend:**
- **CRITICAL:** Foundational to product identity; changes ripple everywhere
- **HIGH:** Affects user experience or revenue significantly
- **MEDIUM:** Important for quality/consistency but localized impact
- **LOW:** Process/cosmetic; can be changed without major consequences

---

### CD-001: App Name & Branding
| Field | Value |
|-------|-------|
| **Decision** | App is "The Pact", not "AtomicHabits" |
| **Status** | CONFIRMED |
| **Date** | January 2026 |
| **Rationale** | Brand differentiation, domain ownership (thepact.co) |
| **Action Required** | Deprecate `atomichabits://` URL scheme, update all branding |

### CD-002: AI as Default Witness
| Field | Value |
|-------|-------|
| **Decision** | The Pact AI is ALWAYS the witness; human witness is ADDITIVE |
| **Status** | CONFIRMED |
| **Date** | January 2026 |
| **Rationale** | "Go Solo" implies AI isn't accountable — wrong framing |
| **Action Required** | Remove "Go Solo" terminology, reframe witness invite as optional/referral |

### CD-003: Sherlock Before Payment
| Field | Value |
|-------|-------|
| **Decision** | Keep Sherlock voice session BEFORE payment gate for MVP |
| **Status** | CONFIRMED (subject to conversion data) |
| **Date** | January 2026 |
| **Rationale** | The "magic" of Sherlock IS the value proposition |
| **Risk** | Higher CAC (AI cost before commitment) |
| **Mitigation** | Track conversion rate, consider timeout for non-converters |

### CD-004: Conversational CLI — Deprioritized
| Field | Value |
|-------|-------|
| **Decision** | Do NOT implement command-line interface for users |
| **Status** | CONFIRMED |
| **Date** | January 2026 |
| **Rationale** | Developer-style interface is incongruent with consumer wellness app |
| **Alternative** | Natural language chat already exists |

### CD-005: 6-Dimension Archetype Model
| Field | Value |
|-------|-------|
| **Decision** | Use 6-dimension continuous model with 4 UI clusters |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **Research** | ChatGPT + Gemini Deep Research + Gemini Deep Think |
| **Rationale** | Research-validated dimensions predict intervention response |
| **Documentation** | See `docs/CORE/RESEARCH_QUESTIONS.md` RQ-001 |

**The 6 Dimensions:**
1. Regulatory Focus (Promotion ↔ Prevention)
2. Autonomy/Reactance (Rebel ↔ Conformist)
3. Action-State Orientation (Executor ↔ Overthinker)
4. Temporal Discounting (Future ↔ Present)
5. Perfectionistic Reactivity (Adaptive ↔ Maladaptive)
6. Social Rhythmicity (Stable ↔ Chaotic)

**The 4 UI Clusters:**
- The Defiant Rebel
- The Anxious Perfectionist
- The Paralyzed Procrastinator
- The Chaotic Discounter

### CD-006: GPS Permission Usage
| Field | Value |
|-------|-------|
| **Decision** | Use full GPS for schedule entropy calculation |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **Rationale** | Permission already granted; provides better signal for Social Rhythmicity dimension |
| **Action Required** | Add "time-only" option in Settings for privacy-conscious users |

### CD-007: 6+1 Dimension Model (Social Sensitivity Extension)
| Field | Value |
|-------|-------|
| **Decision** | Implement 6 core dimensions NOW; add 7th (Social Sensitivity) AFTER social features exist |
| **Status** | CONFIRMED (Two-Phase) |
| **Date** | 05 January 2026 |
| **Rationale** | 6 dimensions are research-validated; 7th is hypothesis requiring validation |

**Phase A (Now):**
- Build Social Leaderboard feature
- Backend accommodates 7-float vector (7th stays null)
- UI shows 4 clusters based on 6 dimensions

**Phase B (After Social Features):**
- Research Social Sensitivity dimension properly
- Validate against intervention response data
- Activate 7th dimension once validated

**Why Not 7 Now:**
- Social Sensitivity wasn't researched to same depth
- Building on unvalidated assumptions creates technical debt
- Social features must exist before we can measure social sensitivity

### CD-008: Identity Development Coach (Recommendation Engine)
| Field | Value |
|-------|-------|
| **Decision** | Build AI-driven Identity Development Coach that guides users toward their aspirational self |
| **Status** | CONFIRMED — ELEVATED PRIORITY |
| **Date** | 05 January 2026 |
| **Supersedes** | Previous "Proactive Analytics Engine" framing |

**Critical Distinction:**
```
JITAI = WHEN to intervene (reactive timing)
Content Library = WHAT to say in interventions
Identity Coach = WHO to become + HOW to get there
```

**The Identity Coach answers:**
1. "Who does the user want to become?" (Aspirational Identity)
2. "What habits/rituals will get them there?" (Habit Recommendations)
3. "What's the next step in their identity journey?" (Progression Path)
4. "What patterns are pulling them backward?" (Regression Detection)
5. "Are their current habits aligned with their stated identity?" (Coherence)

**This is NOT just notifications — it's an AI life coach that constructs and guides identity development.**

**Specification:** See `docs/CORE/IDENTITY_COACH_SPEC.md` (to be created)

### CD-009: Content Library (Serves Identity Coach)
| Field | Value |
|-------|-------|
| **Decision** | Content Library supports BOTH JITAI (reactive) AND Identity Coach (proactive) |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **Rationale** | Detection logic is useless without content; Coach can't guide without recommendations |

**Content Requirements:**

| System | Content Type | Quantity |
|--------|--------------|----------|
| **JITAI** | Intervention messages (7 arms × 4 framings) | 28 |
| **Identity Coach** | Habit recommendations (by dimension) | 50+ |
| **Identity Coach** | Ritual templates (morning/evening/transition) | 20+ |
| **Identity Coach** | Progression milestone descriptions | 15+ |
| **Identity Coach** | Regression warning messages | 15+ |
| **Identity Coach** | Goal alignment prompts | 25+ |
| **Total** | | 153+ |

### CD-010: Retention Tracking Philosophy
| Field | Value |
|-------|-------|
| **Decision** | Track retention from DUAL perspectives (App + User) |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **App Perspective** | Retention rate, cohort analysis, intervention attribution |
| **User Perspective** | "Graduation rate" as positive metric, goal achievement tracking |
| **Rationale** | App success ≠ User success; both must be measured |
| **Action Required** | Design metrics that capture both perspectives |

### CD-011: Identity Coach Architecture Ramifications
| Field | Value |
|-------|-------|
| **Decision** | Identity Coach changes onboarding, dashboard, and widget architecture |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |

**Onboarding Changes:**

| Current | Required |
|---------|----------|
| Extract Holy Trinity (blocks) | ALSO extract Aspirational Identity (goals) |
| "What do you fear becoming?" | ADD "What does your ideal self look like in 1 year?" |
| Focus on resistance | ADD focus on aspiration |

**New Sherlock Extraction Targets:**
```
HOLY TRINITY (Existing — What blocks them)
├── Anti-Identity: Who they fear becoming
├── Failure Archetype: Why they failed before
└── Resistance Lie: Their excuse

ASPIRATIONAL IDENTITY (New — Who they want to become)
├── Ideal Self: "In 1 year, I am..."
├── Core Values: What matters most
├── Identity Evidence: What daily actions prove this identity
└── Milestone Vision: What does "success" look like?
```

**Dashboard Changes:**

| Current | Required |
|---------|----------|
| Habit list + streaks | ADD "Recommended Next Steps" section |
| Static layout | ADD Identity Progress visualization |
| User-defined habits only | ADD Coach-suggested habits |
| No progression path | ADD "Your Identity Journey" map |

**Widget Opportunities:**
- Daily Focus Widget: "Today's identity building block"
- Progress Widget: % toward aspirational self
- Recommendation Widget: "Try this habit today"
- Coherence Widget: "Alignment with stated values"

### CD-012: Git Workflow Protocol
| Field | Value |
|-------|-------|
| **Decision** | All AI agents push directly to main (linear workflow) |
| **Status** | CONFIRMED (Revised) |
| **Date** | 05 January 2026 |
| **Rationale** | User works linearly with one agent at a time; branches add unnecessary friction |

**Workflow:**
```
Agent works → Commits to main → Pushes to main → Next agent continues
```

**Why Direct to Main:**
- Linear workflow (one agent at a time, not parallel)
- TDD is inherent in the workflow (tests run before each commit)
- Reduces merge friction and context-switching overhead
- Human is always in the loop directing work

**Safeguards:**
1. **Pre-commit checks:** Run tests/linters before committing
2. **Atomic commits:** Small, focused commits with clear messages
3. **Human oversight:** User directs all work, no autonomous multi-agent scenarios
4. **Rollback ready:** Git history allows easy revert if needed

**Exception:** If human requests a feature branch for experimental work, create one.

**Agent Responsibilities:**
- Commit frequently (atomic changes)
- Write clear commit messages
- Run tests before pushing
- Never force-push to main

### CD-013: UI Logic Separation Principle
| Field | Value |
|-------|-------|
| **Decision** | UI files contain ONLY presentation; all logic lives in services/providers |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **Rationale** | Enables "vibe coding" (rapid UI iteration), testability, and AI-assisted development |

**The Principle:**
```
UI Layer (screens, widgets)     →  PRESENTATION ONLY
├── Layout and styling          →  ✅ Belongs here
├── User input handling         →  ✅ Belongs here (call provider methods)
├── Navigation                  →  ✅ Belongs here
├── Conditional rendering       →  ✅ Belongs here (based on provider state)
│
├── Business logic              →  ❌ Move to service/provider
├── Data transformation         →  ❌ Move to service/provider
├── API calls                   →  ❌ Move to repository
├── State mutations             →  ❌ Move to provider
└── Calculations                →  ❌ Move to service
```

**Why This Matters for AI Development:**
1. **Vibe Coding:** UI changes don't break logic; logic changes don't break UI
2. **Testing:** Services/providers can be unit tested without UI
3. **AI Assistance:** AI can modify UI without understanding business rules
4. **Parallel Work:** UI and logic can evolve independently

**Current Pattern:**
```dart
// ✅ CORRECT: UI calls provider, provider handles logic
class HabitCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitProvider);
    return GestureDetector(
      onTap: () => ref.read(habitProvider.notifier).toggleComplete(),
      child: Text(habit.name),
    );
  }
}

// ❌ WRONG: Logic in UI file
class HabitCard extends StatelessWidget {
  void _handleTap() {
    final today = DateTime.now();
    if (!habit.isCompleteToday(today)) {
      habit.completions.add(today);
      _updateStreak();  // Logic should not be here
      _saveToDatabase(); // API call should not be here
    }
  }
}
```

**Research Task:** See RQ-008 for best practices on articulating this principle for AI-assisted development.

### PD-105: Unified AI Coaching Architecture (Identity Coach + JITAI + Content)
| Field | Value |
|-------|-------|
| **Question** | How should Identity Coach, JITAI, and Content Library be architected? |
| **Status** | 🔴 PENDING — Requires Research |
| **Priority** | **CRITICAL** — Blocks CD-008, CD-009, CD-011 |
| **Blocking** | Identity Coach implementation, Content Library design |
| **Date Proposed** | 05 January 2026 |

**The Question:**
Should these three components be:
- **Option A:** ONE integrated system ("AI Coaching Engine")
- **Option B:** Three separate systems with integration points
- **Option C:** Two systems (Identity Coach + JITAI) with Content Library as shared resource

**Current Hypothesis (NOT CONFIRMED — Requires Validation):**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AI COACHING ENGINE                                    │
│                        (Single Integrated System?)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    IDENTITY COACH (Brain)                            │   │
│  │                                                                      │   │
│  │  Responsibilities:                                                   │   │
│  │  • Understand user's aspirational identity                          │   │
│  │  • Track progress toward identity goals                             │   │
│  │  • Recommend habits/rituals aligned with identity                   │   │
│  │  • Detect regression patterns                                       │   │
│  │  • Orchestrate WHEN and WHAT to communicate                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                    ┌───────────────┴───────────────┐                       │
│                    ↓                               ↓                        │
│  ┌─────────────────────────────┐   ┌─────────────────────────────┐        │
│  │    JITAI (Timing Engine)    │   │  Content Library (Messages) │        │
│  │                             │   │                             │        │
│  │  Responsibilities:          │   │  Responsibilities:          │        │
│  │  • Determine WHEN to act    │   │  • Provide WHAT to say      │        │
│  │  • Calculate V-O state      │   │  • Framing per dimension    │        │
│  │  • Apply safety gates       │   │  • Personalized messaging   │        │
│  │  • Learn optimal timing     │   │  • Intervention variants    │        │
│  └─────────────────────────────┘   └─────────────────────────────┘        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Hypothesized Relationship (Needs Validation):**
```
Option A (Current Hypothesis):
   Identity Coach (Brain)
   ├── Uses JITAI to decide timing
   └── Uses Content Library for messaging

Option B (Alternative):
   JITAI ←──── shares content ────→ Content Library
      ↓                                    ↑
   triggers                           provides messages
      ↓                                    ↑
   Identity Coach (User Journey) ─────────┘
```

**Arguments FOR Option A (Unified):**
1. Single Source of Truth: One engine tracks user state
2. Coherent Experience: User sees one coach
3. Simpler Architecture: Fewer integration points

**Arguments FOR Option B (Modular):**
1. Separation of Concerns: Easier to test/maintain
2. Independent Evolution: Can update JITAI without touching Coach
3. Existing Code: JITAI already works independently

**Research Required:**
1. What architecture patterns exist for multi-component AI coaching systems?
2. How do existing habit apps (Noom, Headspace) structure their intervention systems?
3. What are the maintenance trade-offs of unified vs modular?
4. Does our current JITAI code naturally extend to orchestration, or is it timing-only?

**Why This Needs Research (Not Assumption):**
- Architecture affects all downstream implementation
- Wrong choice creates significant technical debt
- No literature review has been done on this specific question
- "Unified is better" was an assertion, not a validated finding

**Hypothetical Code (IF Option A is chosen):**
```dart
class IdentityCoachService {
  final JITAIDecisionEngine _timing;
  final ContentLibrary _content;

  Future<Recommendation?> getRecommendation(User user) async {
    // 1. Identity Coach decides IF to recommend
    if (!_shouldRecommend(user)) return null;

    // 2. JITAI decides WHEN (timing optimal?)
    final timing = await _timing.evaluateTiming(user);
    if (!timing.isOptimal) return null;

    // 3. Content Library provides WHAT (message)
    final message = await _content.getPersonalized(
      user: user,
      dimension: user.dominantDimension,
      context: timing.context,
    );

    return Recommendation(message: message, timing: timing);
  }
}
```

**See:** RQ-007 (Identity Roadmap Architecture) for research tracking

### CD-014: Core File Creation Guardrails
| Field | Value |
|-------|-------|
| **Decision** | Agents must NOT create new MD files in `docs/CORE/`; use directory structure below |
| **Status** | CONFIRMED |
| **Date** | 06 January 2026 (Updated for folder structure) |
| **Rationale** | Prevents doc sprawl; ensures all information flows to the right place |

**The Rule:**
```
Before creating a new .md file, ask:
1. Does this belong in an existing Core file? → YES → Add it there
2. Is this a prompt or analysis output? → Use designated folder (see below)
3. Is this temporary/task-specific? → Don't create file; use TODO comments or handover notes
4. Is this truly new documentation? → ASK HUMAN
```

**Directory Structure (Enforced):**

```
docs/CORE/                           ← LOCKED: 11 governance files ONLY
├── index/                           ← Quick reference indexes (auto-maintained)
│   ├── RQ_INDEX.md
│   ├── PD_INDEX.md
│   └── CD_INDEX.md
├── archive/                         ← RESOLVED/COMPLETE items moved here
│   ├── RQ_ARCHIVE_Q1_2026.md
│   └── CD_PD_ARCHIVE_Q1_2026.md
└── [11 Core Files - see below]

docs/prompts/                        ← Deep Think prompts & AI prompt templates
└── DEEP_THINK_PROMPT_*.md

docs/analysis/                       ← Protocol 9 reconciliations & analysis outputs
├── DEEP_THINK_RECONCILIATION_*.md
└── DOCUMENTATION_GOVERNANCE_ANALYSIS.md
```

**Core File Purposes (docs/CORE/ only — do NOT add new files here):**

| Information Type | Where It Belongs |
|-----------------|------------------|
| What was done this session | AI_HANDOVER.md |
| Product philosophy/decisions | PRODUCT_DECISIONS.md |
| Term definitions | GLOSSARY.md |
| Research status/findings | RESEARCH_QUESTIONS.md |
| Agent behavioral rules | AI_AGENT_PROTOCOL.md |
| Decision impact tracing | IMPACT_ANALYSIS.md |
| Identity Coach details | IDENTITY_COACH_SPEC.md |
| Architecture diagrams | AI_CONTEXT.md |
| Task priorities | ROADMAP.md |
| Version history | CHANGELOG.md |
| Project overview | README.md |
| Deep Think prompt guidance | DEEP_THINK_PROMPT_GUIDANCE.md |

**Where New Files GO (Not in docs/CORE/):**

| File Type | Location | Example |
|-----------|----------|---------|
| Deep Think prompts | `docs/prompts/` | `DEEP_THINK_PROMPT_XYZ.md` |
| Protocol 9 reconciliations | `docs/analysis/` | `DEEP_THINK_RECONCILIATION_RQ014.md` |
| ADRs | `docs/architecture/` | `ADR-001-state-management.md` |
| Technical guides | `docs/` | `flutter-testing-guide.md` |
| Audit reports | `docs/audits/` | `2026-01-06-security.md` |

**When New Files Are OK:**
- Explicit human request: "Create a spec for X"
- Deep Think prompt: auto-goes to `docs/prompts/`
- Protocol 9 reconciliation: auto-goes to `docs/analysis/`
- ADR (Architecture Decision Record): `/docs/architecture/ADR-NNN.md`
- Technical guide: `/docs/{topic}.md`

---

### CD-015: psyOS (Psychological Operating System) Architecture
| Field | Value |
|-------|-------|
| **Decision** | The Pact will be built as a **psyOS** — a Psychological Operating System — not a habit tracker |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **Rationale** | User explicitly chose Blue Sky architecture over MVP; identity conflicts are the core value proposition |
| **Depends On** | CD-005 (6-Dimension Model), RQ-011 (Multiple Identity Research) |
| **Blocks** | ALL downstream architecture, schema, UX, and intelligence decisions |

**The Vision:**
The Pact is not a habit tracker with identity features. It is a **Psychological Operating System** that treats the user as a dynamic system of negotiating parts, not a monolithic self requiring discipline.

**Core Philosophy Shift:**

| Old Frame | New Frame (psyOS) |
|-----------|-------------------|
| Habit Tracker | Psychological Operating System |
| Monolithic Self | Parliament of Selves |
| Discipline | Governance (Coalition) |
| Conflict = Bug | Conflict = Core Value |
| Single Identity | Fractal Identity (Facets) |
| Linear Progress | Identity Topology (Graph) |
| Time-only scheduling | State Economics (Bio-energetic) |
| Generic habits | Polymorphic Habits |
| AI Assistant | Council AI (Parliament Mediator) |
| Tree Visualization | Constellation UX (Solar System) |

**7 Core Architectural Elements:**

#### 1. Parliament of Selves
User is not a monolith but a **Parliament**:
- **The Self** = Speaker of the House (conscious observer)
- **Facets** = MPs (each with goals, values, fears, neurochemistry)
- **Conflict** = Debate to be governed, not bug to be squashed
- **Goal** = Governance (coalition building), not Tyranny (discipline)

```
USER = {
  Self: "The Observer/Decider",
  Facets: [
    { name: "The Founder", goals: [...], fears: [...], energy: "high_focus" },
    { name: "The Father", goals: [...], fears: [...], energy: "social" },
    { name: "The Athlete", goals: [...], fears: [...], energy: "high_physical" }
  ],
  Tensions: [
    { source: "Founder", target: "Father", score: 0.7 }
  ]
}
```

#### 2. Fractal Trinity (Hierarchical Psychology)
The Holy Trinity isn't flat — it's fractal:

```sql
-- THE DEEP SOURCE (Global/Biological)
CREATE TABLE psychometric_roots (
  user_id UUID PRIMARY KEY,
  root_fear TEXT,                    -- "I am unworthy of love" (Core Wound)
  base_temperament_vector JSONB,     -- Biological baseline (Big 5, etc.)
  chronotype TEXT                    -- "Wolf" (Night Owl), "Lion" (Early Bird)
);

-- THE CONTEXTUAL MANIFESTATION (Local)
CREATE TABLE psychological_manifestations (
  id UUID PRIMARY KEY,
  facet_id UUID REFERENCES identity_facets(id),
  root_id UUID REFERENCES psychometric_roots(user_id),
  archetype_label TEXT,              -- Root: "Abandoned Child" → Facet: "People Pleaser"
  resistance_script TEXT,            -- "If I say no, I will be fired (abandoned)"
  coaching_strategy TEXT             -- "Compassionate Inquiry" vs "Direct Challenge"
);
```

**Key Insight:** If you only cure the leaf (specific excuse), the root grows new weeds. AI Coach must link: "Same delay tactic in fitness as career. Perfectionist root again."

#### 3. Identity Topology (Graph Model)
Facets don't just exist — they **relate**:

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID,
  target_facet_id UUID,
  interaction_type TEXT,             -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE'
  friction_coefficient FLOAT,        -- 0.0 (Flow) to 1.0 (Gridlock)
  switching_cost_minutes INT         -- Time to reset biology between them
);
```

| Interaction Type | Meaning | Example |
|------------------|---------|---------|
| SYNERGISTIC | Reinforce each other | "Athlete" + "Morning Person" |
| ANTAGONISTIC | Directly conflict | "Night Owl" + "Early Riser" |
| COMPETITIVE | Compete for resources | "Founder" + "Present Father" (time) |

#### 4. State Economics (Bio-Energetic Conflicts)
Beyond time conflicts — **energy state** conflicts:

| Energy State | Neurochemistry | Recovery Time |
|--------------|----------------|---------------|
| `high_focus` | Dopamine/Acetylcholine | 45-90 min |
| `high_physical` | Adrenaline/Endorphin | 30-60 min |
| `social` | Oxytocin/Serotonin | 20-40 min |
| `recovery` | Parasympathetic | 15-30 min |

**Example Conflict:**
- "Deep Work Coder" (high_focus) → "Present Father" (social)
- Time may be free, but **switching cost** is massive
- Detection: Adjacent habits with mismatched energy states

#### 5. Polymorphic Habits
Same action, different encoding based on active facet:

| Action | Active Facet | Metric | Feedback |
|--------|--------------|--------|----------|
| Morning Run | Athlete | Pace, HR Zone | "+10 Physical Points" |
| Morning Run | Founder | Silence, Ideas | "+10 Clarity Points" |
| Morning Run | Father | Stress Regulation | "Cortisol burned. Safe to go home." |

**Implementation:** When checking off habit, user validates "Who did this serve?" reinforcing specific neural pathway.

#### 6. Council AI (Roundtable Simulation)
Not 1:1 chat — **simulate the parliament**:

```
User: "Should I take this promotion requiring travel?"

[COUNCIL SIMULATION]
The Executive Agent: "Take it. Growth we promised."
The Father Agent: "You'll miss soccer practice. Violates 'Present' rule."

Sherlock (Mediator): "Proposal: Take job, negotiate 'No Travel Tuesdays'.
Executive gets growth; Father gets consistency. Treaty?"

[OPTIONS]
1. Accept Treaty
2. Reject — Executive wins
3. Reject — Father wins
4. Request different proposal
```

#### 7. Constellation UX (Solar System)
Dashboard as **Living Solar System**:
- **Sun** = The Self (center of gravity)
- **Planets** = Facets (orbiting)
  - **Mass** = Habit volume
  - **Gravity** = Pull on time/energy
  - **Orbit Distance** = Integration with Core Self
- **Ignored planets** don't shrink — they **cool** (dim), orbit becomes **erratic** (wobbles)

```
             ⭐ SELF
            / | \
         🔵   🟢   🟠
        /     |     \
    Career  Health  Family
   (LARGE)  (Medium) (WOBBLING)

⚠️ Family planet showing orbital decay
   Tap to stabilize
```

**Visual Insight:** User sees their life's gravity distortion in real-time.

---

**Supporting Architectural Elements:**

#### Airlock Protocol (State Transitions)
When Energy State Conflict detected, insert mandatory **Transition Ritual**:
```
"You are switching from Hunter Mode (Work) to Gatherer Mode (Home).
Do not enter yet. 5-minute Box Breathing."
```

#### Identity Priming (Pavlovian Anchors)
Nudges shouldn't just remind (Cognitive); they should **prime** (Sensory):
```
Trigger: 5 mins before "Deep Work"
Action: Play Sonic Trigger specific to "Architect" facet
Content: Hans Zimmer drone + Voice: "You are a builder. The world is noise.
         This is the signal. Enter the Cathedral."
Result: Immediate state shift via sensory anchoring.
```

#### Keystone Onboarding (Progressive Extraction)
Don't extract 5 facets on Day 1:

| Day | Session | Extraction |
|-----|---------|------------|
| Day 1 | The Hook | ONE Keystone Identity + Holy Trinity Root |
| Day 3 | The Shadow | "What's being neglected?" → Facet 2 |
| Day 7+ | The Garden | Unlock full facet creation |

#### Maintenance Mode (Seasonality)
High performers sequence, not balance:

| Status | Meaning | Habit Load |
|--------|---------|------------|
| `active` | Full growth mode | Full daily habits |
| `maintenance` | Low volume | 1x/week minimum |
| `dormant` | Parked | No active habits |

Coaching: "You can't be Level 10 Founder AND Level 10 Athlete this quarter. Which is the Driver?"

---

**Schema Summary (psyOS):**

```sql
-- CORE TABLES
psychometric_roots           -- Global psychology (root fears, temperament)
identity_facets              -- User's identity parts (with status, energy)
psychological_manifestations -- How roots manifest per facet
identity_topology            -- Relationships between facets (graph)
habit_facet_links            -- Many-to-many: habits serve facets

-- KEY FIELDS
identity_facets.status       -- 'active', 'maintenance', 'dormant'
identity_facets.energy_state -- 'high_focus', 'high_physical', 'social', 'recovery'
identity_topology.friction_coefficient  -- 0.0-1.0 tension score
identity_topology.switching_cost_minutes -- Bio-energetic recovery
```

---

**Impact on Existing Decisions:**

| Decision | Impact |
|----------|--------|
| **CD-005** (6-Dimension) | EXTENDED — Dimensions now context-aware per facet |
| **CD-008** (Identity Coach) | ELEVATED — Coach becomes Parliament Mediator |
| **CD-009** (Content Library) | EXPANDED — Need facet-specific content + transition rituals |
| **PD-106** | RESOLVED — Identity Facets model confirmed via psyOS |
| **PD-107** | RESHAPED — PGS must support Council AI pattern |

---

**New Research Questions Generated:**
- RQ-012: Fractal Trinity Architecture
- RQ-013: Identity Topology & Graph Modeling
- RQ-014: State Economics & Bio-Energetic Conflicts
- RQ-015: Polymorphic Habits Implementation
- RQ-016: Council AI (Roundtable Simulation)
- RQ-017: Constellation UX (Solar System Visualization)
- RQ-018: Airlock Protocol & Identity Priming

---

**Technical Debt Acknowledgment:**
User explicitly chose psyOS despite increased complexity:
> "psyOS architecture is what I want to pursue for launch. Not the MVP Version. I want this despite the technical debt it might incur."

**Accepted Trade-offs:**
- Higher implementation complexity
- Longer time to market
- More sophisticated AI requirements
- Richer schema with more tables
- Custom visualization (Constellation UX)

**Implementation Strategy:**
> **Updated 05 Jan 2026:** User explicitly chose FULL implementation at launch, not phased rollout. All psyOS features will be built for initial release.

- Full implementation at launch (not phased)
- Schema designed for psyOS from day one
- All 7 core architectural elements built simultaneously
- DeepSeek V3.2 for cost-effective background processing (see CD-016)

---

### CD-016: AI Model Strategy (Multi-Model Architecture)
| Field | Value |
|-------|-------|
| **Decision** | Use multi-model architecture: Gemini for voice + embeddings, DeepSeek V3.2 for reasoning |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **Updated** | 05 January 2026 (Added gemini-embedding-001 for embeddings per RQ-019) |
| **Rationale** | Each model optimized for specific task characteristics |
| **Depends On** | CD-015 (psyOS Architecture) |
| **Blocks** | All AI prompt routing decisions |

**The Strategy:**
The Pact uses a **multi-model architecture** where different AI models are assigned based on task characteristics:

**Model Allocation:**

| Use Case | Model | Model ID | Rationale |
|----------|-------|----------|-----------|
| **Real-time Voice (Sherlock)** | Gemini 3 Flash | `gemini-3-flash-preview` | Latency-critical; user waiting |
| **Real-time Voice (TTS)** | Gemini 2.5 Flash TTS | `gemini-2.5-flash-preview-tts` | Quality voice synthesis with SSML |
| **Embedding Generation** | **gemini-embedding-001** | `gemini-embedding-001` | Purpose-built, Matryoshka support, 3072-dim |
| **Council AI Script Generation** | **DeepSeek V3.2** | `deepseek-v3.2-chat` | Complex reasoning, cost-effective for single-shot |
| **Root Psychology Synthesis** | **DeepSeek V3.2** | `deepseek-v3.2-chat` | Deep analysis, not time-critical |
| **Gap Analysis** | **DeepSeek V3.2** | `deepseek-v3.2-chat` | Complex pattern detection |
| **Conflict Detection** | **DeepSeek V3.2** | `deepseek-v3.2-chat` | Pattern analysis across facets |
| **JITAI Decision Logic** | Hardcoded | — | Deterministic, no AI variance needed |
| **Chronotype-JITAI Matrix** | Hardcoded | — | Fixed rules, not learned |
| **Treaty Enforcement** | Hardcoded | — | Deterministic logic hooks (json_logic_dart) |

---

**Gemini vs DeepSeek Task Split:**

| Task Category | Model | Why |
|---------------|-------|-----|
| **Real-time (User Waiting)** | Gemini | Latency-critical |
| **Embedding Generation** | Gemini gemini-embedding-001 | Purpose-built, Matryoshka, 3072-dim |
| **Complex Reasoning (Background)** | DeepSeek V3.2 | Cost-effective, high quality |
| **Deterministic Logic** | Hardcoded | No AI variance needed |

**Why gemini-embedding-001 for Embeddings (RQ-019):**
- Purpose-built for embeddings (not a general chat model)
- 3072-dimension vectors with Matryoshka support (can truncate to 768/1536)
- Replaces deprecated text-embedding-004 (deprecated Jan 14, 2026)
- +1.9% F1 improvement over previous model
- Unified multilingual + code support

---

**DeepSeek V3.2 Series:**
- **Model ID:** `deepseek-v3.2-chat` (or latest in series)
- **Strengths:** High reasoning capability, cost-effective, good at structured JSON output
- **Limitations:** Not suitable for real-time conversation (latency)
- **Use Pattern:** Background processing, batch analysis, one-shot complex prompts

**Why Not Gemini for Everything:**
1. **Cost:** DeepSeek V3.2 is significantly cheaper for complex reasoning tasks
2. **Quality:** For non-realtime tasks, DeepSeek V3.2 provides comparable or better reasoning
3. **Latency tolerance:** Background tasks don't require sub-second response times

**Why Not DeepSeek for Embeddings:**
1. **Purpose-built:** gemini-embedding-001 is specifically designed for embeddings
2. **Matryoshka:** Flexible dimension truncation (3072→1536→768) without re-embedding
3. **Quality:** Optimized for semantic similarity, not general reasoning

---

**Implementation Notes:**
```dart
// Model routing in ai_model_config.dart
enum AITask {
  realtimeVoice,      // → Gemini 3 Flash
  voiceSynthesis,     // → Gemini 2.5 Flash TTS
  embeddingGen,       // → gemini-embedding-001 (NOT DeepSeek)
  councilScript,      // → DeepSeek V3.2
  rootSynthesis,      // → DeepSeek V3.2
  gapAnalysis,        // → DeepSeek V3.2
  conflictDetection,  // → DeepSeek V3.2
}

String getModelForTask(AITask task) {
  switch (task) {
    case AITask.realtimeVoice:
      return 'gemini-3-flash-preview';
    case AITask.voiceSynthesis:
      return 'gemini-2.5-flash-preview-tts';
    case AITask.embeddingGen:
      return 'gemini-embedding-001';  // Dedicated embedding model
    default:
      return 'deepseek-v3.2-chat';    // DeepSeek for reasoning tasks
  }
}
```

**Cost Projection:**
| Task Type | Volume/Day | Model | Est. Cost/Day |
|-----------|------------|-------|---------------|
| Voice Sessions | ~5/user | Gemini 3 Flash | $0.02/user |
| TTS Generation | ~10/user | Gemini 2.5 TTS | $0.01/user |
| Embedding Gen | ~0.5/user | gemini-embedding-001 | $0.0001/user |
| Council Sessions | ~0.5/user | DeepSeek V3.2 | $0.005/user |
| Root Synthesis | ~0.1/user | DeepSeek V3.2 | $0.001/user |
| Background Analysis | ~1/user | DeepSeek V3.2 | $0.003/user |

**Migration from Current State:**
- `deepseek-chat` → `deepseek-v3.2-chat` (latest series)
- Embedding generation → `gemini-embedding-001` (not DeepSeek)

---

### CD-017: Android-First Development Strategy
| Field | Value |
|-------|-------|
| **Decision** | Primary development and testing targets Android; iOS is secondary |
| **Status** | CONFIRMED |
| **Date** | 06 January 2026 |
| **Rationale** | Android provides richer API access for passive context detection (UsageStats, Health Connect) |
| **Depends On** | CD-015 (psyOS), CD-016 (AI Model Strategy) |
| **Blocks** | All passive detection, context inference, platform-specific decisions |

**Platform Priority:**
1. **Android First:** All features designed, implemented, and tested on Android
2. **iOS Second:** Adapted from Android implementation with platform-specific adjustments
3. **Feature Parity:** Core value proposition must work on both, but Android may have richer context

**Android Advantages for psyOS:**

| Capability | Android API | iOS Equivalent | Gap |
|------------|-------------|----------------|-----|
| App Usage Stats | `UsageStatsManager` ✅ | Screen Time (limited) | Android richer |
| Foreground App | Available ✅ | Not available | Android only |
| Health Data | Health Connect ✅ | HealthKit ✅ | Parity |
| Background Processing | More permissive | Restricted | Android easier |
| Permissions | User-grantable | Similar | Parity |

**Implications for External Research:**
All Deep Think and external AI research must be reconciled against Android capabilities first. If a feature requires iOS-only APIs, it should be flagged for deferred implementation.

---

### CD-018: Engineering Threshold Framework (Not "MVP")
| Field | Value |
|-------|-------|
| **Decision** | Replace "MVP" thinking with "Android-First Launch Threshold" framework |
| **Status** | CONFIRMED |
| **Date** | 06 January 2026 |
| **Rationale** | AI-accelerated development enables ambitious launch; "MVP" undervalues our capacity |
| **Depends On** | CD-015 (psyOS — full implementation), CD-017 (Android-First) |
| **Blocks** | All scope/complexity decisions during development |

**The Framework:**

Traditional "MVP" thinking assumes human-speed development. With AI-accelerated development (Claude, Gemini, DeepSeek), we can build more ambitious features in the same timeframe. However, we still need guardrails against over-engineering.

**The Android-First Launch Threshold:**

```
For each feature/proposal, answer in sequence:

1. ESSENTIAL CHECK: Is this required for core value proposition?
   ├── YES → Build it (simplify if needed, but build it)
   └── NO → Continue to step 2

2. PLATFORM CHECK: Is the data available on Android without wearables?
   ├── YES → Continue to step 3
   └── NO → DEFER (post-launch or iOS-only)

3. BATTERY CHECK: Is the battery impact < 1% for this feature?
   ├── YES → Continue to step 4
   └── NO → DEFER to optimization phase

4. EFFORT CHECK: Can AI agents implement this in < 1 week?
   ├── YES → INCLUDE
   └── NO → Evaluate: Does value justify effort?
           ├── YES → INCLUDE (break into phases)
           └── NO → DEFER
```

**Complexity Categories:**

| Category | Definition | Action |
|----------|------------|--------|
| **ESSENTIAL** | Core value prop fails without it | Build, simplify if needed |
| **VALUABLE** | Significantly improves UX/accuracy, data available | Include if < 1 week AI effort |
| **NICE-TO-HAVE** | Marginal improvement | Defer to post-launch |
| **OVER-ENGINEERED** | Complexity without proportional value | Reject |

**Examples:**

| Feature | Category | Rationale |
|---------|----------|-----------|
| Energy State Detection | ESSENTIAL | Core to psyOS value |
| 5-State vs 4-State | OVER-ENGINEERED | 4-state sufficient; 5 adds complexity without proportional value |
| Heart Rate Integration | NICE-TO-HAVE | Requires Watch; < 10% users have it |
| Dangerous Transition Tracking | VALUABLE | Simple to implement, high value |
| Full Switching Cost Matrix | OVER-ENGINEERED | 3 dangerous pairs sufficient; 20+ pairs over-engineered |
| Burnout Early Warning | VALUABLE | Uses existing data, high impact |
| Real-time HRV Streaming | OVER-ENGINEERED | Battery drain, requires Watch, marginal improvement |

**How to Use This Framework:**

1. During Protocol 9 (External Research Reconciliation), apply this framework to each proposal
2. Use the Complexity Categories in the reconciliation output
3. When proposing new features, justify using this framework
4. When debating scope, reference this CD

---

## Pending Decisions — Tier 1 (Foundational)

These decisions BLOCK other work. They must be resolved first.

### PD-001: Archetype Philosophy
| Field | Value |
|-------|-------|
| **Question** | Should archetypes be hardcoded buckets or dynamically AI-generated? |
| **Status** | ✅ RESOLVED → See CD-005 |
| **Resolution** | 6-dimension continuous model with 4 UI clusters |
| **Date** | 05 January 2026 |
| **Research** | RQ-001 in RESEARCH_QUESTIONS.md |

---

### PD-106: Multiple Identity Architecture
| Field | Value |
|-------|-------|
| **Question** | How should the app handle users with multiple aspirational identities? |
| **Status** | 🟡 READY FOR DECISION — Research Complete (RQ-011) |
| **Priority** | **CRITICAL** — Fundamental to data model and philosophy |
| **Blocking** | Phase 1 (schema), Phase 2 (recommendations), Phase 3 (dashboard) |
| **Research** | RQ-011 in RESEARCH_QUESTIONS.md ✅ COMPLETE |
| **Research Date** | 05 January 2026 |

**The Core Question:**
Users have multiple aspirational identities ("Worldclass SaaS Salesman" + "Consistent Swimmer" + "Present Father"). How do we:
1. Capture them?
2. Track progress for each?
3. Handle conflicts between them?
4. Prioritize recommendations?

---

#### Research Finding: Identity Facets Model (Recommended)

**Philosophy:** One integrated Self with multiple **facets** — not competing identities.

**Key Insight:** The Holy Trinity (anti-identity, failure archetype, resistance lie) stays **unified** because psychological patterns are consistent. But aspirational facets can diverge.

| Option | Description | Research Verdict |
|--------|-------------|------------------|
| **A: Single Identity** | Force one primary | ❌ Too limiting |
| **B: Multiple Flat** | N identities, equal | ⚠️ No unified self |
| **C: Hierarchical** | Primary + secondary | ⚠️ Feels artificial |
| **D: Identity Facets** | One Self → N Facets | ✅ **RECOMMENDED** |

---

#### Research Recommendations

| Question | Recommendation | Rationale |
|----------|----------------|-----------|
| Max identities? | **5 (soft limit)** | Cognitive load, focus |
| Hierarchy? | **Flat with optional "focus"** | Avoids artificial ranking |
| Conflicts? | **Yes — detect and surface** | Core value differentiator |
| Habits → Identities? | **Many-to-many** | A habit can serve multiple facets |
| Dimension vector? | **One per user + per-facet adjustments** | Base personality + context tweaks |
| Dashboard UX? | **Unified tree with facet branches** | Emphasizes integrated self |

---

#### Proposed Schema (Refined with Deep Think Input)

```sql
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  domain TEXT NOT NULL,              -- "professional", "physical", "relational", "temporal"
  label TEXT NOT NULL,               -- "Early Riser"
  aspiration TEXT,                   -- "I wake before the world awakens"

  -- Seasonality (Deep Think addition)
  status TEXT DEFAULT 'active',      -- 'active', 'maintenance', 'dormant'

  -- Per-facet behavioral adjustments
  dimension_adjustments JSONB,       -- Per-facet tweaks (or use Archetypal Template)
  archetypal_template TEXT,          -- "Entrepreneur", "Parent", "Athlete" (hardcoded presets)

  -- Conflict tracking
  conflicts_with UUID[],             -- Array of conflicting facet IDs
  tension_scores JSONB,              -- {"facet_id": 0.7} (graded, not binary)
  integration_status TEXT,           -- "harmonized", "in_tension", "unexamined"

  created_at TIMESTAMPTZ,
  last_reflected_at TIMESTAMPTZ
);

CREATE TABLE habit_facet_links (
  habit_id UUID NOT NULL,
  facet_id UUID NOT NULL,
  contribution_weight FLOAT DEFAULT 1.0,
  energy_state TEXT,                 -- 'high_focus', 'high_physical', 'social', 'recovery'
  PRIMARY KEY (habit_id, facet_id)
);

-- Archetypal Templates (Hardcoded for MVP)
-- "Entrepreneur": {"risk_tolerance": +0.2, "action_orientation": +0.3}
-- "Parent": {"social_rhythmicity": +0.2}
-- "Athlete": {"temporal_discounting": -0.2}
```

---

#### Migration Path (Updated with Deep Think)

```
Phase 1 (MVP - Jan 16):
├── Add identity_facets table with status field
├── 1 Keystone Facet only at onboarding
├── Archetypal Templates (hardcoded dimension adjustments)
└── Time conflicts only (defer Energy)

Phase 2 (Post-Launch):
├── Dashboard shows facets (optional view)
├── Users organize existing habits into facets
├── Add energy_state tagging to habits
└── Tension Score (graded conflicts)

Phase 3 (Q2):
├── Sherlock extracts multiple facets progressively
├── Day 1: Keystone, Day 3: Shadow, Day 7+: Garden
└── AI-inferred dimension adjustments

Phase 4 (Blue Sky):
├── Energy State conflict detection
├── Airlock Protocol (transition rituals)
├── Council AI (roundtable simulation)
└── Constellation UX (solar system)
```

---

#### Deep Think Guardrails

| Risk | Guardrail | Implementation |
|------|-----------|----------------|
| "Ought Self" | Sherlock asks: "Do you *want* this or *should* this?" | Prompt engineering |
| Capacity overload | Hard limit: 3 Active Facets for new users | Schema constraint |
| Tree imbalance | Visual "leaning" when facets uneven | UI feedback |
| Cognitive overload | Keystone onboarding (1 facet Day 1) | Onboarding flow |

---

#### Decision Required

**Options for Oliver:**

| Choice | What Happens |
|--------|--------------|
| **Approve Facets Model** | Implement schema + migration path |
| **Approve with modifications** | Specify changes to recommendations |
| **Request more research** | Identify specific gaps |
| **Defer** | Document why and when to revisit |

**See:** RQ-011 in RESEARCH_QUESTIONS.md for full analysis

---

### PD-107: Proactive Guidance System Architecture
| Field | Value |
|-------|-------|
| **Question** | How should the Proactive Guidance System (PGS) be architected? |
| **Status** | 🟡 RESHAPED BY CD-015 — Must integrate Council AI pattern |
| **Priority** | **CRITICAL** — Defines core intelligence architecture |
| **Blocking** | Gap Analysis Engine, Recommendation Engine, Content structure |
| **Supersedes** | Clarifies relationship between JITAI, Content Library, and Identity Coach |
| **Reshaped By** | CD-015 (psyOS) — PGS must now support Council AI for conflict resolution |

**The Problem:**
Three overlapping concepts need reconciliation:
- **JITAI** — When and how to intervene (timing, channel)
- **Content Library** — What to say (templates, messages)
- **Identity Coach** — The philosophy of guiding identity development

**Proposed Architecture:**

```
PROACTIVE GUIDANCE SYSTEM (umbrella)
├── Aspiration Extraction (via Sherlock)
│   └── Captures: Holy Trinity + Aspirational Identities
│
├── Guidance Content (renamed from "Content Library")
│   ├── Habit recommendation templates
│   ├── Ritual templates
│   ├── Intervention messages (4 variants per archetype)
│   └── Coaching insights
│
├── Gap Analysis Engine
│   ├── Detects value-behavior dissonance
│   └── Generates Socratic questions
│
├── Recommendation Engine
│   ├── What habits/rituals to suggest
│   └── Based on aspirational identity + gaps
│
└── JITAI (unchanged)
    ├── When to deliver (V-O calculation)
    ├── How to deliver (channel selection)
    └── Learning (Thompson Sampling)
```

**Key Insight:**
JITAI is ONE COMPONENT of PGS, not a separate system. JITAI handles timing. Recommendation Engine handles content selection. Gap Analysis feeds both.

**Options:**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Unified PGS** | Single integrated system | Coherent experience, single source of truth | Complex, harder to test |
| **B: Modular Components** | Separate systems with integration | Easier to test/maintain | Integration overhead |
| **C: Hybrid** | PGS orchestrates, components are modular | Best of both | Requires clear interfaces |

**Recommendation:** Option C (Hybrid) — PGS as orchestration layer, components remain modular but coordinated.

**Related Decisions:**
- PD-105 (Unified AI Coaching Architecture) — This supersedes and clarifies
- CD-008 (Identity Development Coach) — This implements
- CD-009 (Content Library) — Renamed to "Guidance Content"

**Research Required:** RQ-005 (Algorithms), RQ-006 (Content), RQ-007 (Roadmap Architecture)

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| `lib/domain/services/archetype_registry.dart` | 174-210 | Static registry with 6 archetypes, `get()` defaults to PERFECTIONIST |
| `lib/domain/entities/psychometric_profile.dart` | 23-24 | `failureArchetype` stored as nullable String |
| `lib/domain/services/archetype_evolution_service.dart` | — | Evolution logic (assumes first classification is correct) |

**Current Implementation Details:**
```dart
// archetype_registry.dart:185-187
static Archetype get(String id) {
  return _archetypes[id.toUpperCase()] ?? _archetypes['PERFECTIONIST']!;
}
```
- **Problem:** Unknown archetypes silently become PERFECTIONIST
- **Problem:** User never sees/confirms their archetype
- **Problem:** Sherlock extracts freeform text, forced into 6 buckets

**The 6 Hardcoded Archetypes:**
| ID | Display Name | Coaching Style | Core Weakness |
|----|--------------|----------------|---------------|
| PERFECTIONIST | The Perfectionist | Supportive | Quits after one mistake |
| REBEL | The Rebel | Socratic | Resists being told what to do |
| PROCRASTINATOR | The Procrastinator | Tough Love | Delays until pressure |
| OVERTHINKER | The Overthinker | Supportive | Analysis paralysis |
| PLEASURE_SEEKER | The Pleasure Seeker | Supportive | Follows dopamine |
| PEOPLE_PLEASER | The People Pleaser | Supportive | Needs external validation |

**Options:**
| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Keep Hardcoded | Maintain 6 archetypes | Simple, fast | Too reductive, bad fallback |
| B: Dynamic AI | Let AI generate unique labels | Personalized | No shared vocabulary, harder analytics |
| C: Hybrid | AI generates, maps to nearest archetype | Best of both | More complex |
| D: Probabilistic | Multiple archetypes with confidence scores | Most accurate | UI complexity |

**Questions to Answer:**
1. Do users need to "identify" with their archetype label?
2. Is the archetype for internal use (coaching) or external display?
3. Should archetype change over time or be permanent?
4. **NEW:** What happens when Sherlock extracts something that doesn't map cleanly to 6 buckets?
5. **NEW:** Should we show users their archetype and let them confirm/correct it?

---

### PD-002: Streaks vs Rolling Consistency
| Field | Value |
|-------|-------|
| **Question** | Should we use streak counts or rolling consistency metrics? |
| **Status** | PENDING |
| **Blocking** | Evolution milestones, UI messaging, gamification strategy |
| **Current State** | Code uses streaks heavily; messaging says "streaks are vanity metrics" |

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| `lib/data/services/consistency_service.dart` | 1-525 | Implements "Graceful Consistency" philosophy |
| `lib/data/models/consistency_metrics.dart` | — | Data model for metrics |
| `lib/data/models/habit.dart` | — | `currentStreak`, `longestStreak` properties |

**Current Implementation (PHILOSOPHICAL TENSION):**

The **code** implements a sophisticated "Graceful Consistency" system:
```dart
// consistency_service.dart:25-31
/// Formula:
/// - Base (40%): 7-day rolling average
/// - Recovery Bonus (20%): Quick recovery count
/// - Stability Bonus (20%): Consistency of completion times
/// - Never Miss Twice Bonus (20%): Single-miss recovery rate
```

But the **UI and habits model** still use traditional streaks:
- `habit.currentStreak` — consecutive days
- `habit.longestStreak` — historical best
- 21/66/100 day milestones (hardcoded in UI)

**Key Metrics Already Implemented:**
| Metric | What It Measures | Philosophy |
|--------|------------------|------------|
| `gracefulScore` | 0-100 composite score | Rewards recovery, not perfection |
| `neverMissTwiceRate` | % of single-miss recoveries | "Missing once is human, twice is a pattern" |
| `showUpRate` | Total days / possible days | "Identity votes" concept |
| `quickRecoveryCount` | Bounced back within 1 day | Resilience tracking |

**The Philosophical Conflict:**
- `prompt_factory.dart:186-189` says: "Streaks are vanity metrics. We measure rolling consistency."
- But `habit.dart` still has `currentStreak` as primary metric
- UI shows streak counts prominently

**Options:**
| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Keep Streaks | Traditional streak counts | Gamified, clear | All-or-nothing, shame spiral |
| B: Rolling Consistency | % completion over N days | Forgiving | Less motivating |
| C: Hidden Streaks | Track but don't display | Data + safety | Users may want to see |
| D: Hybrid | Show "days with habit" not "consecutive days" | Best of both | Messaging complexity |

**Questions to Answer:**
1. What does our philosophy say about failure recovery?
2. How do we handle the "Never Miss Twice" moment?
3. Should evolution milestones use consecutive or total days?
4. **NEW:** Do we deprecate `currentStreak` in favour of `gracefulScore`?
5. **NEW:** Should the UI prioritise "7-day rolling average" over "consecutive streak"?
6. **NEW:** How do we migrate existing users who are emotionally attached to their streaks?

---

### PD-003: Holy Trinity Validity
| Field | Value |
|-------|-------|
| **Question** | Is the 3-trait model (Anti-Identity, Archetype, Resistance Lie) sufficient? |
| **Status** | PENDING |
| **Blocking** | Sherlock prompt design, personalization strategy |
| **Current State** | Implemented but extraction quality is uncertain |

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| `lib/domain/entities/psychometric_profile.dart` | 17-29 | Holy Trinity field definitions |
| `lib/data/services/ai/prompt_factory.dart` | 119-170 | How Holy Trinity is used in coaching prompts |
| `lib/config/ai_prompts.dart` | 717-745 | Sherlock extraction prompt |

**The Holy Trinity Model:**
```dart
// psychometric_profile.dart:17-29
// 1. Anti-Identity (Fear) - Day 1 Activation
final String? antiIdentityLabel;     // e.g., "The Sleepwalker", "The Ghost"
final String? antiIdentityContext;   // e.g., "Hits snooze 5 times, hates the mirror"

// 2. Failure Archetype (History) - Day 7 Trial Conversion
final String? failureArchetype;      // e.g., "PERFECTIONIST", "NOVELTY_SEEKER"
final String? failureTriggerContext; // e.g., "Missed 3 days, felt guilty, quit"

// 3. Resistance Pattern (The Lie) - Day 30+ Retention
final String? resistanceLieLabel;    // e.g., "The Bargain", "The Tomorrow Trap"
final String? resistanceLieContext;  // e.g., "I'll do double tomorrow"
```

**How It's Used in Coaching:**
```dart
// prompt_factory.dart:139-147
## USER DOSSIER
- Name: $userName
- Target Identity: "$identity"
- The Enemy (Anti-Identity): "$antiIdentity"
  └─ Context: $antiIdentityContext
- Failure Risk: $failureMode
  └─ History: $failureTriggerContext
- The Resistance Lie: "$lie"
  └─ Exact phrase: "$lieContext"
```

**Extraction Gate (app_router.dart:106-110):**
```dart
bool get hasHolyTrinity =>
    antiIdentityLabel != null &&
    failureArchetype != null &&
    resistanceLieLabel != null;
```
- All 3 must be non-null to pass onboarding (AND logic, not OR)
- Fixed in Phase 68 after critical bug

**Questions to Answer:**
1. Are all 3 traits equally important?
2. Is freeform AI extraction accurate enough?
3. Should we validate extracted traits with the user?
4. Do we need more than 3 traits?
5. **NEW:** What's the fallback when Sherlock fails to extract all 3?
6. **NEW:** Should users see their extracted Holy Trinity and confirm accuracy?
7. **NEW:** Is the "Day 1 / Day 7 / Day 30+" timing framework correct, or should all 3 be used from Day 1?

---

### PD-004: Dev Mode Purpose
| Field | Value |
|-------|-------|
| **Question** | What should dev mode control? Keep, remove, or refine? |
| **Status** | PENDING |
| **Blocking** | Production safety, testing workflow |
| **Current State** | Controls premium toggle, skip onboarding, nav shortcuts, logs |

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| `lib/features/dev/dev_tools_overlay.dart` | 1-462 | Full DevTools implementation |
| `lib/features/dev/debug_console_view.dart` | — | Log viewer component |

**Current DevTools Features:**
| Feature | What It Does | Production Risk |
|---------|--------------|-----------------|
| Premium Mode Toggle | Switches Tier 1/Tier 2 AI | **HIGH** — bypasses payment |
| Skip Onboarding | Creates dummy habit, skips to dashboard | **MEDIUM** — bad UX state |
| Quick Navigation | Jump to any screen | LOW — testing convenience |
| View Voice Logs | Real-time Gemini logs | LOW — debugging only |
| Test Voice Connection | Pings servers for latency | LOW — diagnostic |
| Copy Debug Info | Clipboard dump of config | LOW — support tool |

**Access Control (dev_tools_overlay.dart:452-455):**
```dart
// Only enable in debug mode
if (!kDebugMode) {
  return widget.child;
}
```
- Triple-tap gesture only works in debug builds
- **Not accessible in release builds** currently

**The Naming Confusion:**
- `settings.developerMode` — actually controls Premium/Tier 2 access
- Used in: `AIModelConfig.selectTier(isPremiumUser: settings.developerMode)`
- This is NOT dev mode, it's premium mode stored in wrong field name

**Questions to Answer:**
1. Is dev mode only for testing or should it exist in production?
2. Should dev mode be accessible in release builds?
3. What safeguards prevent dev mode abuse?
4. **NEW:** Should we rename `developerMode` → `isPremium` to fix the semantic confusion?
5. **NEW:** Do we need a separate "staff mode" for support/debugging in production?
6. **NEW:** Should triple-tap be removed entirely from release builds?

---

## Pending Decisions — Tier 2 (Dependent on Tier 1)

These decisions depend on Tier 1 resolutions.

### PD-101: Sherlock Prompt Overhaul
| Field | Value |
|-------|-------|
| **Question** | How should the Sherlock conversation be structured? |
| **Status** | PENDING |
| **Depends On** | PD-001 (Archetype Philosophy), PD-003 (Holy Trinity Validity) |
| **Current State** | Simplistic prompt with no turn limit or success criteria |

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| `lib/config/ai_prompts.dart` | 717-745 | Main Sherlock prompt (`voiceOnboardingSystemPrompt`) |
| `lib/data/services/ai/prompt_factory.dart` | 47-67 | `_sherlockPrompt` constant |
| `lib/config/ai_tools_config.dart` | — | Tool schema for `update_user_psychometrics` |

**Current Sherlock Prompt (ai_prompts.dart:717-745):**
```
You are Puck, a high-performance psychological accountability engine...

## THE 3 VARIABLES (THE HOLY TRINITY)
1. ANTI-IDENTITY (The Enemy): Who do they fear becoming?
2. FAILURE ARCHETYPE (History): Why did they fail in the past?
3. RESISTANCE LIE (The Excuse): What exact phrase does their brain whisper?

## TOOL USE (CRITICAL)
- As soon as you capture a variable, call `update_user_psychometrics` IMMEDIATELY.
- Do NOT wait for all three. Save them one by one as they come up.
```

**Alternative Prompt (prompt_factory.dart:47-67):**
```
You are Sherlock, an expert Parts Detective and Identity Architect.
Your Goal: Help users identify their "Protector Parts"...
```
- **Problem:** Two different Sherlock prompts exist!
- One calls itself "Puck", the other "Sherlock"

**Current Issues:**
- No maximum turn count (conversation fatigue risk)
- No extraction success criteria
- No handling for user confusion
- "Parts Detective" framing may confuse users
- **NEW:** Two conflicting prompts — which is canonical?
- **NEW:** Cheat code exists: user says "skip" → outputs `[APPROVED]`

**Proposed Improvements:**
1. Add turn limit (5-7 turns max)
2. Define extraction success criteria
3. Add progress indicators ("We're almost there")
4. Add escape hatch for frustrated users
5. Follow prompt engineering best practices
6. **NEW:** Consolidate to single canonical prompt
7. **NEW:** Remove or secure the cheat code for production

---

### PD-102: JITAI Hardcoded vs AI
| Field | Value |
|-------|-------|
| **Question** | Which JITAI components should be hardcoded vs AI-learned? |
| **Status** | PENDING |
| **Depends On** | PD-001 (Archetype Philosophy) |
| **Current State** | Hybrid — hardcoded weights with Thompson Sampling |

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| `lib/domain/services/jitai_decision_engine.dart` | 1-200+ | Main orchestrator |
| `lib/domain/services/vulnerability_opportunity_calculator.dart` | — | V-O calculation |
| `lib/domain/services/hierarchical_bandit.dart` | — | Thompson Sampling |
| `lib/domain/services/population_learning.dart` | — | Cross-user learning |

**JITAI Decision Pipeline (jitai_decision_engine.dart:63-187):**
```
1. Calculate V-O State (vulnerability + opportunity)
2. Safety Gates (Gottman ratio, fatigue)
3. Optimal Timing Analysis (ML Workstream #1)
4. Cascade Detection (weather, travel, patterns)
5. Quadrant-based Strategy (silence/wait/light/intervene)
6. Hierarchical Bandit Selection
7. Content Generation
```

**Hardcoded vs Adaptive Components:**
| Component | Hardcoded | Adaptive | Notes |
|-----------|-----------|----------|-------|
| V-O thresholds | ✅ 0.5 | ❌ | Fixed threshold for all users |
| Max interventions/day | ✅ 8 | ❌ | `_maxInterventionsPerDay = 8` |
| Gottman ratio | ✅ 5:1 | ❌ | Positive:Negative interactions |
| Min timing score | ✅ 0.35 | ❌ | Gate for poor timing |
| Cascade risk threshold | ✅ 0.6 | ❌ | Proactive intervention trigger |
| Intervention taxonomy | ✅ 7 arms | ❌ | Fixed intervention types |
| Thompson Sampling | ❌ | ✅ | Learns which interventions work |
| Population priors | ❌ | ✅ | Seeded from archetype |
| Optimal timing | ❌ | ✅ | ML-learned from history |

**The 7 Intervention Arms (Hardcoded):**
| Arm | Description | Use Case |
|-----|-------------|----------|
| SILENCE_TRUST | No intervention | Low V-O |
| GENTLE_REMINDER | Light nudge | Light touch quadrant |
| SHADOW_AUTONOMY | Rebel-friendly framing | Rebel archetype |
| TOUGH_LOVE | Direct accountability | Post-miss |
| CELEBRATION | Positive reinforcement | After completion |
| RESCUE_PROTOCOL | Emergency intervention | High cascade risk |
| ENVIRONMENT_CUE | Contextual trigger | Location-based |

**Questions to Answer:**
1. What's industry best practice for JITAI systems?
2. How much personalization is too much vs too little?
3. Do we have enough data to train AI models?
4. **NEW:** Should V-O thresholds be archetype-specific?
5. **NEW:** Is 8 interventions/day too many or too few?
6. **NEW:** Should we add more intervention arms or is 7 sufficient?

---

### PD-103: Sensitivity Detection
| Field | Value |
|-------|-------|
| **Question** | How should we detect sensitive goals (addiction, private issues)? |
| **Status** | PENDING — Proposed Approach Ready |
| **Depends On** | Demographic/firmographic data collection |

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| (Not implemented) | — | No sensitivity detection exists in codebase |

**Current State:**
- **NOT IMPLEMENTED** — No sensitivity detection logic exists
- All habits treated equally regardless of sensitivity
- Witness invites shown to all users
- Share prompts not gated by sensitivity

**Proposed Approach:**
```dart
class SensitivityAssessment {
  final int aiConfidenceLevel;     // 1-5 from DeepSeek
  final String aiReasoning;        // "Contains addiction language"
  final bool userOverride;         // User can override
  final String? userRelationship;  // Who they'd share with
}
```

**Behaviour by Level:**
| Level | Witness Invite | Share Prompts |
|-------|----------------|---------------|
| 1-2 (Public) | Prominent | Encouraged |
| 3 (Moderate) | Available, not emphasized | User choice |
| 4-5 (Private) | Hidden unless user requests | Never auto-suggest |

**Key Principle:** Never assume — always ask, but frame based on AI assessment.

**Questions to Answer:**
1. **NEW:** When should sensitivity be assessed? (During Sherlock? On habit creation?)
2. **NEW:** Should we use keyword detection or AI inference?
3. **NEW:** How do we handle false positives (user says "I'm addicted to coffee" casually)?
4. **NEW:** Does this require a privacy policy update?

---

### PD-104: LoadingInsightsScreen Personalization
| Field | Value |
|-------|-------|
| **Question** | What personalized insights should be shown during loading? |
| **Status** | PENDING |
| **Depends On** | PD-003 (Holy Trinity), JITAI baseline calculations |
| **Current State** | **ALREADY IMPLEMENTED** — Shows animated insights |

**Code References:**
| File | Lines | What It Does |
|------|-------|--------------|
| `lib/features/onboarding/screens/loading_insights_screen.dart` | 1-427 | Full implementation |
| `lib/domain/services/onboarding_insights_service.dart` | — | Insight generation logic |

**Current Implementation (loading_insights_screen.dart):**
- **NOT a generic spinner** — Shows animated insight cards
- Cycles through up to 4 insights with fade/slide animations
- Shows confidence bar for each insight
- Categories: context, intent, baseline, population

**Insight Categories (SignalCategory enum):**
| Category | Color | Example |
|----------|-------|---------|
| context | Blue | Time-based insights |
| intent | Green | Goal-based insights |
| baseline | Orange | Pattern insights |
| population | Purple | Archetype-based insights |

**Current Data Sources:**
```dart
// loading_insights_screen.dart:77-98
await for (final status in _insightsService.captureSignals(
  habits: habits,
  hasWitnesses: hasWitnesses,
  bigWhy: bigWhy,
))
```

**Proposed Insights (from ROADMAP):**
1. Holy Trinity insight: "We see the [Archetype] in you"
2. Baseline insight: "Your energy peaks at [time]"
3. Risk insight: "[Weekends/Evenings] are your drop-off zone"

**Questions to Answer:**
1. What permissions data can we use?
2. How do we calculate baseline without history?
3. How confident do we need to be before showing insight?
4. **NEW (Clarification):** The screen IS implemented — decision is about WHAT insights to show, not whether to show them
5. **NEW:** Should Holy Trinity data (from Sherlock) be displayed back to user here?
6. **NEW:** Is the current `OnboardingInsightsService` generating the right insights?

---

## Pending Decisions — psyOS Architecture (Generated by CD-015)

These decisions are required to implement the psyOS architecture.

### PD-108: Constellation UX Migration Strategy
| Field | Value |
|-------|-------|
| **Question** | How do we transition from Skill Tree to Constellation (Solar System) visualization? |
| **Status** | ✅ RESOLVED |
| **Resolution Date** | 10 January 2026 |
| **Decision** | **Option A (Big Bang) with fallback** |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Resolved By** | RQ-017 reconciliation |

**Decision Rationale:**
The Skill Tree (linear hierarchy) and Constellation (systemic relations) are incompatible mental models. Maintaining both splits engineering focus and creates UX fragmentation.

**Resolution:**
- **Primary:** Replace Skill Tree with Constellation at launch
- **Fallback:** If user struggles, offer simplified "List View" (not Tree)
- **No parallel systems** — focus engineering on one visualization

**Implementation:**
- Phase H tasks: H-01 through H-09, H-15, H-16
- Animation: Flutter CustomPainter (Canvas)
- Battery: Settled state (0 FPS idle) for optimization

---

### PD-109: Council AI Activation Rules
| Field | Value |
|-------|-------|
| **Question** | When should Council AI (roundtable simulation) be triggered vs normal coaching? |
| **Status** | ✅ RESOLVED |
| **Resolution Date** | 05 January 2026 |
| **Priority** | **CRITICAL** — Prevents feature gimmickry |
| **Blocking** | AI prompt architecture, voice session design |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Research** | RQ-016 (Council AI) ✅ COMPLETE + RQ-020 (Treaty-JITAI) ✅ COMPLETE |

**The Risk:**
Council AI could feel gimmicky if overused or triggered inappropriately. Reserved for genuine value moments.

**Confirmed Activation Rules (RQ-020 Deep Think):**

| Parameter | Confirmed Value | Rationale |
|-----------|-----------------|-----------|
| **Tension Threshold** | `0.7` | High enough to avoid spam, low enough to catch real conflicts |
| **Turn Limit** | `6` per session | Prevents fatigue, keeps sessions focused |
| **Rate Limit** | `1 auto-summon per 24h per conflict topic` | Prevents notification spam |
| **Manual Summon** | Unlimited | User always has control |

**Confirmed Trigger Taxonomy:**

| Trigger | Council? | Implementation |
|---------|----------|----------------|
| **tension_score > 0.7** | ✅ Auto-Summon | "Your inner council wants to discuss this. Convene?" |
| **User language matches conflict patterns** | ✅ Auto-Detect | Regex: `/(part of me|torn|conflict|versus|vs|sacrificing)/i` |
| **Guilt/shame + domain pattern** | ✅ Auto-Detect | Regex: `/(guilty|ashamed) about (work|family|rest)/i` |
| **Decision language** | ✅ Auto-Detect | Regex: `/should i (choose|pick)/i` |
| **User explicitly summons** | ✅ Yes | "Summon Council" button in UI |
| **Daily habit conflict** | ❌ No | Use standard coaching |

**Auto-Summon Logic (Dart):**
```dart
bool shouldSummonCouncil(String userInput, double tensionScore) {
  if (tensionScore > 0.7) return true;

  final conflictPatterns = [
    RegExp(r'(part of me|torn|conflict|versus|vs|sacrificing)', caseSensitive: false),
    RegExp(r'(guilty|ashamed) about (work|family|rest)', caseSensitive: false),
    RegExp(r'should i (choose|pick)', caseSensitive: false),
  ];

  for (final pattern in conflictPatterns) {
    if (pattern.hasMatch(userInput)) return true;
  }

  return false;
}
```

**Session Constraints:**
- Max 6 turns per Council session
- One auto-summon per conflict topic per 24 hours
- User can dismiss with "Not Now"
- User can manually summon anytime via UI

**Depends On:** RQ-016 ✅ COMPLETE, RQ-020 ✅ COMPLETE

---

### PD-110: Airlock Protocol User Control
| Field | Value |
|-------|-------|
| **Question** | How much control should users have over Airlock (mandatory transition rituals)? |
| **Status** | ✅ RESOLVED |
| **Resolution Date** | 10 January 2026 |
| **Decision** | **Option D (Severity) + Option E (Treaty)** |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Resolved By** | RQ-018 reconciliation |

**Decision Rationale:**
Forcing all Airlocks undermines user agency and causes abandonment. Making all skippable undermines value. The hybrid approach balances both:

**Resolution:**
- **Default:** Airlocks are "Suggested" (can be dismissed with tap)
- **Severity-Based:** CRITICAL transitions (Focus→Social) get stronger prompt
- **Treaty Override:** If user signs a transition treaty via Council AI, Airlock becomes **mandatory** (no dismiss button) for that specific pair
- **Minimum ritual:** 5-Second Seal (press-and-hold) for v1; max 1 minute for CRITICAL

**Implementation:**
- Phase H tasks: H-10, H-11, H-14
- Intensity matrix from RQ-014 switching costs
- Treaty integration via H-14

---

### PD-111: Polymorphic Habit Attribution
| Field | Value |
|-------|-------|
| **Question** | Should facet attribution for habits be automatic or user-selected? |
| **Status** | 🔴 PENDING — Requires RQ-015 |
| **Priority** | **HIGH** — Core UX decision for habit completion |
| **Blocking** | Habit completion flow, metrics tracking |
| **Generated By** | CD-015 (psyOS Architecture) |

**The Trade-off:**
- **Automatic:** Less friction, but may attribute incorrectly
- **User-selected:** More accurate, but adds tap per completion

**Options:**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Auto-primary** | Attribute to primary linked facet | Fast, no friction | May miss multi-facet value |
| **B: Auto-multi** | Attribute to all linked facets equally | Comprehensive | Dilutes meaning |
| **C: User-select** | Ask "Who did this serve?" on each completion | Accurate, reinforcing | Friction |
| **D: Occasional ask** | Auto most, ask 20% of time | Balance | Inconsistent experience |
| **E: Context-aware** | AI infers from time/location/pattern | Smart, low friction | Inference errors |

**Questions to Answer:**
1. Does the "Who did this serve?" prompt add value or friction?
2. Can we infer from context (morning run before work = Founder; morning run on weekend = Father)?
3. Should users be able to override attribution retroactively?
4. How does attribution affect gamification (points per facet)?

**Depends On:** RQ-015 (Polymorphic Habits research)

---

### PD-112: Identity Priming Audio Strategy
| Field | Value |
|-------|-------|
| **Question** | How should audio assets for Identity Priming be sourced and customized? |
| **Status** | ✅ RESOLVED |
| **Resolution Date** | 10 January 2026 |
| **Decision** | **Option D (Hybrid)** — Stock library + user unlock |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Resolved By** | RQ-018 reconciliation |

**Decision Rationale:**
Stock audio ensures quality at launch. User-recorded mantras add powerful personalization but require user investment — gate behind progression.

**Resolution:**
- **Launch:** 4 stock audio loops (<500KB total)
  - `drone_focus.ogg` (40Hz Gamma binaural)
  - `drone_social.ogg` (Warm acoustic)
  - `drone_physical.ogg` (130bpm percussion)
  - `sfx_airlock_seal.ogg` (Pneumatic hiss)
- **Post-Launch:** Unlock "Record Mantra" at Sapling tier (ICS ≥ 1.2)
- **No AI generation** for v1 (quality concerns, cost)

**Implementation:**
- Phase H task: H-13 (bundle assets)
- Informs RQ-026 (Sound Design) requirements

---

### PD-113: Treaty Priority Hierarchy
| Field | Value |
|-------|-------|
| **Question** | How should Treaties interact with and override default JITAI logic? |
| **Status** | ✅ RESOLVED |
| **Resolution Date** | 05 January 2026 |
| **Priority** | **HIGH** — Core to Council AI value |
| **Blocking** | Treaty enforcement, JITAI modifications |
| **Generated By** | RQ-016 (Council AI) Deep Think research |
| **Research** | RQ-020 (Treaty-JITAI Integration) ✅ COMPLETE |

**The Challenge:**
Deep Think specified that Treaties are "database objects that override default JITAI logic when specific conditions are met."

---

**Confirmed Priority Hierarchy (5-Level Stack):**

| Rank | Component | Behavior | Example |
|------|-----------|----------|---------|
| 1 | **Safety Gates** | ABSOLUTE (Never Overridden) | Gottman ratio, fatigue limits |
| 2 | **Hard Treaties** | BLOCKING — stops action | "No work travel on Tuesdays" |
| 3 | **Soft Treaties** | WARNING — reminds but allows | "Try to avoid screens after 9pm" |
| 4 | **JITAI Algorithm** | DEFAULT — learned interventions | Thompson Sampling selection |
| 5 | **User Preferences** | PASSIVE — lowest priority | Notification timing preferences |

**Key Insight:** Safety Gates > User Values > AI Optimization > User Preferences

---

**Confirmed JITAI Pipeline Position:**

```
JITAI Decision Pipeline (Finalized)
├── 1. Calculate V-O State
├── 2. Safety Gates (Gottman, fatigue) ← NEVER OVERRIDDEN
├── 3. ★ TREATY CHECK ★ (Stage 3)
│   ├── Load active treaties for user
│   ├── Evaluate logic_hooks against ContextSnapshot
│   ├── If Hard Treaty matches → BLOCK (override pipeline)
│   └── If Soft Treaty matches → WARN (continue with reminder)
├── 4. Optimal Timing Analysis
├── 5. Quadrant-based Strategy
├── 6. Hierarchical Bandit Selection
└── 7. Content Generation (may inject Treaty reminder_text)
```

---

**Confirmed Treaty Conflict Resolution:**

| Priority | Rule |
|----------|------|
| 1 | **Hard > Soft** — Hard treaties always win |
| 2 | **Newest > Oldest** — More recent treaty wins ties |

---

**Confirmed Breach → Renegotiation Rules:**

| Breach Count (7 days) | Status | Action |
|----------------------|--------|--------|
| 0 | Active | Normal enforcement |
| 1 | Active | Log only, show gentle reminder |
| 2 | Active | "You've broken this Treaty twice this week" |
| **3** | **Probationary** | "This Treaty isn't working. Reconvene Council?" |
| 4 | Probationary | Continue prompting for renegotiation |
| 5+ | **Auto-Suspended** | Treaty suspended, user notified |

**Auto-Suspension on Dismiss:**
If user dismisses renegotiation prompt 3 times:
- Treaty enters "suspended" status
- Notification: "Your [Treaty Name] has been paused. Tap to reactivate or delete."

---

**Key Questions Answered:**

| # | Question | Answer | Rationale |
|---|----------|--------|-----------|
| 1 | Pipeline position? | **Stage 3 (Post-Safety)** | Safety Gates must remain absolute |
| 2 | Conflict resolution? | **Hard > Soft, then Newest > Oldest** | Clear priority rules |
| 3 | Override safety gates? | **NEVER** | Therapeutic ethics |
| 4 | Breach threshold? | **3 breaches in 7 days → Probationary** | Balanced enforcement |
| 5 | Expired treaties? | Status = 'expired', retain for history | Clean lifecycle |

**Depends On:** RQ-020 ✅ COMPLETE

---

### PD-114: Full Implementation Commitment
| Field | Value |
|-------|-------|
| **Question** | Should psyOS be implemented in full at launch, or phased? |
| **Status** | ✅ RESOLVED → Full Implementation |
| **Resolution Date** | 05 January 2026 |
| **Decision** | Full psyOS implementation at launch, not phased |
| **Rationale** | User explicitly chose full vision despite technical debt |

---

### PD-115: Treaty Creation UX

| Field | Value |
|-------|-------|
| **Question** | How should users create Treaties? Council AI only, or ad-hoc as well? |
| **Status** | ✅ RESOLVED |
| **Resolution Date** | 05 January 2026 |
| **Decision** | **Option C: Templates + Council AI** |
| **Priority** | **HIGH** — Core to Council AI value |
| **Blocking** | Treaty creation UI, template system |
| **Generated By** | RQ-020 + RQ-021 gap analysis |
| **Research** | RQ-021 (Treaty Lifecycle & UX) ✅ COMPLETE |

---

**The "Common Law" Principle:**
80% of habit conflicts are universal (e.g., "Doomscrolling", "Work/Life Balance"). Forcing users to engage a complex AI simulation for simple needs creates "Prompt Fatigue." Templates allow users to install "Best Practices" instantly.

**Psychological Hierarchy:**
- **Templates** are "Protocols" (Maintenance)
- **Council** is "Arbitration" (Crisis)

This distinction preserves the Council as a high-value, novel experience reserved for genuine friction (`tension > 0.7`), preventing the "gimmick" effect.

---

**Confirmed Treaty Creation Flow:**

**Step 1: The Source**
- *Option A: Standard Protocols (Templates)* – Card grid (Rest, Focus, Health)
- *Option B: Summon Council (AI)* – Only available if Tension > 0.7 OR via "Summon Token"

**Step 2: The Drafting**
- *If Template:* User fills variables (e.g., `Start Time: 21:00`)
- *If Council:* **The Session UI** plays the script (Avatars pulse, Audio streams). Sherlock proposes the Draft Treaty at the end.

**Step 3: The Ratification (The Core Interaction)**
- **The Artifact:** A detailed "Treaty Card" appears (Terms, Logic Summary, Signatories)
- **The Ritual:** User must **Long-Press (3s)** a Fingerprint/Seal icon
  - *0-1s:* Haptic ticking (Clockwork feel)
  - *1-2s:* Visual: Wax melting animation. Haptics intensify.
  - *3s:* Heavy "Thud" sound. Screen flashes gold. "RATIFIED."

---

**Confirmed Treaty Template Library (Launch Set):**

| Template | Logic Hook (JSON Logic) | UX Description |
|----------|-------------------------|----------------|
| **The Sunset Clause** | `{"and": [{"==": [{"var": "category"}, "work"]}, {">=": [{"var": "hour"}, {{time}}]}]}` | **Hard Block** work apps after {{time}} |
| **Deep Work Decree** | `{"and": [{"==": [{"var": "context"}, "deep_work"]}, {"==": [{"var": "type"}, "notification"]}]}` | **Mute** notifications during Deep Work |
| **The Sabbath** | `{"and": [{"==": [{"var": "day"}, "Sun"]}, {"==": [{"var": "metric"}, "streak"]}]}` | **Suppress** streak penalties on Sundays |
| **Transition Airlock** | `{"and": [{"==": [{"var": "prev_ctx"}, "work"]}, {"==": [{"var": "next_ctx"}, "home"]}]}` | **Prompt** a "Decompression Ritual" (5m breathing) |
| **Presence Pact** | `{"and": [{"==": [{"var": "loc"}, "dining"]}, {"==": [{"var": "device"}, "phone"]}]}` | **Nudge** (High Severity) if phone unlocked at dinner |

---

**Treaty Management Screen ("The Constitution"):**

A dedicated tab in the Profile section (not Settings).

- **Visual Metaphor:** A solemn, legalistic dashboard. Dark mode default.
- **Sections:**
  - **Active Laws:** List of enforcing Treaties with a "Wax Seal" badge
  - **Probation:** Treaties breached 3+ times in 7 days (Pulsing Red Border)
  - **The Archives:** Repealed or Suspended treaties

- **Action:** Floating Action Button (FAB) "Draft New Law" → Opens Wizard

---

### PD-116: Population Learning Privacy

| Field | Value |
|-------|-------|
| **Question** | Should user embeddings be shared (anonymized) for population learning? |
| **Status** | 🔴 PENDING — Requires RQ-023 |
| **Priority** | **MEDIUM** — Enables cold-start, coaching optimization |
| **Blocking** | Population cluster implementation |
| **Generated By** | RQ-019 population learning pipeline |

**The Value:**
- **Cold-start:** Match new users to resistance archetypes immediately
- **Coaching optimization:** Learn which strategies work for which patterns
- **Research insights:** Understand population-level psychological trends

**The Risk:**
- Privacy concerns with psychological data
- Potential for re-identification via embeddings
- User trust erosion

**Options:**

| Option | Description | Privacy | Utility |
|--------|-------------|---------|---------|
| A | No population learning | ✅ Maximum | ❌ None |
| B | Opt-in, truncated embeddings (768-dim) only | ✅ Good | ⚠️ Medium |
| **C** | **Opt-in, k-anonymity (k≥50), aggregate only** | ✅ Good | ✅ High |
| D | Opt-out, full embeddings | ❌ Poor | ✅ Maximum |

**Recommendation:** Option C with:
- Explicit opt-in during onboarding
- Minimum cluster size of 50 users (k-anonymity)
- Only truncated (768-dim) embeddings shared
- No raw text ever shared
- User can delete their contribution anytime

**Depends On:** RQ-023 (Population Learning Privacy Framework)

---

### PD-117: ContextSnapshot Real-time Data

| Field | Value |
|-------|-------|
| **Question** | Which context fields should be gathered in real-time vs cached? |
| **Status** | 🔴 PENDING — Requires RQ-014 |
| **Priority** | **MEDIUM** — Affects battery life and data accuracy |
| **Blocking** | ContextService implementation |
| **Generated By** | RQ-020 ContextSnapshot class definition |

**Context Fields by Refresh Strategy:**

| Field | Refresh | Rationale |
|-------|---------|-----------|
| `dayOfWeek`, `hour`, `minute` | Real-time (computed) | Always current |
| `locationZone` | Every 5 min | Battery vs accuracy |
| `energyState` | User-reported + inferred | Not reliably detectable |
| `chronotype` | Once (onboarding) | Static user property |
| `activeFacet` | User-explicit or location-triggered | Semi-static |
| `vulnerabilityScore` | Every decision | Computed from signals |
| `tensionScore` | Every hour | Expensive calculation |
| `calendarContext` | Every 15 min | API rate limits |

**Battery Impact Tiers:**
| Tier | Refresh Rate | Battery Impact | Fields |
|------|--------------|----------------|--------|
| Static | Never / Once | None | chronotype, facet definitions |
| Slow | 15-60 min | Low | calendar, tension_score |
| Medium | 5 min | Medium | location_zone |
| Fast | Per-decision | Varies | vulnerability, opportunity |

**Depends On:** RQ-014 (State Economics & Bio-Energetic Conflicts)

---

### PD-118: Treaty Modification UX

| Field | Value |
|-------|-------|
| **Question** | How should users modify, amend, or renegotiate active Treaties? |
| **Status** | 🔴 PENDING — Requires RQ-024 |
| **Priority** | **HIGH** — Core to treaty lifecycle |
| **Blocking** | Treaty modification UI, renegotiation flow |
| **Generated By** | RQ-021 gap analysis |

**Context:**
RQ-021 specified treaty CREATION but not modification. Users need to:
- Edit treaty parameters (e.g., change sunset time from 9pm to 10pm)
- Respond to Probation state (treaty breached 3+ times)
- Pause/resume treaties without deleting

**Options:**

| Option | Description | Recommendation |
|--------|-------------|----------------|
| A: Edit Directly | Users modify terms in-place | ❌ Feels like settings |
| B: Repeal + Recreate | Delete old, create new | ❌ Too much friction |
| **C: Amendment Flow** | Minor edits direct; major changes via Council | ✅ **RECOMMENDED** |
| D: Council Only | All modifications require Council | ❌ High friction |

**Option C Details:**
- **Minor Amendments:** Edit time values, toggle soft/hard directly in Constitution
- **Major Amendments:** Changing signatories, logic structure → Council reconvenes
- **Probation Response:** Auto-prompt "Reconvene Council to renegotiate?"

**Depends On:** RQ-024 (Treaty Modification Flow)

---

### PD-119: Summon Token Economy

| Field | Value |
|-------|-------|
| **Question** | How should the Summon Token gamification mechanic work? |
| **Status** | 🔴 PENDING — Requires RQ-025 |
| **Priority** | **MEDIUM** — Enhancement to Council access |
| **Blocking** | Gamification system, monetization strategy |
| **Generated By** | RQ-021 (Summon Token mentioned) |

**Context:**
Users can access Council AI when tension_score > 0.7. Below that threshold, they need "Summon Tokens" to manually convene Council.

**Key Questions:**
1. How are tokens earned? (Streaks, completions, referrals?)
2. What's the cost? (1 token per summon?)
3. Should premium users get unlimited tokens?
4. Do tokens expire?

**Proposed Economy:**

| Earning | Tokens | Rationale |
|---------|--------|-----------|
| 7-day habit streak | +1 | Reward consistency |
| Treaty successfully resolved | +1 | Reward engagement |
| Premium subscription | Unlimited | Monetization |

**Depends On:** RQ-025 (Summon Token Economy)

---

### PD-120: The Chamber Visual Design

| Field | Value |
|-------|-------|
| **Question** | What visual design and interaction patterns should "The Chamber" (Council session UI) use? |
| **Status** | 🔴 PENDING — Requires design session |
| **Priority** | **HIGH** — Core to Council AI experience |
| **Blocking** | Chamber screen implementation |
| **Generated By** | RQ-021, RQ-022 (Chamber mentioned but not detailed) |

**Context:**
Deep Think specified "The Chamber" as a dark mode overlay with pulsing avatars, but didn't provide detailed visual specifications.

**Key Design Questions:**
1. How do facet avatars appear? (Generated? User-uploaded? Archetypal icons?)
2. How does "pulsing" indicate speaking? (Glow? Scale? Border animation?)
3. Where does dialogue text appear? (Bubbles? Subtitles? Full-screen?)
4. What's the background atmosphere? (Static? Animated? Particle effects?)
5. How do users interact during session? (Passive? Tap to advance? Skip option?)

**Options:**

| Option | Description | Recommendation |
|--------|-------------|----------------|
| A: Theater Mode | Full-screen, no UI chrome, subtitles at bottom | ✅ **Most immersive** |
| B: Chat Mode | Chat bubbles, facet avatars on sides | ❌ Feels like chatbot |
| C: Podcast Mode | Audio only, minimal visual | ❌ Loses visual engagement |

**Depends On:** Design sprint (no RQ dependency)

---

## How Decisions Get Made

1. **Proposal:** Anyone can propose a decision in this doc
2. **Discussion:** Tag as PENDING, list options and questions
3. **Human Input:** Product owner (Oliver) resolves PENDING items
4. **Confirmation:** Move to CONFIRMED with date and rationale
5. **Implementation:** Engineering implements confirmed decisions

**Rule:** Do NOT implement PENDING decisions. Wait for confirmation.

---

## Pending Decisions — Tier 3 (Implementation Details)

### PD-201: URL Scheme Migration
| Field | Value |
|-------|-------|
| **Question** | How do we migrate from `atomichabits://` to `thepact://`? |
| **Status** | PENDING |
| **Depends On** | CD-001 (Branding confirmed) |

**Considerations:**
- Backward compatibility for existing links
- App store update requirements
- Deep link service updates

---

### PD-202: Archive Documentation Handling
| Field | Value |
|-------|-------|
| **Question** | What to do with 52 archived documentation files? |
| **Status** | PENDING |
| **Recommendation** | Keep but mark DEPRECATED, audit individually in future sprint |

---

### PD-121: Archetype Template Count & Definitions

| Field | Value |
|-------|-------|
| **Question** | Should we use 12 archetypes (DeepSeek proposal) or a different number? |
| **Status** | ✅ RESOLVED |
| **Decision** | **Option A: 12 Archetypes** — psychologically grounded in SDT + Big Five/Pearson models |
| **Date** | 10 January 2026 |
| **Source** | RQ-028 ✅ COMPLETE |

**Decision Details:**

The 12 archetypes (Builder, Nurturer, Warrior, Scholar, Healer, Creator, Guardian, Explorer, Sage, Leader, Devotee, Rebel) provide:
- Standard psychological granularity (6 too coarse, 24 unmanageable)
- Clear content bucket mapping
- Validated 6-dimension vectors per archetype

**Unblocks:**
- F-06 (archetype_templates table)
- F-13 (habit templates)
- F-14 (archetype content)

---

### PD-122: User Visibility of Preference Embedding

| Field | Value |
|-------|-------|
| **Question** | Should users be able to see and/or modify their learned preference embedding? |
| **Status** | ✅ RESOLVED |
| **Decision** | **Option A: Hidden** — 768-dim vectors are noise to users |
| **Date** | 10 January 2026 |
| **Source** | RQ-030 ✅ COMPLETE |

**Decision Details:**

User visibility rejected because:
- 768-dimensional vectors are meaningless to end users
- Rocchio algorithm + Trinity Anchor handles drift prevention automatically
- "Taste Tags" (human-readable labels) can be shown in future if transparency needed

**Implementation:**
- preference_embedding stored but not exposed in UI
- Trinity Seed (Day 1 anchor) acts as aspiration checkpoint
- Alpha values configurable for tuning without user intervention

**Unblocks:**
- F-11 (feedback signal tracking)

---

### PD-123: Facet Typical Energy State Field

| Field | Value |
|-------|-------|
| **Question** | Should we add `typical_energy_state` to facets to enable energy gating? |
| **Status** | ✅ RESOLVED |
| **Decision** | **Option A: Explicit field** — with CD-015 4-state enum constraint |
| **Date** | 10 January 2026 |
| **Source** | Deep Think Phase 2 Reconciliation |

**Decision Details:**

Add `typical_energy_state` field to enable JITAI to spot Energy Mismatches (e.g., Focus work recommended during Recovery time).

**Implementation:**
```sql
ALTER TABLE identity_facets
ADD COLUMN typical_energy_state TEXT
CHECK (typical_energy_state IN ('high_focus', 'high_physical', 'social', 'recovery'));
```

**Constraint:** Must use CD-015 4-state enum (NOT 5-state).

**Unblocks:**
- Energy Gating implementation
- RQ-014 integration

---

### PD-124: Recommendation Card Staleness Handling

| Field | Value |
|-------|-------|
| **Question** | How do we handle Architect-generated cards that haven't been shown for days? |
| **Status** | ✅ RESOLVED |
| **Decision** | **Option B: 7-day TTL** — context rots; stale cards are likely irrelevant |
| **Date** | 10 January 2026 |
| **Source** | Deep Think Phase 2 Reconciliation |

**Decision Details:**

Cards generated by the Architect expire after 7 days if not shown:
- User context changes over a week (energy, priorities, facet activity)
- Prevents showing outdated recommendations
- Simple implementation, reasonable freshness guarantee

**Implementation:**
- Add `created_at` timestamp to recommendation cards
- Filter `WHERE created_at > NOW() - INTERVAL '7 days'`
- Expired cards silently dropped (no regeneration cost — only shown if user re-qualifies)

**Unblocks:**
- F-10 (Architect scheduler)
- content_queue schema design

---

### PD-125: Content Library Size at Launch

| Field | Value |
|-------|-------|
| **Question** | How many universal habit templates should we launch with? |
| **Status** | ✅ RESOLVED |
| **Decision** | 50 habits at launch, with caveat to expand to 100 post-launch based on user feedback |
| **Date** | 10 January 2026 |
| **Generated By** | RQ-005/006/007 Deep Analysis (10 Jan 2026) |

**Context:**
DeepSeek recommended 100-200 habits for full coverage. The Two-Stage Hybrid Retrieval requires each habit to have BOTH semantic (768-dim) AND psychometric (6-dim) embeddings, creating significant content creation burden.

**Options Evaluated:**

| Option | Habits | Templates | Effort | Ship Speed |
|--------|--------|-----------|--------|------------|
| **A** (Chosen) | 50 | 12 | Low | Fast |
| **B** | 100 | 24 | Medium | Moderate |
| **C** | 200+ | 48 | High | Slow |

**Decision Rationale:**
- **Ship fast, iterate based on feedback** — 50 habits is sufficient for MVP
- **Caveat:** Expand to 100 post-launch once user patterns reveal gaps
- **Dual embedding burden** makes 100+ habits a significant content effort
- Better to ship with quality curation than broad but shallow coverage

**Impact:**
- Resolves: IMPACT_ANALYSIS.md content library size blocker
- Updates: F-13 task scope (50 habits, not 100)

---

## Proposed Approaches (Awaiting Validation)

### PA-001: Dynamic Archetype Model
**Status:** Proposed, not validated against codebase

```dart
class DynamicArchetype {
  final String primaryLabel;           // AI-generated
  final double confidence;             // 0.0-1.0
  final List<String> traits;           // Extracted from Sherlock
  final String rawTranscript;          // For future refinement
  final DateTime extractedAt;

  bool get isConfident => confidence > 0.7;
  bool get needsRefinement => confidence < 0.5;
}
```

**Concerns:**
- May be too simplistic
- Need to reconcile against entire codebase
- Future sprint required for proper specification

---

### PA-002: Lexicon / Power Words Feature
**Status:** Spec exists in archive (LEXICON_SPEC.md), never implemented

**Concept:** A vocabulary builder where users collect "Power Words" that reinforce their identity.

**Example:** User identifies as "Stoic" → collects words like "Antifragile", "Equanimity"

**Questions:**
1. Is this a core feature or nice-to-have?
2. How does it integrate with coaching?
3. What's the AI role (enrich word meanings)?

---

## Rejected Options

### RO-001: Conversational CLI for Users
**Rejected:** January 2026
**Reason:** Developer-style interface is incongruent with consumer wellness app.

### RO-002: Keyword-Based Sensitivity Detection
**Rejected:** January 2026
**Reason:** Too simplistic — individual subjectivity means hardcoded keywords don't work.

---

## Future Sprint Requirements

The following need dedicated sprints to resolve properly:

| Sprint Topic | Blocking Decisions | Estimated Complexity |
|--------------|-------------------|---------------------|
| Archetype Philosophy | PD-001 | High — affects entire coaching system |
| Sherlock Prompt Overhaul | PD-101 | High — affects onboarding UX |
| JITAI Documentation & Review | PD-102 | Medium — needs best practice research |
| Aspirational Features Reconciliation | N/A | Medium — audit + prioritize |
| Core Docs Accuracy Audit | N/A | Low — systematic verification |
| **Documentation Archiving Strategy** | N/A | Medium — infrastructure sprint |

### Future Sprint: Documentation Archiving Strategy

**Context:** PRODUCT_DECISIONS.md and RESEARCH_QUESTIONS.md both exceed Claude Code's 25,000 token read limit (currently ~35,000 tokens combined). This causes context fragmentation and requires pagination to read.

**Deferred Solution: Structured Archiving (Option A)**

When file sizes become unmanageable, implement the following structure:

```
docs/CORE/
├── PRODUCT_DECISIONS.md           ← Active CDs + PDs only
├── RESEARCH_QUESTIONS.md          ← Active RQs only
├── archive/
│   ├── decisions/
│   │   └── 2026-Q1-resolved.md    ← Resolved CDs/PDs (quarterly)
│   └── research/
│       └── 2026-Q1-complete.md    ← Completed RQs (quarterly)
└── index/
    ├── CD_INDEX.md                ← Cross-reference all CDs
    ├── PD_INDEX.md                ← Cross-reference all PDs
    └── RQ_INDEX.md                ← Cross-reference all RQs
```

**Benefits:**
- Main files stay under token limits
- Full history preserved in archives
- Index files enable quick lookup
- Quarterly batching reduces file churn

**Migration Process:**
1. Create `archive/` and `index/` directories
2. Move all RESOLVED/COMPLETE items to quarterly archives
3. Generate index files with: ID, Title, Status, File Location
4. Update cross-references to use index lookups
5. Add "Archive Location" field to resolved items

**Trigger Criteria:**
- When PRODUCT_DECISIONS.md exceeds 30,000 tokens
- When RESEARCH_QUESTIONS.md exceeds 40,000 tokens
- When reading full files requires >3 paginated reads

**Status:** 🔴 DEFERRED — Not blocking current work. Implement when token limits cause productivity loss.

---

## How Decisions Get Made

1. **Proposal:** Anyone can propose a decision in this doc
2. **Discussion:** Tag as PENDING, list options and questions
3. **Human Input:** Product owner (Oliver) resolves PENDING items
4. **Confirmation:** Move to CONFIRMED with date and rationale
5. **Implementation:** Engineering implements confirmed decisions

**Rule:** Do NOT implement PENDING decisions. Wait for confirmation.
