# AI_AGENT_PROTOCOL.md — Mandatory Behaviors for AI Agents

> **Last Updated:** 05 January 2026
> **Purpose:** Codify reflexive behaviors that ALL AI agents must exhibit
> **Scope:** Claude, Gemini, ChatGPT, any future AI agents working on The Pact

---

## Why This Document Exists

AI agents are powerful but lack instinctive awareness of system-wide impacts. This document defines **mandatory reflexive behaviors** that must be performed automatically, without being asked.

---

## Decision Flow Diagram (Reasoning Order)

**All decisions flow through this hierarchy. Never skip levels.**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           LEVEL 0: CONTEXT ACQUISITION                        │
│                                                                              │
│  Before ANY decision, read in this order:                                    │
│  1. AI_HANDOVER.md (what was done)                                          │
│  2. PRODUCT_DECISIONS.md (what's decided/pending)                           │
│  3. RESEARCH_QUESTIONS.md (what's being researched)                         │
│  4. GLOSSARY.md (terminology = shared vocabulary)                           │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LEVEL 1: DECISION CLASSIFICATION                      │
│                                                                              │
│  What type of decision is this?                                             │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐          │
│  │   PHILOSOPHY    │    │    DIRECTION    │    │ IMPLEMENTATION  │          │
│  │  (Why we do X)  │    │ (What we build) │    │   (How we do)   │          │
│  │                 │    │                 │    │                 │          │
│  │ → Needs human   │    │ → Derived from  │    │ → Agent can     │          │
│  │   confirmation  │    │   philosophy    │    │   decide        │          │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘          │
│         ↓                      ↓                      ↓                      │
│  Log in PRODUCT_       Update ROADMAP.md      Execute + Document            │
│  DECISIONS.md as                                                            │
│  PENDING                                                                     │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LEVEL 2: DEPENDENCY CHECK                             │
│                                                                              │
│  Does this decision depend on another?                                       │
│                                                                              │
│  YES → Find the upstream decision                                            │
│      → Is it CONFIRMED? → Proceed                                            │
│      → Is it PENDING? → STOP. Document dependency. Wait for human.          │
│      → Does it need RESEARCH? → Add to RESEARCH_QUESTIONS.md                │
│                                                                              │
│  NO → Proceed to Level 3                                                     │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LEVEL 3: IMPACT ANALYSIS                              │
│                                                                              │
│  What does this decision affect?                                             │
│                                                                              │
│  CHECK EACH LAYER:                                                           │
│  □ Layer 1 (Evidence Engine) — Database/schema changes?                      │
│  □ Layer 2 (Sherlock) — Onboarding extraction changes?                       │
│  □ Layer 3 (Living Garden) — UI visualization changes?                       │
│  □ Layer 4 (CLI) — Interaction pattern changes?                              │
│  □ Layer 5 (Brain) — AI analysis changes?                                    │
│  □ JITAI — Intervention timing/content changes?                              │
│  □ Identity Coach — Recommendation logic changes?                            │
│  □ Content Library — New message variants needed?                            │
│                                                                              │
│  → Document ALL impacts in IMPACT_ANALYSIS.md                                │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LEVEL 4: EXECUTE + DOCUMENT                           │
│                                                                              │
│  1. Make it work (functionality first)                                       │
│  2. Make it right (refactor after working)                                   │
│  3. Make it documented (update relevant docs)                                │
│  4. Make it committed (atomic commits, clear messages)                       │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Decision Type Quick Reference:**

| Decision Type | Example | Who Decides | Document |
|--------------|---------|-------------|----------|
| Philosophy | "Should archetypes be dynamic?" | Human | PRODUCT_DECISIONS.md |
| Direction | "Add Social Leaderboard to MVP" | Human + Agent | ROADMAP.md |
| Implementation | "Use Thompson Sampling for bandit" | Agent | Code + AI_CONTEXT.md |
| Terminology | "What is an 'Identity Seed'?" | Define first | GLOSSARY.md |

---

## Protocol 1: Research-to-Roadmap Cascade (MANDATORY)

### Trigger
Whenever research concludes OR a product decision is made.

### Action
1. **Read** `ROADMAP.md` and `docs/CORE/PRODUCT_DECISIONS.md`
2. **Analyze** every roadmap item for potential impact
3. **Update** `docs/CORE/IMPACT_ANALYSIS.md` with:
   - Which roadmap items are affected
   - What new questions arise
   - What dependencies change
4. **Log** follow-up research points
5. **Surface** gaps in current roadmap

### Rationale
Each decision has upstream and downstream consequences. A change to archetypes affects JITAI, coaching, analytics, UI, and content. Without systematic tracing, implications are lost.

### Example
```
Research: 6-dimension model replaces 6 hardcoded archetypes

Impact Analysis:
- Layer 2 (Sherlock): Must extract dimension signals → Update prompt
- Layer 5 (Gap Analysis): Must use dimensions → Update DeepSeek context
- JITAI: Dimensions = Context Vector → Update bandit integration
- Content: Need 4 variants per framing → Content library debt identified
- UI: Garden should reflect dimensions → Rive inputs need update
- NEW GAP: No proactive recommendation engine exists
```

---

## Protocol 2: Clean Code Reconciliation (MANDATORY)

### Trigger
After implementing any functionality.

### Action
1. **Execute** the functionality fully (all features working)
2. **THEN** refactor using principles:
   - **YAGNI** (You Aren't Gonna Need It): Remove speculative code
   - **SOLID**: Single responsibility, Open/Closed, Liskov, Interface Seg, Dependency Inv
   - **DRY** (Don't Repeat Yourself): Extract duplicates
   - **KISS** (Keep It Simple, Stupid): Simplify without losing function
3. **NEVER** sacrifice functionality for principles
4. **DOCUMENT** any technical debt created

### Rationale
Product vision and functionality come first. Clean code enables maintainability but must not block features. The sequence is: **Make it work → Make it right → Make it fast**.

### Anti-Pattern (DO NOT)
```
❌ "I'll skip this feature because it violates SOLID"
❌ "Let me refactor before implementing the requirement"
❌ "This abstraction isn't clean, so I won't build it"
```

### Correct Pattern (DO)
```
✅ Implement full feature as specified
✅ Verify all functionality works
✅ THEN refactor for cleanliness
✅ Verify functionality still works after refactor
✅ Document any remaining tech debt
```

---

## Protocol 3: AI Acceleration Timeline (MANDATORY)

### Trigger
When planning or estimating work.

### Action
1. **NEVER** provide human-based time estimates ("2-3 weeks")
2. **DEFAULT** to implementing the "final version" not MVP phases
3. **ONLY** phase work when there is a genuine blocking dependency
4. **REMOVE** phrases like "we can do this later" or "future sprint"

### Rationale
AI agents can work continuously without fatigue. Traditional phased approaches assume human resource constraints that don't apply. Unless there's a true blocker (e.g., "needs social features first"), implement the complete solution.

### Exception: Genuine Blockers
```
Example: "Add Social Sensitivity as 7th dimension"
Blocker: Requires Social Leaderboard feature to exist
Action: Add Social Leaderboard to roadmap, implement both together
```

### Anti-Pattern (DO NOT)
```
❌ "Let's do MVP in Phase 1, then enhance in Phase 2"
❌ "This will take approximately 2 weeks"
❌ "We can defer this to a future sprint"
```

### Correct Pattern (DO)
```
✅ "Implementing complete solution"
✅ "Blocked by [specific dependency], adding to roadmap"
✅ "No phasing needed, building final version"
```

---

## Protocol 4: Dual-Perspective Analysis (MANDATORY)

### Trigger
When evaluating metrics, features, or decisions.

### Action
Always analyze from TWO perspectives:
1. **App Success:** What does the app need to survive/thrive?
2. **User Success:** What does the user need to achieve their goals?

### Rationale
These perspectives sometimes conflict. The app needs retention; the user needs results even if they leave. Both must be considered explicitly.

### Example
```
Metric: Retention Tracking

App Perspective:
- Need to know if interventions keep users engaged
- High retention = healthy business
- Must track to optimize

User Perspective:
- User wants to build habits, not use an app forever
- Success might mean they no longer need the app
- "Graduated" users are a success, not a failure

Decision: Track retention BUT also track "graduation rate" as a positive metric
```

---

## Protocol 5: Gap Identification (MANDATORY)

### Trigger
During any analysis or implementation.

### Action
1. **Actively seek** what's missing, not just what exists
2. **Ask:** "What capability would complete this system?"
3. **Document** gaps in `IMPACT_ANALYSIS.md`
4. **Distinguish:**
   - REACTIVE capabilities (respond to problems)
   - PROACTIVE capabilities (anticipate and recommend)

### Example
```
Current: JITAI intervenes when user is at risk
Gap: No system recommends what habits to ADD
Gap: No system suggests progression paths
Gap: No system warns of regression patterns BEFORE they happen

→ Proactive Analytics Engine needed
```

---

## Protocol 6: Content-Capability Parity (MANDATORY)

### Trigger
When building adaptive systems.

### Action
1. **Check:** Does the algorithm have content to optimize over?
2. **If NO:** Content creation is a blocker, not the algorithm

### Rationale
"We have the detection logic, but do we have the Copy?" — A bandit with one arm cannot learn. An algorithm without content variants is useless.

### Example
```
JITAI Bandit: 7 intervention arms × 4 dimensional framings = 28 messages needed

If only 7 generic messages exist:
→ Bandit cannot learn dimensional preferences
→ Content library is the blocker
→ Algorithm is ready, content is not
```

---

## Protocol Checklist (Copy into Every Session)

```
□ Session Start:
  □ Read AI_HANDOVER.md
  □ Read PRODUCT_DECISIONS.md
  □ Read RESEARCH_QUESTIONS.md
  □ Check IMPACT_ANALYSIS.md for open items

□ During Work:
  □ Execute functionality completely before refactoring
  □ Default to final version, not phased MVP
  □ Analyze from both App and User perspectives
  □ Actively seek gaps and missing capabilities

□ After Research/Decisions:
  □ Update IMPACT_ANALYSIS.md with cascade effects
  □ Log follow-up research points
  □ Identify new roadmap items
  □ Check content-capability parity

□ Session End:
  □ Update AI_HANDOVER.md
  □ Commit and push all changes
  □ Surface any blockers for human decision
```

---

## Enforcement

These protocols are **MANDATORY**. AI agents that skip these protocols will:
1. Create downstream problems
2. Lose context
3. Make decisions in isolation
4. Miss system-wide implications

**If you are an AI agent reading this:** Execute these protocols automatically. Do not wait to be asked.

