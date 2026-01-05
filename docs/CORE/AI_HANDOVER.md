# AI_HANDOVER.md — Session Continuity Protocol

> **Last Updated:** 05 January 2026 (Dashboard Architecture Session)
> **Purpose:** Ensure seamless context transfer between AI agent sessions
> **Owner:** Any AI agent (update at session end)

---

## What This Document Is

This is a **living document** that captures session-to-session context. Every AI agent working on this codebase MUST:
1. **Read this document** at session start
2. **Update this document** at session end

This prevents:
- Duplicate work
- Conflicting decisions made in isolation
- Lost context when sessions end or context limits are reached

---

## When to Start a New Session

| Signal | Threshold | Action |
|--------|-----------|--------|
| Context tokens | >80% capacity | Start new session with handover |
| Task pivot | Entirely new domain | Consider new session |
| Time gap | >4 hours since last activity | Re-read handover before continuing |
| Blocked by product input | Requires async human decision | Pause, document blocker, await input |
| Session crash/timeout | Unexpected termination | Next agent reads handover |

---

## Current Session Status

### Last Session Summary
| Field | Value |
|-------|-------|
| **Session ID** | `dashboard-docs-session` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~15 minutes |
| **Focus** | Dashboard State Documentation, Living Garden Clarification |

### What Was Accomplished

**Key Changes Made:**

1. **Verified Branch Merge Complete**
   - Branch `claude/setup-ai-coordination-ZSkqC` was merged (commit `7d9c56b`)
   - All prior session work is now on main

2. **Documented Current Dashboard State**
   - Binary Interface: Two-state toggle between "Doing" and "Being"
   - **The Bridge** (`the_bridge.dart`): Action deck with JITAI-powered habit sorting
   - **Skill Tree** (`skill_tree.dart`): Custom-painted tree visualization of identity growth
   - See "Current Dashboard Architecture" section below

3. **Resolved Living Garden Documentation Discrepancy**
   - AI_CONTEXT.md incorrectly stated "Living Garden Visualization" as if implemented
   - **Reality:** Living Garden (Layer 3) is ASPIRATIONAL ONLY — not in codebase
   - Fixed AI_CONTEXT.md to reflect actual state (Binary Interface: Bridge + Skill Tree)
   - ROADMAP.md Track G-0 already correctly marked Living Garden as "aspirational only"

### What Was NOT Done (Deferred)
- Track G-0 systematic GLOSSARY review
- Habit vs Ritual data model decision (see GLOSSARY.md)

### Blockers Awaiting Human Input
| Blocker | Question | Status |
|---------|----------|--------|
| Archetype Philosophy (PD-001) | Hardcoded vs Dynamic vs Hybrid? | ✅ DECIDED → CD-005 (6-dimension model) |
| JITAI Architecture (PD-102) | Hardcoded vs AI-driven? | ✅ DECIDED → CD-005 (dimensions as context vector) |
| People Pleaser Archetype | Keep (add social dimension) or delete? | ✅ DECIDED → CD-007 (keep, add 7th dimension with social features) |
| Content Library | Need 4 message variants per trigger | ✅ DECIDED → CD-009 (HIGH PRIORITY) |
| Proactive Engine | Need recommendation system? | ✅ DECIDED → CD-008 (build alongside JITAI) |
| Retention Tracking | How to measure? | ✅ DECIDED → CD-010 (dual perspective) |
| GPS Usage | Full or time-only? | ✅ DECIDED → CD-006 (full GPS, option for time-only) |
| Streaks vs Consistency (PD-002) | Use `gracefulScore` or `currentStreak`? | BLOCKED — Impacted by dimensions |
| Holy Trinity Validity (PD-003) | Is 3-trait model sufficient? | BLOCKED — Maps to dimensions |
| Dev Mode Purpose (PD-004) | Rename `developerMode` → `isPremium`? | BLOCKED |
| Sherlock Prompt (PD-101) | Which of 2 prompts is canonical? | BLOCKED — Needs dimension extraction |

---

## Context for Next Agent

### Current Dashboard Architecture (Phase 67)

The dashboard uses a **Binary Interface** — two distinct views the user toggles between:

```
lib/features/dashboard/
├── habit_list_screen.dart           ← Main list view
└── widgets/
    ├── identity_dashboard.dart      ← Binary interface container (toggle)
    ├── the_bridge.dart              ← "Doing" state (✅ IMPLEMENTED)
    ├── skill_tree.dart              ← "Being" state (✅ IMPLEMENTED)
    ├── comms_fab.dart               ← AI Persona FAB
    └── habit_summary_card.dart      ← Individual habit cards
```

**The Bridge (Doing State)** — `the_bridge.dart:24-38`
- Context-aware action deck with JITAI-powered priority sorting
- Shows habits sorted by V-O scoring, cascade risk, timing
- Features: Glass morphism cards, cascade risk warnings, tiny version buttons
- "NOW" badge for highest priority habit
- Identity votes counter per habit

**Skill Tree (Being State)** — `skill_tree.dart:18-32`
- Custom-painted living tree visualization of identity growth
- Multi-part structure: Root (foundation) → Trunk (primary habit) → Branches (related habits) → Leaves (decorative)
- Health scoring: Green (strong) → Yellow → Orange → Red (at risk)
- Stats overlay showing votes, streak, completions

**Living Garden (Layer 3)** — ❌ NOT IMPLEMENTED
- Mentioned in ROADMAP.md Layer 3 as aspirational
- Would use Rive animation with hexis_score, shadow_presence inputs
- Current replacement: Skill Tree serves the visualization role

### Key Technical Discoveries This Session

1. **Archetypes are hardcoded** (`archetype_registry.dart:175-182`):
   - Only 6 buckets: PERFECTIONIST, REBEL, PROCRASTINATOR, OVERTHINKER, PLEASURE_SEEKER, PEOPLE_PLEASER
   - Fallback is PERFECTIONIST (problematic for production)
   - Evolution service exists but assumes first classification is correct

2. **JITAI is hybrid** (not pure AI):
   - Hardcoded: Base weights, thresholds, V-O calculation
   - Adaptive: Thompson Sampling learns which interventions work
   - NOT AI: No LLM calls in decision flow

3. **TWO Sherlock Prompts exist** (CONFLICTING):
   - `ai_prompts.dart:717-745` — Calls AI "Puck", uses tool calling
   - `prompt_factory.dart:47-67` — Calls AI "Sherlock", has cheat code
   - No turn limit in either
   - No extraction success criteria
   - Needs consolidation before overhaul

4. **Holy Trinity** (`psychometric_profile.dart:17-29`):
   - Anti-Identity (Fear) — Day 1 Activation
   - Failure Archetype (History) — Day 7 Conversion
   - Resistance Lie (Excuse) — Day 30+ Retention
   - Philosophy is sound but extraction may be too simplistic

5. **LoadingInsightsScreen** is ALREADY implemented with animated insight cards — decision is about WHAT insights to show, not whether to implement

6. **Intervention Effectiveness** is well-implemented (`jitai_decision_engine.dart:772-838`):
   - Reward function optimizes for identity evidence (50%), engagement (30%), async identity delta (15%)
   - Tracks: notification open, time-to-open, interaction type, habit completion, streak, annoyance signals
   - **Gap:** No post-intervention emotion capture, no retention tracking, no self-report "was this helpful?"

### Files You Should Read
| File | Why |
|------|-----|
| `docs/CORE/PRODUCT_DECISIONS.md` | All pending decisions documented |
| `docs/CORE/GLOSSARY.md` | Terminology definitions |
| `docs/CORE/RESEARCH_QUESTIONS.md` | Active research (check before implementing) |
| `docs/CORE/IDENTITY_COACH_SPEC.md` | Core value proposition specification |
| `AI_CONTEXT.md` | Technical architecture (includes research blockers) |
| `ROADMAP.md` | Current priorities (needs reconciliation) |

### Files That Need Attention
| File | Issue |
|------|-------|
| `lib/features/onboarding/identity_first/sherlock_permission_screen.dart` | Loading state needs "Streaming Data" (Roadmap) |
| `android/app/src/main/AndroidManifest.xml` | Rename intent filter data scheme to `thepact` |
| `ios/Runner/Info.plist` | Rename `CFBundleURLSchemes` to `thepact` |
| `docs/CORE/PRODUCT_DECISIONS.md` | Single source of truth for philosophy |

---

## Handover Checklist for Incoming Agent

### Before Starting Work
- [ ] Read this AI_HANDOVER.md completely
- [ ] Read PRODUCT_DECISIONS.md for pending decisions
- [ ] Read GLOSSARY.md for terminology
- [ ] Check blockers — can you proceed or is human input needed?
- [ ] Identify your session's scope (docs only? code? both?)

### Before Ending Session
- [ ] Update "Last Session Summary" section above
- [ ] Update "What Was Accomplished"
- [ ] Update "What Was NOT Done (Deferred)"
- [ ] Update "Blockers Awaiting Human Input" if new blockers found
- [ ] Update "Context for Next Agent" with discoveries
- [ ] Commit this file with descriptive message
- [ ] Push to branch

---

## Session History Log

| Date | Agent | Branch | Focus | Outcome |
|------|-------|--------|-------|---------|
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/continue-pact-development-3vnbh` | Dashboard Docs | Documented Bridge+SkillTree, fixed Living Garden references in AI_CONTEXT.md |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/setup-ai-coordination-ZSkqC` | RQ Reconciliation | CD-014→CRITICAL, CD-015→PD-105, RQ-005 through RQ-009 renumbered by importance |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/setup-ai-coordination-ZSkqC` | Deep Protocol Review | 12 user points: Entry/Exit protocols, CD-015, Track G-0, RQ-007, Layer verification |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/setup-ai-coordination-ZSkqC` | Protocol Refinements | 8 action items: Git workflow, cross-doc checks, decision flow, Habit/Ritual defs, CD-013/14, Track G |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/setup-ai-coordination-ZSkqC` | Identity Coach Elevation | Elevated Identity Coach as core value prop, added CD-011/CD-012, doc maintenance protocol |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/setup-ai-coordination-ZSkqC` | Research Coordination | Aligned ChatGPT + Gemini research for PD-001 |
| 05 Jan 2026 | Claude (Opus) | `claude/setup-ai-coordination-ZSkqC` | AI Coordination Setup | Expanded PRODUCT_DECISIONS.md with codebase context, created root symlink |
| 05 Jan 2026 | Claude (Opus) | `claude/docs-core-restructure-b6wmg` | Core docs restructure | Created CORE folder, handover template, glossary, product decisions |
| 05 Jan 2026 | Gemini | `main` | Phase 68 & Docs Restructure | Closed Phase 68, Merged Core Docs, Created Product Vision |
| 05 Jan 2026 | Claude (Opus) | `claude/docs-core-restructure-b6wmg` | Core docs restructure | Created CORE folder, handover template, glossary, product decisions |

---

## Notes for Human (Oliver)

This handover protocol was created because:
1. Gemini made product decisions without explicit approval
2. Context is lost between sessions
3. Multiple agents working on the same codebase need coordination

**Your Action Items:**
- Review PRODUCT_DECISIONS.md and resolve PENDING items
- Confirm core docs structure is acceptable
- Decide on archetype philosophy (future sprint)
- Decide on Sherlock prompt direction (future sprint)
