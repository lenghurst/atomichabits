# AI_AGENT_PROTOCOL.md — Mandatory Behaviors for AI Agents

> **Last Updated:** 11 January 2026
> **Purpose:** Codify reflexive behaviors that ALL AI agents must exhibit
> **Scope:** Claude, Gemini, ChatGPT, any future AI agents working on The Pact
> **Protocols:** 12 mandatory (1-9 operational, 10-12 meta-cognitive)

---

## Why This Document Exists

AI agents are powerful but lack instinctive awareness of system-wide impacts. This document defines **mandatory reflexive behaviors** that must be performed automatically, without being asked.

---

## Session Entry Protocol (Starting Work)

**Every session MUST begin with this checklist:**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        SESSION ENTRY PROTOCOL                                 │
│                                                                              │
│  STEP 1: Context Acquisition (Read in order)                                 │
│  □ CLAUDE.md — Project overview, constraints, routing                       │
│  □ AI_HANDOVER.md — What did the last agent do?                             │
│  □ index/CD_INDEX.md + index/PD_INDEX.md — Quick decision status lookup     │
│  □ index/RQ_INDEX.md — Quick research status lookup                         │
│  □ IMPLEMENTATION_ACTIONS.md — Task quick status + navigation hub           │
│  □ IMPACT_ANALYSIS.md — Cascade tracking ONLY (not task storage)            │
│  □ PRODUCT_DECISIONS.md — Full details for PENDING decisions only           │
│  □ RESEARCH_QUESTIONS.md — Master Task Tracker + ACTIVE research            │
│  □ GLOSSARY.md — What do terms mean in this codebase?                       │
│  □ AI_CONTEXT.md — What's the current architecture?                         │
│  □ ROADMAP.md — What are the current priorities?                            │
│                                                                              │
│  STEP 2: Orientation                                                         │
│  □ Identify session scope (docs? code? research? all?)                      │
│  □ Check for blockers from previous session                                  │
│  □ Verify no conflicting work in progress                                    │
│                                                                              │
│  STEP 3: Confirm with Human                                                  │
│  □ State what you understand the task to be                                 │
│  □ Identify any unclear requirements                                         │
│  □ Flag any PENDING decisions that block this work                          │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Why Entry Protocol Matters:**
- Prevents duplicate work
- Ensures awareness of blockers
- Establishes shared context with human
- Catches stale documentation early

---

## Session Exit Protocol (Ending Work / Handover)

**Every session MUST end with this checklist:**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    SESSION EXIT PROTOCOL v2 (ENHANCED)                        │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 1: ALWAYS UPDATE (Non-negotiable)                                      │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ AI_HANDOVER.md — Summarize what you did, what remains                    │
│  □ PRODUCT_DECISIONS.md — Log any new decisions/questions                   │
│  □ RESEARCH_QUESTIONS.md — Update status, propose new RQs if needed         │
│  □ ROADMAP.md — Update task status, add new items if discovered             │
│  □ IMPACT_ANALYSIS.md — Log cascade effects ONLY (not task storage)         │
│  □ index/*.md — Update quick reference tables if RQ/PD/CD status changed    │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 1.5a: IF TASKS WERE EXTRACTED OR STATUS CHANGED                        │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ IMPLEMENTATION_ACTIONS.md — Update Quick Status + Recently Added         │
│  □ RESEARCH_QUESTIONS.md → Master Tracker — Update task details             │
│  □ PRODUCT_DEVELOPMENT_SHEET.md — Update statistics                         │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 1.5b: IF EXTERNAL RESEARCH WAS PROCESSED                               │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ Protocol 9 was completed before integration                               │
│  □ Reconciliation document created in docs/analysis/                         │
│  □ ACCEPT/MODIFY/REJECT/ESCALATE documented                                  │
│  □ → IF recommendations made: Run Protocol 10 (Bias Analysis)               │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 1.5c: IF NEW RQs WERE CREATED                                          │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ → IF complex/multi-domain RQ: Run Protocol 11 (Sub-RQ Creation)          │
│  □ All parent files updated (RQ_INDEX, PRODUCT_DEV_SHEET, ROADMAP)          │
│  □ Blocking relationships documented in IMPACT_ANALYSIS.md                   │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 1.5d: IF DECISIONS WERE DEFERRED                                       │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ → Run Protocol 12 (Decision Deferral)                                    │
│  □ PD_INDEX updated with DEFERRED status                                     │
│  □ New RQ created to unblock the deferred decision                           │
│  □ MVP fallback documented                                                   │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 2: UPDATE IF RELEVANT                                                  │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ GLOSSARY.md — Add any new terms introduced                               │
│  □ AI_CONTEXT.md — Update if architecture changed OR research completed     │
│  □ IDENTITY_COACH_SPEC.md — Update if Identity Coach evolved                │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 3: VERIFICATION CHECKPOINT (MANDATORY BEFORE GIT)                      │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ Run Cross-File Consistency Check (see checklist below)                    │
│  □ Fix ANY discrepancies found BEFORE committing                             │
│  □ Verify all timestamps updated to current date                             │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 4: GIT OPERATIONS                                                      │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ Commit with clear message                                                 │
│  □ Push to branch (per CD-012)                                               │
│  □ Verify push succeeded                                                     │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIER 5: RARELY (Only when explicitly needed)                                │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  □ AI_AGENT_PROTOCOL.md — Only if behavioral rules change                   │
│  □ README.md — Only if fundamental project info changes                     │
│  □ CHANGELOG.md — Add entry summarizing session changes                     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Cross-File Consistency Checklist (Tier 3 — Mandatory)

Run this checklist BEFORE committing. **Any mismatch = MUST FIX.**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│              CROSS-FILE CONSISTENCY VERIFICATION CHECKLIST                    │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  STATISTICS VERIFICATION                                                     │
│  ═══════════════════════════════════════════════════════════════════════════ │
│                                                                              │
│  RQ Counts (must match across all files):                                    │
│  □ RQ_INDEX.md         → Total: ___ | Complete: ___ | Pending: ___          │
│  □ PRODUCT_DEV_SHEET   → Total: ___ | Complete: ___ | Pending: ___          │
│  □ AI_CONTEXT.md       → Total: ___ | Complete: ___ | Pending: ___          │
│  □ ROADMAP.md          → Total: ___ | Complete: ___ | Pending: ___          │
│  ⚠️ ALL MUST MATCH → If not, fix before commit                              │
│                                                                              │
│  PD Counts (must match across all files):                                    │
│  □ PD_INDEX.md         → Total: ___ | Resolved: ___ | Pending: ___          │
│  □ PRODUCT_DEV_SHEET   → Total: ___ | Resolved: ___ | Pending: ___          │
│  ⚠️ ALL MUST MATCH → If not, fix before commit                              │
│                                                                              │
│  Task Counts:                                                                │
│  □ IMPLEMENTATION_ACTIONS → Total tasks: ___                                 │
│  □ PRODUCT_DEV_SHEET      → Total tasks: ___                                 │
│  ⚠️ MUST MATCH → If not, fix before commit                                  │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  CROSS-REFERENCE VERIFICATION                                                │
│  ═══════════════════════════════════════════════════════════════════════════ │
│                                                                              │
│  For each NEW or CHANGED RQ this session:                                    │
│  □ Listed in RQ_INDEX.md?                                                    │
│  □ Listed in RESEARCH_QUESTIONS.md (if active)?                              │
│  □ Listed in PRODUCT_DEV_SHEET Section 2?                                    │
│  □ Listed in AI_HANDOVER.md session summary?                                 │
│  □ If blocking a PD: PD_INDEX updated?                                       │
│  □ If blocking tasks: IMPLEMENTATION_ACTIONS updated?                        │
│                                                                              │
│  For each NEW or CHANGED PD this session:                                    │
│  □ Listed in PD_INDEX.md?                                                    │
│  □ Listed in PRODUCT_DECISIONS.md?                                           │
│  □ Listed in PRODUCT_DEV_SHEET Section 3?                                    │
│  □ If status changed: All references updated?                                │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  TIMESTAMP VERIFICATION                                                      │
│  ═══════════════════════════════════════════════════════════════════════════ │
│                                                                              │
│  Files that MUST show today's date if modified:                              │
│  □ AI_HANDOVER.md      → Date: ___                                          │
│  □ RQ_INDEX.md         → Date: ___                                          │
│  □ PD_INDEX.md         → Date: ___                                          │
│  □ CD_INDEX.md         → Date: ___ (if CDs changed)                         │
│  □ IMPLEMENTATION_ACTIONS → Date: ___                                        │
│  □ PRODUCT_DEV_SHEET   → Date: ___                                          │
│                                                                              │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  FINAL VERIFICATION                                                          │
│  ═══════════════════════════════════════════════════════════════════════════ │
│                                                                              │
│  □ All mismatches fixed?                                                     │
│  □ All timestamps current?                                                   │
│  □ All cross-references valid?                                               │
│  □ Ready to commit?                                                          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Key Difference: Entry vs Exit:**

| Entry Protocol | Exit Protocol |
|----------------|---------------|
| **READ** to understand context | **WRITE** to preserve context |
| Check for blockers | Document new blockers |
| Understand terminology | Add new terminology |
| Learn what's decided | Record new decisions |
| Verify architecture | Update architecture if changed |

---

## Research Trigger Protocol (When to Propose New Research)

**An agent MUST propose new research when:**

```
RESEARCH TRIGGERS:
1. UNCERTAINTY — "I don't know the best way to implement X"
   → Propose RQ: "What is best practice for X?"

2. TRADE-OFFS — "There are multiple valid approaches with unclear pros/cons"
   → Propose RQ: "What are the trade-offs between A, B, C?"

3. EXTERNAL VALIDATION — "This assumption hasn't been tested against literature"
   → Propose RQ: "Does research support assumption X?"

4. TECHNOLOGY CHANGE — "There may be a better/newer way to do this"
   → Propose RQ: "Has the API/framework evolved? Is there a better approach?"

5. FOUNDATIONAL QUESTION — "This affects many downstream decisions"
   → Propose RQ with CRITICAL priority and blocking dependencies
```

**Research Proposal Format:**
```markdown
### RQ-XXX: [Title]
| Field | Value |
|-------|-------|
| **Question** | What specific question needs answering? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | LOW / MEDIUM / HIGH / CRITICAL |
| **Blocking** | What decisions/tasks are blocked by this? |
| **Assigned** | Which agent type should research this? |
| **Trigger** | What prompted this research need? |
```

**After Proposing Research:**
1. Add to RESEARCH_QUESTIONS.md
2. Update IMPACT_ANALYSIS.md with blocking dependencies
3. Flag to human that research is needed before proceeding

---

## Decision Flow Diagram (Reasoning Order)

**All decisions flow through this hierarchy. Never skip levels.**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LEVEL 1: DECISION CLASSIFICATION                      │
│                                                                              │
│  What type of decision is this?                                             │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐          │
│  │   PHILOSOPHY    │    │    DIRECTION    │    │ IMPLEMENTATION  │          │
│  │  (Why we do X)  │    │ (What we build) │    │   (How we do)   │          │
│  │                 │    │                 │    │                 │          │
│  │ → Needs human   │    │ → Needs human   │    │ → Agent can     │          │
│  │   confirmation  │    │   confirmation  │    │   recommend     │          │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘          │
│         ↓                      ↓                      ↓                      │
│  Log in PRODUCT_       Update ROADMAP.md      Search web for                │
│  DECISIONS.md as       with human approval    best practices,               │
│  PENDING                                      propose approach               │
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
│      → Does it need RESEARCH? → Trigger Research Protocol                   │
│                                                                              │
│  NO → Proceed to Level 3                                                     │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LEVEL 3: IMPACT ANALYSIS                              │
│                                                                              │
│  What does this decision affect?                                             │
│                                                                              │
│  CHECK EACH SYSTEM:                                                          │
│  □ Evidence Engine — Database/schema changes?                                │
│  □ Sherlock (Onboarding) — Extraction/prompt changes?                        │
│  □ JITAI (Reactive) — Intervention timing/arm changes?                       │
│  □ Identity Coach (Proactive) — Recommendation logic changes?                │
│  □ Content Library — New message variants needed?                            │
│  □ Dashboard/UI — User-facing changes?                                       │
│                                                                              │
│  → Document ALL impacts in IMPACT_ANALYSIS.md                                │
└──────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LEVEL 4: IMPLEMENTATION APPROACH                      │
│                                                                              │
│  For IMPLEMENTATION decisions, the agent MUST:                               │
│                                                                              │
│  1. Search the web for current best practices                                │
│     → APIs evolve rapidly (Gemini, Firebase, etc.)                          │
│     → New patterns may exist since last knowledge update                    │
│                                                                              │
│  2. Present options to human with trade-offs                                 │
│     → Don't just pick one; explain alternatives                             │
│                                                                              │
│  3. If uncertain, trigger Research Protocol                                  │
│     → Better to research than guess                                         │
│                                                                              │
│  4. Execute with verification                                                │
│     → Test before committing                                                │
│     → Run linters/tests                                                     │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Decision Type Quick Reference:**

| Decision Type | Example | Who Decides | Document |
|--------------|---------|-------------|----------|
| Philosophy | "Should archetypes be dynamic?" | Human only | PRODUCT_DECISIONS.md |
| Direction | "Add Social Leaderboard to MVP" | Human (agent proposes) | ROADMAP.md |
| Implementation | "Use Thompson Sampling for bandit" | Agent recommends, human approves | Code + AI_CONTEXT.md |
| Terminology | "What is an 'Identity Seed'?" | Define before using | GLOSSARY.md |

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

## Protocol 2: Context-Adaptive Development (MANDATORY)

> **Updated:** 10 January 2026 — Replaced "Make it Work → Right" with task-specific approach per RQ-008/RQ-009 research

### Trigger
Before starting any coding task.

### Action

**Step 1: CLASSIFY the task**

| Task Type | Examples | Strategy |
|-----------|----------|----------|
| **Logic Task** | New feature, data model, algorithm, state management | → CONTRACT-FIRST |
| **Visual Task** | Styling, animations, layout, UI polish | → VIBE CODING |

**Step 2: Execute appropriate strategy**

#### For LOGIC TASKS → Contract-First
```
1. Define State class and Controller interface FIRST
2. Implement logic methods
3. Write unit tests
4. THEN build UI that consumes the Controller
5. Apply clean code principles (YAGNI, SOLID, DRY, KISS)
```

#### For VISUAL TASKS → Vibe Coding
```
1. Iterate rapidly on the UI
2. NEVER introduce business logic into Widget tree
3. Only consume existing Controllers/State
4. Safe to regenerate UI multiple times until it "feels right"
5. Refactor for cleanliness after visual approval
```

**Step 3: VERIFY separation**
```
□ No repository/service imports in UI files
□ No domain entity conditionals in Widget build()
□ All "IF" business decisions are in Logic Layer
□ Animation TRIGGERS are state flags, not inline checks
```

### Boundary Decision Tree

```
WHERE DOES THIS CODE BELONG?
            │
            ▼
┌───────────────────────────────────────────┐
│ Does it decide IF something happens?      │
│ (e.g., "User must be premium")            │
└───────────────────────────────────────────┘
     YES │                    │ NO
         ▼                    ▼
   ┌──────────┐    ┌──────────────────────┐
   │  LOGIC   │    │ Does it transform    │
   │  LAYER   │    │ data? (date→string)  │
   └──────────┘    └──────────────────────┘
                        YES │         │ NO
                            ▼         ▼
                      ┌──────────┐  Animation?
                      │  LOGIC   │  TRIGGER→Logic
                      │ (getter) │  EXECUTION→UI
                      └──────────┘
```

### Rationale
Different tasks require different approaches. Logic tasks benefit from upfront planning ("Contract-First") to anchor AI output. Visual tasks benefit from rapid iteration ("Vibe Coding") enabled by strict separation.

**Key Insight:** Constraint Enables Creativity. By locking business logic in a "Safety Sandbox" that AI cannot modify during UI tasks, we enable fearless UI iteration.

### Anti-Pattern (DO NOT)
```
❌ Putting business conditionals in Widget build methods
❌ Importing repositories/services into UI files
❌ Using "if (streak == 7)" directly in onTap handlers
❌ Treating all tasks the same way
```

### Correct Pattern (DO)
```
✅ Logic emits state flag: state.copyWith(sideEffect: .celebrate)
✅ UI listens and triggers: ref.listen(...) { _confettiController.play() }
✅ Logic Task: Define interface → Implement → Test → Build UI
✅ Visual Task: Iterate UI rapidly, consuming existing state
```

### Example: Celebration Animation

**❌ WRONG (Logic in UI):**
```dart
onTap: () {
  if (habit.streak + 1 == 7) {  // Business logic in UI!
    _confettiController.play();
  }
  provider.complete(habit);
}
```

**✅ CORRECT (Separated):**
```dart
// Logic Layer (Controller)
void completeHabit(Habit habit) {
  final newStreak = habit.streak + 1;
  state = state.copyWith(
    sideEffect: newStreak % 7 == 0 ? HabitSideEffect.celebrate : null,
  );
  _repo.save(habit.copyWith(streak: newStreak));
}

// UI Layer (Widget)
ref.listen(controller, (prev, next) {
  if (next.sideEffect == HabitSideEffect.celebrate) {
    _confettiController.play();  // AI can change to fireworks safely
    controller.consumeSideEffect();
  }
});
```

### Reference
- Full specification: `docs/analysis/DEEP_THINK_RECONCILIATION_RQ008_RQ009.md`
- Glossary terms: Vibe Coding, Contract-First, Safety Sandbox, Logic Leakage

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

□ Before Finalizing Recommendations:
  □ Run Protocol 10 (Bias Analysis) for product-affecting recommendations
  □ If 4+ LOW assumptions → Defer via Protocol 12
  □ If complex RQ needed → Decompose via Protocol 11

□ Session End:
  □ Run Tier 3 Cross-File Consistency Check
  □ Fix any mismatches before committing
  □ Update AI_HANDOVER.md
  □ Commit and push all changes
  □ Surface any blockers for human decision
```

---

## Protocol 7: Deep Think Prompt Quality (MANDATORY)

### Trigger
When preparing prompts for external AI research tools (Google Deep Think, Claude Projects, ChatGPT Canvas, etc.).

### Action
1. **READ** `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md` before writing ANY prompt
2. **USE** the mandatory prompt template from that document
3. **VERIFY** all checklist items before sending
4. **PROCESS** responses using the Post-Response Processing protocol

### Rationale
External AI research output quality is directly proportional to prompt quality. A poorly structured prompt yields vague, unimplementable research. A well-structured prompt yields actionable specifications.

### Key Requirements
| Requirement | Why |
|-------------|-----|
| **Expert Role** | Establishes domain authority |
| **Processing Order** | Ensures interdependent RQs solved correctly |
| **Anti-Patterns** | Prevents known mistakes |
| **Confidence Levels** | Enables follow-up research triage |
| **Concrete Scenarios** | Grounds abstract requirements |
| **Example Output** | Sets quality bar |

### Post-Response Processing (CRITICAL)
After receiving Deep Think output:

```
1. EXTRACT implementation tasks → Add to Master Implementation Tracker
2. UPDATE RQ status → Mark COMPLETE with findings
3. DEDUPLICATE → Check for existing similar tasks
4. CREATE follow-up RQs → For MEDIUM/LOW confidence items
5. UPDATE dependencies → IMPACT_ANALYSIS.md
```

### Anti-Pattern (DO NOT)
```
❌ Send prompts without expert role definition
❌ Send prompts without processing order for multiple RQs
❌ Send prompts without anti-patterns section
❌ Receive responses without extracting implementation tasks
❌ Add tasks without checking for duplicates
```

### Correct Pattern (DO)
```
✅ Read DEEP_THINK_PROMPT_GUIDANCE.md first
✅ Use mandatory template structure
✅ Include concrete user scenarios
✅ Request confidence levels
✅ Process response with full extraction protocol
```

**Reference:** `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md`

---

## Protocol 8: Task Extraction & Deduplication (MANDATORY)

### Trigger
When completing research (RQ) or resolving a product decision (PD).

### Canonical Locations
| Document | Purpose |
|----------|---------|
| **RESEARCH_QUESTIONS.md** | Master Implementation Tracker (detailed task tables) |
| **IMPLEMENTATION_ACTIONS.md** | Quick status + audit trail (cross-reference layer) |
| **IMPACT_ANALYSIS.md** | CASCADE analysis only — does NOT store tasks |

**CRITICAL:** Tasks MUST be added to RESEARCH_QUESTIONS.md Master Tracker. IMPACT_ANALYSIS.md references tasks but does NOT define them.

### Action
1. **EXTRACT** all actionable tasks from the research output
2. **SEARCH** existing Master Implementation Tracker for duplicates
3. **MERGE** if similar task exists (don't create duplicate)
4. **CREATE** new task only if truly novel
5. **LINK** task to source (RQ-XXX or PD-XXX)
6. **UPDATE** IMPLEMENTATION_ACTIONS.md Quick Status section

### Deduplication Rules
| Scenario | Action |
|----------|--------|
| Exact same task exists | Skip (already tracked) |
| Similar task exists | Update existing with new details |
| Task extends existing | Add as sub-task or update scope |
| Truly new task | Create with proper source linkage |

### Task ID Convention
```
Phase-Number format:
A-01, A-02, ... (Schema Foundation)
B-01, B-02, ... (Intelligence Layer)
C-01, C-02, ... (Council AI System)
D-01, D-02, ... (UX & Frontend)
E-01, E-02, ... (Polish & Advanced)
F-01, F-02, ... (Identity Coach System)
```

### Required Task Fields
| Field | Required | Description |
|-------|----------|-------------|
| ID | ✅ | Phase-Number (e.g., C-04) |
| Task | ✅ | Clear action description |
| Priority | ✅ | CRITICAL/HIGH/MEDIUM/LOW |
| Status | ✅ | 🔴/🟡/✅ |
| Source | ✅ | RQ-XXX or PD-XXX that generated it |
| Component | ✅ | Database/Service/Screen/etc. |
| AI Model | Optional | If task requires specific model |

### Anti-Pattern (DO NOT)
```
❌ Complete RQ without extracting tasks
❌ Add tasks without checking for duplicates
❌ Create tasks without source linkage
❌ Use free-form task IDs
❌ Add RQ to RQ_INDEX.md without adding to RESEARCH_QUESTIONS.md (see Protocol 8.5)
```

---

## Protocol 8.5: RQ Consistency Enforcement (MANDATORY)

> **Added:** 12 January 2026
> **Reason:** Parallel sessions created 8 RQs (RQ-039 to RQ-046) that were added to RQ_INDEX.md but NOT to RESEARCH_QUESTIONS.md, breaking the Research → Implementation dataflow.

### Trigger
When creating ANY new Research Question (RQ).

### Why This Protocol Exists
RQs must exist in **TWO canonical locations** to enable proper task extraction:

| Location | Purpose | What Happens If Missing |
|----------|---------|------------------------|
| `RQ_INDEX.md` | Quick reference, status tracking | Agents don't see research exists |
| `RESEARCH_QUESTIONS.md` | **Full definition**, task extraction source | Tasks cannot be extracted, implementation blocked |

**Without both:** The Research → Implementation dataflow breaks.

### The Single Source of Truth Sync Rule

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    RQ CREATION CHECKLIST (MANDATORY)                          │
│                                                                              │
│  BEFORE creating a new RQ:                                                    │
│  □ Check RQ_INDEX.md for next available number                               │
│  □ Check RESEARCH_QUESTIONS.md to confirm number not used                    │
│                                                                              │
│  AFTER deciding on RQ content:                                               │
│  □ Add FULL definition to RESEARCH_QUESTIONS.md FIRST                        │
│     ├── Question, Status, Priority, Blocking fields                          │
│     ├── Context section                                                      │
│     ├── Sub-Questions (if Protocol 11 applies)                               │
│     └── Code References (if applicable)                                      │
│                                                                              │
│  □ Add entry to RQ_INDEX.md SECOND                                           │
│     ├── Main RQ row                                                          │
│     └── Sub-RQ rows (if any)                                                 │
│                                                                              │
│  □ Update RQ_INDEX.md Statistics section                                     │
│  □ Update RQ_INDEX.md Dependency Chain (if RQ has dependencies)              │
│                                                                              │
│  VERIFICATION:                                                               │
│  □ grep "RQ-XXX" docs/CORE/RESEARCH_QUESTIONS.md → Should find definition    │
│  □ grep "RQ-XXX" docs/CORE/index/RQ_INDEX.md → Should find entry             │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Anti-Pattern (DO NOT)
```
❌ Add RQ to RQ_INDEX.md only (index without definition)
❌ Add RQ to domain file only (e.g., WITNESS_INTELLIGENCE_LAYER.md) without RESEARCH_QUESTIONS.md
❌ Create sub-RQs without parent RQ definition
❌ Skip updating RQ_INDEX.md statistics
```

### Session Exit Verification

Before ending ANY session that created new RQs, verify:

```bash
# Count RQs in both files (should match)
grep -c "^### RQ-" docs/CORE/RESEARCH_QUESTIONS.md
grep -c "^\| \*\*RQ-0[0-4][0-9]\*\*" docs/CORE/index/RQ_INDEX.md

# If counts differ, investigate and fix before session end
```

### Recovery Procedure

If you discover RQs exist in RQ_INDEX.md but NOT in RESEARCH_QUESTIONS.md:

1. **STOP** current work
2. **IDENTIFY** all missing RQ definitions
3. **LOCATE** source of definitions (domain files, analysis docs, prompts)
4. **ADD** full definitions to RESEARCH_QUESTIONS.md
5. **RUN** Protocol 8 (Task Extraction) for each added RQ
6. **DOCUMENT** the gap in AI_HANDOVER.md
7. **RESUME** original work

---

## Protocol 9: External Research Reconciliation (MANDATORY)

### Trigger
When integrating research outputs from external AI tools (Google Deep Think, Claude Projects, ChatGPT Canvas, Gemini, or any external research session).

### Why This Protocol Exists
External AI tools produce valuable conceptual insights but lack access to:
1. **Locked Decisions (CDs)** — They may propose changes to confirmed architecture
2. **Codebase Reality** — They assume data/APIs that don't exist
3. **Platform Constraints** — They don't know Android-first strategy or permission realities
4. **Existing Implementation** — They may duplicate or conflict with existing tasks

Without reconciliation, external research drifts from implementable reality.

### Action: The Reconciliation Checklist

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    EXTERNAL RESEARCH RECONCILIATION CHECKLIST                 │
│                                                                              │
│  PHASE 1: LOCKED DECISION AUDIT                                              │
│  ─────────────────────────────────────────────────────────────────────────── │
│  □ Read index/CD_INDEX.md — List all CONFIRMED decisions                     │
│  □ For EACH proposal in research output:                                     │
│    □ Does it CHANGE a confirmed CD? → Flag as CONFLICT                       │
│    □ Does it EXTEND a confirmed CD? → Flag for ESCALATION                    │
│    □ Does it BUILD ON a confirmed CD? → Mark as COMPATIBLE                   │
│  □ Document conflicts:                                                       │
│    │ Proposal         │ Conflicts With │ Resolution                    │     │
│    │─────────────────────────────────────────────────────────────────────│   │
│    │ [e.g., 5-state]  │ CD-015 (4-state)│ REJECT / ESCALATE / MODIFY   │     │
│                                                                              │
│  PHASE 2: DATA REALITY AUDIT                                                 │
│  ─────────────────────────────────────────────────────────────────────────── │
│  □ List ALL data points the research assumes exist                           │
│  □ For EACH data point:                                                      │
│    □ Is it available on Android? (Primary platform)                          │
│    □ What permission does it require?                                        │
│    □ What is the battery impact?                                             │
│    □ Is it real-time or batched?                                             │
│  □ Categorize each data point:                                               │
│    │ Data Point       │ Android Status │ Permission    │ Action            │ │
│    │─────────────────────────────────────────────────────────────────────│   │
│    │ heartRate        │ Conditional    │ Health Connect│ DEFER (not MVP)   │ │
│    │ stepsLast30Min   │ Available      │ Fitness       │ INCLUDE           │ │
│    │ appCategory      │ Available      │ UsageStats    │ INCLUDE           │ │
│                                                                              │
│  PHASE 3: IMPLEMENTATION REALITY AUDIT                                       │
│  ─────────────────────────────────────────────────────────────────────────── │
│  □ Does the proposal require new tables? → Check against existing schema     │
│  □ Does the proposal require new services? → Check against existing code     │
│  □ Does the proposal duplicate existing functionality?                       │
│  □ Does the proposal conflict with existing architecture?                    │
│  □ Document implementation gaps:                                             │
│    │ Proposal         │ Requires       │ Exists?       │ Gap               │ │
│    │─────────────────────────────────────────────────────────────────────│   │
│                                                                              │
│  PHASE 3.5: SCHEMA REALITY CHECK (MANDATORY)                                 │
│  ─────────────────────────────────────────────────────────────────────────── │
│  □ VERIFY tables exist in supabase/migrations/ (don't assume!)               │
│  □ Run: grep -r "table_name" supabase/migrations/                            │
│  □ For EACH referenced table, confirm:                                       │
│    │ Table            │ Exists?        │ Migration File │ Blocker          │ │
│    │─────────────────────────────────────────────────────────────────────│   │
│    │ identity_facets  │ YES/NO         │ filename.sql   │ Phase A          │ │
│  □ If table DOES NOT EXIST:                                                  │
│    → Mark dependent tasks as 🔴 BLOCKED (not NOT STARTED)                   │
│    → Document the dependency chain                                           │
│    → Identify which Phase must complete first                                │
│  □ Check for 0-byte placeholder files (assets/sounds/, etc.)                 │
│                                                                              │
│  PHASE 4: SCOPE & COMPLEXITY AUDIT                                           │
│  ─────────────────────────────────────────────────────────────────────────── │
│  □ Does this ANSWER the RQ, or EXPAND scope?                                 │
│  □ Does it introduce NEW concepts not in the original prompt?                │
│  □ Apply the "Android-First Threshold" test (see below)                      │
│  □ Rate complexity: ESSENTIAL / VALUABLE / NICE-TO-HAVE / OVER-ENGINEERED   │
│  □ Document scope expansions for human review                                │
│                                                                              │
│  PHASE 5: EXTRACT / MODIFY / REJECT DECISION                                 │
│  ─────────────────────────────────────────────────────────────────────────── │
│  For EACH proposal in the research output, assign ONE category:              │
│                                                                              │
│  ✅ ACCEPT — No conflicts, data available, implementable as-is               │
│  🟡 MODIFY — Good concept, needs adjustment for reality                      │
│  🔴 REJECT — Conflicts with locked CD or requires unavailable data           │
│  ⚠️ ESCALATE — Proposes change to confirmed decision (human required)        │
│                                                                              │
│  PHASE 6: INTEGRATION                                                        │
│  ─────────────────────────────────────────────────────────────────────────── │
│  □ For ACCEPT items: Integrate directly into relevant RQ/PD                  │
│  □ For MODIFY items: Document the adjustment and integrate                   │
│  □ For REJECT items: Document WHY rejected for future reference              │
│  □ For ESCALATE items: Create PD-XXX for human decision                      │
│  □ Run Protocol 8 (Task Extraction) on all ACCEPT/MODIFY items               │
│  □ Update AI_HANDOVER.md with reconciliation summary                         │
└──────────────────────────────────────────────────────────────────────────────┘
```

### The Android-First Threshold Test

When evaluating proposals, apply this decision tree:

```
Is this feature ESSENTIAL for core value proposition?
├── YES → Include (regardless of complexity)
└── NO → Is data available on Android without Watch/wearable?
         ├── YES → Is battery impact < 1% for this feature?
         │         ├── YES → Include
         │         └── NO → Defer to optimization phase
         └── NO → Defer or reject for MVP
```

### Complexity Rating Guide

| Rating | Definition | Example | Action |
|--------|------------|---------|--------|
| **ESSENTIAL** | Core value prop doesn't work without it | Energy state detection | Include, simplify if needed |
| **VALUABLE** | Significantly improves UX/accuracy | Chronotype modifiers | Include if < 1 week effort |
| **NICE-TO-HAVE** | Marginal improvement | Creative vs Deep focus distinction | Defer to post-launch |
| **OVER-ENGINEERED** | Adds complexity without proportional value | Real-time HRV streaming | Reject |

### Reconciliation Output Template

After completing the checklist, document the reconciliation:

```markdown
## Research Reconciliation: [RQ-XXX / Research Session Name]

**Source:** [Deep Think / Claude / Gemini / etc.]
**Date:** [Date]
**Reconciled By:** [Agent name]

### Summary
- Total proposals: X
- ACCEPT: X | MODIFY: X | REJECT: X | ESCALATE: X

### ACCEPT (Integrate as-is)
| Proposal | Rationale |
|----------|-----------|
| ... | ... |

### MODIFY (Adjust for reality)
| Proposal | Original | Adjusted | Rationale |
|----------|----------|----------|-----------|
| ... | ... | ... | ... |

### REJECT (Do not implement)
| Proposal | Reason |
|----------|--------|
| ... | ... |

### ESCALATE (Human decision required)
| Proposal | Conflicts With | Options |
|----------|----------------|---------|
| ... | ... | ... |

### Tasks Extracted (via Protocol 8)
[List of tasks with IDs]
```

### Anti-Patterns (DO NOT)

```
❌ Accept external research without running this checklist
❌ Implement proposals that conflict with CONFIRMED CDs
❌ Assume data availability without platform verification
❌ Skip the complexity rating
❌ Integrate without documenting the reconciliation
❌ Let scope expansion go unnoticed
```

### Reference Documents
- `index/CD_INDEX.md` — Quick lookup of all confirmed decisions
- `index/RQ_INDEX.md` — Quick lookup of research status
- `DEEP_THINK_PROMPT_GUIDANCE.md` — How to write better prompts (prevention)

---

## Protocol 10: Bias Analysis (MANDATORY)

### Trigger

Before finalizing any recommendation that affects product direction, monetization, core UX, or multi-stakeholder architecture **AND meets ONE of:**
- Affects 3+ stakeholder groups (users, business, engineering, etc.)
- Reversibility cost is HIGH (schema changes, API contracts, user-facing terminology)
- Implementation effort is >5 tasks
- Recommendation was contested or had multiple options

**Quick Filter:**
```
┌─────────────────────────────────────────────────────────────────────┐
│  PROTOCOL 10 TRIGGER QUICK FILTER                                   │
│                                                                     │
│  Does this recommendation:                                          │
│  □ Affect 3+ stakeholder groups?                                    │
│  □ Have HIGH reversibility cost?                                    │
│  □ Require >5 implementation tasks?                                 │
│  □ Have contested alternatives?                                     │
│                                                                     │
│  If YES to ANY → Run Protocol 10                                    │
│  If NO to ALL → Skip Protocol 10, proceed with standard confidence  │
└─────────────────────────────────────────────────────────────────────┘
```

**Reversibility Cost Classification:**

| Change Type | Reversibility | Classification |
|-------------|---------------|----------------|
| Schema changes (new tables, columns) | LOW — requires migration | **HIGH cost** |
| API contract changes | LOW — breaks clients | **HIGH cost** |
| User-facing terminology | MEDIUM — confuses users | **HIGH cost** |
| Internal service refactoring | HIGH — internal only | LOW cost |
| UI layout/styling | HIGH — easy to change | LOW cost |
| Feature flags | VERY HIGH — toggle off | LOW cost |

**Contested Alternatives Indicators:**
- Analysis document compares 3+ options
- Multiple SME domains have opinions
- Escalated to human for decision
- Previous research had conflicting recommendations

### Why This Protocol Exists
AI agents naturally form biases based on training data, context, and the framing of questions. These biases can lead to overconfident recommendations that haven't been validated. Protocol 10 requires explicit bias identification BEFORE finalizing recommendations.

**Origin:** This protocol was created after RQ-039 Token Economy analysis revealed 8 unvalidated biases that changed recommendation confidence from HIGH to LOW.

### Action

**Step 1: List All Assumptions**
```
For EACH recommendation, document:
"I assumed X because Y"

Example:
- I assumed users want weekly reflection because journaling apps use this pattern
- I assumed 50 chars is minimum quality because it seems "substantial"
- I assumed token cap at 3 prevents anxiety because hoarding is undesirable
```

**Step 2: Rate Each Assumption's Validity**

| Validity | Definition | Example |
|----------|------------|---------|
| **HIGH** | Backed by research, data, or confirmed decision | "CD-010 says track without punishing" |
| **MEDIUM** | Reasonable but unvalidated | "Weekly cadence is common in apps" |
| **LOW** | Gut feeling, arbitrary threshold, untested hypothesis | "50 chars feels substantial" |

**Step 3: Identify SME Domains**
```
List which expert domains this recommendation spans:
- Behavioral Economics
- Self-Determination Theory
- Mental Health Ethics
- Subscription Economics
- Game Design Psychology
- Habit Formation Science
- Mobile Product Design
```

**Step 4: Apply Confidence Decision Rule**

| LOW-Validity Count | Action |
|--------------------|--------|
| **0-1** | Proceed with HIGH confidence |
| **2-3** | Proceed with MEDIUM confidence, flag for validation |
| **4+** | DEFER decision, create RQ to validate assumptions (→ Protocol 12) |

**Hybrid Threshold Rule (Important):**
```
DEFER if ANY of:
- 4+ LOW-validity assumptions, OR
- >50% of assumptions rate LOW (minimum 3 assumptions required)

Example:
- 10 assumptions, 4 LOW (40%) → Check 4+ rule → DEFER ✓
- 4 assumptions, 3 LOW (75%) → Check >50% rule → DEFER ✓
- 2 assumptions, 2 LOW (100%) → Below minimum → Identify more assumptions first
```

**Minimum Assumption Requirement:** You must identify at least 3 assumptions before applying the threshold. If you can only identify 1-2, dig deeper — superficial analysis indicates more assumptions exist.

**Step 5: Document Bias Analysis**

```markdown
### Bias Analysis for [Recommendation]

| # | Assumption | Validity | Basis |
|---|------------|----------|-------|
| 1 | [Assumption] | HIGH/MEDIUM/LOW | [Evidence or lack thereof] |
| 2 | [Assumption] | HIGH/MEDIUM/LOW | [Evidence or lack thereof] |

**LOW-Validity Count:** X
**Decision:** PROCEED / DEFER (pending RQ-XXX)
**Revised Confidence:** HIGH / MEDIUM / LOW
```

### Anti-Patterns (DO NOT)

```
❌ Proceeding with HIGH confidence despite 4+ LOW-validity assumptions
❌ Not documenting assumptions at all ("it's obvious")
❌ Assuming "obvious" things without stating them
❌ Ignoring SME domains outside agent's training
❌ Treating all assumptions as equal validity
```

### Example

**Before Protocol 10:**
> "Recommendation: Weekly Review earns 1 token. HIGH confidence."

**After Protocol 10:**
> "Bias Analysis identified 6 LOW-validity assumptions (Pro-Reflection, Weekly Cadence, Token Cap, etc.). Decision: DEFER pending RQ-039 research. Revised Confidence: LOW."

---

## Protocol 11: Sub-RQ Creation (MANDATORY)

### Trigger
When a Research Question is too complex to answer with a single research effort, specifically when:
- RQ spans 3+ SME domains
- RQ has 5+ distinct sub-questions
- RQ would require 10+ page research output
- RQ has sub-components that can be researched independently

### Why This Protocol Exists
Complex research questions benefit from decomposition. Sub-RQs allow:
1. Parallel research by different agents
2. Clearer scope per research effort
3. Incremental progress tracking
4. Domain-specific expertise matching

**Origin:** This protocol was created during RQ-039 Token Economy work, which required 7 sub-RQs spanning Behavioral Economics, SDT, Mental Health Ethics, and more.

### Action

**Step 1: Verify Decomposition Criteria**
```
Does this RQ meet ANY of these criteria?
□ Spans 3+ SME domains
□ Has 5+ distinct sub-questions
□ Would require 10+ page research output
□ Has sub-components that can be researched independently

If YES to any → Proceed with decomposition
If NO to all → Research as single RQ
```

**Step 2: Identify 3-7 Sub-Questions**
```
Each sub-RQ MUST have:
□ Single SME domain focus (not multi-domain)
□ Clear, specific deliverable
□ Independence from sibling sub-RQs where possible
□ Parent RQ listed as dependency

If dependencies between sub-RQs exist:
□ Document with ↓ notation
□ Note which sub-RQs benefit from sequencing
□ Recommend research order
```

**Sub-RQ Dependency Documentation (if applicable):**
```markdown
### Sub-RQ Dependencies

| Sub-RQ | Depends On | Nature |
|--------|------------|--------|
| 039f | 039a | Soft — premium builds on base earning |
| 039e | 039a | Soft — crisis bypass needs earning context |

**Research Order Recommendation:** 039a → (039b, 039c, 039d parallel) → 039e → 039f → 039g
```

**Step 3: Assign Sub-RQ IDs**
```
Naming Convention: RQ-XXX[a-z]

Example:
RQ-039: Token Economy Architecture (PARENT)
├── RQ-039a: Earning Mechanism & Intrinsic Motivation
├── RQ-039b: Optimal Reflection Cadence
├── RQ-039c: Single vs Multiple Earning Paths
├── RQ-039d: Token Cap vs Decay Alternatives
├── RQ-039e: Crisis Bypass Threshold Validation
├── RQ-039f: Premium Token Allocation
└── RQ-039g: Reflection Quality Thresholds
```

**Step 4: Update All Tracking Files**

| File | Required Update |
|------|-----------------|
| **RQ_INDEX.md** | Add sub-RQs with hierarchy notation (↳) |
| **PRODUCT_DEV_SHEET** | Add to pending research with sub-RQ table |
| **RESEARCH_QUESTIONS.md** | Add to Master Tracker (if active) |
| **IMPLEMENTATION_ACTIONS** | Add to Blocking Research if applicable |

**Step 5: Update Statistics**
```
Main RQ count stays same (e.g., 39)
Add separate "Sub-RQ" count (e.g., +7)
Pending research shows both (e.g., "8 main + 7 sub")
```

### Anti-Patterns (DO NOT)

```
❌ Creating sub-RQs without updating ALL tracking files
❌ Sub-RQs that depend on each other (should be independent)
❌ More than 7 sub-RQs (consider further decomposition)
❌ Sub-RQs that span multiple SME domains
❌ Forgetting to update statistics with sub-RQ count
```

### Example Output

```markdown
## RQ-039: Token Economy Architecture

**Status:** 🔴 NEEDS RESEARCH (decomposed)
**Sub-RQs:** 7

| Sub-RQ | Title | SME Domain | Deliverable |
|--------|-------|------------|-------------|
| 039a | Earning Mechanism | Behavioral Economics | Mechanism comparison |
| 039b | Reflection Cadence | Habit Formation | Optimal frequency |
| 039c | Earning Paths | SDT | Autonomy preservation |
| 039d | Cap vs Decay | Game Design | Alternative analysis |
| 039e | Crisis Bypass | Mental Health | Threshold validation |
| 039f | Premium Allocation | Subscription Econ | Premium strategy |
| 039g | Quality Thresholds | Mobile Product | Validation criteria |
```

---

## Protocol 12: Decision Deferral (MANDATORY)

### Trigger
When analysis reveals that a decision CANNOT be made confidently due to:
- 4+ LOW-validity assumptions identified (via Protocol 10)
- SME domains not represented in current research
- Recommendation would be costly to reverse
- Human explicitly requests deferral

### Why This Protocol Exists
It is better to DEFER a decision and research properly than to proceed with false confidence. Protocol 12 formalizes when and how to defer, ensuring:
1. Deferral is documented (not forgotten)
2. New RQ is created to unblock
3. MVP fallback is provided for timeline pressure
4. Status is tracked correctly (DEFERRED, not PENDING)

**Origin:** This protocol was created when PD-119 Token Economy was initially marked READY but bias analysis revealed 6 LOW-validity assumptions requiring RQ-039 research.

### Action

**Step 1: Verify Deferral Criteria**
```
Does this decision meet ANY of these criteria?
□ 4+ LOW-validity assumptions identified (Protocol 10)
□ SME domains not represented in current research
□ Recommendation would be expensive to reverse
□ Human explicitly requests deferral

If YES to any → Proceed with deferral
If NO to all → Make decision (with documented confidence level)
```

**Step 2: Document Deferral Rationale**
```markdown
### Deferral Rationale for [PD-XXX]

**Original Status:** [READY / PENDING]
**New Status:** DEFERRED

**Unvalidated Assumptions:**
1. [Assumption] — Validity: LOW
2. [Assumption] — Validity: LOW
...

**Missing Research:**
- [What SME domain needs investigation]
- [What specific questions need answering]

**Cost of Proceeding:** [Why this is risky]
```

**Step 3: Create Unblocking RQ**
```
Create new RQ (or sub-RQs via Protocol 11) to address the gap:
- Link RQ to the deferred PD
- Identify specific deliverables needed
- Assign SME domain focus
```

**Step 4: Update PD Status**

| File | Required Update |
|------|-----------------|
| **PD_INDEX.md** | Status → 🟡 DEFERRED |
| **PRODUCT_DECISIONS.md** | Add deferral section with rationale |
| **PRODUCT_DEV_SHEET** | Move to "Deferred Decisions" or update status |
| **IMPACT_ANALYSIS.md** | Note downstream effects of deferral |

**Step 5: Provide MVP Fallback**
```markdown
### MVP Fallback (If Timeline Pressure)

**Option:** [Simplest CD-compliant option]
**Rationale:** [Why this is acceptable as fallback]
**Risks:** [What we're accepting by not researching]
**Replacement Plan:** [When research completes, replace with validated solution]
```

### Status Legend

| Status | Meaning | Use When |
|--------|---------|----------|
| 🔴 PENDING | Awaiting research or decision | Research not yet done |
| 🟢 READY | Research complete, awaiting human decision | All inputs available |
| 🟡 DEFERRED | Deliberately delayed pending new research | Bias analysis revealed gaps |
| ✅ RESOLVED | Decision made, may become CD | Human decided |

**CRITICAL:** DEFERRED is NOT the same as PENDING. DEFERRED means we COULD decide but CHOSE not to due to insufficient confidence.

### PENDING vs DEFERRED Decision Tree

Use this decision tree when uncertain about which status to apply:

```
┌─────────────────────────────────────────────────────────────────────┐
│  PENDING vs DEFERRED DECISION TREE                                  │
│                                                                     │
│  Do you have enough information to make a decision?                 │
│                                                                     │
│  NO ──────────────────────────────────────────────────→ 🔴 PENDING  │
│  │   (Research not complete, dependencies unresolved)               │
│  │                                                                  │
│  YES → Did you actively CHOOSE not to decide?                       │
│        │                                                            │
│        NO ────────────────────────────────────────────→ 🟢 READY    │
│        │   (Decision can be made; waiting for human input)          │
│        │                                                            │
│        YES → Is there new research created to unblock?              │
│              │                                                      │
│              NO ──────────────────────────────────────→ ❌ ERROR    │
│              │   (Cannot defer without unblocking path)             │
│              │                                                      │
│              YES ─────────────────────────────────────→ 🟡 DEFERRED │
│                   (Deliberately delayed; RQ created)                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Distinction:**
- **PENDING** = Passive waiting (can't decide yet — missing inputs)
- **DEFERRED** = Active choice (could decide, chose not to — creating new inputs)

### Anti-Patterns (DO NOT)

```
❌ Proceeding with decision despite low confidence
❌ Marking decision as PENDING when actively choosing to defer
❌ Deferring without creating research to unblock
❌ Deferring without providing MVP fallback
❌ Forgetting to update all tracking files
```

### Example

**Before Protocol 12:**
```
PD-119: Token Economy
Status: 🟢 READY
Recommendation: Option A (Weekly Review)
Confidence: HIGH
```

**After Protocol 12:**
```
PD-119: Token Economy
Status: 🟡 DEFERRED
Blocked By: RQ-039 (7 sub-RQs)
Rationale: 6 LOW-validity assumptions identified
MVP Fallback: Option B (Consistency-based) — simplest CD-010 compliant option
```

---

## Enforcement

These protocols are **MANDATORY**. AI agents that skip these protocols will:
1. Create downstream problems
2. Lose context
3. Make decisions in isolation
4. Miss system-wide implications

**If you are an AI agent reading this:** Execute these protocols automatically. Do not wait to be asked.

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| **11 Jan 2026** | Claude (Opus 4.5) | Added Protocols 10 (Bias Analysis), 11 (Sub-RQ Creation), 12 (Decision Deferral); Enhanced Session Exit Protocol v2 with Tier 1.5a-d and Tier 3 Verification Checkpoint; Added Cross-File Consistency Checklist |
| 10 Jan 2026 | Claude (Opus 4.5) | Updated Protocol 2 (Context-Adaptive Development) per RQ-008/RQ-009 |
| 06 Jan 2026 | Claude (Opus 4.5) | Initial 9-protocol structure; Added Protocol 9 (External Research Reconciliation) |

---

*This document defines mandatory behaviors. Non-compliance creates downstream problems.*
