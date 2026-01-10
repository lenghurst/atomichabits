# Deep Think Prompt: Treaty Modification & Renegotiation Flow

> **Target Research:** RQ-024, PD-118
> **Prepared:** 10 January 2026
> **For:** DeepSeek V3.2 (per CD-016)
> **App Name:** The Pact
> **Priority:** HIGH — Core to treaty lifecycle, blocks E-05/E-06

---

## Your Role

You are a **Senior UX Architect & Behavioral Systems Designer** specializing in:
- Gamification mechanics and psychological weight in digital interactions
- State machine design for complex lifecycle flows
- Conflict resolution systems in habit/productivity apps
- Mobile UX patterns for emotionally significant user actions

Your approach: Think step-by-step through the user's emotional journey. Consider how modifications affect the psychological "weight" of treaties. Balance flexibility with ceremony.

---

## Critical Instruction: Maintain Treaty Gravitas

The treaty system uses **legal/constitutional metaphors** deliberately. Treaties are NOT settings. They are solemn agreements between identity facets, ratified with ritual. Any modification flow must **preserve this gravitas** while remaining practically usable.

```
DESIGN PRINCIPLE:
├── Changing a setting = Quick toggle
├── Modifying a treaty = Constitutional amendment
│   ├── Minor amendment = Direct edit with acknowledgment
│   └── Major amendment = Reconvene negotiating parties
└── Breaching probation = Crisis intervention
```

---

## Mandatory Context: Locked Architecture

### RQ-021: Treaty Lifecycle & UX ✅ COMPLETE
- **Treaty Creation Wizard:** 3-step flow (Source → Drafting → Ratification)
- **Ratification Ritual:** 3-second long-press with haptic feedback
- **The Constitution:** Management dashboard with Active Laws, Probation, Archives
- **Templates:** 5 launch templates (Sunset Clause, Deep Work Decree, etc.)
- **Council AI Access:** tension > 0.7 OR Summon Token

### RQ-020: Treaty-JITAI Integration ✅ COMPLETE
- **Pipeline Position:** Stage 3 (Post-Safety, Pre-Optimization)
- **Logic Parser:** `json_logic_dart` package
- **Severity Levels:** Hard (block) vs Soft (warn)
- **Breach Escalation:**
  - 0–2 breaches: Active status, logging only
  - 3 breaches: **Probationary** status, prompt renegotiation
  - 5+ breaches: **Auto-Suspended**
  - 3 dismissed prompts: Auto-Suspended

### RQ-016: Council AI ✅ COMPLETE
- **Architecture:** Single-Shot Playwright (Sherlock narrates)
- **Turn Limit:** 6 per session
- **Rate Limit:** 1 auto-summon per 24h per conflict topic
- **Output:** Draft treaty with terms_text + logic_hooks

### PD-115: Treaty Creation UX ✅ RESOLVED
- **Decision:** Templates for simple (80%), Council for complex (20%)
- **First-time user:** Low-stakes "Digital Sunset" on Day 1

### CD-015: psyOS Architecture ✅ CONFIRMED
- Treaties are agreements between identity facets (Parliament metaphor)
- Facets are negotiating parties, not just user preferences

### CD-017: Android-First ✅ CONFIRMED
- All flows must work on Android without wearables
- VibrationEffect API for haptics

---

## Current Treaty Schema (Existing)

```sql
CREATE TABLE treaties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Treaty metadata
  title TEXT NOT NULL,                          -- "Tuesday Family Night"
  terms_text TEXT NOT NULL,                     -- Human-readable terms
  facets_involved UUID[] NOT NULL,              -- Array of facet IDs
  status TEXT NOT NULL DEFAULT 'active',        -- 'active', 'probationary', 'suspended', 'expired'

  -- Logic hooks (JSON Logic format)
  logic_hooks JSONB NOT NULL,

  -- Council session reference
  council_session_id UUID REFERENCES council_sessions(id),

  -- Breach tracking
  breach_count INT DEFAULT 0,
  last_breach_at TIMESTAMPTZ,
  breach_window_start TIMESTAMPTZ,              -- Rolling 7-day window

  -- Lifecycle
  signed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,                       -- NULL = never expires
  suspended_at TIMESTAMPTZ,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Gap Identified:** No `amendment_history` tracking. No `version` field. No `parent_treaty_id` for amendment lineage.

---

## Research Question: RQ-024 — Treaty Modification & Renegotiation Flow

### Core Question
How should users modify, amend, or terminate active Treaties while preserving the psychological weight of the original ratification?

### Why This Matters
- RQ-021 specified treaty CREATION but not modification
- Users need to respond to Probation state (3+ breaches in 7 days)
- The "ceremony" of ratification must not become a "settings screen"
- Breach history must be handled appropriately on modification

### The Problem

**Scenario: Marcus's Sunset Clause is Failing**

> Marcus created a "Sunset Clause" treaty: Block work apps after 9pm. It worked for 2 weeks. Then a project deadline hit. He's now breached it 4 times in 7 days. The treaty is in **Probationary** status.
>
> Marcus doesn't want to DELETE the treaty — he still believes in the principle. But he needs to:
> 1. Temporarily pause it during the deadline (2 weeks)
> 2. Change the time from 9pm to 10pm permanently
> 3. Add an exception for "on-call" days
>
> **Question:** What does Marcus see? What can he tap? What ceremony (if any) is required?

### Current Hypothesis: Amendment Flow (Option C from PD-118)

| Change Type | Ceremony Required | Rationale |
|-------------|-------------------|-----------|
| **Minor:** Time values, toggle soft/hard | Direct edit + acknowledgment | Low psychological weight |
| **Major:** Logic structure, signatories | Council reconvenes | Requires renegotiation |
| **Pause:** Temporary suspension | Confirmation modal | Preserve treaty identity |
| **Repeal:** Permanent deletion | Deliberate action (not accidental) | Maintain archives |

**Validate or refine this hypothesis.**

---

## Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| **1** | **Minor vs Major Amendment Criteria:** What specific changes qualify as "minor" (direct edit) vs "major" (Council required)? | Provide exhaustive classification table with examples |
| **2** | **Minor Amendment UX:** How should minor amendments be presented? Inline editing? Modal? What acknowledgment is required? | Specify UI flow with wireframe description |
| **3** | **Major Amendment Flow:** When Council reconvenes, does Sherlock remember the original treaty? What context is passed? | Specify Council session initialization for amendments |
| **4** | **Probation → Renegotiation Journey:** When a treaty enters Probation, what prompts appear? When? How persistent? | Provide notification/prompt sequence with timing |
| **5** | **Pause/Suspend UX:** How does a user temporarily pause a treaty? What visual state? Can they set a resume date? | Specify pause flow and visual treatment |
| **6** | **Repeal/Delete Flow:** How does a user permanently delete a treaty? What confirmation? What happens to breach history? | Specify deletion ceremony and data handling |
| **7** | **Breach History on Amendment:** When a treaty is amended, should breach_count reset? Carry over? Decay? | Recommend with psychological and data rationale |
| **8** | **Amendment History Schema:** What schema additions are needed to track amendment lineage? | Provide SQL DDL for amendment tracking |
| **9** | **Fork/Duplicate:** Can users duplicate an existing treaty as a template for a new one? | Specify UX if yes; justify if no |
| **10** | **Expired Treaty Revival:** Can users reactivate an expired treaty? If so, does it count as new or amendment? | Specify revival flow |

---

## Anti-Patterns to Avoid

- ❌ **Settings Creep:** Don't make treaty editing feel like changing app preferences
- ❌ **Ceremony Overload:** Don't require Council for every minor change (user fatigue)
- ❌ **Hidden Deletion:** Don't allow accidental treaty deletion (swipe-to-delete)
- ❌ **Breach Amnesia:** Don't silently reset breach history (undermines psychological weight)
- ❌ **Orphaned History:** Don't lose amendment lineage (legal metaphor requires paper trail)
- ❌ **Auto-Everything:** Don't auto-suspend without user awareness (agency matters)
- ❌ **Modal Hell:** Don't stack multiple confirmation modals (UX friction)

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule | Source |
|------------|------|--------|
| **Platform** | Android-first (VibrationEffect API 26+) | CD-017 |
| **AI Model** | DeepSeek V3.2 for Council sessions | CD-016 |
| **Logic Parser** | json_logic_dart package | RQ-020 |
| **Breach Window** | Rolling 7 days | RQ-020 |
| **Probation Threshold** | 3 breaches in 7 days | RQ-020 |
| **Auto-Suspend** | 5+ breaches OR 3 dismissed prompts | RQ-020 |
| **Council Rate Limit** | 1 auto-summon per 24h per topic | PD-109 |

---

## Output Required

### Deliverable 1: Amendment Classification Table

| Field/Property | Minor (Direct Edit) | Major (Council Required) | Justification |
|----------------|---------------------|--------------------------|---------------|
| `expires_at` | ✅ | | ... |
| `logic_hooks.condition` | | ✅ | ... |
| ... | ... | ... | ... |

### Deliverable 2: Minor Amendment UX Flow

```
USER TAPS "EDIT" ON TREATY CARD
    ↓
[Screen/Modal Description]
    ↓
[Editable Fields]
    ↓
[Acknowledgment Ceremony]
    ↓
[Success State]
```

### Deliverable 3: Probation → Renegotiation Journey Map

```
BREACH 3 LOGGED (Probation Triggered)
├── T+0: [Immediate feedback]
├── T+6h: [Follow-up prompt if not addressed]
├── T+24h: [Escalation]
├── T+72h: [Final warning before auto-suspend]
└── USER DISMISSES 3x: [Auto-suspend flow]
```

### Deliverable 4: Amendment History Schema

```sql
-- Additions to treaties table or new table
...
```

### Deliverable 5: Pause/Suspend State Machine

```
ACTIVE ──────────────────────────────────────────────────────────────►
   │
   │ User taps "Pause"
   ▼
PAUSED (user-initiated)
   │
   │ Resume date reached OR user taps "Resume"
   ▼
ACTIVE ──────────────────────────────────────────────────────────────►

ACTIVE ──────────────────────────────────────────────────────────────►
   │
   │ 5+ breaches OR 3 dismissed prompts
   ▼
SUSPENDED (system-initiated)
   │
   │ User taps "Reactivate" → Reconvene Council?
   ▼
...
```

### Deliverable 6: Confidence Levels

| Recommendation | Confidence | Rationale |
|----------------|------------|-----------|
| Minor/Major classification | HIGH/MEDIUM/LOW | ... |
| Breach history handling | HIGH/MEDIUM/LOW | ... |
| Amendment schema | HIGH/MEDIUM/LOW | ... |
| Pause UX | HIGH/MEDIUM/LOW | ... |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an engineer build this without clarifying questions? |
| **Gravitas Preserved** | Does the flow maintain treaty "weight" without being tedious? |
| **Consistent** | Does this integrate with RQ-021's creation flow? |
| **State-Complete** | Are all state transitions accounted for? |
| **Edge-Case Covered** | What happens if user has 10 treaties in probation? |

---

## Example of Good Output: Pause Flow

```
PAUSE TREATY FLOW:

1. USER TAPS TREATY CARD → OPTIONS MENU
   - "Amend Treaty" (pencil icon)
   - "Pause Treaty" (pause icon)
   - "Repeal Treaty" (archive icon)

2. USER TAPS "PAUSE TREATY"
   - Modal appears: "Pause [Treaty Name]?"
   - Subtitle: "This treaty will stop enforcing until you resume it."
   - Option: "Resume automatically on [date picker]" (optional)
   - Button: "Pause Treaty" (muted color, not red)

3. HAPTIC: Single gentle pulse (not celebration, not alarm)

4. VISUAL STATE CHANGE:
   - Treaty card becomes grayscale
   - Badge: "PAUSED" with pause icon
   - If resume date set: "Resumes [date]" subtitle

5. PAUSED TREATY BEHAVIOR:
   - Logic hooks do NOT fire
   - Does NOT appear in breach tracking
   - DOES appear in Constitution (Paused section)

6. RESUME:
   - User taps "Resume" on paused treaty
   - Immediate: Treaty returns to Active
   - breach_count: Preserved (not reset)
   - Haptic: Short confirmation pulse
```

---

## Concrete Scenario: Solve This

**Marcus's Sunset Clause (9pm work block) is in Probation after 4 breaches.**

Walk through EXACTLY what Marcus sees and does for each of these actions:

1. **Change time from 9pm to 10pm** (minor amendment)
2. **Add exception for "on-call flag"** (major amendment — logic change)
3. **Pause for 2 weeks during deadline**
4. **Later: Resume the paused treaty**
5. **Eventually: Repeal the treaty entirely**

For each action, specify:
- Where he taps
- What modal/screen appears
- What ceremony (if any) is required
- What happens to `breach_count` and `status`

---

## Final Checklist Before Submitting

- [ ] Each sub-question (1-10) has explicit answer
- [ ] Amendment classification table is exhaustive
- [ ] All state transitions documented (Active, Paused, Probationary, Suspended, Expired, Repealed)
- [ ] Breach history handling on each transition specified
- [ ] Schema additions include field types and constraints
- [ ] Probation journey has specific timing (hours/days)
- [ ] Marcus scenario solved step-by-step for all 5 actions
- [ ] Confidence levels stated for each major recommendation
- [ ] Integration with RQ-021 creation flow is seamless
- [ ] Anti-patterns explicitly avoided in design

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework.*
