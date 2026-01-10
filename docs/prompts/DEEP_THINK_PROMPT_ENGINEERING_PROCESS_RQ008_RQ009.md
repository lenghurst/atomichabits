# Deep Think Prompt: AI-Assisted Engineering Process

> **Target Research:** RQ-008 (UI Logic Separation), RQ-009 (LLM Coding Approach)
> **Prepared:** 10 January 2026
> **For:** DeepSeek Deep Think / Google Deep Think
> **App Name:** The Pact (Flutter habit tracking app)

---

## Your Role

You are a **Senior Software Architect** specializing in:
- AI-assisted software development workflows
- Flutter/Dart application architecture
- Clean Architecture and separation of concerns
- LLM-augmented coding productivity patterns

Your approach: Think step-by-step. Examine evidence from industry practice, academic research where available, and first-principles reasoning. Distinguish between established best practices vs emerging patterns in AI-assisted development.

---

## Critical Instruction: Processing Order

```
RQ-008 (UI Logic Separation)
  ↓ Outputs boundary definitions that inform...
RQ-009 (LLM Coding Approach)
  ↓ Outputs workflow that operates within boundaries
```

**Process RQ-008 FIRST**, then use its outputs to contextualize RQ-009.

---

## Mandatory Context: Current Codebase

### Technology Stack
| Component | Technology | Notes |
|-----------|------------|-------|
| **Framework** | Flutter 3.38.4 | Cross-platform, Android-first (CD-017) |
| **State Management** | Provider (migrating to Riverpod) | Consumer2 patterns in use |
| **Backend** | Supabase (PostgreSQL + pgvector) | Edge Functions for AI calls |
| **AI Models** | DeepSeek V3.2, Gemini embedding | CD-016 locked |
| **Architecture** | Feature-based + layered | See structure below |

### Current Directory Structure
```
lib/
├── config/              # Configuration, routing
├── core/                # Core utilities
├── data/                # Data layer
│   ├── models/          # Data models (DTOs)
│   ├── providers/       # State providers (UserProvider, AppState)
│   └── repositories/    # Data access
├── domain/              # Domain layer
│   ├── entities/        # Domain entities
│   ├── interfaces/      # Abstractions
│   └── services/        # Business logic services
│       ├── jitai_decision_engine.dart
│       ├── psychometric_engine.dart
│       ├── archetype_registry.dart
│       └── ... (17 services)
├── features/            # Feature modules
│   ├── dashboard/       # Habit list, widgets
│   ├── onboarding/      # Sherlock, identity gates
│   ├── today/           # Daily view, skill tree
│   └── ... (15 features)
├── logic/               # Logic layer (unclear boundary)
├── ui/                  # UI components
├── widgets/             # Reusable widgets
└── utils/               # Utilities
```

### Current Code Pattern Example
```dart
// lib/features/dashboard/habit_list_screen.dart (CURRENT STATE)
class HabitListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, AppState>(
      builder: (context, userProvider, appState, child) {
        final habits = appState.habits;  // Data access in UI
        final profile = userProvider.userProfile;

        return Scaffold(
          appBar: AppBar(
            // ... UI with inline business logic decisions
            actions: [
              if (habits.isNotEmpty)  // Business condition in UI
                IconButton(
                  onPressed: () => _showWeeklyReviewPicker(context, habits),
                  // ...
                ),
            ],
          ),
          // ... more mixed logic
        );
      },
    );
  }
}
```

**Problem:** Business logic (`habits.isNotEmpty`, `_showWeeklyReviewPicker`) is embedded in UI layer, making it risky for AI agents to modify UI without potentially breaking business rules.

### Current AI Agent Protocol (Protocol 2)
```
1. Execute functionality completely (make it work)
2. THEN refactor for cleanliness (make it right)
3. NEVER sacrifice functionality for principles
```

This is under review. The question is whether this "Work → Right" approach is optimal for LLM-assisted coding.

---

## Research Question 1: RQ-008 — UI Logic Separation for AI-Assisted Development

### Core Question
What are best practices for articulating UI/logic separation that enables effective "vibe coding" (rapid AI-assisted UI iteration without breaking business logic)?

### Why This Matters
- **107+ tasks** are queued for implementation
- AI agents will be writing 80%+ of the code
- Current codebase has mixed UI/business logic
- Need clear boundaries so agents can safely modify UI
- "Vibe coding" = rapid UI iteration where an AI agent adjusts layouts, colors, animations based on feel/feedback without risk

### The Problem: The Marcus Scenario
**Marcus (Developer)** asks Claude: "Make the habit cards more playful with bouncy animations."

**Current Risk:**
- Agent modifies `habit_list_screen.dart`
- Agent changes the `Consumer2` builder structure for animation
- Agent accidentally breaks the `habits.isNotEmpty` business condition
- Build succeeds but business logic is corrupted

**Desired State:**
- UI layer contains ONLY presentation concerns
- Business conditions live in domain/logic layer
- Agent can freely modify `HabitCardWidget` without touching `HabitListViewModel`
- Clear linting rules catch violations at PR time

### Current Hypothesis (Validate or Refine)

| Boundary | UI Layer Contains | Logic Layer Contains |
|----------|-------------------|----------------------|
| **Data Display** | How to render data | What data to fetch |
| **User Input** | Gesture handling, form validation | Business validation, state mutations |
| **Conditions** | Visibility based on state | What state means |
| **Navigation** | Route transitions | Navigation decisions |
| **Animation** | Animation implementation | Animation triggers? |

**Uncertainty:** Where does animation trigger logic belong? If "show celebration animation when streak reaches 7", is "streak == 7" UI or business logic?

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Pattern Selection:** What Flutter architecture pattern best supports AI-assisted development? (Clean Architecture, BLoC, MVVM, Riverpod+StateNotifier, Other) | Compare patterns specifically for "AI-modifiability." Cite production examples. |
| 2 | **Boundary Definition:** Precisely define what code belongs in UI vs Domain layers. Provide a decision tree. | Create explicit rules: "IF code does X, THEN it belongs in Y layer." |
| 3 | **Animation Logic:** Where should animation trigger logic live? | Recommend with rationale. "Streak == 7" scenario. |
| 4 | **Navigation Routing:** Where should navigation decisions live? (e.g., "if onboarding complete, go to dashboard") | Recommend pattern for Flutter with go_router. |
| 5 | **Provider/Riverpod Bridge:** How to structure providers so UI only consumes, never contains business logic? | Provide code example showing correct Consumer usage. |
| 6 | **Linting Rules:** What Dart analyzer rules can enforce this separation? | Provide `analysis_options.yaml` additions. |
| 7 | **Directory Structure:** Should we restructure lib/ to better reflect boundaries? | Propose structure if current is suboptimal. |
| 8 | **Testing Strategy:** How does this separation affect testability? | Show how UI tests vs logic tests differ. |
| 9 | **Migration Path:** How to migrate existing mixed code (600+ files) incrementally? | Provide strangler-fig or similar strategy. |

### Anti-Patterns to Avoid
- ❌ Overly abstract architectures that create cognitive overhead for AI agents
- ❌ Patterns that require understanding 5+ files to make one UI change
- ❌ Rigid structures that prevent "vibe coding" experimentation
- ❌ Patterns without clear linting enforcement (humans forget, AI forgets more)

### Output Required
1. **Architecture Recommendation** — Which pattern to adopt (with rationale)
2. **Boundary Decision Tree** — Flowchart: "Where does this code go?"
3. **Code Examples** — ✅ Correct vs ❌ Wrong for 5 common scenarios
4. **Linting Configuration** — `analysis_options.yaml` additions
5. **Migration Strategy** — How to incrementally separate existing code
6. **Confidence Assessment** — Rate each output HIGH/MEDIUM/LOW

---

## Research Question 2: RQ-009 — Optimal LLM Coding Approach

### Core Question
Is "Make it work first, then refactor" the optimal approach for LLM-assisted coding, or does explicit structure/planning BEFORE coding produce better results?

### Why This Matters
- Current Protocol 2 mandates "Work → Right" sequence
- Some argue LLMs produce better code with upfront planning
- Wrong approach = accumulated tech debt OR over-engineering
- Need evidence-based recommendation, not opinion

### The Problem: Two Schools of Thought

**School A: "Work → Right" (Current Protocol 2)**
```
1. Implement feature completely (messy is OK)
2. Verify it works
3. Refactor for cleanliness
4. Verify still works
```
- **Pro:** Unblocks functionality, avoids analysis paralysis
- **Con:** May create patterns AI doesn't know to refactor

**School B: "Plan → Work"**
```
1. Define interface/structure first
2. Write tests (TDD-style)
3. Implement to match structure
4. Minimal refactoring needed
```
- **Pro:** Cleaner initial code, fewer rewrites
- **Con:** May over-engineer, LLM may not follow plan

**School C: "Iterative Chunks"**
```
1. Break into small chunks (50-100 lines)
2. For each: plan → code → test → refine
3. Integrate chunks
```
- **Pro:** Balanced approach, manageable context
- **Con:** More context switches, may lose coherence

### Current Evidence
- **Anthropic's Claude** documentation suggests planning complex tasks
- **GitHub Copilot** research shows context matters more than approach
- **No rigorous studies** comparing approaches specifically for LLM coding

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Evidence Review:** What does existing research/practice say about LLM coding approaches? | Cite any studies, blog posts from AI labs, practitioner reports. |
| 2 | **Task Complexity Matrix:** Does optimal approach vary by task type? | Create matrix: task type × recommended approach. |
| 3 | **Context Window Impact:** How does LLM context window size affect approach choice? | Analyze: large context (Claude) vs smaller context. |
| 4 | **Refactoring Quality:** Do LLMs refactor well, or is "refactor later" a myth? | Assess LLM refactoring capability with examples. |
| 5 | **Planning Fidelity:** Do LLMs follow architectural plans, or deviate? | Assess plan-adherence behavior. |
| 6 | **Error Patterns:** What errors are common in each approach? | Catalog: Work→Right errors vs Plan→Work errors. |
| 7 | **Hybrid Recommendation:** Is there a hybrid that captures benefits of both? | Propose optimal workflow for The Pact. |
| 8 | **Task Classification:** How should an AI agent decide which approach to use? | Provide decision rules. |
| 9 | **Protocol 2 Update:** Should Protocol 2 be modified? If so, how? | Provide specific language changes. |

### Anti-Patterns to Avoid
- ❌ Dogmatic adherence to one approach regardless of context
- ❌ Over-planning simple tasks (YAGNI violation)
- ❌ Under-planning complex tasks (tech debt accumulation)
- ❌ Assuming LLMs refactor perfectly (verify this claim)

### Output Required
1. **Approach Comparison Matrix** — Work→Right vs Plan→Work vs Iterative across dimensions
2. **Task Classification System** — When to use which approach
3. **Recommended Workflow** — Specific steps for The Pact's AI agents
4. **Protocol 2 Revision** — Updated protocol text if changes needed
5. **Quality Metrics** — How to measure if approach is working
6. **Confidence Assessment** — Rate each output HIGH/MEDIUM/LOW

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Framework** | Flutter 3.38.4 — no framework changes |
| **State Management** | Currently Provider, transitioning to Riverpod — both must work |
| **Platform** | Android-first (CD-017) — all patterns must work on Android |
| **AI Models** | DeepSeek V3.2 for reasoning, hardcoded JITAI (CD-016) |
| **Codebase Size** | ~600 Dart files, 25K+ lines — migration must be incremental |
| **AI Agent Tools** | Claude Code, GitHub Copilot — patterns must work with both |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an AI agent apply these patterns without clarifying questions? |
| **Enforceable** | Are there linting rules or tests that catch violations? |
| **Incremental** | Can patterns be adopted file-by-file, not big-bang? |
| **Measurable** | Can we measure if the approach is working? |
| **Evidence-Based** | Are recommendations supported by research or practice? |

---

## Example of Good Output (RQ-008 Boundary Decision)

**Scenario:** Should `if (habits.isNotEmpty)` be in UI or Domain?

**Good Output:**
```
Decision: DOMAIN LAYER

Rationale:
- "isNotEmpty" encodes business meaning: "user has active habits"
- This condition drives what UI elements appear
- If business definition changes (e.g., "active habits" excludes paused),
  change should be in domain, not scattered across UI files

Recommended Pattern:
// domain/services/habit_visibility_service.dart
class HabitVisibilityService {
  bool get shouldShowWeeklyReview => habits.isNotEmpty && lastReviewOlderThan7Days;
}

// features/dashboard/habit_list_screen.dart
Consumer<HabitVisibilityService>(
  builder: (context, visibility, _) => Scaffold(
    actions: [
      if (visibility.shouldShowWeeklyReview)  // UI only reads boolean
        WeeklyReviewButton(),
    ],
  ),
)

Linting Rule:
# Disallow .isNotEmpty/.isEmpty in widget build methods
# (Would need custom lint rule via dart_code_metrics)
```

---

## Concrete Scenario to Solve

### The Celebration Animation Decision

**Scenario:**
When a user completes a habit and their streak reaches 7 days, we show a celebration animation (confetti burst).

**Current Code (Mixed):**
```dart
// In UI widget
onHabitComplete: () {
  final newStreak = habit.streak + 1;
  if (newStreak == 7) {
    _showCelebrationAnimation();  // Animation trigger in UI
  }
  habitProvider.markComplete(habit);
}
```

**Question:** Where should the "streak == 7" check live?

**Your Task:**
1. Analyze where this logic belongs using your boundary definitions
2. Show the recommended refactored code
3. Explain how this enables "vibe coding" (agent can change animation without touching streak logic)

---

## Deliverables Checklist

### For RQ-008 (UI Logic Separation)
- [ ] Architecture pattern recommendation with rationale
- [ ] Boundary decision tree (flowchart or decision rules)
- [ ] 5+ code examples (correct vs incorrect)
- [ ] `analysis_options.yaml` additions
- [ ] Migration strategy for existing 600+ files
- [ ] Animation logic placement recommendation
- [ ] Navigation logic placement recommendation
- [ ] Confidence levels for each recommendation

### For RQ-009 (LLM Coding Approach)
- [ ] Approach comparison matrix (Work→Right vs Plan→Work vs Iterative)
- [ ] Task classification system (when to use which)
- [ ] Recommended workflow for AI agents
- [ ] Revised Protocol 2 text (if needed)
- [ ] Quality metrics to measure approach effectiveness
- [ ] Confidence levels for each recommendation

### Integration
- [ ] How RQ-008 boundaries affect RQ-009 workflow
- [ ] Combined recommendation for AI agent onboarding

---

## Final Checklist Before Submitting (For Deep Think)

- [ ] Each sub-question has explicit answer
- [ ] All code examples include correct layer placement
- [ ] All recommendations include confidence level
- [ ] Anti-patterns addressed explicitly
- [ ] The Celebration Animation scenario solved step-by-step
- [ ] Integration with existing Provider + Riverpod migration addressed
- [ ] Linting rules are concrete (not vague suggestions)
- [ ] Migration path is incremental (not big-bang rewrite)

---

*End of Prompt*
