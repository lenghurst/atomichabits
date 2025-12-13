# ROADMAP.md — Atomic Habits Hook App

> **Last Updated:** December 2025 (v4.0.0)
> **Philosophy:** Graceful Consistency > Fragile Streaks
> **CRITICAL:** Keep this file in sync with `main`. Update after every sprint/session.

---

## ⚠️ AI HANDOFF PROTOCOL

### Before Starting Work
1. Read `AI_CONTEXT.md` for current architecture state
2. Read `AI_ONBOARDING_SPEC.md` for AI feature specification
3. Check this roadmap for priorities
4. Check orphaned branches: `git branch -r --no-merged main | wc -l`
5. If item exists on orphaned branch, consider rebasing instead of recreating

### After Completing Work
1. Update the relevant section below (move items, add details)
2. Add to Sprint History with date and changes
3. Cherry-pick this file to main: `git checkout main && git checkout <branch> -- ROADMAP.md`
4. Create/update PR with roadmap changes noted

---

## Current Sprint: Multiple Habits & Polish

**Goal:** Support tracking multiple habits with focus mode

**Status:** 🚧 Planning

**Tasks:**
- [ ] **Model:** Update `AppState` to support `List<Habit>` instead of single habit
- [ ] **UI:** Create habit list view with selection
- [ ] **UI:** Add "Focus Mode" toggle for single-habit concentration
- [ ] **Logic:** Update notification service for multiple habits
- [ ] **Migration:** Preserve existing single-habit data on upgrade

---

## Previous Sprint: AI Onboarding Phase 2 - Conversational UI (✅ Completed)

**Goal:** Implement the "Conversational First" Experience (Tier 1)

**Status:** ✅ Complete (December 2025)

**Spec:** See `AI_ONBOARDING_SPEC.md` (v4.0.0)

**Completed Tasks:**
- [x] **UI:** Create `ConversationalOnboardingScreen` (Chat UI)
- [x] **UI:** Create `ChatMessageBubble` widget (User vs AI bubbles with streaming)
- [x] **Logic:** Implement `OnboardingOrchestrator.sendMessage()` with `ConversationResult`
- [x] **Logic:** Wire up `GeminiChatService` for Tier 1 chat
- [x] **Migration:** Chat is now default route (`/`); Form moved to (`/onboarding/manual`)
- [x] **Guardrails:** Escape hatch triggers on frustration patterns
- [ ] **Pending:** Create `ClaudeChatService` (Tier 2) for "Bad Habit" coaching
- [ ] **Pending:** Integration testing in real network conditions

See Sprint History below for details.

---

## Previous Sprint: AI Onboarding Phase 1 (✅ Completed)

**Goal:** Infrastructure & "Magic Wand" MVP

**Status:** ✅ Complete (December 2025)

See Sprint History below for details.

---

## Immediate Priority (Next 1-2 Sprints)

### 🔴 High Priority

| Item | Description | Complexity | Blocked By |
|------|-------------|------------|------------|
| **Multiple Habits** | Support tracking multiple habits with focus mode | High | Nothing |
| **History/Calendar View** | Visual calendar showing completion history | Medium | Nothing |
| **Settings Implementation** | Connect SettingsScreen to actual preferences | Low | Nothing |

### 🟡 Medium Priority

| Item | Description | Complexity | Notes |
|------|-------------|------------|-------|
| **Bad Habit Protocol** | "Break habit" flow with Claude (Tier 2) | Medium | Needs ClaudeChatService |
| **Habit Stacking** | Link habits together in sequences | Medium | Depends on multi-habit |
| **Failure Playbooks** | Pre-planned recovery strategies | Medium | UX design needed |

---

## Next Phase (Growth & Polish)

### Features
- [ ] **Weekly Review with AI** — AI synthesis of weekly progress
- [ ] **Weekly/Monthly Analytics Dashboard** — Trend charts, insights
- [ ] **Pattern Detection from Miss Reasons** — Identify recurring issues
- [ ] **Backup and Restore** — Export/import habit data
- [ ] **Habit Pause/Vacation Mode** — Planned breaks without penalty
- [ ] **Social Accountability** — Optional sharing features

### Technical
- [ ] **Hive Type Adapters** — Generate with `build_runner` for type safety
- [ ] **iOS Notifications** — Complete permission handling
- [ ] **Error Boundaries** — Proper error handling and crash reporting
- [ ] **Timezone Robustness** — Detect TZ changes and reschedule notifications

### Platform Expansion
- [ ] **Android Home Screen Widget** — One-tap completion from launcher
- [ ] **iOS Widget Support** — WidgetKit implementation

---

## Later (Differentiation)

### User Experience
- [ ] **Accessibility** — Dynamic type, contrast check, larger tap targets
- [ ] **Delight** — Haptics + micro-animations on completion/recovery
- [ ] **Dark Mode & Theming** — User-toggle plus adaptive palette
- [ ] **Localization** — i18n strings and RTL layout validation

### Advanced Features
- [ ] **Insights Engine** — AI-powered recommendations based on patterns
- [ ] **Habit Contracts** — Accountability agreements with witnesses
- [ ] **Deep Links** — Share habits, invite accountability partners

---

## Technical Debt Tracker

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Stale branches cleanup | High | 🔴 Open | 18+ unmerged branches |
| Settings persistence | Medium | 🔴 Open | UI stub exists |
| Hive type adapters | Medium | 🔴 Open | Manual JSON maps work but fragile |
| iOS notification permissions | Medium | 🔴 Open | Android-only code paths |
| Timezone change handling | Low | 🔴 Open | Fixed to UTC/Local |
| Remove unnecessary imports | Low | 🔴 Open | flutter analyze warnings |

---

## Sprint History

### Sprint: AI Onboarding Phase 2 - Conversational UI (December 2025) ✅

**Goal:** "Conversational First" onboarding experience

**Context:**
- Built on Phase 1 infrastructure (Orchestrator, GeminiChatService, Guardrails)
- Chat UI replaces form as default for new users
- Form UI remains as Tier 3 fallback (manual mode)
- Follows Vibecoding pattern: Screen (UI) → Orchestrator (Brain) → Service (API)

**Completed:**
- ✅ Created `ConversationalOnboardingScreen` (full chat UI)
- ✅ Created `ChatMessageBubble` widget with streaming indicator
- ✅ Created `TypingIndicatorBubble` for loading states
- ✅ Extended `OnboardingOrchestrator` with `sendMessage()` returning `ConversationResult`
- ✅ Added `startConversation()` for initializing chat flow
- ✅ Integrated escape hatch (frustration detection → manual form)
- ✅ Added habit confirmation dialog when AI extracts `[HABIT_DATA]`
- ✅ Updated routing: `/` → Chat, `/onboarding/manual` → Form
- ✅ Used `Consumer<OnboardingOrchestrator>` for reactive UI updates

**Files Created:**
- `lib/features/onboarding/conversational_onboarding_screen.dart`
- `lib/features/onboarding/widgets/chat_message_bubble.dart`

**Files Modified:**
- `lib/data/services/onboarding/onboarding_orchestrator.dart` (Phase 2 methods)
- `lib/main.dart` (routing + ChangeNotifierProxyProvider)

**Key Commits:**
- `635a99e` - refactor(onboarding): Wire chat UI through OnboardingOrchestrator
- `a5289f8` - feat(onboarding): Implement Phase 2 Conversational UI

---

### Sprint: AI Onboarding Phase 1 - Magic Wand (December 2025) ✅

**Goal:** Infrastructure & "Magic Wand" MVP

**Context:**
- Solved "Empty State Problem" without full chat UI complexity
- Fixed critical "Data Amnesia" bug (AI metadata was being lost on save)
- Collaborative spec development between Claude, Gemini, and user
- Three-tier AI architecture: Gemini (fast) → Claude (deep) → Manual (fallback)

**Completed:**
- ✅ Created `AI_ONBOARDING_SPEC.md` v4.0.0 (comprehensive spec)
- ✅ Updated `Habit` model with 7 new AI fields
- ✅ Cherry-picked `GeminiChatService`, `ChatConversation`, `ChatMessage` from orphaned branches
- ✅ Created `OnboardingData` model (DTO for AI ↔ Habit mapping)
- ✅ Created `AiResponseParser` helper (`[HABIT_DATA]` JSON extraction)
- ✅ Created `ConversationGuardrails` config (frustration detection patterns)
- ✅ Created `AIModelConfig` config (API keys, timeouts, tier selection)
- ✅ Created `OnboardingOrchestrator` service (The "Brain")
- ✅ Created `MagicWandButton` widget (The "Body")
- ✅ Integrated Magic Wand button into `OnboardingScreen`
- ✅ **Fixed "Data Amnesia"** - AI metadata fields now preserved on save
- ✅ Updated `main.dart` with MultiProvider for AI services
- ✅ Updated `AI_CONTEXT.md` with new architecture

**Files Created:**
- `AI_ONBOARDING_SPEC.md`
- `lib/data/models/onboarding_data.dart`
- `lib/data/models/chat_conversation.dart` (cherry-picked)
- `lib/data/models/chat_message.dart` (cherry-picked)
- `lib/data/services/gemini_chat_service.dart` (cherry-picked)
- `lib/data/services/onboarding/onboarding_orchestrator.dart`
- `lib/data/services/onboarding/ai_response_parser.dart`
- `lib/data/services/onboarding/conversation_guardrails.dart`
- `lib/config/ai_model_config.dart`
- `lib/features/onboarding/widgets/magic_wand_button.dart`

**Files Modified:**
- `lib/data/models/habit.dart` (7 new AI fields)
- `lib/features/onboarding/onboarding_screen.dart` (Magic Wand integration + Data Amnesia fix)
- `lib/main.dart` (MultiProvider setup)

**Key Commits:**
- `d54a6c9` - fix(onboarding): Prevent Data Amnesia - preserve AI metadata fields
- `0614614` - feat(onboarding): Implement Phase 1 Magic Wand AI feature
- `5a17228` - feat(onboarding): Add Phase 1 backend/logic infrastructure
- `fcbe9d5` - feat(ai-onboarding): Add AI Onboarding spec and Phase 1 infrastructure

---

### Sprint: Documentation Sync (December 2024)
**Goal:** Establish AI Handoff Protocol and sync docs to main

**Context:** 
- Discovered AI_CONTEXT.md and ROADMAP.md existed on orphaned branches
- 18+ unmerged branches with potentially valuable work
- New AI sessions couldn't find documentation, recreated it

**Completed:**
- ✅ Cherry-picked AI_CONTEXT.md from `claude/setup-atomic-achievements-architecture-*`
- ✅ Cherry-picked ROADMAP.md from same branch
- ✅ Updated both files to reflect actual main branch state (v1.0.0+1)
- ✅ Added AI Handoff Protocol sections to both files
- ✅ Documented orphaned branch inventory

**Files Modified:**
- `AI_CONTEXT.md` (rewritten to match main)
- `ROADMAP.md` (rewritten to match main)

---

### Previous Sprints (from git history)

#### Never Miss Twice Engine (December 2024)
- ✅ `consecutiveMissedDays` tracking
- ✅ `neverMissTwiceScore` calculation  
- ✅ Recovery urgency levels (gentle/important/compassionate)
- ✅ Flexible tracking metrics (never reset)
- ✅ Comprehensive test suite

#### Vibecoding Refactor (December 2024)
- ✅ Controllers for behavior logic
- ✅ Helpers for pure styling functions
- ✅ Dumb widgets pattern
- ✅ Thin orchestrator screens

#### Async Suggestions Upgrade (December 2024)
- ✅ Remote LLM endpoint support with 5s timeout
- ✅ Local heuristic fallback
- ✅ Loading states in UI
- ✅ Parallel fetching for combined suggestions

#### AI Suggestion System (December 2024)
- ✅ Local heuristic engine for all 4 suggestion types
- ✅ "Get Ideas" buttons in onboarding
- ✅ "Get optimization tips" on Today screen
- ✅ SuggestionDialog widget

#### "Make it Attractive" Features (December 2024)
- ✅ Temptation bundling field
- ✅ Pre-habit ritual with 30s timer
- ✅ Environment cues and distraction guardrails
- ✅ Notification copy includes temptation bundle

#### Initial Release (December 2024)
- ✅ Identity-based onboarding
- ✅ Single habit tracking
- ✅ Graceful Consistency system
- ✅ Daily notifications
- ✅ Reward flow with confetti

---

## Orphaned Branches with Valuable Work

> **Action Required:** Review these branches before starting related work

| Branch Pattern | Contains | Recommendation | Status |
|----------------|----------|----------------|--------|
| `claude/ai-conversational-first-page-*` | `GeminiChatService`, `ChatConversation` | ✅ **Cherry-picked for Phase 1** | ✅ Done |
| `claude/habit-substitution-guardrails-*` | `BadHabitScreen`, substitution logic | **Cherry-pick for Phase 2** | 🟡 Next |
| `claude/setup-atomic-achievements-*` | Home Widget, Multi-habit setup | Cherry-pick widget code | 🟡 Later |
| `claude/merge-missing-code-*` | `PremiumAiOnboardingService` | Review prompts for Claude tier | 🟡 Reference |
| `claude/phase-4-identity-avatar-*` | Avatar cosmetics system | Review scope for gamification | 🔵 Later |
| `codex/create-node.js-backend-*` | Backend API | Review for LLM backend | 🔵 Later |
| `claude/claude-md-*` | CLAUDE.md | Consider merging | 🔵 Optional |
| `claude/atomic-habits-android-app-*` | FEATURE_ROADMAP.md | Close (superseded) | ⚪ Delete |

**Cleanup Command:**
```bash
# List all unmerged branches with last commit date
for branch in $(git branch -r --no-merged main); do
  echo "$branch: $(git log -1 --format='%ai %s' $branch)"
done | sort
```

---

## How to Use This Roadmap

### For AI Agents
1. **Session Start:** Read this file to understand priorities
2. **Pick Work:** Choose from "Current Sprint" or "Immediate Priority"
3. **Check Branches:** See if work already exists on orphaned branch
4. **Do Work:** Follow AI_CONTEXT.md for architecture
5. **Session End:** Update this file, cherry-pick to main

### For Humans
1. **Review Priorities:** Reorder items based on product needs
2. **Review Branches:** Approve/close orphaned PRs
3. **Review Sprints:** Check sprint history for context

---

## Success Metrics

| Metric | Current | Target | Notes |
|--------|---------|--------|-------|
| Orphaned branches | 18+ | < 5 | Need cleanup |
| Test coverage | ~70% | 80%+ | Good foundation |
| Doc sync to main | ✅ Now | Always | New protocol |
| Time to onboard new AI | ~30 min | < 10 min | With Big Three docs |
| Phase 1 Magic Wand | ✅ | ✅ | Complete! |
| Phase 2 Conversational UI | ✅ | ✅ | Complete! |

---

*"You do not rise to the level of your goals. You fall to the level of your systems."* — James Clear

*Last synced to main: December 2025*
