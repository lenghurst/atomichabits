# Deep Think Prompt: Streak Philosophy & Gamification (v2)

> **Target Research:** RQ-033, PD-002
> **Prepared:** 10 January 2026
> **For:** DeepSeek R1 Distilled (per CD-016)
> **App Name:** The Pact
> **Priority:** HIGH — Resolves code/philosophy tension, blocks gamification features
> **Version:** 2.0 — Improved from v1 based on DEEP_THINK_PROMPT_GUIDANCE.md audit

---

## Your Role

You are a **Senior Behavioral Scientist & Gamification Systems Designer** specializing in:
- Habit formation psychology (BJ Fogg, James Clear, Wendy Wood)
- Game design and motivation mechanics (Self-Determination Theory, Flow Theory)
- Behavioral economics (loss aversion, variable reward, endowment effect)
- Streak psychology and "don't break the chain" research
- Metrics design for behavior change applications

**Your approach:** Think step-by-step through each tradeoff. For each major decision point, present 2-3 display/gamification strategies with explicit tradeoffs before recommending. Ground recommendations in BOTH peer-reviewed research AND real-world app data (Duolingo, Headspace, etc.). Balance engagement with long-term habit formation.

---

## Critical Instruction: The Tension to Resolve

The Pact has a **philosophical inconsistency** between code and messaging:

```
CURRENT STATE:
├── Code: Uses streaks heavily (currentStreak, longestStreak properties)
├── Messaging: Says "streaks are vanity metrics"
├── Coaching: Tells perfectionists "We measure rolling consistency"
└── Reality: Both systems exist but guidance is unclear
```

**This research must resolve:** Should The Pact celebrate streaks, hide them, or replace them entirely?

---

## Prior Research Summary: Completed RQs That Inform This Research

### RQ-003: Habit Effectiveness Tracking ✅ COMPLETE
**Key Findings:**
- Effectiveness measured via completion rate, consistency, and habit strength score
- Rolling metrics already calculated: 7-day, 30-day averages
- **Implication for RQ-033:** Infrastructure for rolling consistency exists; question is display priority

### RQ-004: Time Context Analysis ✅ COMPLETE
**Key Findings:**
- Time-of-day affects completion probability
- Users have "prime time" windows for each habit
- **Implication for RQ-033:** Streak breaks may correlate with time disruption, not motivation failure

### RQ-014: State Economics ✅ COMPLETE
**Key Findings:**
- 4-state energy model: high_focus, high_physical, social, recovery
- State mismatches cause habit failures
- **Implication for RQ-033:** "Broken streak" may indicate state conflict, not willpower failure

### RQ-028: Archetype Determination ✅ COMPLETE
**Key Findings:**
- 6 dimensions including Perfectionist-Pragmatist (0.0-1.0)
- High perfectionists (>0.7) at risk for all-or-nothing thinking
- **Implication for RQ-033:** Display strategy MUST vary by perfectionist dimension

---

## Mandatory Context: Locked Decisions

### CD-005: 6-Dimension Archetype Model ✅ CONFIRMED
- Users profiled across 6 dimensions including **Perfectionist-Pragmatist**
- Perfectionist users are at HIGH risk of "all-or-nothing" streak anxiety
- Gamification must adapt to dimensional profile

### CD-015: psyOS Architecture ✅ CONFIRMED
- Identity Facets compete for attention
- Streaks might belong to FACETS, not just HABITS
- "Identity Votes" is the psyOS term for habit completions

### CD-010: Retention Tracking Philosophy ✅ CONFIRMED
- Track retention from BOTH app and user perspective
- "Graduated" users (don't need app) = success, not failure
- **CRITICAL:** Avoid dark patterns that prioritize engagement over outcomes

### CD-018: Engineering Threshold ✅ CONFIRMED
- ESSENTIAL: Core value prop
- VALUABLE: Significant UX improvement
- NICE-TO-HAVE: Marginal improvement
- OVER-ENGINEERED: Complexity without value

---

## Current Implementation: Full Code Context

### Habit Model (habit.dart:21, 70)

```dart
class Habit {
  final String id;
  final String name;
  final int currentStreak;  // De-emphasized, kept for compatibility
  final int longestStreak;  // Historical best, for encouragement
  final double gracefulScore;  // Rolling consistency (0.0-1.0)

  // ... other fields
}
```

### Graceful Consistency Service (consistency_service.dart)

```dart
/// Graceful Consistency > Fragile Streaks philosophy
class ConsistencyService {

  /// Calculate the Graceful Consistency Score
  /// Formula:
  /// - Base (40%): 7-day rolling average
  /// - Recovery Bonus (20%): Quick recovery count
  /// - Stability Bonus (20%): Consistency of completion times
  /// - Never Miss Twice Bonus (20%): Single-miss recovery rate
  static double calculateGracefulConsistencyScore(Habit habit) {
    final sevenDayAverage = _calculateRollingAverage(habit, 7);
    final recoveryCount = _countQuickRecoveries(habit);
    final timeConsistency = _calculateTimeConsistency(habit);
    final nmtRate = _calculateNeverMissTwiceRate(habit);

    return (sevenDayAverage * 0.4) +
           (_recoveryBonus(recoveryCount) * 0.2) +
           (timeConsistency * 0.2) +
           (nmtRate * 0.2);
  }

  /// Calculate 7-day rolling average
  static double _calculateRollingAverage(Habit habit, int days) {
    final completions = habit.getCompletionsInLastDays(days);
    return completions.length / days;
  }

  /// Count quick recoveries (completed day after miss)
  static int _countQuickRecoveries(Habit habit) {
    // Implementation: count instances where miss was followed by completion
    return habit.recoveryEvents.length;
  }

  /// Calculate Never Miss Twice rate
  static double _calculateNeverMissTwiceRate(Habit habit) {
    if (habit.missEvents.isEmpty) return 1.0;
    final singleMisses = habit.missEvents.where((m) => !m.followedByMiss).length;
    return singleMisses / habit.missEvents.length;
  }
}
```

### Coaching Prompt (prompt_factory.dart:186-190)

```dart
// PERFECTIONIST PROTOCOL:
case "PERFECTIONIST":
  specificAdvice = '''
PERFECTIONIST PROTOCOL:
- Explicitly tell them: "Streaks are vanity metrics. We measure rolling consistency."
- Enforce 'Graceful Consistency': "Missing one day doesn't reset anything."
- If they miss, remind them: "99% consistency is still A+. Don't let perfect be the enemy of good."''';
```

### Current UI Tension

| Location | What's Shown | Conflict Level |
|----------|--------------|----------------|
| Habit Card | `currentStreak` days | ❌ HIGH — Celebrates streaks |
| Stats Screen | `gracefulScore` percentage | ✅ LOW — De-emphasizes streaks |
| Coaching | "Streaks are vanity" | ❌ HIGH — Anti-streak messaging |
| Recovery Prompt | "Never miss twice" | ⚠️ MEDIUM — Streak-adjacent framing |

---

## Resource Constraints (Quantified)

| Resource | Constraint | Budget |
|----------|------------|--------|
| **Calculation Frequency** | Graceful score recalculation | On every completion + daily batch |
| **Performance Target** | Score calculation latency | <50ms |
| **Storage** | Per-habit metrics | <500 bytes |
| **Display Updates** | UI refresh frequency | Real-time on completion |
| **A/B Test Duration** | For validation | 30-day minimum |
| **Complexity Threshold** | Must be VALUABLE or higher | Per CD-018 |

---

## Research Question: RQ-033 — Streak Philosophy & Gamification

### Core Question
Should The Pact use streak counts or rolling consistency metrics as the primary gamification mechanic? How should gamification align with habit psychology?

### Why This Matters
- **User Retention:** Streaks drive engagement (Duolingo's business model proves this)
- **User Wellbeing:** Streak anxiety causes dropout (the "broken streak" cliff)
- **Habit Science:** Automatic habits don't need external motivation
- **Product Philosophy:** The Pact claims to be different from gamified habit trackers

### The Problem

**Scenario: The Perfectionist's Dilemma**

> Emma, a PERFECTIONIST archetype user (dimension: 0.8/1.0), has maintained a 47-day meditation streak. On Day 48, she gets food poisoning and can't complete her habit.
>
> **Current System Conflict:**
> - Streak counter shows: "0 days" (reset)
> - Graceful score shows: "98% consistency" (unchanged)
> - Coaching says: "One miss doesn't reset anything"
> - But Emma FEELS like she failed (perfectionist psychology)
>
> **Question:** Which metric should Emma see? How should the app respond?

---

## Sub-Questions (Answer Each Explicitly)

**IMPORTANT:** For questions marked with ⚖️, present 2-3 options with explicit tradeoffs before recommending.

| # | Question | Your Task |
|---|----------|-----------|
| **1** ⚖️ | **Streak vs Consistency Tradeoff:** Short-term engagement (streaks) vs long-term habit formation (consistency)? | Present research on both. Cite 2-3 papers per side. Analyze: At what point does streak motivation become counterproductive? |
| **2** ⚖️ | **Display Strategy Options:** What are the viable display strategies? | Present 3 strategies: (A) Streak-primary, (B) Consistency-primary, (C) Hybrid "resilient streak". Include UI mockup descriptions for each. |
| **3** | **Archetype-Specific Display:** How should display vary by CD-005 dimension? | Create dimension-specific rules for all 6 dimensions. HIGH Perfectionist gets different UI than LOW Perfectionist. |
| **4** ⚖️ | **Concrete vs Abstract Tradeoff:** "47-day streak" (vivid, lossy) vs "98% consistent" (accurate, flat)? | Analyze cognitive impact using Kahneman's concrete vs abstract research. Propose translation strategies. |
| **5** | **The "Broken Streak" Cliff:** What happens psychologically when a streak breaks? | Research on loss aversion, goal abandonment, "what-the-hell effect". Cite Polivy & Herman (2002). |
| **6** ⚖️ | **Recovery Framing Options:** How should the app respond to a broken streak? | Present 3 recovery message strategies with psychological basis. A/B test design included. |
| **7** | **Gamification Alternatives:** What non-streak mechanics support habit formation? | Assess 4+ alternatives: Identity Votes, Levels, Weekly Goals, Resilience Score. Pros/cons table with recommendations. |
| **8** | **Industry Evidence:** What do Duolingo, Headspace, Strava do, and what's the evidence? | Summarize streak implementations. Cite any public research on their effectiveness. |
| **9** | **Hybrid Integration:** Can streaks and rolling consistency coexist? How? | Design "Resilient Streak" that incorporates NMT philosophy. Specify exactly when streak resets. |
| **10** | **Success Metrics:** How do we measure if our gamification approach is working? | Define 5+ KPIs: 30-day retention, habit automation rate, anxiety signals, NMT rate, graduation rate. |

---

## Anti-Patterns to Avoid

- ❌ **Streak worship:** Don't assume streaks are inherently good (engagement ≠ habit formation)
- ❌ **Streak hatred:** Don't assume streaks are inherently bad (some users love them)
- ❌ **One-size-fits-all:** Different archetypes need different approaches
- ❌ **Ignoring industry data:** Duolingo's streak success is real, understand why before dismissing
- ❌ **Over-abstracting:** "98% consistency" may not feel as real as "47 days"
- ❌ **Dark patterns:** Don't use anxiety to drive engagement (violates CD-010)
- ❌ **Feature creep:** Proposing elaborate gamification systems = OVER-ENGINEERED per CD-018
- ❌ **Single solution:** Present multiple strategies with tradeoffs

---

## Output Required

### Deliverable 1: Display Strategy Options (Present 3)

| Strategy | Primary Metric | Secondary Metric | Hidden Data | Best For Archetype | Psychological Basis |
|----------|----------------|------------------|-------------|-------------------|---------------------|
| **A: Streak-Primary** | currentStreak days | gracefulScore % | recoveryCount | LOW Perfectionist | [Cite research] |
| **B: Consistency-Primary** | gracefulScore % | "X of Y days" | currentStreak | HIGH Perfectionist | [Cite research] |
| **C: Resilient Streak** | [Define hybrid] | [Define] | [Define] | MODERATE | [Cite research] |

**Include UI mockup description for each:**
```
STRATEGY A: Streak-Primary
┌─────────────────────────────┐
│  🔥 47 Days                 │  ← Large, prominent
│  98% consistent             │  ← Smaller, secondary
│  [Complete] [Skip]          │
└─────────────────────────────┘

STRATEGY B: Consistency-Primary
┌─────────────────────────────┐
│  98% Consistent             │  ← Large, prominent
│  "47 of 48 days — resilient"│  ← Narrative framing
│  [Complete] [Skip]          │
└─────────────────────────────┘

STRATEGY C: Resilient Streak
┌─────────────────────────────┐
│  🛡️ 47 Days (1 recovery)   │  ← Streak + recovery count
│  "Never Miss Twice: ✅"     │  ← NMT badge
│  [Complete] [Skip]          │
└─────────────────────────────┘
```

### Deliverable 2: Streak Impact Analysis (with Citations)

| Factor | Positive Impact | Negative Impact | Net Assessment | Citation |
|--------|-----------------|-----------------|----------------|----------|
| Short-term motivation | [Evidence] | [Evidence] | +/- | [Paper] |
| Long-term habit formation | [Evidence] | [Evidence] | +/- | [Paper] |
| User anxiety | [Evidence] | [Evidence] | +/- | [Paper] |
| Dropout risk post-break | [Evidence] | [Evidence] | +/- | [Paper] |
| Intrinsic motivation | [Evidence] | [Evidence] | +/- | [Paper] |
| Automatic habit development | [Evidence] | [Evidence] | +/- | [Paper] |

### Deliverable 3: Archetype-Specific Display Rules

Provide Dart implementation specification:

```dart
/// Display strategy selector based on user archetype
class GamificationDisplayStrategy {

  /// Determine primary metric based on perfectionist dimension
  static MetricDisplay getPrimaryMetric(double perfectionistScore) {
    if (perfectionistScore > 0.7) {
      // HIGH Perfectionist: Hide streak, show consistency
      return MetricDisplay.consistency;
    } else if (perfectionistScore > 0.4) {
      // MODERATE: Show resilient streak
      return MetricDisplay.resilientStreak;
    } else {
      // LOW Perfectionist: Traditional streak OK
      return MetricDisplay.streak;
    }
  }

  /// Get recovery message based on archetype
  static String getRecoveryMessage(UserArchetype archetype) {
    switch (archetype.dominantDimension) {
      case 'perfectionist':
        return "[Perfectionist-specific message]";
      case 'rebel':
        return "[Rebel-specific message]";
      // ... for all 6 dimensions
    }
  }
}
```

| CD-005 Dimension | Score Range | Streak Display | Primary Metric | Recovery Framing |
|------------------|-------------|----------------|----------------|------------------|
| HIGH Perfectionist | >0.7 | Hidden | gracefulScore | "98% is A+. Perfect is the enemy of good." |
| MODERATE Perfectionist | 0.4-0.7 | Resilient Streak | resilientStreak | "47 days, 1 recovery. That's resilience." |
| LOW Perfectionist | <0.4 | Traditional | currentStreak | "Back to 1 — let's rebuild." |
| HIGH Rebellious | >0.7 | Optional | Identity Votes | "You showed up on YOUR terms. 47 times." |
| HIGH Novelty-Seeking | >0.7 | Weekly Goals | weeklyTarget | "New week, new goal. 5/5 last week." |
| HIGH Achievement | >0.7 | Levels/Tiers | progressLevel | "Level 7 Writer — 3 more days to Level 8" |

### Deliverable 4: Recovery Flow Design (in Dart)

```dart
/// Recovery flow after streak break
class StreakBreakRecoveryFlow {

  /// Day 0 (Miss Day) - Evening notification
  Notification getMissNotification(Habit habit, UserArchetype archetype) {
    if (archetype.perfectionist > 0.7) {
      return Notification(
        title: "Still 98% consistent",
        body: "One day doesn't define you. ${habit.nmtRate * 100}% NMT rate.",
        // NO streak reset language
      );
    } else {
      return Notification(
        title: "Tomorrow's a new day",
        body: "Your ${habit.currentStreak}-day streak paused. Resume tomorrow.",
      );
    }
  }

  /// Day 1 (Day After Miss) - App open experience
  Widget getDayAfterExperience(Habit habit, UserArchetype archetype) {
    // Return archetype-specific UI
  }

  /// Recovery celebration when user completes after miss
  Widget getRecoveryCelebration(Habit habit) {
    return CelebrationWidget(
      message: "Recovery counted! NMT streak: ${habit.nmtStreak} days",
      // Celebrate the RECOVERY, not just the completion
    );
  }
}
```

### Deliverable 5: "Never Miss Twice" Integration Specification

| Scenario | Streak System | NMT System | Recommended Hybrid | UI Display |
|----------|---------------|------------|-------------------|------------|
| 1 day missed | Reset to 0 | NMT active | Resilient streak continues | "47 days (1 recovery)" |
| 2 days missed (NMT broken) | Reset to 0 | NMT reset | Streak resets | "Streak reset — 0 days" |
| 3+ days missed | Reset to 0 | Recovery mode | Recovery journey starts | "Recovery Day 1" |
| Returned after 1-day miss | New streak: 1 | NMT maintained | Resilient streak continues | "48 days (1 recovery)" |
| Returned after 2-day miss | New streak: 1 | NMT broken | New streak | "Day 1 — fresh start" |

### Deliverable 6: Gamification Alternatives Assessment

| Mechanic | Psychological Basis | Pros | Cons | For Archetype | Recommendation |
|----------|---------------------|------|------|---------------|----------------|
| Streaks | Loss aversion (Kahneman) | [List] | [List] | Low Perfectionist | [Verdict] |
| Identity Votes | SDT — autonomy | [List] | [List] | Rebel | [Verdict] |
| Levels/Tiers | SDT — competence | [List] | [List] | Achievement | [Verdict] |
| Rolling Average | Growth mindset | [List] | [List] | Perfectionist | [Verdict] |
| Weekly Goals | Fresh start effect | [List] | [List] | Novelty-Seeker | [Verdict] |
| Resilience Score | Post-traumatic growth | [List] | [List] | All | [Verdict] |

### Deliverable 7: Success Metrics with Targets

| Metric | Definition | Collection Method | Target | Warning Sign | Diagnostic Action |
|--------|------------|-------------------|--------|--------------|-------------------|
| 30-Day Retention | % users active at day 30 | Analytics | >40% | <30% | Check recovery flow |
| NMT Rate | % of misses followed by next-day completion | Automatic | >70% | <50% | Improve recovery messaging |
| Streak Anxiety Signal | Users who check app 3+ times on miss day | Analytics | <10% | >20% | Hide streak for this user |
| Habit Automation Rate | Habits completed without reminder | Analytics | >50% at 60 days | <30% | Reduce gamification |
| Graduation Rate | Users who "don't need app anymore" | Self-report | Track (success metric) | N/A | Celebrate these users |

### Deliverable 8: Confidence Assessment

| Recommendation | Confidence | Rationale | Follow-Up Needed |
|----------------|------------|-----------|------------------|
| Archetype-specific display | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what A/B test?] |
| Resilient streak concept | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what research?] |
| NMT integration | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what validation?] |
| Recovery flow design | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what test?] |
| Hide streaks for perfectionists | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what data?] |

---

## Example of Good Output: Display Strategy Analysis

```markdown
### Strategy C: Resilient Streak — Detailed Analysis

**Definition:**
A "Resilient Streak" counts consecutive days of EITHER completion OR single-day recovery. The streak only resets when NMT is violated (2+ consecutive misses).

**UI Mockup:**
┌─────────────────────────────────────┐
│  🛡️ 47 Days                        │
│  "1 recovery, 0 defeats"            │
│  ███████████████████░ 98%           │
│  [Complete Today]                   │
└─────────────────────────────────────┘

**Psychological Basis:**
1. **Lally et al. (2010):** Single missed days don't significantly impact habit formation
2. **Dweck (2006):** Growth mindset — celebrates recovery, not just perfection
3. **SDT (Ryan & Deci):** Maintains autonomy by not punishing single misses

**Implementation:**

```dart
int calculateResilientStreak(Habit habit) {
  int resilientStreak = 0;
  bool previousWasMiss = false;

  for (final day in habit.history.reversed) {
    if (day.completed) {
      resilientStreak++;
      previousWasMiss = false;
    } else if (!previousWasMiss) {
      // First miss — streak continues (NMT in effect)
      resilientStreak++;  // Count the miss as "protected"
      previousWasMiss = true;
    } else {
      // Second consecutive miss — streak resets
      break;
    }
  }
  return resilientStreak;
}
```

**Archetype Fit:**
- HIGH Perfectionist: ✅ Reduces anxiety (miss doesn't reset)
- LOW Perfectionist: ✅ Still feels like "streak" (familiar mechanic)
- Rebel: ⚠️ May feel like "rules" — offer opt-out

**Tradeoffs:**
| Pro | Con |
|-----|-----|
| Reduces broken streak anxiety | May feel like "cheating" to some users |
| Aligns with habit science (NMT) | More complex to explain |
| Celebrates resilience, not just perfection | Requires tracking recovery events |

**Recommendation: IMPLEMENT for Perfectionist dimension >0.4**
```

---

## Concrete Scenario: Solve This

**Emma's Broken Streak (Full Scenario)**

Emma (PERFECTIONIST dimension: 0.8/1.0) has:
- 47-day meditation streak (about to hit 50-day milestone)
- 98% graceful consistency score
- Never missed twice (100% NMT rate)

Day 48: Food poisoning. Can't meditate.

**Walk through EXACTLY what happens:**

1. **What notification does Emma receive that evening?**
   - Provide exact copy
   - Justify based on archetype

2. **What does she see when opening the app Day 49?**
   - Describe UI state
   - What metric is PRIMARY?
   - What metric is SECONDARY/HIDDEN?

3. **What does the coaching system say?**
   - Provide exact message
   - Reference her PERFECTIONIST archetype

4. **When Emma completes Day 49, how do we celebrate?**
   - Describe celebration UI
   - Focus on RECOVERY, not just completion

5. **What happens to her "streak" display long-term?**
   - Does it show 0? 47? 48?
   - Justify with psychological research

**Success Criteria:**
- Emma doesn't feel like a failure
- Emma is motivated to continue
- Emma's high-perfectionist profile is respected
- The system is psychologically honest (not manipulative)

---

## Literature to Consider

**Required (cite for streak analysis):**
- **Habit Formation:** Lally et al. (2010), Wood & Neal (2007), Clear (2018)
- **Goal Abandonment:** Polivy & Herman (2002) — "What-the-Hell Effect"
- **Loss Aversion:** Kahneman & Tversky (1979)
- **Self-Determination Theory:** Ryan & Deci (2000, 2017)

**Required (cite for gamification):**
- **Gamification Research:** Deterding et al. (2011), Hamari et al. (2014)
- **Goal Setting:** Locke & Latham (2002)
- **Growth Mindset:** Dweck (2006)

**Industry Data (cite if available):**
- Duolingo streak research (any public data)
- Headspace retention data
- Strava "Kudos" engagement data

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Research-Grounded** | Are ALL recommendations backed by cited research? |
| **Tradeoff-Aware** | Did you present 2-3 options for major decisions? |
| **Archetype-Aware** | Does solution adapt to all 6 CD-005 dimensions? |
| **Implementable** | Is Dart pseudocode provided for key logic? |
| **User-Centric** | Does it prioritize user wellbeing over engagement? |
| **Measurable** | Are KPIs defined with targets and warning signs? |
| **Philosophically Consistent** | Does it resolve the code/messaging tension? |
| **CD-010 Compliant** | Are dark patterns explicitly avoided? |

---

## Final Checklist Before Submitting

- [ ] Each sub-question (1-10) has explicit answer with citations
- [ ] Questions marked ⚖️ have 2-3 options with tradeoff analysis
- [ ] Display strategy options table completed (3 strategies with mockups)
- [ ] Streak impact analysis completed with citations for each factor
- [ ] Archetype-specific display rules for all 6 dimensions
- [ ] Recovery flow provided in Dart pseudocode
- [ ] "Never Miss Twice" integration table completed
- [ ] Gamification alternatives assessed (6+ mechanics)
- [ ] Success metrics have targets AND warning signs
- [ ] Confidence levels stated for each major recommendation
- [ ] Emma scenario solved step-by-step with exact copy
- [ ] Anti-patterns explicitly avoided
- [ ] Solution respects CD-010 (no dark patterns verified)
- [ ] Integration with RQ-003, RQ-004, RQ-014, RQ-028 explicit

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework (v2 improvements applied).*
