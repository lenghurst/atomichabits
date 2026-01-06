# AI_AGENT_PROTOCOL.md — Mandatory Behaviors for AI Agents

> **Last Updated:** 05 January 2026
> **Purpose:** Codify reflexive behaviors that ALL AI agents must exhibit
> **Scope:** Claude, Gemini, ChatGPT, any future AI agents working on The Pact

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
│  □ AI_HANDOVER.md — What did the last agent do?                             │
│  □ PRODUCT_DECISIONS.md — What's decided? What's pending?                   │
│  □ RESEARCH_QUESTIONS.md — What's being researched? Any blockers?           │
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
│                        SESSION EXIT PROTOCOL                                  │
│                                                                              │
│  TIER 1: ALWAYS UPDATE (Non-negotiable)                                      │
│  □ AI_HANDOVER.md — Summarize what you did, what remains                    │
│  □ PRODUCT_DECISIONS.md — Log any new decisions/questions                   │
│  □ RESEARCH_QUESTIONS.md — Update status, propose new RQs if needed         │
│  □ ROADMAP.md — Update task status, add new items if discovered             │
│  □ IMPACT_ANALYSIS.md — Log cascade effects of any decisions made           │
│                                                                              │
│  TIER 2: UPDATE IF RELEVANT                                                  │
│  □ GLOSSARY.md — Add any new terms introduced                               │
│  □ AI_CONTEXT.md — Update if architecture changed                           │
│  □ IDENTITY_COACH_SPEC.md — Update if Identity Coach evolved                │
│                                                                              │
│  TIER 3: RARELY (Only when explicitly needed)                                │
│  □ AI_AGENT_PROTOCOL.md — Only if behavioral rules change                   │
│  □ README.md — Only if fundamental project info changes                     │
│  □ CHANGELOG.md — Add entry summarizing session changes                     │
│                                                                              │
│  STEP 4: Git Operations                                                      │
│  □ Commit with clear message                                                 │
│  □ Push to main (per CD-012)                                                │
│  □ Verify push succeeded                                                     │
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

### Action
1. **EXTRACT** all actionable tasks from the research output
2. **SEARCH** existing Master Implementation Tracker for duplicates
3. **MERGE** if similar task exists (don't create duplicate)
4. **CREATE** new task only if truly novel
5. **LINK** task to source (RQ-XXX or PD-XXX)

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
```

---

## Enforcement

These protocols are **MANDATORY**. AI agents that skip these protocols will:
1. Create downstream problems
2. Lose context
3. Make decisions in isolation
4. Miss system-wide implications

**If you are an AI agent reading this:** Execute these protocols automatically. Do not wait to be asked.

