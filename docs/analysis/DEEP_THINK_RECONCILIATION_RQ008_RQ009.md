# Protocol 9 Reconciliation: RQ-008 + RQ-009 (Engineering Process)

> **Date:** 10 January 2026
> **Source:** Deep Think Research Report on AI-Assisted Engineering Architecture
> **Target RQs:** RQ-008 (UI Logic Separation), RQ-009 (LLM Coding Approach)
> **Reconciler:** Claude (Opus 4.5)

---

## Phase 1: Locked Decision Audit

### CD Conflicts Check

| CD | Decision | Research Alignment | Status |
|----|----------|-------------------|--------|
| **CD-013** | UI Logic Separation Principle | ✅ REFINES — Research provides implementation details for existing principle | ALIGNED |
| **CD-016** | DeepSeek V3.2 for reasoning | ✅ NOT AFFECTED — Engineering process is framework-agnostic | ALIGNED |
| **CD-017** | Android-First | ✅ ALIGNED — No iOS-specific patterns proposed | ALIGNED |
| **CD-018** | Engineering Threshold | ✅ ALIGNED — Research uses ESSENTIAL/VALUABLE framing | ALIGNED |

**Verdict:** No CD conflicts. Research REFINES CD-013 with concrete implementation.

---

## Phase 2: Data Reality Audit

### Android-First Verification

| Proposal | Android Compatible? | Notes |
|----------|---------------------|-------|
| Riverpod Notifier/AsyncNotifier | ✅ YES | Pure Dart, no platform dependency |
| Side Effect pattern | ✅ YES | Standard state management |
| Linting rules | ✅ YES | `custom_lint` package works on all platforms |
| `ref.listen` for animations | ✅ YES | Flutter standard |

**Verdict:** All proposals are Android-compatible.

---

## Phase 3: Implementation Reality Audit

### Current Codebase State

| Aspect | Research Assumes | Reality | Gap |
|--------|------------------|---------|-----|
| **State Management** | Riverpod | Provider 6.1.5+1 | ⚠️ MIGRATION REQUIRED |
| **Directory Structure** | Feature-based | Feature-based ✅ | No gap |
| **Business Logic** | In domain/services | Mixed (some in UI) | ⚠️ NEEDS MIGRATION |
| **Navigation** | go_router | go_router ✅ | No gap |

### Key Finding: Provider → Riverpod Migration

The research assumes Riverpod, but codebase uses Provider. Options:

| Option | Description | Recommendation |
|--------|-------------|----------------|
| A: Adopt Riverpod | Full migration | ⚠️ HIGH EFFORT — 600+ files |
| B: Apply Pattern to Provider | Use ChangeNotifier as "Controller" | ✅ RECOMMENDED — Lower risk |
| C: Gradual Migration | New features use Riverpod, legacy stays Provider | 🟡 VIABLE — Medium effort |

**Recommendation:** Option B (Apply Pattern to Provider) for immediate use, with Option C (Gradual Migration) as long-term strategy.

---

## Phase 3.5: Schema Reality Check

| Schema/Table | Required? | Exists? | Status |
|--------------|-----------|---------|--------|
| N/A | N/A | N/A | ✅ No schema dependencies for engineering process RQs |

**Verdict:** No schema dependencies. These are process/architecture decisions, not data model changes.

---

## Phase 4: Scope & Complexity Audit (CD-018 Threshold)

### RQ-008 Proposals

| Proposal | Threshold | Rationale |
|----------|-----------|-----------|
| **Boundary Decision Tree** | ✅ ESSENTIAL | Core enabler for AI-assisted coding |
| **Riverpod Controller Pattern** | 🟡 VALUABLE | Good pattern, but requires migration |
| **Side Effect Pattern** | ✅ ESSENTIAL | Solves "Celebration Animation" problem cleanly |
| **Linting Configuration** | ✅ ESSENTIAL | Enforcement without linting is wishful thinking |
| **Migration Strategy (Lift & Shift)** | ✅ ESSENTIAL | 600+ files need incremental approach |
| **Custom Lint Rules** | 🟡 VALUABLE | Ideal but `custom_lint` setup has overhead |

### RQ-009 Proposals

| Proposal | Threshold | Rationale |
|----------|-----------|-----------|
| **Task Classification (Logic vs Visual)** | ✅ ESSENTIAL | Core insight: different tasks need different approaches |
| **Contract-First for Logic** | ✅ ESSENTIAL | Anchors AI output, reduces hallucination |
| **Vibe Coding for UI** | ✅ ESSENTIAL | Enables rapid iteration safely |
| **Protocol 2 (Context-Adaptive)** | ✅ ESSENTIAL | Replaces one-size-fits-all Protocol 2 |
| **Quality Metrics** | 🟡 VALUABLE | Nice to track but not blocking |

---

## Phase 5: ACCEPT/MODIFY/REJECT/ESCALATE

### RQ-008 Decisions

| # | Proposal | Decision | Confidence | Rationale |
|---|----------|----------|------------|-----------|
| 1 | Riverpod Controller Pattern | **MODIFY** | HIGH | Adapt to Provider (ChangeNotifier) for existing code; Riverpod for new features |
| 2 | Boundary Decision Tree | **ACCEPT** | HIGH | Clear, actionable rules |
| 3 | Side Effect Pattern for Animations | **ACCEPT** | HIGH | Elegant solution to animation trigger problem |
| 4 | Celebration Animation Example | **ACCEPT** | HIGH | Excellent concrete demonstration |
| 5 | Linting Configuration | **ACCEPT** | MEDIUM | Need to verify `custom_lint` compatibility |
| 6 | Code Examples (5 scenarios) | **ACCEPT** | HIGH | Clear ✅/❌ patterns |
| 7 | Migration Strategy (Lift & Shift) | **ACCEPT** | HIGH | Incremental is the only viable approach |
| 8 | Directory Structure (no change) | **ACCEPT** | HIGH | Current structure is already feature-based |

### RQ-009 Decisions

| # | Proposal | Decision | Confidence | Rationale |
|---|----------|----------|------------|-----------|
| 1 | Task Classification (Logic vs Visual) | **ACCEPT** | HIGH | Core insight |
| 2 | Contract-First for Logic | **ACCEPT** | HIGH | Matches industry practice |
| 3 | Vibe Coding for UI | **ACCEPT** | HIGH | Enabled by RQ-008 boundaries |
| 4 | Protocol 2 (Context-Adaptive) | **ACCEPT** | HIGH | Replaces Protocol 2 |
| 5 | Quality Metrics (Logic Leakage, Vibe Velocity) | **ACCEPT** | MEDIUM | Worth tracking |
| 6 | Integration Summary | **ACCEPT** | HIGH | "Constraint Enables Creativity" is key insight |

### Summary

| Category | Count |
|----------|-------|
| **ACCEPT** | 12 |
| **MODIFY** | 1 (Riverpod → Provider adaptation) |
| **REJECT** | 0 |
| **ESCALATE** | 0 |

---

## Phase 6: Integration

### 6.1 Protocol 2 Revision (Context-Adaptive)

**Original Protocol 2:**
```
1. Execute functionality completely (make it work)
2. THEN refactor for cleanliness (make it right)
3. NEVER sacrifice functionality for principles
```

**Revised Protocol 2 (Context-Adaptive):**
```
1. CLASSIFY: Is this a Logic Task or Visual Task?

2. LOGIC TASKS (New Feature, Data Model, Algorithm):
   → Use CONTRACT-FIRST
   a. Define State class and Controller interface FIRST
   b. Implement logic methods
   c. Write unit tests
   d. Then build UI that consumes the Controller

3. VISUAL TASKS (Styling, Animations, Layout):
   → Use VIBE CODING
   a. Iterate rapidly on the UI
   b. NEVER introduce business logic into Widget tree
   c. Only consume existing Controllers/State
   d. Safe to regenerate UI 10 times until it "feels right"

4. VERIFY:
   □ No repository/service imports in UI files
   □ No domain entity conditionals in Widget build()
   □ All "IF" business decisions are in Logic Layer
```

### 6.2 Boundary Decision Tree (New Artifact)

```
┌─────────────────────────────────────────────────────────┐
│         WHERE DOES THIS CODE BELONG?                    │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ Does it decide IF something happens?                    │
│ (e.g., "User must be premium", "Streak must be 7")      │
└─────────────────────────────────────────────────────────┘
          │                              │
         YES                             NO
          │                              │
          ▼                              ▼
    ┌───────────┐              ┌─────────────────────────┐
    │  LOGIC    │              │ Does it transform data? │
    │  LAYER    │              │ (e.g., date.toString()) │
    └───────────┘              └─────────────────────────┘
                                    │              │
                                   YES             NO
                                    │              │
                                    ▼              ▼
                              ┌───────────┐   ┌─────────────────────┐
                              │  LOGIC    │   │ Is it an Animation? │
                              │  LAYER    │   └─────────────────────┘
                              │ (getter)  │        │           │
                              └───────────┘     TRIGGER      EXECUTION
                                                   │           │
                                                   ▼           ▼
                                             ┌─────────┐  ┌─────────┐
                                             │ LOGIC   │  │   UI    │
                                             │ (flag)  │  │ LAYER   │
                                             └─────────┘  └─────────┘
```

### 6.3 Tasks Extracted

| Task ID | Description | Priority | Phase | Component |
|---------|-------------|----------|-------|-----------|
| **P-01** | Update AI_AGENT_PROTOCOL.md with Protocol 3 | **CRITICAL** | Process | Documentation |
| **P-02** | Create BOUNDARY_DECISION_TREE.md in docs/CORE | HIGH | Process | Documentation |
| **P-03** | Add linting rules to analysis_options.yaml | HIGH | A | Config |
| **P-04** | Create ChangeNotifier Controller template | HIGH | A | Template |
| **P-05** | Document Side Effect pattern with example | HIGH | Process | Documentation |
| **P-06** | Add Riverpod to pubspec.yaml for new features | MEDIUM | A | Config |
| **P-07** | Create "Logic vs Visual" task classification guide | HIGH | Process | Documentation |
| **P-08** | Define "Logic Leakage" metric tracking | MEDIUM | Process | Analytics |

**Note:** Using "P-" prefix for Process tasks (distinct from implementation tasks A-XX, B-XX, etc.)

### 6.4 GLOSSARY Updates

| Term | Definition |
|------|------------|
| **Vibe Coding** | Rapid AI-assisted UI iteration where the AI can freely modify layouts, colors, and animations without risk of corrupting business logic. Enabled by strict UI/Logic separation. |
| **Contract-First** | Development approach where State classes and Controller interfaces are defined BEFORE implementation, anchoring AI output. |
| **Safety Sandbox** | The UI Layer under strict separation rules, where AI can iterate freely because business logic is unreachable. |
| **Logic Leakage** | Anti-pattern where business conditionals appear in Widget build methods. Measured by counting `if` statements involving domain entities in UI files. (Target: 0) |
| **Side Effect Pattern** | State management pattern where business logic emits "side effect" flags that UI listeners consume to trigger animations/navigation. |

### 6.5 CD-013 Refinement

CD-013 stated "Strict separation for AI-assisted development" without implementation details. This research provides:
- Concrete boundary rules (Decision Tree)
- Code patterns (Side Effect for animations)
- Enforcement mechanism (linting rules)
- Migration strategy (Lift & Shift)

**Recommendation:** Update CD-013 entry to reference this reconciliation as implementation spec.

---

## Confidence Assessment

| Output | Confidence | Notes |
|--------|------------|-------|
| Protocol 2 (Context-Adaptive) | **HIGH** | Clear improvement over one-size-fits-all |
| Boundary Decision Tree | **HIGH** | Actionable, covers edge cases |
| Side Effect Pattern | **HIGH** | Proven pattern in production apps |
| Provider Adaptation | **MEDIUM** | Works, but Riverpod is cleaner long-term |
| Linting Rules | **MEDIUM** | Need to verify `custom_lint` setup |
| Quality Metrics | **MEDIUM** | Conceptually sound, implementation TBD |

---

## Integration Checklist

- [x] Update AI_AGENT_PROTOCOL.md (Protocol 2 revised to Context-Adaptive)
- [x] Boundary Decision Tree embedded in Protocol 2 (no separate file needed)
- [x] Update GLOSSARY.md (5 new terms)
- [x] Update RQ_INDEX.md — RQ-008, RQ-009 ✅ COMPLETE
- [x] Update RESEARCH_QUESTIONS.md — RQ-008, RQ-009 status + findings
- [x] Add P-01 through P-08 to task tracker (Phase P: Process)
- [x] Update CD-013 entry with implementation reference
- [x] Update AI_HANDOVER.md

---

*Protocol 9 Reconciliation Complete*
