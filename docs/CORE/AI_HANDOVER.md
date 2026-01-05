# AI_HANDOVER.md — Session Continuity Protocol

> **Last Updated:** 05 January 2026
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
| **Session ID** | `claude/explore-onboarding-codebase-b6wmg` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~2 hours |
| **Focus** | Core documentation restructure and product decision audit |

### What Was Accomplished
- Explored codebase: archetypes, JITAI, Sherlock prompt, psychometric profile
- Identified documentation gaps and inaccuracies
- Created `/docs/CORE/` folder structure
- Created this AI_HANDOVER.md template
- Identified 11+ pending product decisions requiring human input
- Discussed philosophy vs implementation gaps (streaks, archetypes, sensitivity)

### What Was NOT Done (Deferred)
- Code changes (deliberately avoided — docs-only session)
- Final decisions on archetypes, JITAI, Sherlock prompt
- Removing or archiving old documentation
- Device testing

### Blockers Awaiting Human Input
| Blocker | Question | Status |
|---------|----------|--------|
| Archetype Philosophy | Hardcoded 6 buckets vs dynamic AI-generated? | PENDING |
| Streaks vs Consistency | Keep streak logic or move to rolling consistency? | PENDING |
| Dev Mode Purpose | Keep, remove, or refine? | PENDING |
| Sherlock Prompt | Major overhaul needed — what's target UX? | PENDING |

---

## Context for Next Agent

### Key Technical Discoveries This Session

1. **Archetypes are hardcoded** (`archetype_registry.dart:175-182`):
   - Only 6 buckets: PERFECTIONIST, REBEL, PROCRASTINATOR, OVERTHINKER, PLEASURE_SEEKER, PEOPLE_PLEASER
   - Fallback is PERFECTIONIST (problematic for production)
   - Evolution service exists but assumes first classification is correct

2. **JITAI is hybrid** (not pure AI):
   - Hardcoded: Base weights, thresholds, V-O calculation
   - Adaptive: Thompson Sampling learns which interventions work
   - NOT AI: No LLM calls in decision flow

3. **Sherlock Prompt is simplistic** (`prompt_factory.dart:47-67`):
   - No turn limit
   - No extraction success criteria
   - No conversation fatigue handling
   - Needs major overhaul

4. **Holy Trinity** (`psychometric_profile.dart:17-29`):
   - Anti-Identity (Fear) — Day 1 Activation
   - Failure Archetype (History) — Day 7 Conversion
   - Resistance Lie (Excuse) — Day 30+ Retention
   - Philosophy is sound but extraction may be too simplistic

5. **LoadingInsightsScreen** is a generic spinner — should show personalized insights from permissions data + JITAI baseline

### Files You Should Read
| File | Why |
|------|-----|
| `docs/CORE/PRODUCT_DECISIONS.md` | All pending decisions documented |
| `docs/CORE/GLOSSARY.md` | Terminology definitions |
| `AI_CONTEXT.md` | Technical architecture (but contains stale info) |
| `ROADMAP.md` | Current priorities (needs reconciliation) |

### Files That Need Attention
| File | Issue |
|------|-------|
| `AI_CONTEXT.md` | Contains stale commits, aspirational features marked as complete |
| `ROADMAP.md` | Mixes history with future, needs restructuring |
| `lib/domain/services/archetype_registry.dart` | Hardcoded archetypes need philosophy decision |
| `lib/data/services/ai/prompt_factory.dart` | Sherlock prompt needs overhaul |

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
| 05 Jan 2026 | Claude (Opus) | `claude/docs-core-restructure-b6wmg` | Core docs restructure | Created CORE folder, handover template, glossary, product decisions |
| 04 Jan 2026 | Gemini | `main` | Phase 68 onboarding fixes | Integration tests, security fix, analytics, bug fixes |

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
