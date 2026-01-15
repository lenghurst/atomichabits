# UX Decisions — Screens, Flows & Visual Design

> **Domain:** UX
> **Token Budget:** <12k
> **Load:** When working on screens, onboarding, visual design, user flows
> **Dependencies:** PD_CORE.md (always load first)
> **Related RQs:** RQ-010cdf, RQ-016-018, RQ-021, RQ-024, RQ-033, RQ-036

---

## Quick Reference

| PD# | Decision | Phase | Status | Blocking RQ |
|-----|----------|-------|--------|-------------|
| PD-002 | Streaks vs Rolling Consistency | D | READY | RQ-033 ✅ |
| PD-004 | Dev Mode Purpose | D | PENDING | — |
| PD-104 | LoadingInsightsScreen Personalization | D | PENDING | — |
| PD-108 | Constellation UX Migration | H | RESOLVED | — |
| PD-109 | Council AI Activation Rules | C, D | RESOLVED | — |
| PD-110 | Airlock Protocol User Control | H | RESOLVED | — |
| PD-111 | Polymorphic Habit Attribution | D | RESOLVED | — |
| PD-112 | Identity Priming Audio Strategy | H | RESOLVED | — |
| PD-113 | Treaty Priority Hierarchy | D | RESOLVED | — |
| PD-115 | Treaty Creation UX | D | RESOLVED | — |
| PD-118 | Treaty Modification UX | D | RESOLVED | — |
| PD-120 | The Chamber Visual Design | H | PENDING | RQ-036 |
| PD-150 | Permission Ladder Sequence (Hybrid) | D | 🟢 CONFIRMED | RQ-010d |
| PD-151 | Background Location Gating | D | 🔵 OPEN | RQ-010d |
| PD-152 | TrustScore Permission Gating | D | 🔵 OPEN | RQ-010d |
| PD-153 | Manual Mode First-Class Experience | D | 🔵 OPEN | RQ-010c |
| PD-154 | Permission Re-Request Cooldowns | D | 🔵 OPEN | RQ-010d |
| PD-155 | Privacy Messaging Mental Model | D | 🔵 OPEN | RQ-010f |
| PD-201 | URL Scheme Migration | — | PENDING | — |
| PD-202 | Archive Documentation Handling | — | PENDING | — |

---

## PD-002: Streaks vs Rolling Consistency 🟢 READY

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Question** | Should we show traditional streaks or rolling consistency metrics? |
| **Status** | READY (Research complete) |
| **Research** | RQ-033 ✅ COMPLETE |

### Research Finding

RQ-033 recommends **Resilient Streak** hybrid approach:
- Streak count with "grace days" built in
- Focus on "votes cast" rather than "unbroken chain"
- De-emphasize streak breaking as catastrophic

### Recommendation

Implement Resilient Streak:
- "You've voted for The Writer 23 of the last 30 days"
- Grace period before streak "breaks"
- Recovery messaging for missed days

---

## PD-004: Dev Mode Purpose

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Question** | What should Dev Mode contain and who is it for? |
| **Status** | PENDING |

### Current State

Dev Mode exists but purpose unclear:
- Testing tools?
- Admin functions?
- Debug information?

### Options

| Option | Audience | Content |
|--------|----------|---------|
| **A: Debug Only** | Developers | Logs, state inspection |
| **B: Admin Tools** | Product team | User simulation, content preview |
| **C: Power User** | Advanced users | Hidden settings, shortcuts |
| **D: Remove** | — | Not needed for MVP |

---

## PD-104: LoadingInsightsScreen Personalization

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Question** | How should the loading screen personalize based on user data? |
| **Status** | PENDING |

### Current State

Generic loading messages. Opportunity for personalization:
- Reference user's identity goal
- Mention recent progress
- Tease upcoming recommendations

---

## PD-108: Constellation UX Migration ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Decision** | "Big Bang" migration with Skill Tree fallback |
| **Status** | RESOLVED |
| **Research** | RQ-017 |

### Decision

Replace current dashboard with Constellation visualization:
- Solar system metaphor for identity facets
- Orbit distance = Identity Coherence Score (ICS)
- Fallback to Skill Tree if performance issues

---

## PD-109: Council AI Activation Rules ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | C, D |
| **Decision** | Treaty-centric activation with emergency override |
| **Status** | RESOLVED |
| **Research** | RQ-016 |

### Rules

1. Council convenes for treaty negotiation
2. Council reconvenes for treaty breach
3. Emergency summon via Summon Tokens
4. Cool-down period between sessions

---

## PD-110: Airlock Protocol User Control ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Decision** | Severity + Treaty hybrid control model |
| **Status** | RESOLVED |
| **Research** | RQ-018 |

### Airlock Triggers

| Trigger | User Control |
|---------|--------------|
| Treaty breach | Automatic |
| Context transition | User can skip |
| Identity priming | Configurable |
| Emergency | Always shows |

---

## PD-111: Polymorphic Habit Attribution ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Habits can belong to multiple identity facets |
| **Status** | RESOLVED |
| **Research** | RQ-015 |

### Implementation

- Many-to-many relationship: habits ↔ identity_facets
- Attribution weight per facet
- UI shows primary facet with secondary indicators

---

## PD-112: Identity Priming Audio Strategy ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Decision** | Hybrid audio strategy (stock + generative) |
| **Status** | RESOLVED |
| **Research** | RQ-018 |

### Strategy

- **Stock audio:** Background ambience, transitions
- **Generative:** Personalized affirmations (future phase)
- **Current state:** 0-byte placeholder files (needs real audio)

---

## PD-113: Treaty Priority Hierarchy ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Treaties ordered by activation time, user can reorder |
| **Status** | RESOLVED |
| **Research** | RQ-020 |

---

## PD-115: Treaty Creation UX ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Council-mediated creation with visual ceremony |
| **Status** | RESOLVED |
| **Research** | RQ-021 |

### Flow

1. User expresses intent
2. Council convenes to negotiate terms
3. Treaty terms presented
4. Ratification ceremony (3-second hold)
5. Treaty activated

---

## PD-118: Treaty Modification UX ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Constitutional Amendment Model |
| **Status** | RESOLVED |
| **Research** | RQ-024 |

### Modification Types

| Type | Process | Council |
|------|---------|---------|
| **Minor amendment** | In-app editor | No |
| **Major amendment** | Re-ratification | Yes |
| **Pause** | Modal + date picker | No |
| **Repeal** | Type-to-confirm | Optional |

---

## PD-120: The Chamber Visual Design

| Field | Value |
|-------|-------|
| **Phase** | H |
| **Question** | How should The Chamber (Council meeting space) be visualized? |
| **Status** | PENDING |
| **Blocking RQ** | RQ-036 (Chamber Visual Design Patterns) |

### Considerations

- Parliament of Selves metaphor
- Council members as visual personas
- Negotiation table representation
- Turn-taking visualization

---

## PD-201: URL Scheme Migration

| Field | Value |
|-------|-------|
| **Phase** | — |
| **Question** | How to migrate from `atomichabits://` to `thepact://`? |
| **Status** | PENDING |

### Tasks

- Update URL scheme in AndroidManifest
- Handle legacy deep links
- Update documentation

---

## PD-202: Archive Documentation Handling

| Field | Value |
|-------|-------|
| **Phase** | — |
| **Question** | How should archived documentation be managed? |
| **Status** | PENDING |

### Considerations

- Archive file naming conventions
- Quarterly vs monthly archiving
- Cross-reference maintenance

---

---

## PD-150: Permission Ladder Sequence (Hybrid) 🟢 CONFIRMED

| Field | Value |
|-------|-------|
| **Phase** | D (UX) |
| **Decision** | HYBRID: Soft Ask in Onboarding + Context-Triggered Reinforcement |
| **Status** | 🟢 CONFIRMED |
| **Source RQ** | RQ-010d |
| **Confirmed** | 15 Jan 2026 — Executive decision: "Can't we do both?" |

**Executive Decision (15 Jan 2026):** Hybrid approach — BOTH soft ask AND context-triggered

**Hybrid Strategy:**

| Phase | Approach | When | Psychology |
|-------|----------|------|------------|
| **Onboarding** | Soft Ask (skippable) | During onboarding flow | Early adopters can grant upfront |
| **In-App** | Context-Triggered | After friction experienced | "Frustration-driven" conversion |

**Onboarding Soft Ask (NEW):**
- Single screen explaining permission philosophy
- "These permissions help The Pact work for you. Skip if unsure — we'll ask again when it matters."
- Each permission shows 1-line value prop
- **SKIPPABLE** — no blocking, no nag

**Context-Triggered Sequence (unchanged):**

| Step | Permission | Trigger | Psychology |
|------|------------|---------|------------|
| 1 | Notifications | After first Pact signed | Commitment consistency |
| 2 | Activity Recognition | After 3 manual "Run" logs | Effort reduction |
| 3 | Fine Location | When creating gym habit | Feature enablement |
| 4 | Background Location | After 3 foreground successes | Automation upsell |
| 5 | Calendar | After missing habit due to meeting | Conflict resolution |

**User Quote:**
> "Can't we do both - a soft ask and context triggered?"

**Play Store Friendly:** Both approaches avoid dark patterns. Soft ask is optional; context-triggered respects user journey.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §1.1

**Alternatives Rejected:**
- All-at-once mandatory request (current anti-pattern in `permissions_screen.dart`)
- Random/as-needed ordering — loses psychological sequencing
- EITHER/OR approach — hybrid captures both early adopters and skeptics

**CD-018 Tier:** ESSENTIAL

---

## PD-151: Background Location Gating 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | D (UX) |
| **Decision** | Background Location request requires 3 successful foreground location interactions first |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010d |

**Rationale:** Play Store policy favors progressive disclosure. Users who haven't benefited from foreground location won't value background location.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §1.2

**Gate Criteria:**
- User has Fine Location permission granted
- User has triggered 3+ successful geofence/location interactions
- TrustScore > 60 (see PD-152)

**UI Flow:**
1. Phase 1: Request `ACCESS_FINE_LOCATION` when setting up Zone
2. Phase 2: Wait for 3 successful interactions
3. Phase 3: Show "Upgrade to Guardian Mode" → Request `ACCESS_BACKGROUND_LOCATION`

**Alternatives Rejected:** Request both together — higher denial rate, Play Store risk

**CD-018 Tier:** ESSENTIAL

---

## PD-152: TrustScore Permission Gating 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | D (UX) |
| **Decision** | Internal TrustScore (0-100) gates sensitive permission requests; threshold > 60 |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010d |

**Rationale:** Users who have invested in the app are more likely to grant permissions. Requesting too early causes denials that are hard to recover from.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §2

**Scoring:**

| Action | Points |
|--------|--------|
| Completed onboarding | +10 |
| Manually logged a habit | +20 |
| Used app on 3 distinct days | +30 |
| Denied a permission | -50 |

**Threshold:** Score > 60 required for Background Location, Calendar requests.

**Storage:** Local (SharedPreferences) — simpler, no sync needed; analytics optional via Supabase.

**Alternatives Rejected:** No gating — premature requests lead to permanent denials

**CD-018 Tier:** VALUABLE

---

## PD-153: Manual Mode First-Class Experience 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | D (UX) |
| **Decision** | Manual Mode (Context Chips) is a first-class experience, not a degraded fallback |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010c |

**Rationale:** Users who deny all permissions should have a great experience. Manual logging is valid, not punishment.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §4, §5

**Context Chips UI:**
```
📍 WHERE ARE YOU?
[🏠 Home]  [🏢 Work]  [💪 Gym]  [+]
(Tapping sets context for 1hr — configurable)

⚡ CURRENT VIBE?
[💤 Tired]  [🏃 Active]  [🔥 Focused]
```

**Manual Fallback Mapping:**

| Denied Permission | Manual Fallback |
|-------------------|-----------------|
| Location | Context Chips: [🏠 Home] [🏢 Work] [💪 Gym] [+] |
| Activity | "Start Run" manual toggle with timer |
| Calendar | "Focus Mode" (DND) toggle |
| Notifications | In-app "Daily Briefing" card |

**Alternatives Rejected:** Nag screens, degraded UI for non-permission users

**CD-018 Tier:** VALUABLE

---

## PD-154: Permission Re-Request Cooldowns 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | D (UX) |
| **Decision** | Permission re-requests follow cooldown schedule: 7 days → 14 days → never |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010d |

**Rationale:** Respecting the "No" builds trust for a future "Yes." Nagging causes app deletion.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §6

**Cooldown Schedule:**

| Denial # | Response | Cooldown |
|----------|----------|----------|
| 1st | Snackbar: "Understood. Manual Mode active." | 7 days OR 3 manual interactions |
| 2nd | Enhanced Rationale Screen (Glass Pane) | 14 days |
| Permanent | Never ask again | Small "Fix" button in Habit Settings only |

**Re-invite Trigger (after 1st denial):**
- 7 days elapsed, OR
- User manually logged same action 3 times
- Copy: "You've manually logged 'Gym' 8 times. Want to automate?"

**Alternatives Rejected:**
- No cooldown — annoys users
- Single denial = never ask — loses conversion opportunity

**CD-018 Tier:** VALUABLE

---

## PD-155: Privacy Messaging Mental Model 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | D (UX) |
| **Decision** | Location privacy messaging uses "Zones, not coordinates" mental model |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010f |

**Rationale:** Users fear location tracking. Framing as "zone detection" rather than "GPS tracking" reduces anxiety.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §7

**Primary Message:**
> "We see ZONES, not coordinates."

**Messaging per Permission:**

| Permission | Privacy Note |
|------------|--------------|
| Fine Location | "🔒 We see ZONES (e.g., 'Gym'), not coordinates. Your location is converted to a label instantly." |
| Background Location | "🔒 We do not track your commute. We only listen for entry/exit events at zones YOU defined." |
| Activity Recognition | "🔒 Processed on-device. We see 'Walking' or 'Still' — we do not count steps or track fitness data." |
| Calendar | "🔒 We only read 'Busy/Free' status. We do not read event titles." |

**Play Store Justification (ready for Play Console):**
> "The Pact requires background location to detect arrival at user-defined habit zones (e.g., Gym) for Just-In-Time interventions. This automation is core to the behavioral accountability model and functions when the app is closed."

**Alternatives Rejected:** Technical language ("geofencing", "GPS coordinates") — increases anxiety

**CD-018 Tier:** ESSENTIAL

---

## Related Research Questions

| RQ# | Title | Status | Blocks |
|-----|-------|--------|--------|
| RQ-010c | Degradation Scenarios | COMPLETE | PD-153 |
| RQ-010d | Progressive Permission Strategy | COMPLETE | PD-150, PD-151, PD-152, PD-154 |
| RQ-010f | Privacy-Value Transparency | COMPLETE | PD-155 |
| RQ-016 | Council AI (Roundtable Simulation) | COMPLETE | PD-109 |
| RQ-017 | Constellation UX | COMPLETE | PD-108 |
| RQ-018 | Airlock Protocol | COMPLETE | PD-110, PD-112 |
| RQ-021 | Treaty Lifecycle & UX | COMPLETE | PD-115 |
| RQ-024 | Treaty Modification | COMPLETE | PD-118 |
| RQ-033 | Streak Philosophy | COMPLETE | PD-002 |
| RQ-036 | Chamber Visual Design | NEEDS RESEARCH | PD-120 |

---

*UX decisions define how users experience The Pact's interface and flows.*
