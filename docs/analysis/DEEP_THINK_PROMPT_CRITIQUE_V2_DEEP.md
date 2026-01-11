# Deep Critique: v1 Prompts vs DEEP_THINK_PROMPT_GUIDANCE.md

> **Purpose:** Rigorous gap analysis before v2 drafts
> **Date:** 10 January 2026
> **Method:** Line-by-line comparison against mandatory framework requirements

---

## Framework Requirements Audit

### 1. Rich Context (MANDATORY)

| Requirement | RQ-037 | RQ-033 | RQ-025 | Gap Analysis |
|-------------|--------|--------|--------|--------------|
| **Prior Research Summary** | ❌ MISSING | ❌ MISSING | ⚠️ PARTIAL | Lists CDs but NOT completed RQs with key findings |
| **Locked Decisions** | ✅ Has CDs | ✅ Has CDs | ✅ Has CDs | Good |
| **Schema Examples** | ⚠️ Dart only | ✅ Dart code | ❌ No schema | SQL/Dart for data storage not included |
| **Current State** | ✅ Clear | ✅ Clear | ✅ Clear | Good |

**Critical Gap:** The guidance says *"Summarize all completed RQs that inform this research"* — none of the prompts do this properly.

### 2. Structured Sub-Questions (MANDATORY)

| Requirement | RQ-037 | RQ-033 | RQ-025 | Gap Analysis |
|-------------|--------|--------|--------|--------------|
| **Tabular Format** | ✅ | ✅ | ✅ | Good |
| **Explicit Numbering** | ✅ | ✅ | ✅ | Good |
| **Task Clarity** | ✅ | ✅ | ✅ | Good |
| **Tradeoff Framing** | ❌ MISSING | ❌ MISSING | ❌ MISSING | Questions ask for answers, not tradeoff analysis |

**Critical Gap:** The guidance says *"Frame questions as tradeoffs when applicable"* — none of the sub-questions use tradeoff framing.

### 3. Constraints Section (MANDATORY)

| Requirement | RQ-037 | RQ-033 | RQ-025 | Gap Analysis |
|-------------|--------|--------|--------|--------------|
| **Technical Constraints** | ✅ | ✅ | ✅ | Good |
| **UX Constraints** | ✅ | ✅ | ✅ | Good |
| **Resource Constraints QUANTIFIED** | ⚠️ Time only | ❌ MISSING | ⚠️ Partial | Not fully quantified (budget, API calls) |
| **Anti-Patterns section** | ✅ | ✅ | ✅ | Good |

**Gap:** Resource constraints need specific numbers (API budget per user, battery %, etc.)

### 4. Output Format Specification (MANDATORY)

| Requirement | RQ-037 | RQ-033 | RQ-025 | Gap Analysis |
|-------------|--------|--------|--------|--------------|
| **Markdown Structure** | ✅ | ✅ | ✅ | Good |
| **Code Expectations** | ❌ MISSING | ❌ MISSING | ❌ MISSING | "Specify pseudocode, Dart, SQL" not done |
| **Confidence Levels** | ✅ | ✅ | ✅ | Good |
| **Deliverables List** | ✅ | ✅ | ✅ | Good |

**Critical Gap:** None of the prompts specify what code format is expected in deliverables.

### 5. Weaknesses to Avoid (From Guidance)

| Anti-Pattern | RQ-037 | RQ-033 | RQ-025 |
|--------------|--------|--------|--------|
| No Expert Role | ✅ Avoided | ✅ Avoided | ✅ Avoided |
| Missing Think-Chain | ✅ Avoided | ✅ Avoided | ✅ Avoided |
| No Priority Sequence | ✅ Has diagram | N/A (single) | N/A (single) |
| No Examples | ✅ Avoided | ✅ Avoided | ✅ Avoided |
| No Anti-Patterns | ✅ Avoided | ✅ Avoided | ✅ Avoided |
| No Confidence Levels | ✅ Avoided | ✅ Avoided | ✅ Avoided |
| **Single Solution** | ❌ VIOLATED | ❌ VIOLATED | ❌ VIOLATED |
| Weak Interdependencies | ✅ Avoided | ✅ Avoided | ⚠️ Partial |
| No User Scenarios | ✅ Avoided | ✅ Avoided | ✅ Avoided |
| No Literature Guidance | ✅ Avoided | ✅ Avoided | ✅ Avoided |
| No Validation Checklist | ✅ Avoided | ✅ Avoided | ✅ Avoided |

**Critical Gap:** The guidance says *"Present 2-3 options with tradeoffs, then recommend"* — none of the prompts explicitly request this.

---

## Prompt-Specific Deep Gaps

### RQ-037 (Holy Trinity Validation)

**1. Missing Completed RQ Context:**
The following RQs are DIRECTLY relevant but not summarized:
- **RQ-012 (Fractal Trinity):** Established that psychology is fractal — root traits manifest differently per facet
- **RQ-013 (Identity Topology):** Defined how facets relate to each other
- **RQ-014 (State Economics):** Defined 4-state energy model relevant to trait extraction timing
- **RQ-015 (Polymorphic Habits):** Same action serves different facets differently

*Impact:* Deep Think model can't reason about how Holy Trinity fits into already-established psyOS architecture.

**2. Missing `identity_seeds` Schema:**
Prompt says "Traits stored in `identity_seeds` table" but doesn't show actual schema. Should include:
```sql
CREATE TABLE identity_seeds (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  anti_identity_label TEXT,
  anti_identity_context TEXT,
  failure_archetype TEXT,
  failure_trigger_context TEXT,
  resistance_lie_label TEXT,
  resistance_lie_context TEXT,
  extraction_quality_score FLOAT,
  created_at TIMESTAMPTZ
);
```

**3. No Multi-Option Request:**
Sub-question 2 asks "Are these the optimal 3 traits?" but should request:
> "Present 3 model alternatives: (A) Current 3-trait, (B) 4-trait with [X] added, (C) 2-trait simplified. Analyze tradeoffs, then recommend."

**4. Missing API Cost Quantification:**
How many Gemini TTS + DeepSeek calls does extraction require? What's the per-user extraction cost?

**5. No Dart Output Request:**
Should specify: "Provide extraction protocol as Dart pseudocode compatible with existing `PsychometricProfile` class."

---

### RQ-033 (Streak Philosophy)

**1. Missing Completed RQ Context:**
No prior RQs summarized. Relevant ones:
- **RQ-003 (Effectiveness Tracking):** How is habit effectiveness currently measured?
- **RQ-004 (Time Context):** Relationship between time and habit success

**2. Missing Full Graceful Score Implementation:**
Shows formula comments but not actual calculation code. Should include:
```dart
static HabitMetrics _calculateMetrics(Habit habit) {
  final sevenDayAverage = _calculateRollingAverage(habit, 7);
  final recoveryCount = _countQuickRecoveries(habit);
  final timeConsistency = _calculateTimeConsistency(habit);
  final nmtRate = _calculateNeverMissTwiceRate(habit);

  return HabitMetrics(
    gracefulScore: (sevenDayAverage * 0.4) +
                   (recoveryBonus(recoveryCount) * 0.2) +
                   (timeConsistency * 0.2) +
                   (nmtRate * 0.2),
    // ...
  );
}
```

**3. No Multi-Option Request:**
Should explicitly request:
> "Present 3 display strategies: (A) Streak-primary with consistency secondary, (B) Consistency-primary with streak hidden, (C) Hybrid 'resilient streak' that doesn't reset. Analyze psychological tradeoffs for each archetype."

**4. No Tradeoff-Framed Sub-Questions:**
- Q1 should be: "Streak motivation (short-term engagement) vs Habit automaticity (long-term formation) — analyze the tradeoff"
- Q4 should be: "Concrete streak count (vivid, lossy) vs Abstract percentage (accurate, flat) — which drives behavior?"

**5. Missing Battery/Performance Constraint:**
Rolling average calculations happen frequently. What's the performance target?

---

### RQ-025 (Summon Token Economy)

**1. Missing RQ Key Findings:**
Lists RQ-016 and RQ-021 as complete but doesn't include their KEY FINDINGS:
- **RQ-016:** What's the exact Council AI cost model? What did research determine about optimal session length?
- **RQ-021:** What's the treaty success rate that should inform token value?

**2. Missing Database Schema:**
Where are tokens stored? Should include proposed schema:
```sql
CREATE TABLE user_tokens (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  balance INT DEFAULT 0,
  lifetime_earned INT DEFAULT 0,
  lifetime_spent INT DEFAULT 0,
  last_earned_at TIMESTAMPTZ,
  last_spent_at TIMESTAMPTZ
);

CREATE TABLE token_transactions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  amount INT,
  action_type TEXT, -- 'earned', 'spent'
  source TEXT, -- 'streak', 'council_complete', 'purchase'
  created_at TIMESTAMPTZ
);
```

**3. No Multi-Option Request:**
Should explicitly request:
> "Present 3 economy models: (A) Generous (easy earn, abundant access), (B) Balanced (weekly earn rate, monthly spend rate), (C) Scarce (achievement-gated, high-value). Simulate 90-day token flow for each."

**4. No Economy Simulation Request:**
Token economies need modeling. Should request:
> "Provide 90-day simulation showing: tokens earned, tokens spent, balance trajectory for casual (2x/week), regular (5x/week), and power (daily) user segments."

**5. Missing Budget Constraint:**
Has API cost ($0.02-0.10) but no target:
> "Target: Average user should cost < $0.50/month in Council API calls"

---

## Summary: Critical Gaps to Fix in v2

| Gap | Impact | Fix |
|-----|--------|-----|
| **Missing Completed RQ Summaries** | Model can't reason about existing architecture | Add "Prior Research Summary" section with key findings |
| **No Multi-Option Request** | Gets single solution instead of tradeoff analysis | Add explicit "Present 2-3 options with tradeoffs" to each major question |
| **No Tradeoff Framing** | Questions get binary answers instead of nuanced analysis | Reframe sub-questions as explicit tradeoffs |
| **No Code Output Spec** | Unclear what format deliverables should use | Add "Provide in Dart/SQL format" to relevant deliverables |
| **Missing Database Schemas** | Can't reason about data storage | Include actual or proposed schemas |
| **Incomplete Resource Quantification** | Can't make cost-aware recommendations | Add specific budget/performance targets |

---

## v2 Improvement Targets

| Prompt | v1 Score | Target v2 Score | Key Improvements |
|--------|----------|-----------------|------------------|
| RQ-037 | 9.2/10 | 9.7/10 | +RQ summaries, +multi-option, +schema, +code spec |
| RQ-033 | 9.0/10 | 9.6/10 | +RQ summaries, +tradeoff framing, +multi-option, +full code |
| RQ-025 | 8.8/10 | 9.5/10 | +RQ findings, +schema, +simulation, +multi-option |

---

*This critique identifies 6 systemic gaps that reduce Deep Think output quality. v2 drafts will address each.*
