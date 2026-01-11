# Deep Think Response Consumption Protocol — Exhaustive Guide

> **Purpose:** Step-by-step instructions for processing Deep Think (external AI) research output
> **Target:** RQ-040 Viral Witness Growth Strategy
> **Created:** 11 January 2026
> **Protocol Version:** 1.0

---

## Overview: The 10-Step Process

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DEEP THINK RESPONSE CONSUMPTION FLOW                          │
│                                                                                  │
│  STEP 1: Initial Read & Structure Mapping                                        │
│      ↓                                                                           │
│  STEP 2: Protocol 9 — Phase 1: Locked Decision Audit                            │
│      ↓                                                                           │
│  STEP 3: Protocol 9 — Phase 2: Data Reality Audit                               │
│      ↓                                                                           │
│  STEP 4: Protocol 9 — Phase 3: Implementation Reality Audit                     │
│      ↓                                                                           │
│  STEP 5: Protocol 9 — Phase 4: Scope & Complexity Audit                         │
│      ↓                                                                           │
│  STEP 6: Protocol 9 — Phase 5: Categorization (ACCEPT/MODIFY/REJECT/ESCALATE)   │
│      ↓                                                                           │
│  STEP 7: Protocol 10 — Bias Analysis                                            │
│      ↓                                                                           │
│  STEP 8: Task Extraction & Prioritization                                       │
│      ↓                                                                           │
│  STEP 9: Governance Documentation Updates                                        │
│      ↓                                                                           │
│  STEP 10: Verification, Commit & Handover                                       │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## STEP 1: Initial Read & Structure Mapping

### 1.1 First Pass — Understand the Response Structure

**Objective:** Understand what Deep Think provided before auditing.

**Actions:**

1. **Read the entire response once without judgment**
   - Do NOT start accepting/rejecting yet
   - Note the overall structure
   - Identify how Deep Think organized its answer

2. **Create a Response Map**

   ```markdown
   ## Deep Think Response Map

   | Section | Deep Think's Header | Page/Length | Key Topics |
   |---------|---------------------|-------------|------------|
   | RQ-1 | [Header they used] | [~X words] | [Main points] |
   | RQ-2 | [Header they used] | [~X words] | [Main points] |
   | ... | ... | ... | ... |
   ```

3. **Count Proposals**
   - How many distinct recommendations did Deep Think make?
   - Number each one for tracking (P-001, P-002, etc.)

### 1.2 Extract All Proposals into Tracking Table

**Create a master tracking table:**

```markdown
## Proposal Tracking Table

| ID | RQ | Proposal Summary | Confidence (DT) | Audit Status | Final Verdict |
|----|----|--------------------|-----------------|--------------|---------------|
| P-001 | RQ-1 | [One-sentence summary] | [H/M/L] | ⏳ Pending | ⏳ Pending |
| P-002 | RQ-1 | [One-sentence summary] | [H/M/L] | ⏳ Pending | ⏳ Pending |
| P-003 | RQ-2 | [One-sentence summary] | [H/M/L] | ⏳ Pending | ⏳ Pending |
| ... | ... | ... | ... | ... | ... |
```

**Expected Proposals for RQ-040 (estimate 40-60 total):**

| RQ | Expected Proposal Count | Topics |
|----|------------------------|--------|
| RQ-1 | 8-12 | Witness value prop, visibility models, actions |
| RQ-2 | 8-10 | Channels, message templates, timing |
| RQ-3 | 8-10 | Conversion triggers, prompts, onboarding |
| RQ-4 | 6-8 | Multi-witness, network effects |
| RQ-5 | 6-8 | K-factor targets, projections |
| RQ-6 | 4-6 | Contingency plans |
| RQ-7 | 4-6 | Witness retention |
| RQ-8 | 4-6 | Validation experiment |

### 1.3 Identify Options Presented

For questions marked ⚖️, Deep Think should have presented 2-3 options.

**Track each:**

```markdown
## Options Tracking

| Question | Option A | Option B | Option C | DT Recommended | Our Decision |
|----------|----------|----------|----------|----------------|--------------|
| 1.2 Visibility | Minimal | Moderate | Full | [X] | ⏳ Pending |
| 1.3 App Access | Notifications | Web View | Full App | [X] | ⏳ Pending |
| ... | ... | ... | ... | ... | ... |
```

---

## STEP 2: Protocol 9 — Phase 1: Locked Decision Audit

### 2.1 Reference Documents

**Open these files:**
- `docs/CORE/index/CD_INDEX.md` — All 18 confirmed decisions
- `docs/CORE/archive/CD_ARCHIVE_Q1_2026.md` — Full decision rationale

### 2.2 Critical CDs for RQ-040

| CD | Title | What It Constrains | Violation Check |
|----|-------|-------------------|-----------------|
| **CD-002** | AI as Default Witness | Cannot REQUIRE human witness | Does proposal require human witness? |
| **CD-010** | Retention Philosophy | No dark patterns | Does proposal use guilt/shame/FOMO? |
| **CD-015** | psyOS Architecture | 4-state energy model | Does proposal conflict with psyOS? |
| **CD-017** | Android-First | No iOS-only features | Does proposal require iOS APIs? |
| **CD-018** | Engineering Threshold | No over-engineering | Is proposal overly complex? |

### 2.3 Audit Process

**For EACH proposal (P-001 through P-XXX):**

```markdown
### P-001: [Proposal Summary]

#### CD-002 Check (AI as Default Witness)
- [ ] Does NOT require human witness? ✅/❌
- Notes: [Any observations]

#### CD-010 Check (No Dark Patterns)
- [ ] No guilt-based messaging? ✅/❌
- [ ] No shame-based messaging? ✅/❌
- [ ] No artificial scarcity/FOMO? ✅/❌
- [ ] User success prioritized over engagement? ✅/❌
- Notes: [Any observations]

#### CD-015 Check (psyOS Architecture)
- [ ] Compatible with Parliament of Selves? ✅/❌
- [ ] Compatible with 4-state energy model? ✅/❌
- Notes: [Any observations]

#### CD-017 Check (Android-First)
- [ ] Works on Android? ✅/❌
- [ ] No iOS-specific APIs required? ✅/❌
- [ ] No iMessage integration required? ✅/❌
- Notes: [Any observations]

#### CD-018 Check (Engineering Threshold)
- [ ] Not OVER-ENGINEERED? ✅/❌
- Complexity Classification: ESSENTIAL / VALUABLE / NICE-TO-HAVE / OVER-ENGINEERED
- Notes: [Any observations]

#### Phase 1 Result: ✅ PASS / ❌ FAIL (specify which CD)
```

### 2.4 Common CD Violations to Watch For

| CD | Likely Violations in Growth Research |
|----|-------------------------------------|
| **CD-002** | "Users MUST invite a witness to proceed" |
| **CD-010** | "Show countdown timer for invitation expiry", "Tell users their friends are waiting" |
| **CD-015** | N/A for growth research |
| **CD-017** | "Use iMessage for rich invitations", "Leverage iOS Contacts API" |
| **CD-018** | "Multi-level referral tree with points", "Complex gamification with badges" |

### 2.5 Phase 1 Output

```markdown
## Phase 1 Results: Locked Decision Audit

| ID | CD-002 | CD-010 | CD-015 | CD-017 | CD-018 | Phase 1 Result |
|----|--------|--------|--------|--------|--------|----------------|
| P-001 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ PASS |
| P-002 | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ FAIL (CD-010) |
| P-003 | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ FAIL (CD-017) |
| ... | ... | ... | ... | ... | ... | ... |

**Summary:**
- Total Proposals: [X]
- Passed Phase 1: [Y]
- Failed Phase 1: [Z] (list which CDs violated)
```

---

## STEP 3: Protocol 9 — Phase 2: Data Reality Audit

### 3.1 What Data Do We Actually Have?

**Reference: Android-First Data Availability**

| Data Point | Available? | API | Permission Required |
|------------|-----------|-----|---------------------|
| `foregroundApp` | ✅ YES | UsageStatsManager | PACKAGE_USAGE_STATS |
| `screenOnDuration` | ✅ YES | UsageStatsManager | PACKAGE_USAGE_STATS |
| `stepsLast30Min` | ✅ YES | Health Connect | Health Connect |
| `locationZone` | ✅ YES | Geofencing API | ACCESS_FINE_LOCATION |
| `calendarEvents` | ✅ YES | CalendarContract | READ_CALENDAR |
| `timeOfDay` | ✅ YES | System | None |
| `dayOfWeek` | ✅ YES | System | None |
| `contactList` | ✅ YES | ContactsContract | READ_CONTACTS |
| `SMSsending` | ✅ YES | SmsManager | SEND_SMS |
| Heart rate | ❌ NO | Requires wearable | N/A |
| Stress level | ❌ NO | Requires wearable | N/A |
| Sleep data | ⚠️ LIMITED | Health Connect (if user tracks) | Health Connect |

### 3.2 Audit Process

**For EACH proposal that passed Phase 1:**

```markdown
### P-001: [Proposal Summary]

#### Data Requirements
What data does this proposal require?
- [List each data point needed]

#### Availability Check
| Required Data | Available? | Source | Notes |
|---------------|-----------|--------|-------|
| [Data 1] | ✅/❌/⚠️ | [Source] | [Notes] |
| [Data 2] | ✅/❌/⚠️ | [Source] | [Notes] |

#### Permission Requirements
| Permission | Already Requested? | User Burden |
|------------|-------------------|-------------|
| [Permission 1] | ✅/❌ | LOW/MEDIUM/HIGH |

#### Phase 2 Result: ✅ PASS / ⚠️ PASS WITH MODIFICATIONS / ❌ FAIL
```

### 3.3 Common Data Reality Issues

| Deep Think Might Assume | Reality |
|------------------------|---------|
| "Analyze user's social graph" | We only have contacts if permission granted |
| "Track when user opens invitation" | Requires link tracking infrastructure |
| "Measure witness engagement time" | Need to build this tracking |
| "Detect user's mood from activity" | We don't have mood detection |
| "Use location to suggest witnesses" | Possible but privacy-sensitive |

### 3.4 Phase 2 Output

```markdown
## Phase 2 Results: Data Reality Audit

| ID | Data Available? | Permissions OK? | Phase 2 Result |
|----|----------------|-----------------|----------------|
| P-001 | ✅ | ✅ | ✅ PASS |
| P-004 | ⚠️ Partial | ✅ | ⚠️ MODIFY (need alternative data) |
| P-007 | ❌ | N/A | ❌ FAIL (requires unavailable data) |
| ... | ... | ... | ... |

**Summary:**
- Passed Phase 2: [X]
- Need Modification: [Y]
- Failed Phase 2: [Z]
```

---

## STEP 4: Protocol 9 — Phase 3: Implementation Reality Audit

### 4.1 Current Codebase State

**Key Facts:**
- Phase A schema (identity_facets, identity_topology) **DOES NOT EXIST YET**
- Witness-related tables **DO NOT EXIST YET**
- Basic supporter functionality exists in `habits` table

**Current Schema (Relevant):**

```sql
-- EXISTING: habits table has basic supporter field
CREATE TABLE habits (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  supporter_name TEXT,      -- Basic name storage
  supporter_contact TEXT,   -- Phone/email
  -- No structured witness tracking
);

-- PROPOSED BUT NOT BUILT: witness_relationships
-- PROPOSED BUT NOT BUILT: witness_events
```

### 4.2 Audit Process

**For EACH proposal that passed Phase 1 & 2:**

```markdown
### P-001: [Proposal Summary]

#### Schema Requirements
Does this proposal require:
- [ ] New tables? Which ones?
- [ ] Modifications to existing tables? Which ones?
- [ ] New indexes?
- [ ] New RLS policies?

#### Code Requirements
Does this proposal require:
- [ ] New Flutter screens?
- [ ] New services?
- [ ] Modifications to existing services?
- [ ] New API endpoints?

#### Conflict Check
Does this proposal conflict with existing code?
- [ ] No conflicts identified
- [ ] Conflicts with: [List]

#### Dependency Check
What must be built BEFORE this proposal?
- [ ] Phase A schema
- [ ] [Other dependencies]

#### Phase 3 Result: ✅ PASS / ⚠️ PASS WITH DEPENDENCIES / ❌ FAIL (conflict)
```

### 4.3 Expected Dependencies for RQ-040

| Proposal Type | Likely Dependencies |
|---------------|---------------------|
| Witness schema proposals | None (new tables) |
| Invitation flow proposals | `witness_relationships` table |
| Conversion tracking proposals | `witness_events` table |
| K-factor calculation | `witness_relationships`, `witness_events` |
| UI proposals | Schema + services |

### 4.4 Phase 3 Output

```markdown
## Phase 3 Results: Implementation Reality Audit

| ID | Schema Needs | Code Conflicts? | Dependencies | Phase 3 Result |
|----|-------------|-----------------|--------------|----------------|
| P-001 | New table | ❌ None | None | ✅ PASS |
| P-005 | Modify habits | ❌ None | P-001 | ⚠️ PASS (depends on P-001) |
| P-012 | None | ✅ Yes | N/A | ❌ FAIL (conflicts with X) |
| ... | ... | ... | ... | ... |

**Dependency Chain:**
P-001 (schema) → P-005 (service) → P-012 (UI)
```

---

## STEP 5: Protocol 9 — Phase 4: Scope & Complexity Audit

### 5.1 Engineering Threshold Framework (CD-018)

| Tier | Definition | Action |
|------|------------|--------|
| **ESSENTIAL** | Must have for MVP. App doesn't work without it. | Implement immediately |
| **VALUABLE** | Strong ROI. Significantly improves UX/growth. | Include if time permits |
| **NICE-TO-HAVE** | Would be good. Low priority. | Defer to post-MVP |
| **OVER-ENGINEERED** | Too complex. Diminishing returns. | **REJECT** |

### 5.2 Complexity Scoring

**For EACH proposal, assess:**

```markdown
### P-001: [Proposal Summary]

#### Complexity Assessment

| Factor | Score (1-5) | Notes |
|--------|-------------|-------|
| Schema complexity | [1-5] | [How many tables/fields?] |
| Code complexity | [1-5] | [How many new files/services?] |
| UI complexity | [1-5] | [How many new screens?] |
| Integration complexity | [1-5] | [How many touchpoints?] |
| Testing complexity | [1-5] | [How hard to test?] |
| **Total** | [5-25] | |

#### Effort Estimate
- Engineering time: [X days/weeks]
- Blocked by: [Dependencies]

#### Value Assessment
- Impact on K-factor: [HIGH/MEDIUM/LOW]
- Impact on user experience: [HIGH/MEDIUM/LOW]
- Impact on retention: [HIGH/MEDIUM/LOW]

#### ROI Classification
- Complexity Total: [X/25]
- Value: [HIGH/MEDIUM/LOW]
- **Classification:** ESSENTIAL / VALUABLE / NICE-TO-HAVE / OVER-ENGINEERED

#### Phase 4 Result: ✅ INCLUDE / ⚠️ DEFER / ❌ REJECT (over-engineered)
```

### 5.3 Common Over-Engineering Patterns

| Pattern | Why It's Over-Engineered | Better Alternative |
|---------|-------------------------|-------------------|
| Multi-level referral tree | Complex tracking, MLM-like | Simple 1-level witness |
| Points/badges for invitations | Gamification bloat | Natural social value |
| ML-based contact suggestions | Requires training data | User choice |
| Real-time K-factor dashboard | Complex infrastructure | Weekly batch calculation |
| A/B test framework built-in | Premature optimization | Use external tool |

### 5.4 Phase 4 Output

```markdown
## Phase 4 Results: Scope & Complexity Audit

| ID | Complexity | Value | Classification | Phase 4 Result |
|----|-----------|-------|----------------|----------------|
| P-001 | 8/25 (Low) | HIGH | ESSENTIAL | ✅ INCLUDE |
| P-006 | 12/25 (Med) | HIGH | VALUABLE | ✅ INCLUDE |
| P-009 | 18/25 (High) | MEDIUM | NICE-TO-HAVE | ⚠️ DEFER |
| P-015 | 22/25 (High) | LOW | OVER-ENGINEERED | ❌ REJECT |
| ... | ... | ... | ... | ... |

**Summary by Classification:**
- ESSENTIAL: [X] proposals
- VALUABLE: [Y] proposals
- NICE-TO-HAVE: [Z] proposals (defer)
- OVER-ENGINEERED: [W] proposals (reject)
```

---

## STEP 6: Protocol 9 — Phase 5: Final Categorization

### 6.1 Categorization Decision Tree

```
                    ┌─────────────────┐
                    │ Phase 1 PASSED? │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │ NO           │              │ YES
              ▼              │              ▼
        ┌─────────┐          │        ┌─────────────┐
        │ REJECT  │          │        │ Phase 2     │
        │(CD viol)│          │        │ PASSED?     │
        └─────────┘          │        └──────┬──────┘
                             │               │
                             │    ┌──────────┼──────────┐
                             │    │ NO       │          │ YES
                             │    ▼          │          ▼
                             │  ┌─────────┐  │    ┌─────────────┐
                             │  │ REJECT  │  │    │ Phase 3     │
                             │  │(no data)│  │    │ PASSED?     │
                             │  └─────────┘  │    └──────┬──────┘
                             │               │           │
                             │               │ ┌─────────┼─────────┐
                             │               │ │ NO      │         │ YES
                             │               │ ▼         │         ▼
                             │               │┌────────┐ │   ┌─────────────┐
                             │               ││ REJECT │ │   │ Phase 4     │
                             │               ││(confl.)│ │   │ Result?     │
                             │               │└────────┘ │   └──────┬──────┘
                             │               │           │          │
                             │               │           │   ┌──────┼──────┐
                             │               │           │   │OVER  │      │
                             │               │           │   │ENG.  │OTHER │
                             │               │           │   ▼      ▼      │
                             │               │           │┌──────┐┌───────┐│
                             │               │           ││REJECT││ACCEPT ││
                             │               │           │└──────┘│or     ││
                             │               │           │        │MODIFY ││
                             │               │           │        └───────┘│
                             │               │           │                 │
                             │               │           │    Check: Human │
                             │               │           │    decision     │
                             │               │           │    needed?      │
                             │               │           │         │       │
                             │               │           │    YES  │  NO   │
                             │               │           │    ▼    ▼       │
                             │               │           │ ┌────────┐      │
                             │               │           │ │ESCALATE│      │
                             │               │           │ └────────┘      │
```

### 6.2 Final Categorization Table

```markdown
## Phase 5 Results: Final Categorization

| ID | P1 | P2 | P3 | P4 | Verdict | Rationale | Action Required |
|----|----|----|----|----|---------|-----------|-----------------|
| P-001 | ✅ | ✅ | ✅ | ESSENTIAL | **ACCEPT** | Core schema needed | Create task |
| P-002 | ❌ | — | — | — | **REJECT** | Violates CD-010 (FOMO) | None |
| P-003 | ✅ | ⚠️ | ✅ | VALUABLE | **MODIFY** | Needs data alternative | Adapt proposal |
| P-004 | ✅ | ✅ | ✅ | N/A | **ESCALATE** | Affects monetization | Human decision |
| ... | ... | ... | ... | ... | ... | ... | ... |

**Final Counts:**
- **ACCEPT:** [X] proposals — Ready for task extraction
- **MODIFY:** [Y] proposals — Need adaptation before tasks
- **REJECT:** [Z] proposals — Document rationale
- **ESCALATE:** [W] proposals — Await human decision
```

### 6.3 Documentation for Each Category

#### ACCEPT Template
```markdown
### P-001: [Proposal] — ACCEPT ✅

**Deep Think Recommendation:**
[Quote the recommendation]

**Why Accepted:**
- Passes all CD checks
- Data available
- No code conflicts
- Appropriate complexity

**Implementation Notes:**
[Any specific guidance for implementation]

**Task to Create:** [Task ID preview]
```

#### MODIFY Template
```markdown
### P-003: [Proposal] — MODIFY ⚠️

**Deep Think Recommendation:**
[Quote the recommendation]

**Issue Identified:**
[What needs to change]

**Proposed Modification:**
[How to adapt it]

**Modified Proposal:**
[The adapted version]

**Task to Create:** [Task ID preview - for modified version]
```

#### REJECT Template
```markdown
### P-002: [Proposal] — REJECT ❌

**Deep Think Recommendation:**
[Quote the recommendation]

**Rejection Reason:**
- **Phase Failed:** [1/2/3/4]
- **Specific Issue:** [CD violation / Data unavailable / Code conflict / Over-engineered]

**Why This Is Correct:**
[Rationale]

**Alternative Considered:**
[Was there any way to salvage this? Why not?]
```

#### ESCALATE Template
```markdown
### P-004: [Proposal] — ESCALATE ⬆️

**Deep Think Recommendation:**
[Quote the recommendation]

**Why Escalated:**
This affects [product direction / monetization / core UX / multi-stakeholder]

**Decision Options:**
| Option | Pros | Cons |
|--------|------|------|
| A: [X] | [X] | [X] |
| B: [X] | [X] | [X] |
| C: [X] | [X] | [X] |

**My Recommendation:** [A/B/C]

**Rationale:**
[Why I recommend this option]

**Awaiting:** Human decision
```

---

## STEP 7: Protocol 10 — Bias Analysis

### 7.1 When Protocol 10 Applies

```
Protocol 10 is REQUIRED when Deep Think recommendations affect:
- Product direction
- Monetization strategy
- Core UX patterns
- Multi-stakeholder architecture
- Growth strategy ← RQ-040 QUALIFIES
```

### 7.2 Bias Identification Process

**For each ACCEPTED or ESCALATED proposal, check for these biases:**

| Bias ID | Bias Name | Question to Ask | How It Might Appear |
|---------|-----------|-----------------|---------------------|
| B1 | **Pro-Viral Assumption** | Does it assume K>1 is achievable? | "Once you reach K=1.2..." |
| B2 | **Conversion-First** | Does it prioritize conversion over experience? | Heavy focus on prompts, light on value |
| B3 | **Tech-Solutionism** | Does it assume tech fixes human problems? | "An algorithm can predict..." |
| B4 | **Short-Term Optimization** | Does it optimize for 90 days vs 12 months? | No mention of sustainability |
| B5 | **Single-Path** | Does it assume one strategy fits all? | No segmentation by user type |
| B6 | **Measurability** | Does it only recommend what's measurable? | Ignores relationship quality |
| B7 | **Positive Network Effects** | Does it ignore negative network effects? | No mention of fatigue/spam |
| B8 | **Survivor Bias** | Does it only reference successful examples? | "Duolingo did X, so we should too" |

### 7.3 Bias Audit Table

```markdown
## Protocol 10: Bias Analysis

### Bias Identification

| Bias | Present? | Where? | Validity | Risk | Mitigation |
|------|----------|--------|----------|------|------------|
| B1: Pro-Viral | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |
| B2: Conversion-First | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |
| B3: Tech-Solutionism | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |
| B4: Short-Term | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |
| B5: Single-Path | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |
| B6: Measurability | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |
| B7: Positive Network | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |
| B8: Survivor Bias | [Y/N] | [Quote/Reference] | [H/M/L] | [H/M/L] | [Action] |

### Bias Count
- Total biases identified: [X]
- HIGH validity (probably real insights): [Y]
- MEDIUM validity (partially valid): [Z]
- LOW validity (likely flawed assumptions): [W]

### Decision
- [ ] If 4+ LOW validity biases → Consider Protocol 12 (Decision Deferral)
- [ ] If <4 LOW validity biases → Proceed with mitigations
```

### 7.4 Mitigation Strategies

| Bias | Mitigation Strategy |
|------|---------------------|
| B1: Pro-Viral | Add contingency tasks for K<0.5 scenario |
| B2: Conversion-First | Add witness satisfaction metrics to task list |
| B3: Tech-Solutionism | Add user research tasks |
| B4: Short-Term | Request 12-month projection in follow-up |
| B5: Single-Path | Add segmentation by user dimension |
| B6: Measurability | Add qualitative metrics (NPS, satisfaction) |
| B7: Positive Network | Add negative network effect prevention tasks |
| B8: Survivor Bias | Note limitations, add failure case analysis |

---

## STEP 8: Task Extraction & Prioritization

### 8.1 Task Extraction Rules

```
EXTRACT TASKS ONLY FROM:
- ACCEPT proposals (implement as proposed)
- MODIFY proposals (implement modified version)
- Bias mitigations (from Protocol 10)

DO NOT EXTRACT TASKS FROM:
- REJECT proposals
- ESCALATE proposals (until human decides)
```

### 8.2 Task ID Convention

```
[Phase]-[Number]

Phases:
A = Schema (database tables, indexes, RLS)
B = Intelligence (AI, algorithms, ML)
C = Council (Council AI specific)
D = UX (screens, flows, interactions)
E = Polish (animations, sounds, haptics)
F = Analytics (tracking, dashboards, metrics)
G = Identity Coach (coaching specific)
P = Process (documentation, workflows)
```

### 8.3 Task Template

```markdown
### Task ID: [A-XX]

**Source:** [Proposal P-XXX from RQ-040]

**Title:** [Clear, actionable title]

**Description:**
[What needs to be done]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

**Priority:** CRITICAL / HIGH / MEDIUM / LOW

**Complexity:** [1-5]

**Blocked By:** [Task IDs or "None"]

**Enables:** [Task IDs or "None"]

**Phase:** [A/B/C/D/E/F/G/P]

**Estimated Effort:** [X hours/days]
```

### 8.4 Expected Task Categories for RQ-040

| Phase | Expected Tasks |
|-------|----------------|
| **A (Schema)** | witness_relationships table, witness_events table, indexes, RLS policies |
| **B (Intelligence)** | K-factor calculation service, conversion prediction model |
| **D (UX)** | Invitation flow, witness dashboard, conversion prompts, onboarding screens |
| **E (Polish)** | Notification cadence logic, re-engagement flows |
| **F (Analytics)** | K-factor dashboard, cohort tracking, funnel analytics |
| **P (Process)** | Witness experience guidelines, privacy documentation |

### 8.5 Priority Assignment

```
CRITICAL — Blocks other work, must be done first
  Example: Schema creation (nothing else works without it)

HIGH — MVP required, core functionality
  Example: Basic invitation flow

MEDIUM — Post-MVP, enhances experience
  Example: Re-engagement flows for dormant witnesses

LOW — Nice to have, defer if needed
  Example: Advanced analytics dashboards
```

### 8.6 Task Extraction Output

```markdown
## Extracted Tasks

### Phase A: Schema

| ID | Title | Priority | Blocked By | Enables |
|----|-------|----------|------------|---------|
| A-20 | Create witness_relationships table | CRITICAL | None | A-21, D-15 |
| A-21 | Create witness_events table | CRITICAL | A-20 | F-10 |
| A-22 | Create K-factor materialized view | HIGH | A-20, A-21 | F-11 |

### Phase D: UX

| ID | Title | Priority | Blocked By | Enables |
|----|-------|----------|------------|---------|
| D-15 | Build invitation flow screen | HIGH | A-20 | D-16 |
| D-16 | Build witness dashboard | HIGH | A-20, D-15 | D-17 |
| D-17 | Build conversion prompt system | MEDIUM | D-16 | E-10 |

### Phase F: Analytics

| ID | Title | Priority | Blocked By | Enables |
|----|-------|----------|------------|---------|
| F-10 | Implement event tracking | HIGH | A-21 | F-11 |
| F-11 | Build K-factor dashboard | MEDIUM | A-22, F-10 | None |

**Task Summary:**
- Total tasks extracted: [X]
- CRITICAL: [Y]
- HIGH: [Z]
- MEDIUM: [W]
- LOW: [V]
```

---

## STEP 9: Governance Documentation Updates

### 9.1 Documents to Update

| Document | What to Update | Priority |
|----------|---------------|----------|
| `RQ_INDEX.md` | Mark RQ-040 complete, add sub-RQs | REQUIRED |
| `IMPLEMENTATION_ACTIONS.md` | Add tasks to Quick Status | REQUIRED |
| `GLOSSARY.md` | Add new terms | REQUIRED |
| `AI_HANDOVER.md` | Session summary | REQUIRED |
| `PRODUCT_DEVELOPMENT_SHEET.md` | Update statistics | REQUIRED |
| `RESEARCH_QUESTIONS.md` | Full RQ-040 entry + tasks | REQUIRED |
| `IMPACT_ANALYSIS.md` | Cascade effects | IF APPLICABLE |
| `PD_INDEX.md` | If any PDs resolved | IF APPLICABLE |

### 9.2 RQ_INDEX.md Update

```markdown
## Update to Add:

| RQ-040 | Viral Witness Growth Strategy | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040a | Witness Value Proposition | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040b | Invitation Channel Optimization | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040c | Witness-to-Creator Conversion | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040d | Multi-Witness Network Effects | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040e | Viral Coefficient Modeling | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040f | Contingency Planning | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040g | Witness Retention | ✅ COMPLETE | 11 Jan 2026 |
| RQ-040h | High-Value User Validation | ✅ COMPLETE | 11 Jan 2026 |

## Statistics Update:
- Total RQs: [Previous] → [New]
- Complete: [Previous] → [New]
- Pending: [Previous] → [New]
```

### 9.3 GLOSSARY.md Update

```markdown
## New Terms to Add:

| Term | Definition |
|------|------------|
| **Viral Coefficient (K)** | K = i × c where i = invitations per user, c = conversion rate. K > 1 = exponential growth. |
| **Witness Conversion** | When a witness (observer) becomes a creator (creates their own pact). |
| **Witness Fatigue** | Reduced engagement due to excessive notifications or observation requests. |
| **Network Lock-In** | Point at which a user has enough connections to be retained long-term. |
| **Diffusion of Responsibility** | With multiple witnesses, each feels less personally accountable. |
```

### 9.4 IMPLEMENTATION_ACTIONS.md Update

```markdown
## Quick Status Dashboard Update:

### Phase A: Schema
| Previous | New |
|----------|-----|
| [X] tasks | [X+N] tasks |

### New Section: Witness/Growth Tasks

| Task ID | Title | Priority | Status | Source |
|---------|-------|----------|--------|--------|
| A-20 | witness_relationships table | CRITICAL | 🔴 TODO | RQ-040 |
| A-21 | witness_events table | CRITICAL | 🔴 TODO | RQ-040 |
| ... | ... | ... | ... | ... |

### Task Addition Log

| Date | Source | Phase | Count | Added By |
|------|--------|-------|-------|----------|
| 11 Jan 2026 | RQ-040 Reconciliation | A, D, F | [X] | Claude |
```

### 9.5 AI_HANDOVER.md Update

```markdown
## Session Summary to Add:

### [Session Number]: RQ-040 Viral Witness Growth Reconciliation

**Date:** 11 January 2026
**Agent:** Claude (Opus 4.5)
**Focus:** Protocol 9 + 10 reconciliation of Deep Think research

**What Was Accomplished:**

1. **Protocol 9 Complete:**
   - [X] proposals audited
   - ACCEPT: [Y]
   - MODIFY: [Z]
   - REJECT: [W]
   - ESCALATE: [V]

2. **Protocol 10 Complete:**
   - [X] biases identified
   - [Y] mitigations applied

3. **Tasks Extracted:**
   - Total: [X] tasks
   - Phase A: [Y] tasks
   - Phase D: [Z] tasks
   - Phase F: [W] tasks

4. **Governance Updates:**
   - RQ_INDEX.md — RQ-040 marked complete
   - GLOSSARY.md — [X] new terms added
   - IMPLEMENTATION_ACTIONS.md — [Y] tasks added

**What Remains:**
- [X] ESCALATED items awaiting human decision
- [If any follow-up RQs needed]

**Next Agent Should:**
1. Address escalated items
2. Begin Phase A schema work
3. [Any other recommendations]
```

---

## STEP 10: Verification, Commit & Handover

### 10.1 Cross-File Consistency Check

```markdown
## Pre-Commit Verification

### RQ Count Verification
| File | Total | Complete | Pending |
|------|-------|----------|---------|
| RQ_INDEX.md | [X] | [Y] | [Z] |
| PRODUCT_DEV_SHEET.md | [X] | [Y] | [Z] |
| AI_CONTEXT.md | [X] | [Y] | [Z] |

✅ All match? / ❌ Mismatch found: [Fix required]

### Task Count Verification
| File | Total Tasks |
|------|-------------|
| IMPLEMENTATION_ACTIONS.md | [X] |
| PRODUCT_DEV_SHEET.md | [X] |

✅ All match? / ❌ Mismatch found: [Fix required]

### Timestamp Verification
| File | Updated to Today? |
|------|-------------------|
| AI_HANDOVER.md | ✅/❌ |
| RQ_INDEX.md | ✅/❌ |
| IMPLEMENTATION_ACTIONS.md | ✅/❌ |
| GLOSSARY.md | ✅/❌ |

### Cross-Reference Verification
- [ ] RQ-040 listed in RQ_INDEX.md? ✅
- [ ] RQ-040 listed in PRODUCT_DEV_SHEET.md? ✅
- [ ] All new tasks in IMPLEMENTATION_ACTIONS.md? ✅
- [ ] All new terms in GLOSSARY.md? ✅
```

### 10.2 Git Operations

```bash
# Stage all updated files
git add docs/analysis/DEEP_THINK_RECONCILIATION_RQ040_VIRAL_GROWTH.md
git add docs/CORE/index/RQ_INDEX.md
git add docs/CORE/GLOSSARY.md
git add docs/CORE/IMPLEMENTATION_ACTIONS.md
git add docs/CORE/AI_HANDOVER.md
git add docs/CORE/PRODUCT_DEVELOPMENT_SHEET.md
git add docs/CORE/RESEARCH_QUESTIONS.md
# ... any other files

# Verify staged changes
git status

# Commit with detailed message
git commit -m "$(cat <<'EOF'
docs: reconcile RQ-040 Viral Witness Growth Deep Think research

Protocol 9 Complete:
- Total proposals: [X]
- ACCEPT: [Y]
- MODIFY: [Z]
- REJECT: [W]
- ESCALATE: [V] (awaiting human decision)

Protocol 10 Complete:
- Biases identified: [X]
- Mitigations applied: [Y]

Tasks extracted:
- Phase A (Schema): [X] tasks
- Phase D (UX): [Y] tasks
- Phase F (Analytics): [Z] tasks
- Total: [W] new tasks

Governance updates:
- RQ_INDEX: RQ-040 + 8 sub-RQs marked COMPLETE
- GLOSSARY: [X] new terms added
- IMPLEMENTATION_ACTIONS: [Y] tasks added
- AI_HANDOVER: Session summary added

Escalated items (require human decision):
- [E-001]: [Brief description]
- [E-002]: [Brief description]
EOF
)"

# Push to remote
git push -u origin claude/read-markdown-files-HgiyZ
```

### 10.3 Final Handover Summary

```markdown
## Handover to User

### Reconciliation Complete

**Research Source:** DeepSeek R1 Distilled
**Research Question:** RQ-040 Viral Witness Growth Strategy

### Results Summary

| Category | Count |
|----------|-------|
| Total Proposals | [X] |
| ACCEPTED | [Y] |
| MODIFIED | [Z] |
| REJECTED | [W] |
| ESCALATED | [V] |

### Key Decisions Made

1. **[Decision 1]:** [What and why]
2. **[Decision 2]:** [What and why]
3. **[Decision 3]:** [What and why]

### Rejected Proposals (Why)

| Proposal | Rejection Reason |
|----------|------------------|
| [P-XXX] | [Brief reason] |
| [P-XXX] | [Brief reason] |

### Awaiting Your Decision

| Item | Options | My Recommendation |
|------|---------|-------------------|
| [E-001] | A, B, C | [X] because [Y] |
| [E-002] | A, B, C | [X] because [Y] |

### Tasks Ready for Implementation

| Phase | Count | First Task |
|-------|-------|------------|
| A (Schema) | [X] | A-20: witness_relationships table |
| D (UX) | [Y] | D-15: Invitation flow |
| F (Analytics) | [Z] | F-10: Event tracking |

### Recommended Next Steps

1. Resolve escalated items
2. Begin Phase A schema work
3. [Any other recommendations]

### Files Updated

- `docs/analysis/DEEP_THINK_RECONCILIATION_RQ040_VIRAL_GROWTH.md` — NEW
- `docs/CORE/index/RQ_INDEX.md` — Updated
- `docs/CORE/GLOSSARY.md` — Updated
- `docs/CORE/IMPLEMENTATION_ACTIONS.md` — Updated
- `docs/CORE/AI_HANDOVER.md` — Updated
```

---

## Appendix: Quick Reference Checklists

### Protocol 9 Quick Checklist

```
□ Phase 1: CD Audit (CD-002, CD-010, CD-015, CD-017, CD-018)
□ Phase 2: Data Reality Audit (What data do we have?)
□ Phase 3: Implementation Audit (Code conflicts? Dependencies?)
□ Phase 4: Complexity Audit (ESSENTIAL → OVER-ENGINEERED)
□ Phase 5: Categorize (ACCEPT/MODIFY/REJECT/ESCALATE)
□ Phase 6: Document everything
```

### Protocol 10 Quick Checklist

```
□ Check for Pro-Viral bias
□ Check for Conversion-First bias
□ Check for Tech-Solutionism bias
□ Check for Short-Term bias
□ Check for Single-Path bias
□ Check for Measurability bias
□ Check for Positive Network bias
□ Check for Survivor bias
□ Count LOW validity biases
□ If 4+ LOW → Consider deferral
□ Apply mitigations
```

### Governance Update Quick Checklist

```
□ RQ_INDEX.md updated
□ IMPLEMENTATION_ACTIONS.md updated
□ GLOSSARY.md updated
□ AI_HANDOVER.md updated
□ PRODUCT_DEV_SHEET.md updated
□ RESEARCH_QUESTIONS.md updated
□ Cross-file counts match
□ Timestamps updated
```

---

*This document provides exhaustive step-by-step guidance for consuming Deep Think research output. Follow each step in sequence.*
