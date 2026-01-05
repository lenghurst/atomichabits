# PRODUCT_DECISIONS.md — Product Philosophy & Pending Decisions

> **Last Updated:** 05 January 2026
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

## Confirmed Decisions

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

---

## Pending Decisions — Tier 1 (Foundational)

These decisions BLOCK other work. They must be resolved first.

### PD-001: Archetype Philosophy
| Field | Value |
|-------|-------|
| **Question** | Should archetypes be hardcoded buckets or dynamically AI-generated? |
| **Status** | PENDING |
| **Blocking** | Evolution logic, coaching personalization, JITAI seeding |
| **Current State** | 6 hardcoded archetypes with PERFECTIONIST as fallback |

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

---

### PD-002: Streaks vs Rolling Consistency
| Field | Value |
|-------|-------|
| **Question** | Should we use streak counts or rolling consistency metrics? |
| **Status** | PENDING |
| **Blocking** | Evolution milestones, UI messaging, gamification strategy |
| **Current State** | Code uses streaks heavily; messaging says "streaks are vanity metrics" |

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

---

### PD-003: Holy Trinity Validity
| Field | Value |
|-------|-------|
| **Question** | Is the 3-trait model (Anti-Identity, Archetype, Resistance Lie) sufficient? |
| **Status** | PENDING |
| **Blocking** | Sherlock prompt design, personalization strategy |
| **Current State** | Implemented but extraction quality is uncertain |

**Questions to Answer:**
1. Are all 3 traits equally important?
2. Is freeform AI extraction accurate enough?
3. Should we validate extracted traits with the user?
4. Do we need more than 3 traits?

---

### PD-004: Dev Mode Purpose
| Field | Value |
|-------|-------|
| **Question** | What should dev mode control? Keep, remove, or refine? |
| **Status** | PENDING |
| **Blocking** | Production safety, testing workflow |
| **Current State** | Controls premium toggle, skip onboarding, nav shortcuts, logs |

**Questions to Answer:**
1. Is dev mode only for testing or should it exist in production?
2. Should dev mode be accessible in release builds?
3. What safeguards prevent dev mode abuse?

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

**Current Issues:**
- No maximum turn count (conversation fatigue risk)
- No extraction success criteria
- No handling for user confusion
- "Parts Detective" framing may confuse users

**Proposed Improvements:**
1. Add turn limit (5-7 turns max)
2. Define extraction success criteria
3. Add progress indicators ("We're almost there")
4. Add escape hatch for frustrated users
5. Follow prompt engineering best practices

---

### PD-102: JITAI Hardcoded vs AI
| Field | Value |
|-------|-------|
| **Question** | Which JITAI components should be hardcoded vs AI-learned? |
| **Status** | PENDING |
| **Depends On** | PD-001 (Archetype Philosophy) |
| **Current State** | Hybrid — hardcoded weights with Thompson Sampling |

**Current Components:**
| Component | Current Approach | Alternative |
|-----------|-----------------|-------------|
| Base vulnerability weights | Hardcoded | AI-learned |
| V-O thresholds | Hardcoded (0.5) | User-configurable |
| Intervention taxonomy | Hardcoded 7 arms | Dynamically generated |
| Population priors | Seeded from archetype | Individual learning |

**Questions to Answer:**
1. What's industry best practice for JITAI systems?
2. How much personalization is too much vs too little?
3. Do we have enough data to train AI models?

---

### PD-103: Sensitivity Detection
| Field | Value |
|-------|-------|
| **Question** | How should we detect sensitive goals (addiction, private issues)? |
| **Status** | PENDING — Proposed Approach Ready |
| **Depends On** | Demographic/firmographic data collection |

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

---

### PD-104: LoadingInsightsScreen Personalization
| Field | Value |
|-------|-------|
| **Question** | What personalized insights should be shown during loading? |
| **Status** | PENDING |
| **Depends On** | PD-003 (Holy Trinity), JITAI baseline calculations |
| **Current State** | Generic spinner |

**Proposed Insights:**
1. Holy Trinity insight: "We see the [Archetype] in you"
2. Baseline insight: "Your energy peaks at [time]"
3. Risk insight: "[Weekends/Evenings] are your drop-off zone"

**Questions to Answer:**
1. What permissions data can we use?
2. How do we calculate baseline without history?
3. How confident do we need to be before showing insight?

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
