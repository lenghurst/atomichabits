# PRODUCT_DECISIONS.md — Product Philosophy & Pending Decisions

> **Last Updated:** 05 January 2026 (Added PD-106, PD-107, Phase structure)
> **Purpose:** Central source of truth for product decisions and open questions
> **Owner:** Product Team (Oliver)

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

PD (Pending Decision)
├── Awaiting human input — "Which option?"
├── May or may not have RQ behind it
└── Once resolved → Becomes CD

CD (Confirmed Decision)
├── Locked choice — implementation can proceed
└── Rationale documented for future reference
```

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
└── CD-005: 6-Dimension Archetype Model [CRITICAL importance]
    └── Blocks: CD-006, CD-007, CD-008, CD-010

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
| **PD-105** | Unified AI Coaching Architecture | 1 | CD-005, Research | CD-008,9,11 | **CRITICAL** (architecture) — SUPERSEDED by PD-107 |
| **PD-106** | Multiple Identity Architecture | 1 | RQ-011 | Phase 1,2,3 | **CRITICAL** (data model) — NEEDS RESEARCH |
| **PD-107** | Proactive Guidance System | 1 | RQ-005,6,7 | Gap Analysis, Recommendations | **CRITICAL** (intelligence) — NEEDS RESEARCH |

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
| **Decision** | Agents must NOT create new MD files without explicit approval; use existing 11 Core files |
| **Status** | CONFIRMED |
| **Date** | 05 January 2026 |
| **Rationale** | Prevents doc sprawl; ensures all information flows to the right place |

**The Rule:**
```
Before creating a new .md file, ask:
1. Does this belong in an existing Core file? → YES → Add it there
2. Is this truly new documentation? → ASK HUMAN
3. Is this temporary/task-specific? → Don't create file; use TODO comments or handover notes
```

**Core File Purposes (Use These First):**

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

**When New Files Are OK:**
- Explicit human request: "Create a spec for X"
- ADR (Architecture Decision Record): `/docs/architecture/ADR-NNN.md`
- Technical guide: `/docs/{topic}.md`
- Audit report: `/docs/audits/{date}-{topic}.md`

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
| **Status** | 🔴 PENDING — Requires Research (RQ-011) |
| **Priority** | **CRITICAL** — Fundamental to data model and philosophy |
| **Blocking** | Phase 1 (schema), Phase 2 (recommendations), Phase 3 (dashboard) |
| **Research** | RQ-011 in RESEARCH_QUESTIONS.md |

**The Core Question:**
Users have multiple aspirational identities ("Worldclass SaaS Salesman" + "Consistent Swimmer" + "Present Father"). How do we:
1. Capture them?
2. Track progress for each?
3. Handle conflicts between them?
4. Prioritize recommendations?

**Options:**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Single Identity** | Force one primary identity | Simple data model, clear focus | Limiting, doesn't reflect reality |
| **B: Multiple + Conflict Detection** | Allow multiple, AI flags conflicts | Deep reflection opportunity | Complex logic |
| **C: Multiple + User Resolves** | Allow multiple, user handles conflicts | Maximum autonomy | May overwhelm user |
| **D: Hierarchical** | Primary + secondary identities | Clear prioritization | Artificial hierarchy |

**Example Conflict:**
- Identity 1: "Early Riser" → wake 5am, morning run
- Identity 2: "Night Owl Creative" → work until 2am, sleep late
- These directly conflict — what should the app do?

**Philosophical Opportunity:**
Identity conflicts could be the app's MOST valuable coaching moments. Surfacing tension between "who I want to be" in different domains enables genuine self-reflection.

**Data Model Implications:**
```
Current: User → 1 Identity → N Habits
Option B: User → N Identities → N Habits (many-to-many?)
         Identity → Dimension Vector (per identity or composite?)
```

**Questions to Resolve:**
1. Max number of identities?
2. Can habits serve multiple identities?
3. Does each identity have its own dimension vector?
4. How does dashboard visualize multiple identities?
5. How do conflicts surface in coaching?

---

### PD-107: Proactive Guidance System Architecture
| Field | Value |
|-------|-------|
| **Question** | How should the Proactive Guidance System (PGS) be architected? |
| **Status** | 🔴 PENDING — Requires Research (RQ-005, RQ-006, RQ-007) |
| **Priority** | **CRITICAL** — Defines core intelligence architecture |
| **Blocking** | Gap Analysis Engine, Recommendation Engine, Content structure |
| **Supersedes** | Clarifies relationship between JITAI, Content Library, and Identity Coach |

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

---

## How Decisions Get Made

1. **Proposal:** Anyone can propose a decision in this doc
2. **Discussion:** Tag as PENDING, list options and questions
3. **Human Input:** Product owner (Oliver) resolves PENDING items
4. **Confirmation:** Move to CONFIRMED with date and rationale
5. **Implementation:** Engineering implements confirmed decisions

**Rule:** Do NOT implement PENDING decisions. Wait for confirmation.
