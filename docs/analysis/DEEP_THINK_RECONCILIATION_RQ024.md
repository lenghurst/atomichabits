# Protocol 9 Reconciliation: RQ-024 Treaty Modification & Renegotiation

**Source:** Deep Think Research Report (10 January 2026)
**Reconciled By:** Claude (Opus 4.5)
**Date:** 10 January 2026

---

## Phase 1: Locked Decision Audit

| Proposal | Conflicts With | Resolution |
|----------|----------------|------------|
| Re-Ratification Ritual (3s hold) | CD-017 (Android-First) | ✅ COMPATIBLE — VibrationEffect API supported |
| Constitutional Amendment Model | CD-015 (psyOS) | ✅ COMPATIBLE — Aligns with Parliament metaphor |
| Breach History preserved on minor | None | ✅ COMPATIBLE |
| Amnesty on major amendments | None | ✅ COMPATIBLE — Psychologically sound |
| 14-day max pause | None | ✅ COMPATIBLE |
| "REPEAL" type-to-confirm | None | ✅ COMPATIBLE — Prevents accidental deletion |

**Verdict:** No conflicts with locked CDs. All proposals compatible.

---

## Phase 2: Data Reality Audit

| Data Point | Android Status | Permission | Action |
|------------|----------------|------------|--------|
| `breach_count` | ✅ Local DB | None | INCLUDE |
| `status` field | ✅ Local DB | None | INCLUDE |
| `version` field (new) | ✅ Local DB | None | INCLUDE |
| `treaty_history` table (new) | ✅ Local DB | None | INCLUDE |
| VibrationEffect (haptic) | ✅ API 26+ | VIBRATE | INCLUDE |
| Time picker | ✅ Native widget | None | INCLUDE |

**Verdict:** All data points Android-available. No external dependencies.

---

## Phase 3: Implementation Reality Audit

| Proposal | Requires | Exists? | Gap |
|----------|----------|---------|-----|
| `treaties` table | Supabase table | ✅ YES (RQ-020 schema) | None |
| `treaty_history` table | New table | ❌ NO | Add to Phase A |
| Redline Editor UI | Custom Flutter widget | ❌ NO | New widget needed |
| Re-Ratification ceremony | Haptic + animation | ⚠️ PARTIAL (haptic exists in spec) | Wire up |
| Probation notification | JITAI notification | ✅ YES | Integrate |
| Council reconvene for major | Council session flow | ✅ YES (RQ-016) | Wire context |

**Gaps Identified:**
1. `treaty_history` table needs creation (Phase A)
2. Redline Editor widget needs implementation (Phase D)

---

## Phase 3.5: Schema Reality Check

| Table | Exists? | Migration File | Blocker |
|-------|---------|----------------|---------|
| `treaties` | ⚠️ SCHEMA ONLY | RQ-020 spec, not migrated | Phase A |
| `treaty_history` | ❌ NO | Proposed in this research | Phase A |
| `council_sessions` | ⚠️ SCHEMA ONLY | RQ-016 spec, not migrated | Phase A |

**Reality:** The `treaties` table is specified in RQ-020 but the actual Supabase migration file does NOT exist yet. This is consistent with the red team finding that Phase A schema hasn't been implemented.

**Action:** Add `treaty_history` table to Phase A tasks alongside `treaties` table.

---

## Phase 4: Scope & Complexity Audit

| Proposal | Complexity Rating | Justification |
|----------|-------------------|---------------|
| Amendment Classification Table | **ESSENTIAL** | Core to treaty lifecycle |
| Redline Editor (strikethrough UI) | **VALUABLE** | High UX value, moderate effort |
| Re-Ratification Ritual | **ESSENTIAL** | Maintains gravitas per prompt requirements |
| Probation Journey (T+0 to T+96h) | **ESSENTIAL** | Core escalation flow |
| `treaty_history` schema | **ESSENTIAL** | Audit trail required |
| Pause State Machine | **ESSENTIAL** | User agency for temporary relief |
| Suspend State Machine | **ESSENTIAL** | System consequence for non-compliance |
| Repeal "type REPEAL" | **VALUABLE** | Safety feature, good UX |
| 14-day max pause | **VALUABLE** | Prevents indefinite avoidance |

**Scope Creep Check:**
- Research stayed within prompt boundaries
- No new concepts introduced beyond prompt scope
- Marcus scenario fully addressed

**Verdict:** Research is well-scoped. All proposals are ESSENTIAL or VALUABLE.

---

## Phase 5: ACCEPT / MODIFY / REJECT / ESCALATE

### ✅ ACCEPT (Integrate as-is)

| # | Proposal | Rationale |
|---|----------|-----------|
| 1 | **Amendment Classification Table** | Clear minor/major distinction with breach history logic |
| 2 | **Breach Preservation on Minor** | Prevents gaming; maintains gravitas |
| 3 | **Amnesty on Major** | New agreement = fresh start; psychologically sound |
| 4 | **Probation Journey Timing** (T+0 → T+96h) | Clear escalation with user agency windows |
| 5 | **Pause State** (user-initiated, 14-day max) | Preserves treaty identity while allowing relief |
| 6 | **Suspend State** (system-initiated, requires renegotiation) | Consequence for non-compliance |
| 7 | **Repeal with type-to-confirm** | Prevents accidental deletion |
| 8 | **`treaty_history` schema** | Essential audit trail |
| 9 | **`version` field on treaties** | Enables lineage tracking |
| 10 | **`parent_treaty_id` for major amendments** | Links renegotiated treaties |

### 🟡 MODIFY (Adjust for reality)

| # | Proposal | Original | Adjusted | Rationale |
|---|----------|----------|----------|-----------|
| 1 | **Redline Editor** | Full strikethrough Rich Text UI | **Simplified: Show old → new inline** | Custom Rich Text is complex; simple diff display sufficient for MVP |
| 2 | **Probation T+24h Sherlock Prompt** | Sherlock appears with dialogue | **Notification with "Fix Treaty" CTA** | Sherlock prompts are expensive (DeepSeek API); notification sufficient |
| 3 | **Wax melting animation** | Animation over strikethrough | **Color change + haptic only** | Animation complexity; defer to post-MVP |

### 🔴 REJECT (Do not implement)

| # | Proposal | Reason |
|---|----------|--------|
| 1 | **Tension score +0.2 at T+72h** | Tension score is computed from facet conflicts, not breaches. Breach count already visible. Adding arbitrary +0.2 conflates systems. |

### ⚠️ ESCALATE (Human decision required)

None. All proposals are implementable within constraints.

---

## Phase 6: Integration Summary

### A. RQ-024 Key Findings

**Core Model:** Constitutional Amendment with Minor (Preserve Breaches) / Major (Amnesty) distinction.

| Amendment Type | Ceremony | Breach History |
|----------------|----------|----------------|
| Minor (params) | Re-Ratify (3s hold) | PRESERVED |
| Major (logic/parties) | Council Session | RESET (Amnesty) |
| Pause | Modal + date picker | FROZEN |
| Suspend | System-initiated | N/A |
| Repeal | Type "REPEAL" | Archived |

**Probation Journey:**
- T+0: Notification + Orange border
- T+24h: "Fix Treaty" nudge
- T+72h: Final warning
- T+96h: Auto-suspend

### B. PD-118 Resolution

**Decision:** Option C (Amendment Flow) — CONFIRMED with specifications:
- Minor amendments: Direct edit + Re-Ratification
- Major amendments: Council reconvene
- Probation response: Time-bound escalation to auto-suspend

### C. Tasks Extracted

| ID | Task | Priority | Status | Source | Component |
|----|------|----------|--------|--------|-----------|
| **A-11** | Create `treaty_history` table (audit log) | HIGH | 🔴 NOT STARTED | RQ-024 | Database |
| **A-12** | Add `version`, `parent_treaty_id`, `last_amended_at` to `treaties` | HIGH | 🔴 NOT STARTED | RQ-024 | Database |
| **D-11** | Implement Treaty Amendment Editor (minor amendments) | HIGH | 🔴 NOT STARTED | RQ-024 | Widget |
| **D-12** | Implement Re-Ratification ceremony (3s hold + haptic) | HIGH | 🔴 NOT STARTED | RQ-024 | Widget |
| **D-13** | Implement Pause Treaty flow (modal + date picker) | MEDIUM | 🔴 NOT STARTED | RQ-024 | Widget |
| **D-14** | Implement Repeal Treaty flow (type-to-confirm) | MEDIUM | 🔴 NOT STARTED | RQ-024 | Widget |
| **C-13** | Wire Council reconvene for major amendments (pass treaty context) | HIGH | 🔴 NOT STARTED | RQ-024 | Service |
| **B-16** | Implement Probation notification journey (T+0 to T+96h) | HIGH | 🔴 NOT STARTED | RQ-024 | Service |
| **B-17** | Implement Auto-suspend logic (5+ breaches OR 3 dismissed) | HIGH | 🔴 NOT STARTED | RQ-024 | Service |

### D. Glossary Additions

| Term | Definition |
|------|------------|
| **Minor Amendment** | Changes to treaty parameters (time, count) that preserve breach history and require Re-Ratification. |
| **Major Amendment** | Changes to treaty logic or signatories that require Council reconvene and grant Amnesty (breach reset). |
| **Re-Ratification** | 3-second long-press ceremony to confirm minor treaty amendments. |
| **Amnesty** | Breach count reset granted when treaty is fundamentally renegotiated (major amendment). |
| **Probation Journey** | Time-bound escalation (T+0 → T+96h) prompting user to fix, pause, or repeal a failing treaty. |

---

## Confidence Assessment

| Recommendation | Confidence | Rationale |
|----------------|------------|-----------|
| Minor/Major Classification | **HIGH** | Clear criteria, prevents gaming |
| Breach History Logic | **HIGH** | Psychologically sound, maintains gravitas |
| Probation Timing | **HIGH** | Gives user 4 days to respond |
| Redline Editor (simplified) | **MEDIUM** | Simplified version for MVP; enhance later |
| Schema Additions | **HIGH** | Standard audit pattern |

---

## Final Reconciliation Verdict

| Metric | Count |
|--------|-------|
| **ACCEPT** | 10 |
| **MODIFY** | 3 |
| **REJECT** | 1 |
| **ESCALATE** | 0 |

**Research Quality:** HIGH — Well-structured, scenario-driven, actionable specifications.

**Integration Ready:** YES — After applying 3 modifications.
