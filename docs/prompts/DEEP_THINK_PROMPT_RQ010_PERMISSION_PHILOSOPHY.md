# Deep Think Prompt: RQ-010 — Permission Data Philosophy & JITAI Graceful Degradation

> **Target Research:** RQ-010 (main), RQ-010a through RQ-010h (sub-RQs)
> **Prepared:** 13 January 2026
> **For:** Google Deep Think / Gemini / DeepSeek
> **App Name:** The Pact
> **Urgency:** **CRITICAL** — JITAI system has no graceful degradation strategy for denied permissions
> **Origin:** Audit revealed no consideration of partial permission scenarios (20%, 40%, 60% granted)

---

## Your Role

You are a **Senior Mobile Privacy Architect & Behavioral Systems Designer** specializing in:
- Android permission models (runtime, manifest, special permissions)
- Graceful degradation patterns for context-aware systems
- Privacy-preserving JITAI (Just-In-Time Adaptive Intervention) design
- User trust and transparency in health/wellness apps
- Battery optimization vs data quality tradeoffs

**Your approach:**
1. Analyze each permission's contribution to JITAI accuracy
2. Model degradation scenarios mathematically (not just conceptually)
3. Propose concrete fallback strategies for each denied permission
4. Ground recommendations in Android best practices and research
5. Consider the "suspicious user" who grants NOTHING initially

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. The app uses a **JITAI (Just-In-Time Adaptive Intervention)** system to decide WHEN and HOW to nudge users toward their goals. JITAI effectiveness depends on **context signals** — many of which require Android permissions the user may deny.

### The Core Problem

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         THE PERMISSION PARADOX                               │
│                                                                              │
│  JITAI needs context data to be effective:                                   │
│    • Location (is user at gym?)                                              │
│    • Calendar (is user in a meeting?)                                        │
│    • Health Connect (did user sleep well?)                                   │
│    • Activity Recognition (is user walking?)                                 │
│    • Notifications (can we even reach them?)                                 │
│                                                                              │
│  BUT: Users increasingly DENY permissions (50-70% deny at least one)         │
│                                                                              │
│  RESULT: System designed for 100% permissions may FAIL at 40%                │
│                                                                              │
│  QUESTION: How does The Pact work when users grant only SOME permissions?    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Why This Research Is CRITICAL

**Current State:** The JITAI system assumes all ContextSnapshot fields are available:

```dart
ContextSnapshot {
  TimeContext time;          // Always available (no permission)
  BiometricContext? bio;     // Requires Health Connect (Android 14+)
  CalendarContext? calendar; // Requires READ_CALENDAR
  WeatherContext? weather;   // API call (no permission, but requires internet)
  LocationContext? location; // Requires ACCESS_FINE_LOCATION or COARSE
  DigitalContext? digital;   // Requires USAGE_STATS (special permission)
  HistoricalContext history; // App-internal (no permission)
}
```

**The Gap:** No documentation exists for:
- What happens if `bio` is null?
- What happens if `calendar` is null?
- What happens if 50% of context is missing?
- Does JITAI accuracy degrade gracefully or catastrophically?

**Downstream Impact:**
- 30+ implementation tasks depend on ContextSnapshot
- JITAI decision engine assumes context availability
- No fallback strategies are defined

---

## PART 2: Android Permission Landscape (2024-2025)

### Permission Categories

| Category | Android Behavior | User Friction |
|----------|------------------|---------------|
| **Normal** | Granted at install, no prompt | None |
| **Dangerous** | Runtime prompt, user can deny | Medium |
| **Special** | Settings page redirect required | High |
| **Signature** | System apps only | N/A |

### Permissions Required by ContextSnapshot

| Context | Permission(s) | Category | Deny Rate* | Impact if Denied |
|---------|---------------|----------|------------|------------------|
| **Time** | None | — | 0% | N/A |
| **Weather** | INTERNET | Normal | ~0% | No outdoor context |
| **History** | None (app-internal) | — | 0% | N/A |
| **Location** | ACCESS_FINE_LOCATION | Dangerous | 30-50% | No gym/home/work detection |
| **Calendar** | READ_CALENDAR | Dangerous | 40-60% | No meeting awareness |
| **Biometric** | Health Connect access | Special | 50-70% | No sleep/HRV data |
| **Digital** | PACKAGE_USAGE_STATS | Special | 70-90% | No distraction context |
| **Activity** | ACTIVITY_RECOGNITION | Dangerous | 30-40% | No walking/stationary detection |
| **Notifications** | POST_NOTIFICATIONS (Android 13+) | Dangerous | 20-40% | Cannot nudge user |

*Estimated from industry data; actual rates vary by demographic and app category.

### The Reality: Permission Combinations

With 6 deniable permissions, there are **64 possible combinations** (2^6). Common scenarios:

| Scenario | Permissions Granted | % of Context | User Profile |
|----------|---------------------|--------------|--------------|
| **Paranoid** | Notifications only | ~20% | Privacy-conscious |
| **Minimal** | Notifications + Location | ~35% | Typical skeptic |
| **Partial** | Notifications + Location + Calendar | ~50% | Moderate trust |
| **Trusting** | All except Health Connect | ~70% | Engaged user |
| **Full** | Everything | 100% | Power user |

---

## PART 3: The Research Questions

### RQ-010: Permission Data Philosophy (Main)

**Core Question:** How should The Pact's JITAI system behave when users grant only partial permissions?

**Why This Matters:**
- 50-70% of users will deny at least one permission
- System designed for 100% will fail for majority
- Poor degradation = poor user experience = churn
- Overly aggressive permission asks = uninstalls

---

### RQ-010a: Permission-to-Accuracy Mapping

**Question:** What is the quantitative contribution of each permission to JITAI timing accuracy?

**Context:** Not all permissions are equal. Location might contribute 20% to accuracy; Health Connect might contribute 10%.

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Accuracy Decomposition:** If JITAI accuracy = 100% at full context, what % does each context source contribute? | Provide breakdown (e.g., Location: 20%, Calendar: 15%, etc.) |
| 2 | **Marginal Value:** Which permission has highest marginal value (most accuracy per privacy cost)? | Rank permissions by value/privacy ratio |
| 3 | **Redundancy:** Do any context sources overlap (e.g., Location + Calendar both indicate "at work")? | Identify redundant signals |
| 4 | **Baseline:** What is JITAI accuracy with ZERO optional permissions? | Estimate % using only Time + History |

**Output Required:**
1. Permission → Accuracy contribution table
2. Ranked list by marginal value
3. Redundancy matrix
4. Baseline accuracy estimate with confidence

---

### RQ-010b: Graceful Degradation Strategies

**Question:** What fallback strategies should JITAI use when specific permissions are denied?

**Context:** Each denied permission needs a fallback:
- **Direct substitute:** Use another signal
- **Inference:** Predict from available data
- **Prompt:** Ask user directly (low friction)
- **Default:** Use population-average behavior

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Location denied:** How can we infer location context without GPS? | Propose 3 fallbacks (WiFi SSID inference? Time-of-day patterns? Manual "I'm at gym" button?) |
| 2 | **Calendar denied:** How can we infer busyness without calendar access? | Propose fallbacks (historical patterns? explicit "busy now" toggle?) |
| 3 | **Health Connect denied:** How can we estimate sleep/energy without biometrics? | Propose fallbacks (self-report? time-based defaults? phone usage patterns?) |
| 4 | **Usage Stats denied:** How can we estimate distraction level? | Propose fallbacks |
| 5 | **Notifications denied:** What's the point of JITAI if we can't nudge? | Propose alternatives (widget? email? in-app prompts on next open?) |

**Output Required:**
1. Fallback strategy table (Permission → Primary Fallback → Secondary Fallback → Last Resort)
2. Accuracy penalty estimate for each fallback
3. User friction assessment for each fallback
4. Implementation complexity rating

---

### RQ-010c: Degradation Scenarios (20/40/60/80/100%)

**Question:** Model specific permission combinations and their impact on JITAI effectiveness.

**Context:** We need concrete scenarios, not abstract "it degrades gracefully."

**Sub-Questions:**

| # | Scenario | Permissions Granted | Your Task |
|---|----------|---------------------|-----------|
| 1 | **20% (Paranoid)** | Notifications only | Model JITAI behavior. What can it do? What fails? |
| 2 | **40% (Skeptic)** | Notifications + Location | Model JITAI behavior. How much better than 20%? |
| 3 | **60% (Moderate)** | Notifications + Location + Calendar | Model JITAI behavior. Is this the "sweet spot"? |
| 4 | **80% (Trusting)** | All except Health Connect + Usage Stats | Model JITAI behavior. Is extra 20% worth the asks? |
| 5 | **100% (Full)** | Everything | Establish baseline accuracy |

**Output Required:**
1. Detailed behavior model for each scenario
2. JITAI capabilities matrix (what works, what doesn't, what's degraded)
3. User experience impact assessment
4. Recommendation: Which scenario is "minimum viable"?

---

### RQ-010d: Progressive Permission Strategy

**Question:** How should The Pact sequence permission requests to maximize grants while minimizing friction?

**Context:** Asking all permissions at once = high denial rate. Progressive disclosure = higher acceptance.

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Sequence:** In what order should permissions be requested? (Value + trust-building) | Propose sequence with rationale |
| 2 | **Timing:** When should each permission be requested? (Onboarding? After value shown? At point of need?) | Propose timing for each |
| 3 | **Framing:** How should each permission be framed to maximize acceptance? | Provide copy examples |
| 4 | **Recovery:** If user denies, when/how to re-ask? | Propose retry strategy |
| 5 | **Never-Ask:** Which permissions should NEVER be requested (too much friction, too little value)? | Identify candidates |

**Output Required:**
1. Sequenced permission flow diagram
2. Timing recommendations with rationale
3. Permission request copy (3 variants per permission)
4. Re-request strategy with timing
5. "Do not request" list with justification

---

### RQ-010e: JITAI Flexibility Architecture

**Question:** Should JITAI be designed as rigid (assumes full context) or flexible (adapts to available context)?

**Context:** Two architectural approaches:

| Approach | Description | Pros | Cons |
|----------|-------------|------|------|
| **Rigid** | One algorithm assuming full context | Simpler, optimal when data available | Fails catastrophically at low permissions |
| **Flexible** | Multiple algorithms for different contexts | Robust, works at any level | Complex, harder to optimize |
| **Adaptive** | One algorithm that weights available data | Balance | Requires careful calibration |

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Current State:** Is the existing JITAI design rigid or flexible? | Assess based on ContextSnapshot design |
| 2 | **Recommendation:** Which architecture for The Pact's MVP? | Recommend with rationale |
| 3 | **Migration Path:** If rigid now, how to migrate to flexible? | Propose steps |
| 4 | **Testing:** How to test JITAI at different permission levels? | Propose test strategy |

**Output Required:**
1. Assessment of current architecture
2. Recommended architecture with rationale
3. Migration plan if needed
4. Test matrix (permission combo × expected behavior)

---

### RQ-010f: Privacy-Value Transparency

**Question:** How should The Pact communicate the permission→value tradeoff to users?

**Context:** Users are more likely to grant permissions if they understand the benefit.

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Value Proposition:** For each permission, what's the user-facing benefit? | Write copy: "Grant location to unlock: [benefit]" |
| 2 | **Privacy Dashboard:** Should users see what data is collected and how it's used? | Recommend design |
| 3 | **Accuracy Indicator:** Should users see "JITAI is operating at 60% accuracy due to denied permissions"? | Recommend yes/no with rationale |
| 4 | **Upgrade Prompts:** When JITAI fails due to missing data, should we explain? | Propose UX pattern |

**Output Required:**
1. Permission → User benefit mapping (marketing copy)
2. Privacy dashboard recommendation (yes/no, design if yes)
3. Accuracy indicator recommendation
4. Failure explanation UX pattern

---

### RQ-010g: Minimum Viable Permission Set

**Question:** What is the MINIMUM set of permissions that makes JITAI valuable?

**Context:** If JITAI needs 80% permissions to be useful, we have a problem. If it can be valuable at 30%, we have flexibility.

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Absolute Minimum:** Below what permission level is JITAI NOT worth having? | Define threshold |
| 2 | **Notification Dependency:** Is POST_NOTIFICATIONS the true gatekeeper? | Analyze if app is useless without it |
| 3 | **Alternative Value:** If JITAI is degraded, what other value can app provide? | Propose fallback features |
| 4 | **Competitive Analysis:** What permissions do competing apps (Fabulous, Streaks, etc.) require? | Research |

**Output Required:**
1. Minimum viable permission set definition
2. Analysis of notification criticality
3. Fallback value proposition if JITAI is severely degraded
4. Competitive permission comparison table

---

### RQ-010h: Battery vs Accuracy Tradeoff

**Question:** How do aggressive context sensing and permission-constrained operation affect battery?

**Context:** More permissions often means more battery drain. But denied permissions might force more frequent polling.

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Full Permission Battery:** What's battery impact with all permissions? | Estimate % daily battery |
| 2 | **Degraded Battery:** Does denied location cause more frequent time-based checks? | Analyze |
| 3 | **Optimal Point:** Is there a permission combo that maximizes accuracy/battery? | Recommend |
| 4 | **User Control:** Should users have a "battery saver mode" that disables some sensing? | Recommend |

**Output Required:**
1. Battery impact estimates by permission combo
2. Degraded mode battery analysis
3. Optimal permission combo recommendation
4. Battery saver mode recommendation

---

## PART 4: Architectural Constraints

| Constraint | Rule |
|------------|------|
| **Platform** | Android-first (Flutter). No iOS-specific APIs. |
| **Android Version** | Target API 33+, but support back to API 26 |
| **Health Connect** | Android 14+ only; must gracefully handle pre-14 devices |
| **Battery** | < 5% daily battery impact target |
| **Background** | WorkManager for periodic checks; foreground service for active tracking |
| **CD-017** | Android-first — all features must work without iOS/wearables |

---

## PART 5: Anti-Patterns to Avoid

```
❌ Assuming users will grant all permissions
❌ Designing for 100% and "handling denial later"
❌ Requesting all permissions at onboarding (permission fatigue)
❌ No explanation for why permission is needed
❌ Blocking app functionality completely if one permission denied
❌ Ignoring pre-Android 14 devices (no Health Connect)
❌ Battery-draining workarounds for denied permissions
❌ Dark patterns to trick users into granting permissions
❌ Never re-asking after denial (some users change their mind)
❌ Re-asking too aggressively (harassment)
```

---

## PART 6: Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Quantitative** | Are accuracy/battery estimates specific numbers, not vague? |
| **Actionable** | Can an engineer implement the fallback strategy? |
| **User-Centric** | Does the recommendation consider user trust and friction? |
| **Robust** | Does the system work at 20% permissions? |
| **Testable** | Can we verify the degradation behavior? |

---

## PART 7: Example of Good Output

**For RQ-010b Sub-Question 1 (Location Fallback):**

```markdown
### Location Permission Denied: Fallback Strategies

**Permission:** ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION

**Primary Use:** Detect user context (home, work, gym, commuting)

**Fallback Strategy 1: Time-Based Inference (Accuracy: ~60%)**
- Use historical patterns: "User is usually at gym 6-7 PM on weekdays"
- Requires 2 weeks of data collection
- Implementation: Pattern mining on habit completion times
- Accuracy Penalty: -40% location accuracy

**Fallback Strategy 2: WiFi SSID Inference (Accuracy: ~75%)**
- Map known SSIDs to locations without GPS
- Requires ACCESS_WIFI_STATE (normal permission)
- User labels SSIDs: "This is my home WiFi"
- Accuracy Penalty: -25% location accuracy

**Fallback Strategy 3: Manual Context Button (Accuracy: ~95%)**
- User taps "I'm at gym" when they arrive
- Zero privacy cost
- Accuracy Penalty: -5% (only if user forgets)
- Friction: Medium (requires active input)

**Recommended Approach:**
1. Try WiFi SSID inference first (low friction, decent accuracy)
2. Fall back to time-based inference for unknown WiFi
3. Offer manual button for power users

**Confidence:** MEDIUM
- WiFi SSID inference is a known technique but requires user labeling
- Time-based inference accuracy varies by user routine consistency
```

---

## PART 8: Deliverables Summary

| RQ | Deliverable |
|----|-------------|
| **RQ-010a** | Permission → Accuracy contribution table |
| **RQ-010b** | Fallback strategy table with accuracy penalties |
| **RQ-010c** | Degradation scenario models (20/40/60/80/100%) |
| **RQ-010d** | Progressive permission request flow |
| **RQ-010e** | JITAI architecture recommendation (rigid/flexible/adaptive) |
| **RQ-010f** | Privacy-value transparency UX recommendations |
| **RQ-010g** | Minimum viable permission set definition |
| **RQ-010h** | Battery vs accuracy analysis |

---

## PART 9: Final Checklist Before Submitting

- [ ] Each sub-question (RQ-010a through RQ-010h) has explicit answers
- [ ] Accuracy estimates are specific numbers (not "good" or "degraded")
- [ ] Fallback strategies include implementation details
- [ ] Degradation scenarios cover 20/40/60/80/100% permission levels
- [ ] Progressive permission flow includes timing AND framing
- [ ] Architecture recommendation is clear (rigid vs flexible)
- [ ] Minimum viable permission set is defined
- [ ] Battery estimates are realistic
- [ ] Android version constraints are respected
- [ ] User trust and friction are considered throughout

---

## PART 10: Integration Points

This research feeds into:

| Task | Dependency |
|------|------------|
| B-10 | `ContextSnapshot` implementation — needs null-handling for each context |
| B-11 | `calculateTensionScore()` — needs fallback logic |
| B-08 | Chronotype-JITAI matrix — needs degraded mode |
| All JITAI | Every intervention timing decision needs permission awareness |

---

*End of Prompt*
