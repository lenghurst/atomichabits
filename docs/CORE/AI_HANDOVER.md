# AI_HANDOVER.md — Session Continuity Protocol

> **Last Updated:** 10 January 2026 (RQ-024 Treaty Modification COMPLETE — 9 tasks extracted, PD-118 RESOLVED)
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

### Latest Session Summary
| Field | Value |
|-------|-------|
| **Session ID** | `claude/setup-pact-context-1i4ze` |
| **Date** | 10 January 2026 (continued) |
| **Agent** | Claude (Opus 4.5) |
| **Focus** | RQ-008/009 Engineering Process — Protocol 9 Complete + Protocol 2 Updated |

### What Was Accomplished (This Latest Session)

**16. RQ-008/009 Engineering Process Reconciliation**
- **Research Input:** Deep Think Research Report on AI-Assisted Engineering Architecture
- **Protocol 9:** All 6 phases completed
- **Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ008_RQ009.md`

**Key Decisions:**

| Decision | Resolution |
|----------|------------|
| **Architecture Pattern** | Riverpod Controller (Passive View) — adapted to Provider for existing code |
| **Task Classification** | Logic Tasks → Contract-First; Visual Tasks → Vibe Coding |
| **Protocol 2** | REPLACED with Context-Adaptive Development approach |
| **Boundary Rule** | "IF" decisions → Logic Layer; Rendering → UI Layer |
| **Animation Triggers** | Side Effect Pattern (state flags, not inline checks) |

**Protocol 9 Results:**
| Metric | Count |
|--------|-------|
| **ACCEPT** | 12 |
| **MODIFY** | 1 (Riverpod → Provider adaptation) |
| **REJECT** | 0 |
| **ESCALATE** | 0 |

**Tasks Extracted (8 Process Tasks):**
- P-01: Update AI_AGENT_PROTOCOL.md with Protocol 2 ✅ DONE
- P-02: Create BOUNDARY_DECISION_TREE.md
- P-03: Add linting rules to analysis_options.yaml
- P-04: Create ChangeNotifier Controller template
- P-05: Document Side Effect pattern with example
- P-06: Add Riverpod to pubspec.yaml for new features
- P-07: Create "Logic vs Visual" task classification guide
- P-08: Define "Logic Leakage" metric tracking

**Documents Updated:**
- `AI_AGENT_PROTOCOL.md` — Protocol 2 REPLACED with Context-Adaptive Development
- `index/RQ_INDEX.md` — RQ-008, RQ-009 ✅ COMPLETE (28/32 = 88%)
- `PRODUCT_DEVELOPMENT_SHEET.md` — RQ count updated
- `GLOSSARY.md` — 5 new terms (Vibe Coding, Contract-First, Safety Sandbox, Logic Leakage, Side Effect Pattern)

**Status Summary:**

| Category | Complete | Pending | Change |
|----------|----------|---------|--------|
| CDs | 18/18 (100%) | 0 | — |
| RQs | 28/32 (88%) | 4 | +2 (RQ-008, RQ-009) |
| PDs | 15/31 (48%) | 16 | — |
| Tasks | 0/116 (0%) | 116 | +8 process tasks (P-XX) |

**Key Insight:** "Constraint Enables Creativity" — Strict UI/Logic separation creates a Safety Sandbox where AI can iterate freely on UI without risk of corrupting business logic.

---

**Previous Session:**

**15. RQ-024 Treaty Modification Reconciliation**
- **Research Input:** Deep Think Research Report on Treaty Modification & Renegotiation
- **Protocol 9:** All 6 phases completed
- **Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ024.md`

**Key Decisions:**

| Decision | Resolution |
|----------|------------|
| **Amendment Model** | Constitutional Amendment (Minor vs Major distinction) |
| **Minor Amendment** | 3s Re-Ratification, breach history PRESERVED |
| **Major Amendment** | Council reconvene, Amnesty (breach reset), new lineage |
| **Probation Trigger** | 5 breaches in 7 days OR 3 dismissed warnings |
| **Probation Journey** | T+0 → T+24h → T+72h → T+96h escalation |
| **Pause** | User-initiated, 14-day max |
| **Suspend** | System-initiated (auto at T+96h) |
| **Repeal** | Type "REPEAL" to confirm |

**Protocol 9 Results:**
| Metric | Count |
|--------|-------|
| **ACCEPT** | 10 |
| **MODIFY** | 3 |
| **REJECT** | 1 (Tension score +0.2 at T+72h — conflates systems) |
| **ESCALATE** | 0 |

**Tasks Extracted (9):**
- A-11: Create `treaty_history` table
- A-12: Add `version`, `parent_treaty_id`, `last_amended_at` to treaties
- B-16: Probation notification journey
- B-17: Auto-suspend logic
- C-13: Council reconvene for major amendments
- D-11: Treaty Amendment Editor
- D-12: Re-Ratification ceremony
- D-13: Pause Treaty flow
- D-14: Repeal Treaty flow

**Documents Updated:**
- `index/RQ_INDEX.md` — RQ-024 ✅ COMPLETE
- `index/PD_INDEX.md` — PD-118 ✅ RESOLVED
- `PRODUCT_DEVELOPMENT_SHEET.md` — Counts updated
- `RESEARCH_QUESTIONS.md` — RQ-024 marked complete, 9 tasks added
- `PRODUCT_DECISIONS.md` — PD-118 resolved
- `GLOSSARY.md` — 5 new terms (Minor/Major Amendment, Re-Ratification, Amnesty, Probation Journey)
- `IMPLEMENTATION_ACTIONS.md` — 9 tasks added, totals updated (116 tasks)

**Status Summary:**

| Category | Complete | Pending | Change |
|----------|----------|---------|--------|
| CDs | 18/18 (100%) | 0 | — |
| RQs | 26/32 (81%) | 6 | +1 (RQ-024) |
| PDs | 15/31 (48%) | 16 | +1 (PD-118) |
| Tasks | 0/116 (0%) | 116 | +9 new tasks |

**All MVP-Critical Research is NOW COMPLETE.**

---

**Previous Session:**

**14. Product Development Sheet Created**
- **Document:** `docs/CORE/PRODUCT_DEVELOPMENT_SHEET.md`
- **Purpose:** Single consolidated view of all CDs, RQs, PDs, and Tasks

**Key Findings:**

| Category | Complete | Pending | Action |
|----------|----------|---------|--------|
| CDs | 18/18 (100%) | 0 | All locked |
| RQs | 25/32 (78%) | 7 | Only RQ-024 needs research for MVP |
| PDs | 14/31 (45%) | 17 | 4 ready to resolve NOW |
| Tasks | 0/107 (0%) | 107 | Phase A is critical blocker |

**RQ Triage:**
- **RESEARCH NOW:** RQ-024 (Treaty Modification) — Only 1 RQ truly needed for MVP
- **DEFER:** RQ-023, RQ-025, RQ-026, RQ-010 — Post-MVP concerns
- **DEPRIORITIZE:** RQ-008, RQ-009, RQ-027 — Low priority, not blocking

**PDs Ready to Resolve (No Blockers):**
1. PD-105 (Unified AI Coaching) — Architecture decision
2. PD-107 (Proactive Guidance) — Architecture decision
3. PD-002 (Streaks vs Consistency) — Core UX
4. PD-101 (Sherlock Prompt) — Which is canonical

**Critical Path Identified:**
```
PHASE 0: Resolve PD-105, PD-107, PD-002, PD-101
    ↓
PHASE A: Create identity_facets, identity_topology tables
    ↓
PHASE B-G: Implementation can proceed
    ↓
PHASE H: Now unblocked
```

**Previous Session:**

**13. Red Team Adversarial Critique**
- **Critique Document:** `docs/analysis/RED_TEAM_CRITIQUE_RQ017_RQ018.md`
- **Verdict:** HIGH RISK — Critical schema dependencies don't exist

**Critical Findings:**

| Finding | Severity | Impact |
|---------|----------|--------|
| `identity_facets` table doesn't exist | **CRITICAL** | Constellation cannot be built |
| `identity_topology` table doesn't exist | **CRITICAL** | Tether/conflict viz blocked |
| Audio files are 0 bytes (placeholders) | **HIGH** | Airlock has no audio |
| 107+ tasks at 0% completion | **HIGH** | Feasibility concern |
| Dependency chain violation | **HIGH** | Phase H assigned before Phase A |

**Corrective Actions Required:**

| Action | Priority |
|--------|----------|
| **BLOCK** all Phase H tasks | IMMEDIATE |
| **PRIORITIZE** Phase A schema creation | CRITICAL |
| **RETAIN** Skill Tree as fallback | HIGH |
| **SOURCE** actual audio files (>0 bytes) | HIGH |

**Key Insight:** The Deep Think reconciliation is internally consistent but fails the reality check. Documentation assumes infrastructure that doesn't exist. The `skill_tree.dart` (549 lines, production-ready) is the ONLY working visualization.

**Schema Reality:**
- `identity_seeds` EXISTS — Sherlock Protocol (Holy Trinity)
- `identity_facets` DOES NOT EXIST — Required for Constellation
- `identity_topology` DOES NOT EXIST — Required for Tethers
- `facet_relationships` DOES NOT EXIST — Required for friction

**Previous Session:**

### What Was Accomplished (Previous Session)

**12. Protocol 9 Reconciliation: RQ-017 + RQ-018 (psyOS UX Phase)**
- **Research Source:** Deep Think UX Architecture Report (Constellation & Airlock)
- **Reconciliation Results:**
  - 20 ACCEPT, 6 MODIFY, 2 REJECT, 0 ESCALATE
- **RQs Completed:** RQ-017 (Constellation UX), RQ-018 (Airlock Protocol)
- **PDs Resolved:**
  - PD-108: Big Bang migration with fallback
  - PD-110: Severity + Treaty hybrid for user control
  - PD-112: Hybrid audio strategy (stock + user unlock)
- **Tasks Added:** Phase H (16 tasks) — Constellation/Airlock implementation
- **Total Tasks:** 107 (was 91)
- **RQ Progress:** 25/32 = 78% (was 23/32 = 72%)
- **PD Progress:** 14/31 = 45% (was 11/31 = 35%)
- **GLOSSARY Updated:** Added Ghost Mode, The Tether, The Seal; Updated Constellation UX, Airlock Protocol
- **Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ017_RQ018.md`

**Key Modifications Applied:**
1. `hexis_score → aggregate ICS` for Sun visualization (hexis_score deprecated)
2. `3-min → 1-min max` Breathwork for CRITICAL transitions
3. `Auto-summon → Modal with option` for tether tap
4. `Level 10 → Sapling tier` for mantra unlock

---

### Previous Session (10 January — Identity Coach Phase 2)

**1. PD-125 Resolved: Content Library Size**
- **Decision:** 50 habits at launch, with caveat to expand to 100 post-launch
- Updated PRODUCT_DECISIONS.md with full rationale
- Updated PD_INDEX.md (now 7 resolved, 31 total)

**2. Implementation Task Tracking Audit**
- **Issue Found:** F-01 through F-20 were in IMPACT_ANALYSIS.md but NOT in Master Implementation Tracker
- **Root Cause:** Ambiguity between IMPACT_ANALYSIS.md (cascade tracking) and RESEARCH_QUESTIONS.md (task storage)
- **Fix Applied:** Added Phase F (20 tasks) to Master Implementation Tracker in RESEARCH_QUESTIONS.md
- Updated Implementation Summary: Now 77 tasks (was 57)

**3. Created IMPLEMENTATION_ACTIONS.md**
- New canonical document for task tracking
- Quick status + audit trail
- Cross-reference layer between reconciliation and Master Tracker
- Updated Protocol 8 in AI_AGENT_PROTOCOL.md with canonical locations
- Added Phase F task ID convention

**4. Updated Core Documentation**
- CLAUDE.md: Updated project structure and key documentation table
- AI_AGENT_PROTOCOL.md: Protocol 8 now specifies canonical locations
- RESEARCH_QUESTIONS.md: Added Phase F (Identity Coach) with 20 tasks

**5. Created Deep Think Prompt for Phase 2 Research**
- File: `docs/prompts/DEEP_THINK_PROMPT_IDENTITY_COACH_PHASE2_RQ028-RQ032.md`
- Covers: RQ-028, RQ-029, RQ-030, RQ-031, RQ-032
- Related decisions: PD-121, PD-122, PD-123, PD-124

**6. Ran Critique Framework Against Deep Think Prompt**
- Applied DEEP_THINK_PROMPT_GUIDANCE.md quality checklist
- Original score: 6.6/10 — Good foundation, missing critical elements
- Identified gaps: No example output, no user scenarios, sub-questions not tabular
- Created `docs/analysis/DEEP_THINK_PROMPT_CRITIQUE_RQ028-RQ032.md`

**7. Applied P0/P1 Fixes to Deep Think Prompt**
Enhanced prompt from 6.6/10 to 8.5/10:
- Added "Example of Good Output" — Full Builder archetype definition
- Added "Concrete Scenario: Solve This" — 5 user scenarios covering all RQs
- Converted all sub-questions to tabular format with "Your Task" column
- Added anti-patterns per RQ (20+ specific anti-patterns)
- Added "Current Schema Reference" — SQL for existing + proposed tables
- Added "Code Expectations" — SQL, Dart pseudocode, JSON examples expected
- Added "Output Quality Criteria" — 6-criterion validation table
- Added "Architectural Constraints" — UX friction, AI cost, onboarding limits

**8. Exhaustively Enhanced IMPLEMENTATION_ACTIONS.md**
- Added Agent Entry Point Routing (Claude, DeepSeek, Gemini, Human paths)
- Added Complete Documentation Hierarchy visual map
- Added Task Management Governance with decision tree
- Added Canonical Locations table (what goes where)
- Added External Agent Instructions (for DeepSeek/Gemini)
- Added Cross-Reference Quick Links table
- Document now serves as navigation hub for all agents

**9. IMPLEMENTATION_ACTIONS Signposting Audit — ALL CORE DOCS**
- **Audit Document:** `docs/analysis/IMPLEMENTATION_ACTIONS_SIGNPOSTING_AUDIT.md`
- **Issue Found:** IMPLEMENTATION_ACTIONS.md was well-designed but invisible to agents during standard session workflows
- **Root Cause:** Core documents didn't reference IA in entry/exit protocols

**P0 Fixes Applied:**
| Document | Fix |
|----------|-----|
| AI_AGENT_PROTOCOL.md (Entry) | Added IA to Session Entry Protocol read list |
| AI_AGENT_PROTOCOL.md (Exit) | Added Tier 1.5 for task status updates |
| IMPACT_ANALYSIS.md | Added CASCADE ONLY warning (not task storage) |

**P1 Fixes Applied:**
| Document | Fix |
|----------|-----|
| DEEP_THINK_PROMPT_GUIDANCE.md | Added Step 1.5: Update Implementation Actions Quick Status |

**Architecture Now Consistent:**
```
CLAUDE.md → AI_HANDOVER.md → index/*.md → IMPLEMENTATION_ACTIONS.md → RESEARCH_QUESTIONS.md → IMPACT_ANALYSIS.md
                                            (Task Quick Status)         (Master Tracker)       (Cascade ONLY)
```

**10. Protocol 9 Reconciliation: Deep Think Phase 2 (RQ-028 through RQ-032)**
- **Research Report:** Identity Coach Phase 2 (Archetypes, Preference Learning, Pace Car, ICS)
- **Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md`
- **Results:** 25 ACCEPT, 5 MODIFY, 0 REJECT, 0 ESCALATE (1 ESCALATE resolved via audit)

**RQs Completed (5):**
| RQ | Title | Key Deliverable |
|----|-------|-----------------|
| RQ-028 | Archetype Definitions | 12 archetypes with 6-dim vectors |
| RQ-029 | Dimension Curation | DeepSeek prompt + audit workflow |
| RQ-030 | Preference Update | Rocchio algorithm + Trinity Anchor |
| RQ-031 | Pace Car Threshold | Building vs Maintenance model |
| RQ-032 | ICS Integration | Logarithmic formula, hexis_score deprecated |

**PDs Resolved (4):**
| PD | Decision |
|----|----------|
| PD-121 | 12 Archetypes (psychologically grounded) |
| PD-122 | Preference embedding HIDDEN (768-dim is noise) |
| PD-123 | typical_energy_state field (4-state enum) |
| PD-124 | 7-day TTL for recommendation cards |

**Tasks Added (14):**
- Phase G: G-01 through G-14 (Identity Coach Intelligence Phase 2)
- Total tasks now: 91 (was 77)

**Audit Resolved:**
- hexis_score: NOT in codebase (documentation-only term) — safe to deprecate

**11. Congruency Verification Complete**
- Verified all post-processing steps from DEEP_THINK_PROMPT_GUIDANCE.md (Step 0-5)
- Added comprehensive cascade analysis to IMPACT_ANALYSIS.md
- Added CD Congruency Verification table confirming alignment with:
  - CD-005 (6-Dimension Model)
  - CD-015 (4-State Energy Model)
  - CD-016 (DeepSeek V3.2)
  - CD-017 (Android-First)
  - CD-018 (ESSENTIAL Threshold)
- Updated GLOSSARY.md with 4 new terms + ICS formula + hexis_score deprecation
- Commit: `a2d4b3b`

---

### Previous Session Summary (10 January — Identity Coach Reconciliation)
| Field | Value |
|-------|-------|
| **Session ID** | `claude/setup-pact-context-1i4ze` |
| **Date** | 10 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Focus** | Identity Coach Deep Think Reconciliation (RQ-005, RQ-006, RQ-007) |

### What Was Accomplished (Previous Session)

**1. Protocol 9 Reconciliation — Identity Coach Architecture**
- Analyzed DeepSeek Deep Think research report for RQ-005/006/007
- Ran full 6-phase reconciliation per Protocol 9
- Created `docs/analysis/DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md`
- Results: 14 ACCEPT, 5 MODIFY, 1 REJECT, 1 ESCALATE

**2. Research Questions Completed (3)**
- **RQ-005:** Proactive Recommendation Algorithms → Two-Stage Hybrid Retrieval
- **RQ-006:** Content Library for Recommendations → Launch spec (50+12+12+4)
- **RQ-007:** Identity Roadmap Architecture → Schema + ICS formula

**3. Key Architectural Decisions Documented**
- **The Architect vs The Commander:** Async recommendation engine (Supabase Edge) separated from real-time JITAI
- **Two-Stage Hybrid Retrieval:** Semantic (768-dim) + Psychometric (6-dim) matching
- **Archetype Templates:** 12 presets solve infinite facet name scaling
- **Trinity Seed:** Cold-start using Day 1 Holy Trinity extraction

**4. Documentation Updates**
- RESEARCH_QUESTIONS.md: RQ-005/006/007 marked COMPLETE with findings
- RQ_INDEX.md: Updated status (18/27 = 67% complete)
- GLOSSARY.md: Added 12 new Identity Coach terms
- IMPACT_ANALYSIS.md: Added cascade effects, 20 new implementation tasks (F-01 through F-20)

**5. Tasks Extracted (20 new)**
- Database: F-01 through F-06 (tables + field additions)
- Backend: F-07 through F-11 (Edge Functions, scheduler)
- Content: F-13 through F-16, F-20 (habit templates, framing, rituals)
- Service: F-17, F-18, F-19 (Dart models, services)
- Onboarding: F-12 (Future Self Interview)

**6. Exhaustive Deep Analysis (Second Pass)**
- Created `docs/analysis/IDENTITY_COACH_DEEP_ANALYSIS.md` (~750 lines)
- Documented all 12 DeepSeek concepts with gaps identified
- Identified 5 new RQs: RQ-028 through RQ-032
- Identified 4 new PDs: PD-121 through PD-124
- Updated PD-105, PD-107 status to READY (unblocked by RQ-005/006/007)
- Total RQs: 32 (18 complete = 56%)
- Total PDs: 30 (6 resolved, 2 ready, 22 pending)

**7. Critical Gaps Identified**
- RQ-028 (Archetype Definitions) is CRITICAL — blocks F-06, F-13, F-14
- Two-Stage Retrieval requires DUAL embeddings per habit (content burden)
- Trinity Seed depends on PD-101 (Sherlock Prompt) being resolved
- Preference embedding drift vs stated aspirations is a design concern

---

### Previous Session Summary (10 January — Documentation Unification)
| Field | Value |
|-------|-------|
| **Session ID** | `claude/setup-pact-context-rApSv` |
| **Date** | 10 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Focus** | Documentation Unification, Entry Point Creation, Governance Cleanup |

### What Was Accomplished (Previous Session)

**1. Created Project Entry Point (`/CLAUDE.md`)**
- Concise (~45 lines) overview for AI agents
- Auto-loads in Claude Code
- Contains: WHAT, WHY, HOW, Critical Constraints, Reading Order

**2. Unified Documentation Reading Order**
- Standardized the "Mandatory Reading Order" across all governance docs
- Updated `README.md`, `AI_AGENT_PROTOCOL.md`, `AI_CONTEXT.md` to match new flow
- Established `CLAUDE.md` as the single source of truth for routing

**3. Fixed Documentation Orphaning**
- **IMPACT_ANALYSIS.md**: Added "Related Documentation" cross-references to fix connectivity
- Ensured all Core documents link bidirectionally

**4. Created Agent Custom Instructions**
- Created `docs/prompts/USER_CUSTOM_INSTRUCTIONS.md` (User-level behavioral config)
- Created `docs/prompts/AGENT_CUSTOM_INSTRUCTIONS_DRAFT.md` (Draft agent instructions)

---

### Previous Session Summary (Jan 06 — Android First Strategy)
| Field | Value |
|-------|-------|
| **Session ID** | `session-priming-docs-r6fCh` (continued x3) |
| **Date** | 06 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~90 minutes (session continued from third context recovery) |
| **Focus** | Android-First Strategy + Deep Think Reconciliation Protocol + Engineering Threshold Framework |

### What Was Accomplished (Jan 06 Session)

**Major Decisions Confirmed:**
1. **CD-017: Android-First Development Strategy** — Primary development targets Android for richer API access
2. **CD-018: Engineering Threshold Framework** — Replace "MVP" with Android-First Launch Threshold

**Protocol Additions:**
1. **Protocol 9: External Research Reconciliation** — Comprehensive 6-phase checklist for integrating Deep Think and external AI research
   - Phase 1: Locked Decision Audit
   - Phase 2: Data Reality Audit (Android-first)
   - Phase 3: Implementation Reality Audit
   - Phase 4: Scope & Complexity Audit
   - Phase 5: ACCEPT/MODIFY/REJECT/ESCALATE categorization
   - Phase 6: Integration

**Deep Think Reconciliation Completed:**
- **Source:** Google Deep Think (Identity System Architecture Report)
- **Target:** RQ-014, RQ-013, PD-117, RQ-015
- **Reconciliation File:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ014_RQ013_PD117_RQ015.md`
- **Results:** 11 ACCEPT, 5 MODIFY, 1 REJECT (5-state model), 1 ESCALATE (heart rate)

**Key Modifications from Deep Think:**
| Original | Reconciled | Reason |
|----------|------------|--------|
| 5-state energy model | 4-state model | CD-015 locked 4-state |
| Full switching matrix (25 pairs) | 3 dangerous pairs focus | Over-engineered |
| Heart rate required | Heart rate optional | Android-first, requires Watch |
| Complex burnout algorithm | 3-signal early warning | Middle ground |

**RQs Marked COMPLETE:**
- RQ-013: Identity Topology & Graph Modeling
- RQ-014: State Economics & Bio-Energetic Conflicts
- RQ-015: Polymorphic Habits Implementation

**PDs Marked RESOLVED:**
- PD-111: Polymorphic Habit Attribution (via RQ-015)
- PD-117: ContextSnapshot Real-time Data (via RQ-014)

**Pending Human Decision:**
- **Heart Rate:** Option A (include as nullable) vs Option B (defer entirely)

---

### Previous Session Summary (Archiving Strategy)

### What Was Accomplished (This Session)

**Key Changes Made:**

1. **Documentation Archiving Strategy IMPLEMENTED:**
   - Created `docs/CORE/index/` directory with quick reference tables
   - Created `docs/CORE/archive/` directory for completed items
   - Moved `DOCUMENTATION_GOVERNANCE_ANALYSIS.md` to `docs/analysis/`

2. **Index Files Created:**
   - `index/RQ_INDEX.md` — All 27 RQs with status, blocking info, dependency chain
   - `index/CD_INDEX.md` — All 16 CDs with tier, impact, critical path
   - `index/PD_INDEX.md` — All 26 PDs with status, requirements, resolution chain

3. **Archive Files Created:**
   - `archive/RQ_ARCHIVE_Q1_2026.md` — Full findings for 12 COMPLETE RQs
   - `archive/CD_PD_ARCHIVE_Q1_2026.md` — Full rationale for 16 CDs + 6 RESOLVED PDs

4. **Main Files Updated with Quick Navigation:**
   - `RESEARCH_QUESTIONS.md` — Added Quick Navigation header pointing to index/archive
   - `PRODUCT_DECISIONS.md` — Added Quick Navigation header pointing to index/archive
   - `README.md` — Added Index Folder and Archive Folder sections

5. **Token Management Strategy:**
   - Problem: RESEARCH_QUESTIONS.md ~41K tokens, PRODUCT_DECISIONS.md ~27K tokens
   - Solution: Quick reference indexes + archives reduce cognitive load
   - Agents can now start with index files for rapid lookup

6. **Verification Fixes Applied (Trust & Verify Pass):**
   - Fixed misleading "summaries only" claim in headers → Now says "full details"
   - Updated AI_AGENT_PROTOCOL.md Session Entry Protocol to include index files
   - Updated README.md Mandatory Reading Order to include index files (steps 3-4)
   - All documentation now congruent with archiving strategy

**Archiving Strategy Applied:**
| Item | Action | Location |
|------|--------|----------|
| COMPLETE RQs (12) | Archived with full findings | `archive/RQ_ARCHIVE_Q1_2026.md` |
| CONFIRMED CDs (16) | Archived with rationale | `archive/CD_PD_ARCHIVE_Q1_2026.md` |
| RESOLVED PDs (6) | Archived with resolution | `archive/CD_PD_ARCHIVE_Q1_2026.md` |
| DOCUMENTATION_GOVERNANCE_ANALYSIS | Moved out of CORE | `docs/analysis/` |

**Statistics:**
| Metric | Before | After |
|--------|--------|-------|
| Total RQs | 27 | 27 (12 archived, 15 active) |
| Total CDs | 16 | 16 (all archived with summaries) |
| Total PDs | 26 | 26 (6 archived, 20 active) |
| Index files | 0 | 3 |
| Archive files | 0 | 2 |

---

### Previous Session Summary (Earlier Today — Governance Framework)
| Field | Value |
|-------|-------|
| **Session ID** | `session-priming-docs-r6fCh` (continued) |
| **Date** | 06 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Focus** | Documentation governance: prompt guidance framework, protocol additions, root cause analysis |

**What Was Done:**
- Created DEEP_THINK_PROMPT_GUIDANCE.md (prompt engineering framework)
- Added Protocol 7 & 8 to AI_AGENT_PROTOCOL.md (task extraction, deduplication)
- Created DOCUMENTATION_GOVERNANCE_ANALYSIS.md (root cause investigation)
- Renamed prompt file to follow naming convention

---

### Earlier Session Summary (Implementation Tracker)
| Field | Value |
|-------|-------|
| **Session ID** | `session-priming-docs-r6fCh` |
| **Date** | 06 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Focus** | Implementation tracker, archiving strategy, Deep Think Prompt B initial version |

**What Was Done:**
- Created Master Implementation Tracker (57 tasks across 5 phases)
- Added archiving strategy to PRODUCT_DECISIONS.md (deferred)
- Created initial Deep Think Prompt B (later enhanced)

---

### Prior Session Summary
| Field | Value |
|-------|-------|
| **Session ID** | `deep-think-rq021-rq022-pd115` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~30 minutes |
| **Focus** | Integrate Deep Think research for RQ-021 (Treaty Lifecycle & UX), RQ-022 (Council Script Prompts), and resolve PD-115 |

### What Was Accomplished (That Session)

**Key Changes Made:**

1. **RQ-021: Treaty Lifecycle & UX — ✅ RESEARCH COMPLETE:**
   - Integrated Google Deep Think specifications
   - **The Constitution:** Treaty management dashboard (Active Laws, Probation, Archives)
   - **Treaty Creation Wizard:** 3-step flow (Source → Drafting → Ratification)
   - **Ratification Ritual:** 3-second haptic "wax seal" interaction
   - **5 Treaty Templates:** Sunset Clause, Deep Work Decree, The Sabbath, Transition Airlock, Presence Pact
   - Common Law Principle: Templates = Protocols (80%), Council = Arbitration (20%)

2. **RQ-022: Council Script Generation Prompts — ✅ RESEARCH COMPLETE:**
   - Complete DeepSeek V3.2 system prompt template
   - "The Council Engine" role with Sherlock as narrator
   - 6-turn arc structure (Thesis → Antithesis → Synthesis)
   - **Voice Archetype system:** neutral, urgent, warm, shadow
   - **SSMLBuilder:** Client-side prosody mapping (not LLM-generated)
   - User context injection format (facets + resistance patterns)
   - JSON output schema (`script[]` + `proposed_treaty`)
   - Edge case handling (single facet, no conflict)

3. **PD-115: Treaty Creation UX — ✅ RESOLVED:**

---

### Previous Session Summary
| Field | Value |
|-------|-------|
| **Session ID** | `deep-think-rq021-rq022-pd115` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~30 minutes |
| **Focus** | Integrate Deep Think research for RQ-021 (Treaty Lifecycle & UX), RQ-022 (Council Script Prompts), and resolve PD-115 |

### What Was Accomplished (This Session)

**Key Changes Made:**

1. **RQ-021: Treaty Lifecycle & UX — ✅ RESEARCH COMPLETE:**
   - Integrated Google Deep Think specifications
   - **The Constitution:** Treaty management dashboard (Active Laws, Probation, Archives)
   - **Treaty Creation Wizard:** 3-step flow (Source → Drafting → Ratification)
   - **Ratification Ritual:** 3-second haptic "wax seal" interaction
   - **5 Treaty Templates:** Sunset Clause, Deep Work Decree, The Sabbath, Transition Airlock, Presence Pact
   - Common Law Principle: Templates = Protocols (80%), Council = Arbitration (20%)

2. **RQ-022: Council Script Generation Prompts — ✅ RESEARCH COMPLETE:**
   - Complete DeepSeek V3.2 system prompt template
   - "The Council Engine" role with Sherlock as narrator
   - 6-turn arc structure (Thesis → Antithesis → Synthesis)
   - **Voice Archetype system:** neutral, urgent, warm, shadow
   - **SSMLBuilder:** Client-side prosody mapping (not LLM-generated)
   - User context injection format (facets + resistance patterns)
   - JSON output schema (`script[]` + `proposed_treaty`)
   - Edge case handling (single facet, no conflict)

3. **PD-115: Treaty Creation UX — ✅ RESOLVED:**
   - **Decision:** Option C (Templates + Council AI)
   - Templates for common conflicts (80%), Council for complex (20%)
   - Summon Token allows Council access below tension threshold
   - First-time users get low-stakes "Digital Sunset" on Day 1

4. **PRODUCT_DECISIONS.md Updated:**
   - PD-115 marked RESOLVED with full specification
   - Treaty creation flow, templates, ratification ritual documented
   - Treaty management screen specification added

5. **RESEARCH_QUESTIONS.md Updated:**
   - RQ-021 marked COMPLETE with full Treaty Lifecycle spec
   - RQ-022 marked COMPLETE with system prompt + SSML strategy
   - Sub-questions answered tables added to both

6. **GLOSSARY.md Updated — 7 New Terms:**
   - The Constitution (treaty dashboard)
   - Ratification Ritual (3-second haptic seal)
   - Summon Token (Council access mechanism)
   - The Chamber (Council session UI)
   - Voice Archetype (SSML modulation category)
   - SSMLBuilder (Dart TTS service)
   - Treaty Templates (5 launch templates)

7. **New Research Questions Generated (RQ-024 through RQ-027):**
   - **RQ-024**: Treaty Modification & Renegotiation Flow
   - **RQ-025**: Summon Token Economy
   - **RQ-026**: Sound Design & Haptic Specification
   - **RQ-027**: Treaty Template Versioning Strategy

8. **New Product Decisions Generated (PD-118 through PD-120):**
   - **PD-118**: Treaty Modification UX
   - **PD-119**: Summon Token Economy
   - **PD-120**: The Chamber Visual Design

9. **Implementation Checklist Added (14 tasks across 4 phases):**
   - Phase 1: Foundation (4 tasks)
   - Phase 2: Council Engine (3 tasks)
   - Phase 3: UX Frontend (4 tasks)
   - Phase 4: Integration (3 tasks)

---

### Upstream/Downstream Impact Analysis (RQ-021 + RQ-022)

**How this research affects existing decisions:**

| Decision | Type | Impact | Details |
|----------|------|--------|---------|
| **CD-015** (psyOS) | ✅ Enhanced | Council AI now fully specified | Treaty lifecycle completes the Parliament metaphor |
| **CD-016** (AI Model) | ✅ Validated | DeepSeek V3.2 + Gemini TTS confirmed | System prompt template + SSML strategy delivered |
| **PD-109** (Council Activation) | ✅ Extended | Summon Token adds manual access | tension > 0.7 OR Summon Token |
| **PD-110** (Airlock) | ⚠️ Connected | "Transition Airlock" template implements | Template provides concrete airlock example |
| **PD-113** (Treaty Priority) | ✅ Validated | Hierarchy confirmed | Hard > Soft > JITAI remains |
| **RQ-016** (Council AI) | ✅ Extended | Implementation details added | System prompt, voice archetypes, JSON schema |
| **RQ-018** (Airlock Protocol) | ⚠️ Partial | Template exists, full protocol pending | "Transition Airlock" is one use case |
| **RQ-020** (Treaty-JITAI) | ✅ Completed | TreatyEngine pipeline position confirmed | Stage 3 in JITAI pipeline |

**New dependencies created:**

```
RQ-021 (Treaty Lifecycle)
├── → RQ-024 (Modification Flow)     [NEW - HIGH]
├── → RQ-025 (Summon Token Economy)  [NEW - MEDIUM]
├── → RQ-026 (Sound Design)          [NEW - MEDIUM]
└── → RQ-027 (Template Versioning)   [NEW - LOW]

RQ-022 (Council Prompts)
├── → PD-120 (Chamber Visual Design) [NEW - HIGH]
└── → RQ-026 (Sound Design)          [Shared dependency]

PD-115 (Treaty Creation UX)
├── → PD-118 (Modification UX)       [NEW - HIGH]
└── → PD-119 (Summon Token Economy)  [NEW - MEDIUM]
```

**Research Status Summary (Post-Session):**

| RQ | Status | Blocking |
|----|--------|----------|
| RQ-021 | ✅ COMPLETE | — |
| RQ-022 | ✅ COMPLETE | — |
| RQ-023 | 🔴 PENDING | PD-116 |
| **RQ-024** | 🔴 **NEW** | PD-118 |
| **RQ-025** | 🔴 **NEW** | PD-119 |
| **RQ-026** | 🔴 **NEW** | Audio assets |
| **RQ-027** | 🔴 **NEW** | Template launch |

---

### Previous Session Summary (Same Day)
| Field | Value |
|-------|-------|
| **Session ID** | `deep-analysis-gaps-new-rqs-pds` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~45 minutes |
| **Focus** | Deep analysis of gaps, exhaustive documentation, new RQs/PDs, impact tracing |

### What Was Accomplished (Previous Session)

**Key Changes Made:**

1. **Gap Analysis Completed:**
   - Identified missing specifications in RQ-019 and RQ-020
   - Added Similarity Search Query Patterns (SQL + Dart)
   - Added Population Learning Pipeline (privacy-first design)
   - Added Treaties table complete SQL schema
   - Added ContextSnapshot full Dart class (30+ fields)
   - Added Tension Score calculation algorithm

2. **New Research Questions Created:**
   - **RQ-021**: Treaty Lifecycle & UX (creation, templates, management)
   - **RQ-022**: Council Script Generation Prompts (DeepSeek V3.2 templates)
   - **RQ-023**: Population Learning Privacy Framework (k-anonymity, opt-in)

3. **New Product Decisions Created:**
   - **PD-115**: Treaty Creation UX (Templates + Council AI recommended)
   - **PD-116**: Population Learning Privacy (opt-in, k-anonymity k≥50)
   - **PD-117**: ContextSnapshot Real-time Data (refresh strategies)

---

### Previous Session Summary (Same Day, Earlier)
| Field | Value |
|-------|-------|
| **Session ID** | `deep-think-rq019-rq020-integration` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~30 minutes |
| **Focus** | Deep Think RQ-019 + RQ-020 integration, embedding model correction |

### What Was Accomplished (Previous Session)

**Key Changes Made:**

1. **RQ-019: pgvector Implementation — ✅ RESEARCH COMPLETE:**
   - Integrated full Deep Think specifications
   - **Corrected embedding model**: `gemini-embedding-001` (not text-embedding-004)
   - HNSW index with parameters (m=16, ef_construction=64)
   - Null-on-Update trigger for embedding invalidation
   - Edge Function code for async embedding generation
   - Cost projection: $7/mo at 10K users → $700/mo at 1M users

2. **RQ-020: Treaty-JITAI Integration — ✅ RESEARCH COMPLETE:**
   - Pipeline position: Stage 3 (Post-Safety, Pre-Optimization)
   - Parser: `json_logic_dart` package (not custom eval)
   - Full TreatyEngine Dart class implementation
   - Conflict resolution: Hard > Soft, then Newest > Oldest
   - Breach escalation: 3 breaches in 7 days → Probationary → Auto-Suspend
   - Council activation keywords (regex patterns)

3. **PD-109: Council AI Activation — ✅ RESOLVED:**
   - Tension threshold: `0.7` confirmed
   - Turn limit: `6` per session confirmed
   - Rate limit: `1 auto-summon per 24h per conflict topic`
   - Activation keyword regex patterns documented

4. **PD-113: Treaty Priority Hierarchy — ✅ RESOLVED:**
   - 5-level priority stack confirmed
   - Safety Gates > Hard Treaties > Soft Treaties > JITAI > User Prefs
   - Breach escalation thresholds confirmed

5. **CD-016: AI Model Strategy — Updated:**
   - **Critical correction**: Embeddings use `gemini-embedding-001`, NOT DeepSeek V3.2
   - DeepSeek V3.2 for reasoning tasks (Council AI, Root Synthesis, Gap Analysis)
   - Gemini for real-time (voice, TTS) + embeddings

6. **GLOSSARY.md Updated — 7 New Terms:**
   - gemini-embedding-001
   - Matryoshka Representation Learning (MRL)
   - HNSW (Hierarchical Navigable Small World)
   - JSON Logic
   - TreatyEngine
   - Treaty Priority Stack
   - Breach Escalation

7. **ROADMAP.md Updated:**
   - Model configuration table corrected (gemini-embedding-001)
   - Research status: RQ-019 + RQ-020 marked complete
   - PD-109 + PD-113 resolutions documented

---

### Previous Session Summary (Same Day, Earlier)
| Field | Value |
|-------|-------|
| **Session ID** | `full-implementation-deepseek-documentation` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~45 minutes |
| **Focus** | Full implementation confirmation, DeepSeek V3.2 integration, new RQs/PDs |

### What Was Accomplished (Previous Session)

**Key Changes Made:**

1. **Full Implementation Confirmed (PD-114):**
   - User explicitly chose full psyOS implementation at launch, NOT phased
   - Updated RQ-012 and RQ-016 implementation roadmaps to reflect full scope
   - Added PD-114 documenting this decision

2. **CD-016: AI Model Strategy (DeepSeek V3.2) — ✅ CONFIRMED:**
   - Documented multi-model architecture
   - DeepSeek V3.2 for: Council AI, Root Synthesis, Gap Analysis
   - Gemini for: Real-time voice, TTS
   - Hardcoded for: JITAI logic, Chronotype matrix, Treaty enforcement
   - Updated ROADMAP.md with model allocation table

3. **New Research Questions Added:**
   - **RQ-019**: pgvector Implementation Strategy (embedding infrastructure)
   - **RQ-020**: Treaty-JITAI Integration Architecture (how treaties override JITAI)

4. **New Product Decisions Added:**
   - **PD-113**: Treaty Priority Hierarchy (how treaties interact with JITAI)
   - **PD-114**: Full Implementation Commitment (resolved: full launch)
   - **PD-109**: Council AI Activation Rules — Updated status (RQ-016 complete)

5. **Implementation Tasks Added:**
   - 8 tasks from RQ-012 (Fractal Trinity)
   - 9 tasks from RQ-016 (Council AI)
   - All tasks include AI model assignment

6. **GLOSSARY.md Updated:**
   - Added 7 new Deep Think terms: Triangulation Protocol, Treaty, Logic Hooks, Single-Shot Playwright, Audiobook Pattern, Chronotype-JITAI Matrix, DeepSeek V3.2

7. **ROADMAP.md Updated:**
   - Header reflects full implementation + CD-016
   - Model configuration table with DeepSeek V3.2
   - Task breakdown shows AI model assignments
   - Research status updated

---

### Previous Session Summary (Same Day, Earlier)
| Field | Value |
|-------|-------|
| **Session ID** | `rq-012-016-deep-think-integration` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~30 minutes |
| **Focus** | Integrate Deep Think RQ-012 (Fractal Trinity) + RQ-016 (Council AI) Research |

### What Was Accomplished (Previous Session)

**Key Changes Made:**

1. **RQ-012: Fractal Trinity Architecture — ✅ RESEARCH COMPLETE**
   - Integrated Google Deep Think's comprehensive specifications
   - **Schema finalized** with pgvector for semantic pattern matching
   - **Triangulation Protocol**: Extract manifestations over Days 1-7
   - **Sherlock Day 7 Synthesis Prompt**: JSON output format
   - **Chronotype-JITAI Matrix**: Intervention timing per chronotype

2. **RQ-016: Council AI (Roundtable Simulation) — ✅ RESEARCH COMPLETE**
   - **Architecture Decision**: Single-Shot Playwright Model
   - **Treaty Protocol**: Database schema with logic_hooks JSONB
   - **UX Flow**: Summon → The Show → The Deal → Binding → Enforcement
   - **Voice Mode**: Audiobook Pattern (single narrator)

---

### Previous Session Summary (Same Day, Even Earlier)
| Field | Value |
|-------|-------|
| **Session ID** | `psyos-architecture-documentation` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~60 minutes |
| **Focus** | CD-015 psyOS Architecture Documentation + New RQs/PDs |

### What Was Accomplished (Previous Session)

**Key Changes Made:**

1. **CD-015: psyOS Architecture — ✅ CONFIRMED**
   - User explicitly chose Blue Sky / psyOS architecture for launch
   - NOT the MVP version — full Psychological Operating System vision
   - Technical debt acknowledged and accepted
   - Comprehensive CD-015 entry added to PRODUCT_DECISIONS.md

2. **New Research Questions Generated (RQ-012 through RQ-018):**
   - **RQ-012**: Fractal Trinity Architecture — How to structure root vs manifestations
   - **RQ-013**: Identity Topology & Graph Modeling — Facet relationships
   - **RQ-014**: State Economics & Bio-Energetic Conflicts — Energy state switching
   - **RQ-015**: Polymorphic Habits Implementation — Context-aware habit encoding
   - **RQ-016**: Council AI (Roundtable Simulation) — Multi-agent conflict resolution
   - **RQ-017**: Constellation UX (Solar System) — Dashboard visualization
   - **RQ-018**: Airlock Protocol & Identity Priming — State transitions + sensory triggers

3. **New Product Decisions Generated (PD-108 through PD-112):**
   - **PD-108**: Constellation UX Migration Strategy
   - **PD-109**: Council AI Activation Rules
   - **PD-110**: Airlock Protocol User Control
   - **PD-111**: Polymorphic Habit Attribution
   - **PD-112**: Identity Priming Audio Strategy

4. **ROADMAP.md Updated:**
   - Added psyOS Implementation Roadmap section
   - Five implementation phases: A (Schema) → B (Intelligence) → C (Council AI) → D (Constellation UX) → E (Airlock/Priming)
   - Critical path and research order documented
   - Future Features updated (Living Garden → Constellation, Shadow Dialogue → Council AI)

5. **GLOSSARY.md Updated:**
   - Added complete psyOS terminology section
   - 14 new term definitions: psyOS, Parliament of Selves, Identity Facets, Fractal Trinity, Identity Topology, Tension Score, State Economics, Polymorphic Habits, Council AI, Constellation UX, Airlock Protocol, Identity Priming, Maintenance Mode, Keystone Onboarding

6. **Impact Analysis:**
   - CD-005 (6-Dimension): EXTENDED — Dimensions now context-aware per facet
   - CD-008 (Identity Coach): ELEVATED — Coach becomes Parliament Mediator
   - CD-009 (Content Library): EXPANDED — Need facet-specific content + transition rituals
   - PD-106: RESOLVED — Identity Facets model confirmed via psyOS
   - PD-107: RESHAPED — PGS must support Council AI pattern

---

### Previous Session Summary (Same Day, Even Earlier)
| Field | Value |
|-------|-------|
| **Session ID** | `rq-011-deep-think-validation` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) + Google Deep Think |
| **Duration** | ~90 minutes |
| **Focus** | RQ-011 Research + Deep Think External Validation |

### What Was Accomplished (Previous Session)

**Key Changes Made:**

1. **RQ-011: Multiple Identity Architecture — ✅ RESEARCH COMPLETE + VALIDATED**
   - Initial research by Claude (Identity Facets model)
   - **External validation by Google Deep Think**
   - Model validated with critical refinements identified

2. **Deep Think Critical Findings:**
   - **Invariance Fallacy**: Holy Trinity manifestations differ by domain (Sherlock must contextualize)
   - **Energy Blind Spot**: Missing State Switching conflicts (not just Time conflicts)
   - **New: Maintenance Mode** — High performers sequence, not balance ("Driver vs Passenger")
   - **New: Keystone Onboarding** — 1 facet Day 1, progressive unlock over 7 days
   - **New: Archetypal Templates** — Hardcoded dimension adjustments (users can't self-report)
   - **New: Tension Score** — Graded (0.0-1.0), not binary conflicts

3. **Blue Sky Architecture Documented:**
   - **Parliament of Selves** — User as dynamic system of negotiating parts
   - **Fractal Trinity** — Root archetypes with contextual manifestations
   - **Identity Topology** — Graph-based facet relationships
   - **Polymorphic Habits** — Same action, different encoding by context
   - **Council AI** — Roundtable simulation for conflict resolution
   - **Constellation UX** — Solar system visualization

4. **Schema Refined:**
   - Added `status` field: `active`, `maintenance`, `dormant`
   - Added `archetypal_template` for hardcoded presets
   - Added `tension_scores` JSONB for graded conflicts
   - Added `energy_state` to habit_facet_links

5. **Guardrails Added:**
   - "Ought Self" detection (Sherlock asks: want vs should)
   - Capacity cap: 3 Active Facets for new users
   - Visual tree "leaning" for imbalance feedback

---

### Previous Session Summary (Same Day, Earlier)
| Field | Value |
|-------|-------|
| **Session ID** | `roadmap-restructure-session` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~60 minutes |
| **Focus** | Major Roadmap Restructure, New RQs/PDs, Phase Model |

### What Was Accomplished (Previous Session)

**Key Changes Made:**

1. **ROADMAP.md — Major Restructure**
   - **Deprecated "5 Parallel Layers"** — concept was misleading
   - **Introduced Phase Model:** Phase 0 (Research/Perpetual) → Phase 1 (Foundation) → Phase 2 (Intelligence) → Phase 3 (User Experience)
   - **Future Features** section for parked items (Living Garden, CLI, etc.)
   - **Track G-0 (Terminology)** marked ✅ COMPLETE
   - Legacy layers preserved in collapsed section

2. **RESEARCH_QUESTIONS.md — New RQs**
   - **RQ-010: Permission Data Philosophy** — How to use Health, Location, Usage data
   - **RQ-011: Multiple Identity Architecture** — CRITICAL, fundamental to data model
   - Added "Implementation Tasks from Research" tracking section
   - Updated priority order with BLOCKING tier

3. **PRODUCT_DECISIONS.md — New PDs**
   - **PD-106: Multiple Identity Architecture** — How to handle multiple aspirational identities
   - **PD-107: Proactive Guidance System Architecture** — JITAI + Content + Recommendations hierarchy
   - Added RQ/PD hierarchy documentation

4. **GLOSSARY.md — Major Additions**
   - **Proactive Guidance System (PGS)** definition with full hierarchy
   - **Behavioral Dimensions** — All 6 dimensions with detailed definitions
   - **Ghost Term Policy** — Requires PD/RQ reference for aspirational terms
   - **Signposting Guidance** — When to reference GLOSSARY from other docs

5. **Key Conceptual Clarifications:**
   - **Phases** = Vertical dependency (what before what)
   - **Tracks** = Horizontal workstreams (domain-specific)
   - **Phase 0 is perpetual** — never completes
   - **Identity-First Design** = Philosophy; **PGS** = Implementation

6. **Branch Commits:**
   - `9680a39`: docs: major roadmap restructure - Phases replace Layers

---

### Previous Session Summary (Same Day, Earlier)
| Field | Value |
|-------|-------|
| **Session ID** | `glossary-reconciliation-session` |
| **Date** | 05 January 2026 |
| **Agent** | Claude (Opus 4.5) |
| **Duration** | ~45 minutes |
| **Focus** | GLOSSARY Systematic Review, Ghost Term Resolution |

### What Was Accomplished (Previous Session, Earlier)

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

---

### What Was NOT Done (Deferred)
- None — GLOSSARY review was completed this session

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
| 10 Jan 2026 | Claude (Opus 4.5) | `claude/setup-pact-context-1i4ze` | Identity Coach Deep Analysis + New RQs/PDs | ✅ Exhaustive analysis; 5 new RQs (028-032); 4 new PDs (121-124); PD-105/107 unblocked; Critical gaps identified |
| 10 Jan 2026 | Claude (Opus 4.5) | `claude/setup-pact-context-1i4ze` | Identity Coach Deep Think Reconciliation | ✅ RQ-005/006/007 COMPLETE; Protocol 9 applied; 20 tasks extracted (F-01 to F-20); 12 GLOSSARY terms added |
| 10 Jan 2026 | Claude (Opus 4.5) | `claude/setup-pact-context-rApSv` | Documentation Unification | ✅ CLAUDE.md created; Reading order unified; IMPACT_ANALYSIS.md orphaning fixed; Agent custom instructions drafted |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/pact-session-setup-QVINO` | Deep Analysis: Gaps + New RQs/PDs | ✅ RQ-021-023 NEW; PD-115-117 NEW; Treaties schema; ContextSnapshot class; Tension Score algorithm; Impact analysis |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/pact-session-setup-QVINO` | Deep Think RQ-019 + RQ-020 Integration | ✅ RQ-019+020 COMPLETE; PD-109+113 RESOLVED; CD-016 corrected (gemini-embedding-001); 7 GLOSSARY terms added |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/pact-session-setup-QVINO` | Full Implementation + DeepSeek V3.2 | ✅ PD-114, CD-016, RQ-019-020, PD-113; GLOSSARY + ROADMAP updated |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/pact-session-setup-QVINO` | Deep Think Integration | ✅ RQ-012 + RQ-016 COMPLETE with schemas, prompts, protocols |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/pact-session-setup-QVINO` | psyOS Documentation | ✅ CD-015 confirmed, RQ-012-018 + PD-108-112 added, ROADMAP + GLOSSARY updated |
| 05 Jan 2026 | Claude + Deep Think | `claude/pact-session-setup-QVINO` | RQ-011 + Deep Think Validation | ✅ Model validated, Blue Sky architecture documented, schema refined with status/energy fields |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/pact-session-setup-QVINO` | RQ-011 Research | ✅ Research complete: Identity Facets model recommended, PD-106 ready for decision |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/continue-pact-development-3vnbh` | Roadmap Restructure | Phases replace Layers, RQ-010/011, PD-106/107, PGS hierarchy, Track G-0 complete |
| 05 Jan 2026 | Claude (Opus 4.5) | `claude/continue-pact-development-3vnbh` | GLOSSARY Review | Deprecated Hexis Score, documented Shadow Presence, prioritized Gap Analysis Engine |
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

**Major Progress This Session:**
Full implementation confirmed (not phased). DeepSeek V3.2 documented as primary backend AI model. New implementation research questions and product decisions added.

**Research Status Update:**
| Research Question | Status | Key Deliverables |
|-------------------|--------|------------------|
| RQ-012 (Fractal Trinity) | ✅ COMPLETE | pgvector schema, Triangulation Protocol, Chronotype-JITAI Matrix |
| RQ-016 (Council AI) | ✅ COMPLETE | Single-Shot Playwright, Treaty Protocol, Audiobook Pattern |
| RQ-019 (pgvector Implementation) | ✅ COMPLETE | gemini-embedding-001, HNSW, similarity queries, population learning |
| RQ-020 (Treaty-JITAI Integration) | ✅ COMPLETE | TreatyEngine, treaties schema, ContextSnapshot, tension score algorithm |
| **RQ-021 (Treaty Lifecycle & UX)** | 🔴 NEW | Treaty creation flow, templates, management UI |
| **RQ-022 (Council Script Prompts)** | 🔴 NEW | DeepSeek V3.2 prompt templates for facet dialogue |
| **RQ-023 (Population Learning Privacy)** | 🔴 NEW | Privacy framework, k-anonymity, opt-in |
| RQ-013 (Identity Topology) | 🔴 NEEDS RESEARCH | — (unblocked by pgvector) |
| RQ-014 (State Economics) | 🔴 NEEDS RESEARCH | — (new dependency: ContextSnapshot) |
| RQ-015 (Polymorphic Habits) | 🔴 NEEDS RESEARCH | — |
| RQ-017 (Constellation UX) | 🔴 NEEDS RESEARCH | — |
| RQ-018 (Airlock & Priming) | 🔴 NEEDS RESEARCH | — |

**New Pending Decisions:**
| Decision | Status | Depends On |
|----------|--------|------------|
| PD-115 (Treaty Creation UX) | 🔴 PENDING | RQ-021 |
| PD-116 (Population Learning Privacy) | 🔴 PENDING | RQ-023 |
| PD-117 (ContextSnapshot Real-time Data) | 🔴 PENDING | RQ-014 |

**New Confirmed Decisions:**
| Decision | Summary |
|----------|---------|
| **CD-016** | AI Model Strategy — DeepSeek V3.2 for background, Gemini for realtime |
| **PD-114** | Full Implementation — All psyOS at launch (not phased) |

**New Pending Decisions:**
| Decision | Summary |
|----------|---------|
| **PD-113** | Treaty Priority Hierarchy — How treaties interact with JITAI |
| **PD-109** | Council AI Activation — 🟡 Ready for decision (RQ-016 complete) |

**Your Action Items:**
- **✅ RESOLVED:** PD-106 (Multiple Identity Architecture) — Now confirmed via CD-015
- **✅ COMPLETE:** RQ-012 and RQ-016 — CRITICAL research done, ready for implementation
- **✅ CONFIRMED:** CD-016 (AI Model Strategy) — DeepSeek V3.2 for background tasks
- **✅ CONFIRMED:** PD-114 (Full Implementation) — All psyOS features at launch
- **🟡 READY:** PD-109 (Council AI Activation) — Needs confirmation of thresholds
- **🔴 NEW:** RQ-019, RQ-020 — Implementation research needed before building
- **🔴 REMAINING:** RQ-013-018 — 6 HIGH priority research questions
- **🟡 TIMELINE:** Full psyOS scope — significant build required

**Key Documentation Updated This Session:**
| Document | Section | Change |
|----------|---------|--------|
| PRODUCT_DECISIONS.md | CD-016 | NEW: AI Model Strategy with DeepSeek V3.2 allocation |
| PRODUCT_DECISIONS.md | PD-113, PD-114 | NEW: Treaty Priority + Full Implementation |
| PRODUCT_DECISIONS.md | PD-109 | Updated status (RQ-016 complete) |
| RESEARCH_QUESTIONS.md | RQ-019, RQ-020 | NEW: Implementation research questions |
| RESEARCH_QUESTIONS.md | RQ-012, RQ-016 | Updated roadmaps for full implementation |
| RESEARCH_QUESTIONS.md | Implementation Tasks | Added 17 tasks from RQ-012 + RQ-016 |
| ROADMAP.md | Model Config | Added multi-model architecture table |
| ROADMAP.md | Task Breakdown | Added AI model assignments |
| GLOSSARY.md | Deep Think Terms | Added 7 new terms |
| AI_HANDOVER.md | Session Log | Added this session entry |
