# Witness JITAI Architecture Analysis

> **Created:** 11 January 2026
> **Status:** DRAFT — Architectural exploration
> **Related:** RQ-040, Deep Think "The Confidant" proposal
> **Insight Origin:** "Could we apply JITAI except with an outward witness focus?"

---

## The Core Insight

**Current JITAI** adapts interventions for the **creator** based on their context:
```
Creator Context → JITAI Decision Engine → Personalized Intervention → Creator
```

**Witness JITAI** could adapt what **witnesses see** based on multiple contexts:
```
Creator State + Witness Context + Role Type → Witness JITAI → Tailored Narrative → Witness
```

This aligns perfectly with **"The Confidant"** model from Deep Think: witnesses don't just observe completions — they see the **inner battle** (Parliament of Selves narrative).

---

## Current JITAI Architecture Summary

### Inputs (ContextSnapshot)
```dart
ContextSnapshot {
  TimeContext time;          // Hour, day, weekend
  BiometricContext? bio;     // Sleep, HRV z-scores
  CalendarContext? calendar; // Busyness, meetings
  WeatherContext? weather;   // Outdoor suitability
  LocationContext? location; // Home, work, gym
  DigitalContext? digital;   // Distraction level
  HistoricalContext history; // Streak, identity score
}
```

### Decision Engine
```dart
JITAIDecisionEngine.decide() {
  1. Calculate V-O State (Vulnerability × Opportunity)
  2. Check Safety Gates (fatigue, timing, Gottman)
  3. Check Cascade Risk (weather, travel, patterns)
  4. Select Intervention Arm (Hierarchical Bandit)
  5. Generate Content (archetype-aware templates)
}
```

### Output
```dart
JITAIDecision {
  InterventionContent content;  // Title, body, CTA
  BurdenType burden;            // Deposit/withdrawal
  InterventionArm arm;          // Which mechanism
}
```

---

## Witness JITAI: Conceptual Model

### What Makes Witness Different?

| Aspect | Creator JITAI | Witness JITAI |
|--------|---------------|---------------|
| **Primary Goal** | Change creator behavior | Maintain witness engagement + eventual conversion |
| **Context Source** | Creator's own sensors | Creator's state + witness's engagement |
| **Sensitivity** | High (direct intervention) | Medium (narrative sharing) |
| **Personalization** | By archetype | By role type |
| **Complexity** | 20+ parameters | 5-8 parameters (simpler) |

### Witness JITAI Inputs (Reduced Parameter Set)

```dart
WitnessContext {
  // Creator's State (what story to tell)
  CreatorState creatorState;  // Streak, facet battles, milestones

  // Witness's Engagement (when to reach)
  WitnessEngagement engagement;  // Active, dormant, last_interaction

  // Role Type (how to frame)
  WitnessRoleType roleType;  // Confidant, Cheerleader, Mentor

  // Relationship (depth of narrative)
  RelationshipStrength relationship;  // Close, casual

  // Timing (fatigue prevention)
  Duration timeSinceLastNotification;
}
```

### Witness JITAI Outputs

```dart
WitnessNotification {
  WitnessNarrativeType narrativeType;  // Battle, win, struggle, milestone
  String title;
  String body;
  List<WitnessAction> actions;  // Encourage, challenge, convert
  DateTime? scheduledFor;  // Optimal timing
}
```

---

## Three Refactor Approaches

### Option A: Extend Existing JITAIDecisionEngine

**Concept:** Add an `Audience` parameter to the existing engine.

```dart
enum Audience { SELF, WITNESS, COUNCIL }

class JITAIDecisionEngine {
  Future<JITAIDecision> decide({
    required ContextSnapshot context,
    required PsychometricProfile profile,
    required Habit habit,
    Audience audience = Audience.SELF,  // NEW
    WitnessProfile? witnessProfile,      // NEW (for WITNESS)
  }) async {
    if (audience == Audience.WITNESS) {
      return _decideForWitness(context, witnessProfile!);
    }
    // ... existing logic
  }

  Future<JITAIDecision> _decideForWitness(
    ContextSnapshot creatorContext,
    WitnessProfile witness,
  ) async {
    // Simplified decision logic for witnesses
    final narrative = _selectNarrative(creatorContext, witness.roleType);
    final timing = _selectWitnessTiming(witness);
    final content = _generateWitnessContent(narrative, witness);
    // ...
  }
}
```

**Pros:**
- Single source of truth for all interventions
- Shared infrastructure (timing, fatigue)
- Easy to compare creator vs witness decisions

**Cons:**
- Complicates an already complex engine
- Different concerns mixed (behavior change vs engagement)
- Harder to maintain/test

**Complexity:** HIGH
**Recommendation:** AVOID — couples unrelated concerns

---

### Option B: Separate WitnessJITAIService (Recommended)

**Concept:** Purpose-built service with reduced parameter set.

```dart
/// Simplified JITAI for witness notifications
///
/// Design philosophy: Witnesses need NARRATIVE, not intervention.
/// Reduced parameter set focused on storytelling.
class WitnessJITAIService {
  final WitnessNotificationThrottler _throttler;
  final NarrativeGenerator _narrativeGen;

  /// Decide what to tell a witness, and when
  Future<WitnessDecision> decide({
    required CreatorState creatorState,
    required WitnessProfile witness,
  }) async {
    // 1. Check throttling (fatigue prevention)
    if (_throttler.isFatigued(witness.id)) {
      return WitnessDecision.defer();
    }

    // 2. Select narrative type based on role + creator state
    final narrative = _selectNarrative(
      creatorState: creatorState,
      roleType: witness.roleType,
      permissions: witness.permissions,
    );

    // 3. Generate content
    final content = _narrativeGen.generate(
      narrative: narrative,
      creatorName: creatorState.creatorName,
      facetBattle: creatorState.currentFacetBattle,
      milestone: creatorState.recentMilestone,
    );

    // 4. Determine optimal timing
    final timing = _calculateTiming(witness, narrative);

    return WitnessDecision.notify(
      content: content,
      scheduledFor: timing,
      actions: _getActionsForRole(witness.roleType),
    );
  }

  NarrativeType _selectNarrative({
    required CreatorState creatorState,
    required WitnessRoleType roleType,
    required WitnessPermissions permissions,
  }) {
    // Role-based narrative selection
    switch (roleType) {
      case WitnessRoleType.confidant:
        // Confidant sees the inner battle
        if (creatorState.hasActiveFacetBattle && permissions.canSeeFacetBattles) {
          return NarrativeType.facetBattle;
        }
        if (creatorState.isStruggling && permissions.canSeeStruggles) {
          return NarrativeType.struggle;
        }
        return NarrativeType.progress;

      case WitnessRoleType.cheerleader:
        // Cheerleader sees wins only
        if (creatorState.recentMilestone != null) {
          return NarrativeType.milestone;
        }
        if (creatorState.completedToday) {
          return NarrativeType.win;
        }
        return NarrativeType.none;  // Silence if no wins

      case WitnessRoleType.mentor:
        // Mentor sees struggles + can guide
        if (creatorState.isStruggling) {
          return NarrativeType.struggleWithGuidance;
        }
        return NarrativeType.weeklyDigest;
    }
  }
}
```

**Pros:**
- Clean separation of concerns
- Simpler, more maintainable
- Role types as first-class concept
- Easier to test in isolation

**Cons:**
- Some duplication (timing logic, throttling)
- Two systems to maintain

**Complexity:** MEDIUM
**Recommendation:** PREFERRED — right level of abstraction

---

### Option C: Role-Based Database Configuration (Hybrid)

**Concept:** Define role permissions and templates in database, minimal code.

```sql
-- Role definitions with permissions
CREATE TABLE witness_role_types (
  id TEXT PRIMARY KEY,  -- 'confidant', 'cheerleader', 'mentor'
  display_name TEXT NOT NULL,
  description TEXT,

  -- Narrative permissions
  can_see_facet_battles BOOLEAN DEFAULT FALSE,
  can_see_struggles BOOLEAN DEFAULT FALSE,
  can_see_completions BOOLEAN DEFAULT TRUE,
  can_see_streaks BOOLEAN DEFAULT TRUE,
  can_see_milestones BOOLEAN DEFAULT TRUE,

  -- Action permissions
  can_send_encouragement BOOLEAN DEFAULT TRUE,
  can_send_challenges BOOLEAN DEFAULT FALSE,
  can_request_update BOOLEAN DEFAULT FALSE,

  -- Notification settings
  default_cadence TEXT DEFAULT 'milestone',  -- 'realtime', 'daily_digest', 'weekly_digest', 'milestone'
  max_notifications_per_week INT DEFAULT 7,

  -- Template set
  template_set_id TEXT NOT NULL,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed data
INSERT INTO witness_role_types VALUES
  ('confidant', 'The Confidant', 'Sees the inner battle. Gets exclusive insight into the struggle.',
   TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, 'milestone', 7, 'confidant_templates', NOW()),

  ('cheerleader', 'The Cheerleader', 'Celebrates wins. Only sees positive moments.',
   FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, 'milestone', 3, 'cheerleader_templates', NOW()),

  ('mentor', 'The Mentor', 'Guides through struggles. Can offer challenges.',
   FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, 'weekly_digest', 5, 'mentor_templates', NOW());

-- Notification templates by role
CREATE TABLE witness_notification_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_set_id TEXT NOT NULL,
  narrative_type TEXT NOT NULL,  -- 'facet_battle', 'struggle', 'win', 'milestone', 'digest'
  title_template TEXT NOT NULL,
  body_template TEXT NOT NULL,
  action_labels JSONB,

  -- Variables: {creator_name}, {facet_winning}, {facet_losing}, {streak}, {milestone_name}

  UNIQUE(template_set_id, narrative_type)
);

-- Example templates
INSERT INTO witness_notification_templates VALUES
  (gen_random_uuid(), 'confidant_templates', 'facet_battle',
   '{creator_name}''s inner battle',
   'The {facet_winning} is fighting the {facet_losing} today. {creator_name} could use your belief.',
   '{"primary": "Send strength", "secondary": "Watch quietly"}'),

  (gen_random_uuid(), 'confidant_templates', 'struggle',
   '{creator_name} is struggling',
   'Day {days_since_completion} without a vote. The {facet_losing} is winning. You see what they can''t.',
   '{"primary": "Reach out", "secondary": "Send a message"}'),

  (gen_random_uuid(), 'cheerleader_templates', 'milestone',
   '🎉 {creator_name} hit {milestone_name}!',
   '{streak} days strong. Your support matters.',
   '{"primary": "Celebrate!", "secondary": "Send encouragement"}');
```

```dart
/// Thin service layer that reads from database config
class WitnessJITAIService {
  final SupabaseClient _supabase;

  Future<WitnessDecision> decide({
    required CreatorState creatorState,
    required WitnessProfile witness,
  }) async {
    // 1. Get role config from database
    final roleConfig = await _getRoleConfig(witness.roleType);

    // 2. Determine narrative based on permissions
    final narrative = _selectNarrative(creatorState, roleConfig);
    if (narrative == null) return WitnessDecision.none();

    // 3. Get template from database
    final template = await _getTemplate(roleConfig.templateSetId, narrative);

    // 4. Fill template
    final content = _fillTemplate(template, creatorState);

    // 5. Check cadence
    if (!_shouldNotify(witness, roleConfig)) {
      return WitnessDecision.defer();
    }

    return WitnessDecision.notify(content: content);
  }

  NarrativeType? _selectNarrative(CreatorState state, RoleConfig config) {
    // Permission-based selection
    if (state.hasActiveFacetBattle && config.canSeeFacetBattles) {
      return NarrativeType.facetBattle;
    }
    if (state.isStruggling && config.canSeeStruggles) {
      return NarrativeType.struggle;
    }
    if (state.recentMilestone != null && config.canSeeMilestones) {
      return NarrativeType.milestone;
    }
    if (state.completedToday && config.canSeeCompletions) {
      return NarrativeType.win;
    }
    return null;  // Nothing to share for this role
  }
}
```

**Pros:**
- Configuration-driven (change behavior without deploy)
- Easy to add new roles
- Templates are editable by product team
- Very thin code layer

**Cons:**
- Requires database schema changes
- More complex queries
- Template system can become unwieldy

**Complexity:** MEDIUM
**Recommendation:** GOOD FOR SCALE — consider for v2

---

## Recommended Architecture: Option B + C Hybrid

### Phase 1: WitnessJITAIService (Code-First)

Start with Option B for MVP:

```dart
// lib/domain/services/witness_jitai_service.dart

enum WitnessRoleType {
  confidant,   // "I see the inner battle"
  cheerleader, // Wins only
  mentor,      // Struggles + guidance
}

class WitnessPermissions {
  final bool canSeeFacetBattles;
  final bool canSeeStruggles;
  final bool canSeeCompletions;
  final bool canSeeMilestones;
  final bool canSendEncouragement;
  final bool canSendChallenges;

  factory WitnessPermissions.forRole(WitnessRoleType role) {
    switch (role) {
      case WitnessRoleType.confidant:
        return WitnessPermissions(
          canSeeFacetBattles: true,
          canSeeStruggles: true,
          canSeeCompletions: true,
          canSeeMilestones: true,
          canSendEncouragement: true,
          canSendChallenges: false,
        );
      case WitnessRoleType.cheerleader:
        return WitnessPermissions(
          canSeeFacetBattles: false,
          canSeeStruggles: false,
          canSeeCompletions: true,
          canSeeMilestones: true,
          canSendEncouragement: true,
          canSendChallenges: false,
        );
      case WitnessRoleType.mentor:
        return WitnessPermissions(
          canSeeFacetBattles: false,
          canSeeStruggles: true,
          canSeeCompletions: true,
          canSeeMilestones: true,
          canSendEncouragement: true,
          canSendChallenges: true,
        );
    }
  }
}

class WitnessJITAIService {
  static const int _maxNotificationsPerWeek = 7;
  static const Duration _minNotificationInterval = Duration(hours: 24);

  Future<WitnessDecision> decide({
    required CreatorState creatorState,
    required WitnessProfile witness,
  }) async {
    final permissions = WitnessPermissions.forRole(witness.roleType);

    // 1. Check fatigue
    if (_isFatigued(witness)) {
      return WitnessDecision.defer(reason: 'notification_fatigue');
    }

    // 2. Select narrative
    final narrative = _selectNarrative(creatorState, permissions, witness.roleType);
    if (narrative == null) {
      return WitnessDecision.none(reason: 'no_relevant_narrative');
    }

    // 3. Generate content
    final content = _generateContent(narrative, creatorState, witness);

    // 4. Determine actions
    final actions = _getActions(permissions, narrative);

    return WitnessDecision.notify(
      narrative: narrative,
      content: content,
      actions: actions,
    );
  }

  WitnessNarrative? _selectNarrative(
    CreatorState state,
    WitnessPermissions perms,
    WitnessRoleType role,
  ) {
    // Priority order: Facet battles > Milestones > Struggles > Wins

    if (state.hasActiveFacetBattle && perms.canSeeFacetBattles) {
      return WitnessNarrative.facetBattle(
        winningFacet: state.winningFacet,
        losingFacet: state.losingFacet,
      );
    }

    if (state.recentMilestone != null && perms.canSeeMilestones) {
      return WitnessNarrative.milestone(state.recentMilestone!);
    }

    if (state.isStruggling && perms.canSeeStruggles) {
      return WitnessNarrative.struggle(
        daysSinceLast: state.daysSinceLastCompletion,
        canGuidance: role == WitnessRoleType.mentor,
      );
    }

    if (state.completedToday && perms.canSeeCompletions) {
      return WitnessNarrative.win(streak: state.currentStreak);
    }

    return null;
  }

  WitnessContent _generateContent(
    WitnessNarrative narrative,
    CreatorState state,
    WitnessProfile witness,
  ) {
    switch (narrative) {
      case FacetBattleNarrative n:
        return WitnessContent(
          title: "${state.creatorName}'s inner battle",
          body: "The ${n.winningFacet} is fighting the ${n.losingFacet} today. "
                "${state.creatorName} could use your belief.",
        );

      case MilestoneNarrative n:
        return WitnessContent(
          title: "🎉 ${state.creatorName} hit ${n.milestoneName}!",
          body: "${state.currentStreak} days strong. Your support matters.",
        );

      case StruggleNarrative n:
        if (n.canGuidance) {
          return WitnessContent(
            title: "${state.creatorName} could use your guidance",
            body: "Day ${n.daysSinceLast} without a vote. "
                  "As their mentor, your words carry weight.",
          );
        } else {
          return WitnessContent(
            title: "${state.creatorName} is in a tough moment",
            body: "They haven't checked in for ${n.daysSinceLast} days. "
                  "Sometimes just knowing someone sees you is enough.",
          );
        }

      case WinNarrative n:
        return WitnessContent(
          title: "${state.creatorName} showed up today",
          body: "Day ${n.streak} in the books. Small wins add up.",
        );
    }
  }
}
```

### Phase 2: Move to Database Config (Optional)

When we need:
- Product team to edit templates without deploys
- A/B testing of notification copy
- Per-user role customization

Then migrate to Option C schema.

---

## Schema Changes Required

### Extend witness_relationships

```sql
-- Add role type and notification tracking
ALTER TABLE witness_relationships
  ADD COLUMN role_type TEXT DEFAULT 'confidant',
  ADD COLUMN notification_count_this_week INT DEFAULT 0,
  ADD COLUMN last_notification_at TIMESTAMPTZ,
  ADD COLUMN notification_preferences JSONB DEFAULT '{"cadence": "milestone", "enabled": true}';

-- Add constraint
ALTER TABLE witness_relationships
  ADD CONSTRAINT valid_role_type
  CHECK (role_type IN ('confidant', 'cheerleader', 'mentor'));
```

### New table for creator state (if not exists)

```sql
-- Materialized view or table for creator state
CREATE TABLE creator_state_cache (
  creator_id UUID PRIMARY KEY REFERENCES profiles(id),
  current_streak INT DEFAULT 0,
  days_since_last_completion INT DEFAULT 0,
  is_struggling BOOLEAN DEFAULT FALSE,
  recent_milestone TEXT,
  winning_facet TEXT,
  losing_facet TEXT,
  has_active_facet_battle BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Update trigger when habits change
-- (implementation depends on habit completion flow)
```

---

## Comparison to Current JITAI

| Dimension | Creator JITAI | Witness JITAI |
|-----------|---------------|---------------|
| **Parameters** | ~25 (full context) | ~8 (reduced) |
| **Decision Frequency** | Every 15-30 min | On events + digest |
| **Safety Gates** | 5 (timing, fatigue, Gottman, cascade, sensitivity) | 2 (fatigue, cadence) |
| **Personalization** | By archetype + profile | By role type |
| **Content Generation** | Template + LLM fallback | Template only (simpler) |
| **Outcome Tracking** | Thompson Sampling bandit | Simple engagement metrics |
| **Complexity** | HIGH | LOW-MEDIUM |

---

## Implementation Priority

| Phase | Task | Complexity | Value |
|-------|------|------------|-------|
| **1** | Define WitnessRoleType enum + permissions | LOW | ESSENTIAL |
| **2** | Create WitnessJITAIService skeleton | MEDIUM | ESSENTIAL |
| **3** | Implement role-based narrative selection | MEDIUM | ESSENTIAL |
| **4** | Add notification throttling | LOW | ESSENTIAL |
| **5** | Create template system | MEDIUM | VALUABLE |
| **6** | Add role selection in witness invitation flow | LOW | VALUABLE |
| **7** | Migrate to database config | HIGH | NICE-TO-HAVE |

---

## Key Insight: "The Confidant" Maps Perfectly

Deep Think's "The Confidant" model:
> "I see the inner battle."

This is **exactly** what role-based Witness JITAI enables:
- `canSeeFacetBattles: true` → Confidant sees Parliament of Selves narrative
- `canSeeStruggles: true` → Confidant sees the real story, not just wins
- Narrative templates that expose the *struggle*, not just the *outcome*

The Cheerleader only sees wins = simpler relationship
The Mentor sees struggles + can act = deeper investment

**This is not just a permissions system — it's a storytelling framework.**

---

## Questions for Further Research (RQ-040 Sub-Questions)

1. **RQ-040h:** What's the optimal notification cadence by role type?
2. **RQ-040i:** Should witnesses choose their role, or should creators assign it?
3. **RQ-040j:** How does role type affect conversion rate to creator?
4. **RQ-040k:** Should role type be static or evolve with relationship depth?

---

*This document explores the architectural question: "Could we apply JITAI with an outward witness focus?" The answer is YES, with a purpose-built service that uses reduced parameters and role-based permissions.*
