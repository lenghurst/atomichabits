# Impact Analysis: RQ-048a/b + RQ-014 + RQ-013 Schema Foundation

**Date:** 14 January 2026
**Trigger:** Research completion via Protocol 9/10 reconciliation
**Scope:** Cascade effects of completing 4 foundational schema RQs
**Reconciliation Doc:** `docs/CORE/RECONCILIATION_RQ048ab_RQ014_RQ013_SCHEMA_FOUNDATION.md`

---

## Executive Summary

Completion of RQ-048a/b (Domain Taxonomy + Cognitive Limits), RQ-014 (State Economics), and RQ-013 (Identity Topology) **UNBLOCKS Phase A schema creation**, which has been the primary blocker for 116 implementation tasks across 8 phases.

**Critical Path Impact:**
- ✅ **Phase A (12 tasks):** Now actionable — `identity_facets` and `identity_topology` tables can be created
- ✅ **Phase H (16 tasks):** Unblocked after Phase A — Constellation/Airlock UX implementation
- ✅ **Phase G (14 tasks):** Partially unblocked — Identity Coach intelligence layer can add fields to schema
- ⚠️ **JITAI Intelligence:** Enhanced with switching cost matrix, but needs RQ-010c-h for passive energy detection accuracy

**Key Decisions Finalized:**
- **4-Domain Taxonomy:** vocational, somatic, relational, intellectual (merged creative, rejected spiritual)
- **Cognitive Limits:** 5 soft cap / 9 safety cap / 12 hard cap
- **Switching Cost Matrix:** 4×4 asymmetric (12 unique values) with chronotype modifiers
- **Airlock Pattern:** Composite FK tenant isolation (security)

---

## 1. Upstream Dependencies (What These RQs Relied On)

| Dependency | Status | How It Was Used |
|---|---|---|
| **RQ-012** (Chronotype) | ✅ COMPLETE | Chronotype modifiers for switching costs; psychometric_root_id FK |
| **CD-015** (4-State Energy) | ✅ LOCKED | Energy state enum (high_focus, high_physical, social, recovery) |
| **RQ-010a/b** (Permission Accuracy) | ✅ COMPLETE | Passive energy detection algorithm (biometric, activity, calendar) |
| **CD-018** (ESSENTIAL/VALUABLE threshold) | ✅ LOCKED | Used to evaluate 6-domain → 4-domain reduction |

**Result:** All upstream dependencies were satisfied. No blockers encountered.

---

## 2. Downstream Impacts (What These RQs Unblock)

### 2.1 IMMEDIATE UNBLOCKS — Phase A Schema (12 Tasks)

| Task ID | Task | Priority | Previous Status | New Status |
|---|---|---|---|---|
| **A-01** | Enable pgvector extension | CRITICAL | 🔴 NOT STARTED | 🟢 READY |
| **A-06** | Create `identity_facets` table | CRITICAL | 🔴 NOT STARTED | 🟢 READY |
| **A-13** | Create `identity_topology` table | CRITICAL | 🔴 NOT STARTED | 🟢 READY |
| **A-14** | Create RLS policies for identity_facets | HIGH | 🔴 NOT STARTED | 🟢 READY |
| **A-15** | Create RLS policies for identity_topology | HIGH | 🔴 NOT STARTED | 🟢 READY |
| **A-16** | Create facet_limit_trigger function | MEDIUM | 🔴 NOT STARTED | 🟢 READY |
| **A-17** | Seed switching cost matrix defaults | HIGH | 🔴 NOT STARTED | 🟢 READY |
| **A-19** | Add `keystone_habit_id` FK to identity_facets | P1 | ❌ DID NOT EXIST | 🟢 READY |
| **A-20** | Add `sort_order` field to identity_facets | P1 | ❌ DID NOT EXIST | 🟢 READY |

**New Tasks Created:**
- A-19: Add `keystone_habit_id` FK (E-001 escalation resolved)
- A-20: Add `sort_order` field (user-defined Parliament ordering)

### 2.2 DOWNSTREAM UNBLOCKS — Phase H Constellation/Airlock (16 Tasks)

**Previous State:** 🔴 **BLOCKED** — "identity_facets table DOES NOT EXIST"
**New State:** 🟡 **READY AFTER PHASE A**

| Task ID | Task | Priority | Dependency Chain |
|---|---|---|---|
| **H-01** | ConstellationPainter (CustomPainter) | CRITICAL | A-06 → G-02 → H-01 |
| **H-02** | Orbit distance formula (ICS-based) | CRITICAL | A-06 → G-01 → H-02 |
| **H-06** | Tether visualization (friction > 0.6) | MEDIUM | A-13 → H-06 |
| **H-10** | TransitionDetector service | CRITICAL | RQ-014 (switching costs) → H-10 |
| **H-11** | AirlockOverlay widget (5-Second Seal) | CRITICAL | RQ-018 → H-11 |
| **H-14** | Airlock + Treaty integration | HIGH | A-13 → H-14 |

**Unblocking Path:** A-01 → A-06 → G-01 + G-02 → Phase H tasks actionable

### 2.3 ENHANCED FEATURES — Existing Systems

| System | Enhancement | Source |
|---|---|---|
| **JITAI Timing Logic** | Now has 4×4 asymmetric switching cost matrix | RQ-014 |
| **JITAI Timing Logic** | Chronotype modifiers for high_focus transitions | RQ-014 + RQ-012 |
| **Passive Energy Detection** | 4-tier confidence algorithm (bio → activity → calendar → default) | RQ-014 |
| **Parliament UX** | User-defined sort_order for facet display | RQ-048b (A-20) |
| **Identity Security** | Airlock Pattern prevents cross-tenant topology leaks | RQ-013 |

### 2.4 RESEARCH DEPENDENCIES CREATED

| New Dependency | Affects | Priority |
|---|---|---|
| **RQ-010c-h** (Permission sub-RQs) | Passive energy detection accuracy | MEDIUM |
| **RQ-015** (Polymorphic Habits) | Habit polymorphism by facet | HIGH |
| **RQ-007** (Identity Roadmap) | Roadmap progression via topology | HIGH |

**Note:** RQ-015 and RQ-007 were already identified as HIGH priority, but are now **actionable** because the schema foundation exists.

---

## 3. Product Decision (PD) Impacts

### 3.1 PDs Now Implementable

| PD | Decision | Previous State | New State | Path Forward |
|---|---|---|---|---|
| **PD-106** | Multiple Identity (Parliament of Selves) | RESOLVED → CD-015 | ✅ IMPLEMENTABLE | Phase A → Phase H |
| **PD-108** | Constellation as Identity Dashboard | RESOLVED | ✅ IMPLEMENTABLE | Phase A → H-01 to H-09 |
| **PD-110** | Tether Conflict Visualization | RESOLVED | ✅ IMPLEMENTABLE | A-13 → H-06 |
| **PD-112** | Airlock 5-Second Seal | RESOLVED | ✅ IMPLEMENTABLE | H-10 → H-11 |
| **PD-117** | ContextSnapshot Data Schema | RESOLVED | ✅ ENHANCED | Now includes passive energy detection (RQ-014) |

### 3.2 PDs Still Blocked by Research

| PD | Question | Blocker | Est. Unblock |
|---|---|---|---|
| **PD-119** | Token Economy Mechanics | RQ-039 + 7 sub-RQs | Q1 2026 |
| **PD-101** | Sherlock Prompt Consolidation | RQ-034 (Sherlock Architecture) | Q1 2026 |
| **PD-103** | Sensitivity Detection (7th dimension) | RQ-035 | Q2 2026 |

---

## 4. Implementation Roadmap Impact

### 4.1 Critical Path Analysis

**BEFORE RQ-048/014/013 Completion:**
```
BLOCKED: Phase A schema → BLOCKED: Phase H → BLOCKED: 116 tasks
```

**AFTER RQ-048/014/013 Completion:**
```
Phase A (12 tasks) → Phase G fields (2 tasks) → Phase H (16 tasks)
                                               ↘ Phase B intelligence (3 tasks)
                                               ↘ Phase F Identity Coach (5 tasks)
```

**Newly Actionable Task Count:**
- **Immediate:** 12 (Phase A)
- **After Phase A:** 28 (Phase H + Phase G + Phase B + Phase F dependencies)
- **Total unblocked:** 40 tasks

### 4.2 New Critical Path

```
A-01: Enable pgvector (5 min)
  ↓
A-06: identity_facets table (30 min)
  ↓
A-13: identity_topology table (20 min)
  ↓
A-14 + A-15: RLS policies (15 min)
  ↓
A-16: Facet limit trigger (20 min)
  ↓
A-17: Seed switching cost matrix (10 min)
  ↓
A-19 + A-20: keystone_habit_id + sort_order (10 min)
  ↓
G-02: Add typical_energy_state to identity_facets (5 min)
  ↓
G-01: Add ics_score to identity_facets (5 min)
  ↓
Phase H tasks now actionable (H-01 to H-16: ~2-3 days)
```

**Total estimated time for Phase A + Phase G fields:** ~2 hours
**Blocking 40 tasks worth:** ~5-7 days of implementation

---

## 5. Outstanding Research Gaps

### 5.1 CRITICAL Priority (Blocks Features)

| RQ | Topic | Blocks | Next Action |
|---|---|---|---|
| **RQ-039** + 7 sub-RQs | Token Economy Architecture | E-12, E-14, PD-119 | Create Deep Think prompt |
| **RQ-010c-h** | Permission sub-RQs (6 RQs) | Passive energy detection accuracy | Split into 2 focused prompts |

### 5.2 HIGH Priority (Unlocked by Schema)

| RQ | Topic | Why Now Actionable | Next Action |
|---|---|---|---|
| **RQ-015** | Polymorphic Habits | identity_facets table will exist | Create Deep Think prompt |
| **RQ-007** | Identity Roadmap Architecture | identity_topology table will exist | Create Deep Think prompt |
| **RQ-034** | Sherlock Conversation Architecture | RQ-037 complete | Create Deep Think prompt |

### 5.3 MEDIUM Priority (Post-Launch)

| RQ | Topic | Rationale |
|---|---|---|
| **RQ-023** | Population Learning Privacy | Depends on RQ-019 ✅, post-launch feature |
| **RQ-026** | Sound Design & Haptic | UX polish, not blocking |
| **RQ-035** | Sensitivity Detection | 7th dimension (social), needs social features first |
| **RQ-036** | Chamber Visual Design | UX polish, not blocking |
| **RQ-038** | JITAI Component Allocation | Engineering process, not blocking features |

---

## 6. Schema Evolution Notes

### 6.1 Fields Added Beyond Deep Think Proposal

| Field | Table | Source | Rationale |
|---|---|---|---|
| `keystone_habit_id` | identity_facets | Reconciliation | "One habit = one identity" anchor |
| `sort_order` | identity_facets | E-001 escalation | User-defined Parliament ordering |
| `psychometric_root_id` | identity_facets | RQ-012 integration | Fractal Trinity linkage |

### 6.2 Domain Taxonomy Decision Rationale

**Deep Think Proposed:** 6 domains (vocational, somatic, relational, intellectual, creative, spiritual)
**Protocol 9 Decision:** 4 domains (vocational, somatic, relational, intellectual)

**Modifications:**
- ✅ Merged "creative" into "intellectual" — Both use high_focus, both are self-actualization
- ❌ Rejected "spiritual" — NICE-TO-HAVE for MVP, can use relational (service) or free-text labels

**Impact on UX:**
- Simpler onboarding (fewer choices)
- Clearer Parliament seating (4 sections vs 6)
- Maintains flexibility via embedding similarity

### 6.3 Cognitive Limits Decision Rationale

**Deep Think Proposed:** Soft 5 / Safety 9 / Hard 15
**Protocol 9 Decision:** Soft 5 / Safety 9 / Hard 12

**Modification:**
- Protocol 10 flagged "15" as LOW-validity assumption (no empirical basis)
- Reduced to 12 = 2× safety cap (sufficient for edge cases)

**Impact:**
- Prevents database bloat
- Maintains user flexibility
- Research-backed threshold (Cowan 2001: 4±1 chunks)

---

## 7. Follow-Up Actions

### 7.1 IMMEDIATE (This Sprint)

| Action | Owner | Timeline |
|---|---|---|
| Create Deep Think prompt for RQ-039 (Token Economy) | AI Agent | Today |
| Split RQ-010c-h into 2 focused prompts (Permission UX vs Technical) | AI Agent | Today |
| Create Deep Think prompt for RQ-015 (Polymorphic Habits) | AI Agent | Today |
| Create Deep Think prompt for RQ-034 (Sherlock Architecture) | AI Agent | Today |
| Update IMPACT_ANALYSIS.md with this entry | AI Agent | ✅ DONE |

### 7.2 NEXT (After Prompts Created)

| Action | Owner | Timeline |
|---|---|---|
| Execute Deep Think prompts (external AI) | Human | This week |
| Reconcile Deep Think responses (Protocol 9/10) | AI Agent | This week |
| Implement Phase A schema (A-01 to A-20) | Developer | 2 hours |
| Implement Phase H Constellation/Airlock (H-01 to H-16) | Developer | 2-3 days |

---

## 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| RQ-010c-h blocks passive energy detection | MEDIUM | MEDIUM | Use hardcoded defaults from RQ-014 matrix; improve later |
| Phase A schema breaks existing code | LOW | HIGH | Schema is greenfield (tables don't exist yet) |
| 4-domain taxonomy insufficient | LOW | MEDIUM | Embedding similarity maintains flexibility; can add 5th domain post-launch |
| Cognitive limits (12) too restrictive | LOW | LOW | Database allows 12; can increase to 15 if needed |

---

## 9. Success Metrics

| Metric | Target | Verification |
|---|---|---|
| Phase A tasks READY | 12/12 | ✅ All Phase A tasks now actionable |
| Phase H tasks UNBLOCKED | 16/16 (after Phase A) | 🟡 Pending Phase A completion |
| New RQ dependencies created | 3 (RQ-010c-h, RQ-015, RQ-007) | ✅ Identified and prioritized |
| Implementation time saved | ~5-7 days | 40 tasks unblocked by ~2hr Phase A work |

---

**Impact Analysis Complete:** 14 January 2026
**Next Update Trigger:** RQ-039, RQ-010c-h, RQ-015, or RQ-034 completion
