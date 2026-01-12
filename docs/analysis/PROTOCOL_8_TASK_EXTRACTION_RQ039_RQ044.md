# Protocol 8: Task Extraction — RQ-039/RQ-044

> **Date:** 12 January 2026
> **Extractor:** Claude (Opus 4.5)
> **Source:** Protocol 9 Reconciliation of RQ-039/RQ-044 Deep Think Response
> **Protocol Version:** 8 (from AI_AGENT_PROTOCOL.md)

---

## Part 1: Extracted Tasks Overview

### Task Summary

| Phase | Task Count | CRITICAL | HIGH | MEDIUM | LOW |
|-------|------------|----------|------|--------|-----|
| **A (Schema)** | 4 | 2 | 2 | 0 | 0 |
| **B (Services)** | 6 | 2 | 3 | 1 | 0 |
| **D (UX)** | 8 | 1 | 5 | 2 | 0 |
| **E (Polish)** | 4 | 0 | 1 | 2 | 1 |
| **TOTAL** | **22** | **5** | **11** | **5** | **1** |

---

## Part 2: Phase A — Schema Tasks

### A-13: Create `user_tokens` Table

| Field | Value |
|-------|-------|
| **ID** | A-13 |
| **Task** | Create `user_tokens` table for token balance tracking |
| **Priority** | CRITICAL |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039 |
| **Component** | Database |
| **Blocking** | B-18, B-19, D-15 |

**Schema:**
```sql
CREATE TABLE user_tokens (
  user_id UUID PRIMARY KEY REFERENCES profiles(id),
  current_balance INTEGER DEFAULT 0,
  lifetime_earned INTEGER DEFAULT 0,
  lifetime_spent INTEGER DEFAULT 0,
  last_earned_at TIMESTAMPTZ,
  last_spent_at TIMESTAMPTZ,
  visible_cap INTEGER DEFAULT 3,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### A-14: Create `token_transactions` Table

| Field | Value |
|-------|-------|
| **ID** | A-14 |
| **Task** | Create `token_transactions` ledger table |
| **Priority** | CRITICAL |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039 |
| **Component** | Database |
| **Blocking** | B-18 |

**Schema:**
```sql
CREATE TABLE token_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  amount INTEGER NOT NULL,
  transaction_type TEXT NOT NULL,
  source_id UUID,
  balance_after INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_token_transactions_user ON token_transactions(user_id);
CREATE INDEX idx_token_transactions_type ON token_transactions(transaction_type);
```

---

### A-15: Create `witness_stakes` Table

| Field | Value |
|-------|-------|
| **ID** | A-15 |
| **Task** | Create `witness_stakes` configuration table |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-044 |
| **Component** | Database |
| **Blocking** | B-22 |

**Schema:**
```sql
CREATE TABLE witness_stakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID REFERENCES habits(id) NOT NULL,
  witness_id UUID REFERENCES profiles(id) NOT NULL,
  stake_type TEXT NOT NULL CHECK (stake_type IN ('visibility_only', 'encouragement')),
  visibility_level TEXT DEFAULT 'summary' CHECK (visibility_level IN ('summary', 'detailed')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(habit_id, witness_id)
);
```

**Note:** Only `visibility_only` and `encouragement` types allowed per CD-010.

---

### A-16: Add `suppress_bonus_prompts` to User Preferences

| Field | Value |
|-------|-------|
| **ID** | A-16 |
| **Task** | Add archetype calibration flag to user preferences |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.10 |
| **Component** | Database |
| **Blocking** | D-21 |

**Migration:**
```sql
ALTER TABLE user_preferences
ADD COLUMN suppress_bonus_prompts BOOLEAN DEFAULT false;
```

---

## Part 3: Phase B — Service Tasks

### B-18: Create `TokenService` (Core)

| Field | Value |
|-------|-------|
| **ID** | B-18 |
| **Task** | Create Dart service for token balance and transactions |
| **Priority** | CRITICAL |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039 |
| **Component** | Service |
| **Depends On** | A-13, A-14 |
| **Blocking** | D-15, D-16, D-17 |

**Methods:**
```dart
class TokenService {
  Future<int> getBalance(String userId);
  Future<void> earnToken(String userId, String transactionType, {String? sourceId});
  Future<bool> spendToken(String userId, String transactionType, {String? sourceId});
  Future<List<TokenTransaction>> getTransactionHistory(String userId);
}
```

---

### B-19: Create Weekly Token Cron Job

| Field | Value |
|-------|-------|
| **ID** | B-19 |
| **Task** | Create Supabase Edge Function for weekly token distribution |
| **Priority** | CRITICAL |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.1 |
| **Component** | Edge Function |
| **Depends On** | A-13 |

**Logic:**
- Run every Sunday at 00:00 UTC
- For ALL users: Add 1 to `current_balance`, increment `lifetime_earned`
- Log transaction with type `earned_weekly_base`

---

### B-20: Create Crisis Bypass Logic

| Field | Value |
|-------|-------|
| **ID** | B-20 |
| **Task** | Implement tension threshold check for free Council access |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.8 |
| **Component** | Service |
| **Depends On** | Tension score calculation (existing) |

**Logic:**
```dart
Future<bool> canBypassToken(String userId) async {
  final tensionScore = await getTensionScore(userId);
  final lastBypass = await getLastCrisisBypass(userId);
  final daysSinceBypass = DateTime.now().difference(lastBypass).inDays;

  return tensionScore >= 0.65 && daysSinceBypass >= 30;
}
```

---

### B-21: Create Bonus Token Claim Logic

| Field | Value |
|-------|-------|
| **ID** | B-21 |
| **Task** | Implement Weekly Review bonus token earning |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.1e |
| **Component** | Service |
| **Depends On** | B-18, Weekly Review (existing) |

**Logic:**
- After Weekly Review completion, check if bonus already claimed this week
- If not claimed, add 1 token with type `earned_weekly_bonus`
- Respect `suppress_bonus_prompts` flag (don't even show option)

---

### B-22: Create `WitnessStakeService`

| Field | Value |
|-------|-------|
| **ID** | B-22 |
| **Task** | Create service for witness stake configuration |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-044 |
| **Component** | Service |
| **Depends On** | A-15 |

**Methods:**
```dart
class WitnessStakeService {
  Future<void> configureStake(String habitId, String witnessId, StakeType type);
  Future<StakeType?> getStakeType(String habitId, String witnessId);
  Future<void> removeStake(String habitId, String witnessId);
  Future<void> notifyWitness(String habitId, HabitEvent event);
}
```

**Note:** Only `visibility_only` and `encouragement` types implemented.

---

### B-23: Create Perfectionist Calibration Logic

| Field | Value |
|-------|-------|
| **ID** | B-23 |
| **Task** | Auto-set `suppress_bonus_prompts` for HIGH Perfectionist users |
| **Priority** | MEDIUM |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.10 |
| **Component** | Service |
| **Depends On** | A-16, Psychometric profile (existing) |

**Logic:**
- On archetype calculation, if `perfectionist_reactivity > 0.7`:
  - Set `suppress_bonus_prompts = true`
- User can manually override in settings

---

## Part 4: Phase D — UX Tasks

### D-15: Token Balance Display

| Field | Value |
|-------|-------|
| **ID** | D-15 |
| **Task** | Add token balance badge to Council button |
| **Priority** | CRITICAL |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.12 (MVP) |
| **Component** | Screen/Widget |
| **Depends On** | B-18 |

**UI:**
- Circular badge showing token count (1, 2, 3, etc.)
- Positioned on Council entry button
- Updates in real-time

---

### D-16: Council Entry Token Check

| Field | Value |
|-------|-------|
| **ID** | D-16 |
| **Task** | Add token spending confirmation to Council entry |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.12 (MVP) |
| **Component** | Screen |
| **Depends On** | B-18, B-20 |

**Flow:**
1. User taps Council button
2. If balance ≥ 1: Show "Spend 1 token to enter Council? (You have X)"
3. If balance = 0 AND crisis bypass eligible: Show "High tension detected. Free access available."
4. If balance = 0 AND no bypass: Show "No tokens available. Next token arrives Sunday."
5. On confirm: Deduct token, enter Council

---

### D-17: Post-Council Token Feedback

| Field | Value |
|-------|-------|
| **ID** | D-17 |
| **Task** | Show remaining tokens after Council session |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039 |
| **Component** | Screen |
| **Depends On** | B-18 |

**UI:**
- After Council completion: "Session complete. You have X tokens remaining."
- If X = 0: "Your next token arrives Sunday."

---

### D-18: Weekly Token Notification

| Field | Value |
|-------|-------|
| **ID** | D-18 |
| **Task** | Send push notification when weekly token earned |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.3 |
| **Component** | Notification |
| **Depends On** | B-19 |

**Copy:**
- "🎉 Your weekly Council token is ready!"
- Tapping opens app to token balance screen

---

### D-19: Bonus Token Prompt (Weekly Review)

| Field | Value |
|-------|-------|
| **ID** | D-19 |
| **Task** | Add bonus token CTA to Weekly Review completion screen |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.1e |
| **Component** | Screen |
| **Depends On** | B-21, B-23 |

**Flow:**
1. User completes Weekly Review
2. If NOT `suppress_bonus_prompts` AND bonus not yet claimed:
   - Show "Earn a bonus token?" with claim button
3. If claimed: Show "Bonus token earned! 🎉"
4. If `suppress_bonus_prompts`: Skip directly to success screen

---

### D-20: Witness Stake Configuration UI

| Field | Value |
|-------|-------|
| **ID** | D-20 |
| **Task** | Add stake type selector to witness invitation flow |
| **Priority** | MEDIUM |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-044.8 |
| **Component** | Screen |
| **Depends On** | B-22 |

**UI:**
- During witness invitation:
  - "What would you like [Witness] to see?"
  - Option A: "Progress summaries only" (visibility_only)
  - Option B: "Progress + encouragement messages" (encouragement)
- Default: Progress summaries only

---

### D-21: Bonus Prompt Settings Toggle

| Field | Value |
|-------|-------|
| **ID** | D-21 |
| **Task** | Add setting to enable/disable bonus token prompts |
| **Priority** | MEDIUM |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.10 |
| **Component** | Screen |
| **Depends On** | A-16, B-23 |

**UI:**
- Settings > Tokens > "Show bonus token prompts"
- Toggle (default: ON unless HIGH Perfectionist)
- Help text: "Turn off to reduce prompts. You'll still earn your weekly base token."

---

### D-22: Recovery Path UI (Post-Failure)

| Field | Value |
|-------|-------|
| **ID** | D-22 |
| **Task** | Implement dignity-preserving failure messaging |
| **Priority** | MEDIUM |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-044.7 |
| **Component** | Screen/Widget |
| **Depends On** | — |

**Copy (on habit miss):**
- User sees: "Today didn't go as planned. That's okay — tomorrow is a fresh start."
- NOT: "You missed your habit."

**Copy (witness notification):**
- Witness sees: "[User] is having a challenging day."
- NOT: "[User] failed their habit."

---

## Part 5: Phase E — Polish Tasks

### E-15: Witness Training Content

| Field | Value |
|-------|-------|
| **ID** | E-15 |
| **Task** | Create in-app witness onboarding content |
| **Priority** | HIGH |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-044.5 |
| **Component** | Content |

**Content:**
```
"When [User] has a tough day:

✅ DO: Send encouragement ("Tomorrow's yours!")
✅ DO: Share your own struggles
✅ DO: Stay quiet (sometimes silence is supportive)

❌ DON'T: Ask why they failed
❌ DON'T: Express disappointment
❌ DON'T: Offer unsolicited advice"
```

---

### E-16: A/B Test Framework for Crisis Threshold

| Field | Value |
|-------|-------|
| **ID** | E-16 |
| **Task** | Implement A/B test for crisis bypass threshold |
| **Priority** | MEDIUM |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.8 |
| **Component** | Analytics |

**Groups:**
- A: 0.60 threshold
- B: 0.70 threshold
- Control: 0.65 threshold

**Metrics:**
- Crisis bypass usage rate
- Council session quality (completion, treaty creation)
- User satisfaction (post-session survey)

---

### E-17: Token Economy Analytics Dashboard

| Field | Value |
|-------|-------|
| **ID** | E-17 |
| **Task** | Create internal dashboard for token economy monitoring |
| **Priority** | MEDIUM |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.12 |
| **Component** | Analytics |

**Metrics:**
- Avg tokens accumulated per user
- % users at 0 tokens
- % users at 3+ tokens
- Council sessions per token spent
- Time from token earn to spend
- Bonus token claim rate

---

### E-18: Premium Token Cap Upgrade

| Field | Value |
|-------|-------|
| **ID** | E-18 |
| **Task** | Implement higher visible cap for premium users |
| **Priority** | LOW |
| **Status** | 🔴 NOT STARTED |
| **Source** | RQ-039.9 |
| **Component** | Service/Database |
| **Depends On** | Premium subscription (existing) |

**Logic:**
- Free users: `visible_cap = 3`
- Premium users: `visible_cap = 5`
- No change to earning rate

---

## Part 6: Task Dependency Graph

```
A-13 (user_tokens) ─┬─→ B-18 (TokenService) ─┬─→ D-15 (Balance Display)
                    │                        ├─→ D-16 (Council Entry)
                    │                        ├─→ D-17 (Post-Council)
                    │                        └─→ D-19 (Bonus Prompt)
                    │
                    └─→ B-19 (Weekly Cron) ─→ D-18 (Notification)

A-14 (token_transactions) ─→ B-18 (TokenService)

A-15 (witness_stakes) ─→ B-22 (WitnessStakeService) ─→ D-20 (Stake UI)

A-16 (suppress_bonus) ─→ B-23 (Perfectionist Logic) ─→ D-21 (Settings)
                                                    └─→ D-19 (Bonus Prompt)

B-20 (Crisis Bypass) ─→ D-16 (Council Entry)
```

---

## Part 7: Implementation Phases

### Phase T1: MVP (Week 1)

**Scope:** Base token earning + spending only

| Task | Effort |
|------|--------|
| A-13 | 2 hours |
| A-14 | 1 hour |
| B-18 | 4 hours |
| B-19 | 3 hours |
| D-15 | 2 hours |
| D-16 | 3 hours |
| D-17 | 1 hour |
| **TOTAL** | **16 hours (~2 days)** |

---

### Phase T2: Bonus + Calibration (Week 2)

**Scope:** Bonus tokens, Perfectionist calibration

| Task | Effort |
|------|--------|
| A-16 | 1 hour |
| B-21 | 3 hours |
| B-23 | 2 hours |
| D-18 | 2 hours |
| D-19 | 3 hours |
| D-21 | 2 hours |
| **TOTAL** | **13 hours (~2 days)** |

---

### Phase T3: Stakes + Crisis (Week 3)

**Scope:** Witness stakes, crisis bypass

| Task | Effort |
|------|--------|
| A-15 | 2 hours |
| B-20 | 3 hours |
| B-22 | 4 hours |
| D-20 | 3 hours |
| D-22 | 2 hours |
| **TOTAL** | **14 hours (~2 days)** |

---

### Phase T4: Polish (Week 4+)

**Scope:** Analytics, A/B testing, premium

| Task | Effort |
|------|--------|
| E-15 | 2 hours |
| E-16 | 4 hours |
| E-17 | 6 hours |
| E-18 | 2 hours |
| **TOTAL** | **14 hours (~2 days)** |

---

## Part 8: Protocol 8 Checklist

- [x] All ACCEPT/MODIFY items converted to tasks
- [x] Each task has ID, priority, status, source
- [x] Dependencies documented
- [x] No duplicate tasks (checked against existing)
- [x] Phase assigned to each task
- [x] Effort estimates included
- [x] Schema SQL provided where applicable
- [x] Service method signatures provided where applicable
- [x] UI copy provided where applicable

---

## Part 9: Summary

### New Tasks Created: 22

| Category | Count |
|----------|-------|
| Schema (A-*) | 4 |
| Service (B-*) | 6 |
| UX (D-*) | 8 |
| Polish (E-*) | 4 |

### Research Questions Completed: 2

| RQ | Status |
|----|--------|
| RQ-039 (Token Economy) | ✅ COMPLETE |
| RQ-044 (Stakes Psychology) | ✅ COMPLETE |

### Product Decisions Resolved: 1

| PD | Resolution |
|----|------------|
| PD-119 (Token Economy) | Automatic base (1/week) + optional bonus; soft cap; gain framing |

---

*Protocol 8 Task Extraction Complete — 22 tasks ready for RESEARCH_QUESTIONS.md Master Tracker*
