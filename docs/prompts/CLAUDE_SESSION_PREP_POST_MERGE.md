# Claude Session: Protocol 15 Execution — PD Extraction

> **Session Type:** Governance (Protocol 15 — PD Extraction from Analysis Files)
> **Prerequisite:** Branch merged to main ✅
> **Priority:** CRITICAL — Implementation cannot begin without PDs
> **Estimated Output:** ~8-12 PDs marked 🔵 OPEN

---

## CONTEXT PRIMING

### Why This Session Exists

The workflow is: **Research → Document → DECIDE → Implement**

We completed Research (Deep Think prompts) and Document (Analysis files), but stopped before DECIDE (PD creation). This is a governance violation that must be corrected before any implementation begins.

### The Risk If We Skip This

| If We Skip PDs | Consequence |
|----------------|-------------|
| No human sign-off | AI decides what to build — violates governance model |
| No scope control | Implementer reads Analysis file, builds EVERYTHING including optional "nice-to-have" items |
| No single source of truth | "Where is the decision?" — Answer: buried in 300-line Analysis file |
| Cross-agent divergence | Gemini reads one section, Claude another → divergent implementations |
| Blocked implementation | Protocol 15 is MANDATORY before any code is written |

### What This Session Produces

| Input | Output |
|-------|--------|
| `DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` | ~4-6 Technical PDs |
| `DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` | ~4-6 UX PDs |
| `CD_INDEX.md` (cross-check) | Verification no PD violates CDs |
| `PD_INDEX.md` (update) | New PDs indexed and tracked |

---

## MANDATORY READING ORDER

### Step 0: Read Protocol 15
**File:** `docs/CORE/AI_AGENT_PROTOCOL.md` (search for "Protocol 15")

This defines:
- Trigger: After Protocol 9, BEFORE implementation
- Element-by-element review template
- Anti-patterns to avoid

### Step 1: Read Supporting Protocol
**File:** `docs/CORE/protocols/PROTOCOL_PD_EXTRACTION.md`

This defines:
- Pattern detection (what IS vs IS NOT a decision)
- PD template format
- Quality checklist

### Step 2: Read CD Constraints (Critical)
**File:** `docs/CORE/index/CD_INDEX.md`

Every PD must be checked against these locked decisions:

| CD# | Constraint | PD Must Align |
|-----|------------|---------------|
| **CD-015** | 4-state energy model (high_focus, high_physical, social, recovery) — NOT 5-state | Any PD referencing energy/states |
| **CD-016** | DeepSeek V3.2 (analyst), R1 Distilled (reasoning) | Any PD referencing AI |
| **CD-017** | Android-first — all features must work without iOS/wearables | Every PD |
| **CD-018** | ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED threshold | Tag every PD with tier |
| **CD-006** | GPS Permission Usage (established early) | Permission-related PDs |

### Step 3: Read Analysis Files
**Files:**
1. `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` — Technical
2. `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` — UX

---

## ANALYSIS FILE DECISION INVENTORY

Below is every section that may contain extractable decisions. Use this as your checklist.

### Technical Analysis (RQ-010egh)

| Section | Topic | Likely PD? | Notes |
|---------|-------|-----------|-------|
| §1.1 | Activity Recognition API (Transition API) | ✅ YES | Architecture choice |
| §1.2 | Confidence Thresholds (per activity) | ✅ YES | Config values |
| §1.3 | V-O Opportunity Weight Adjustments | ✅ YES | Config values |
| §1.4 | Doze Mode Decision Tree | ✅ YES | Priority levels |
| §1.5 | Geofencing Architecture | ✅ YES | Requirements |
| §1.6 | WiFi Fallback Assessment | ⚠️ MAYBE | Finding, not decision |
| §1.7 | Zero-Permission Signals | ⚠️ MAYBE | List, not decision |
| §2 | ActivityContext Specification | ❌ NO | Implementation detail |
| §3 | Zone Storage Schema | ❌ NO | Implementation detail |

### UX Analysis (RQ-010cdf)

| Section | Topic | Likely PD? | Notes |
|---------|-------|-----------|-------|
| §1.1 | Permission Ladder Sequence | ✅ YES | Ordering decision |
| §1.2 | Location Sequence (Foreground → Background) | ✅ YES | Phased approach |
| §2 | TrustScore Framework | ✅ YES | Gating mechanism |
| §3 | PermissionConfigs | ❌ NO | Implementation detail |
| §4 | Context Chips UI | ⚠️ MAYBE | UI pattern, needs PD for approach |
| §5 | Manual Fallback Mapping | ✅ YES | Fallback strategy |
| §6 | Privacy Messaging | ✅ YES | "Zones not coordinates" |

---

## ELEMENT-BY-ELEMENT REVIEW TEMPLATE

For **EACH** candidate decision identified above, execute this template:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ELEMENT REVIEW #[N]                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ SOURCE: [Analysis file] §[Section]                                          │
│ RAW TEXT: "[Exact quote from Analysis file]"                                │
│                                                                             │
│ REASONING:                                                                  │
│                                                                             │
│ 1. Is this a DECISION or just INFORMATION?                                  │
│    → [DECISION because... / INFORMATION because...]                         │
│                                                                             │
│ 2. Is this ACTIONABLE for an implementer?                                   │
│    → [YES: implementer would do X / NO: too vague because...]               │
│                                                                             │
│ 3. Does this contradict ANY locked CD?                                      │
│    □ CD-015 (4-state energy): [OK / CONFLICT]                               │
│    □ CD-016 (DeepSeek): [OK / N/A]                                          │
│    □ CD-017 (Android-first): [OK / CONFLICT]                                │
│    □ CD-018 (Threshold): Tier = [ESSENTIAL / VALUABLE / NICE-TO-HAVE]       │
│    □ CD-006 (GPS): [OK / CONFLICT / N/A]                                    │
│                                                                             │
│ 4. Does this contradict any EXISTING PD?                                    │
│    → [Check PD_INDEX.md] [OK / CONFLICT with PD-XXX]                        │
│                                                                             │
│ VERDICT: [✅ EXTRACT AS PD / ⏭️ SKIP / 🚨 ESCALATE]                         │
│                                                                             │
│ If EXTRACT, draft PD below:                                                 │
│ ─────────────────────────────────────────────────────────────────────────── │
│ | **PD-XXX** | [One-line decision] | 🔵 OPEN | [DOMAIN] | RQ-010X |         │
│                                                                             │
│ **Rationale:** [WHY this decision]                                          │
│ **Source:** [Analysis file + section]                                       │
│ **Alternatives Rejected:** [What was NOT chosen]                            │
│ **CD-018 Tier:** [ESSENTIAL / VALUABLE / NICE-TO-HAVE]                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## EXPECTED PD OUTPUT

Based on the decision inventory, expect approximately:

### From RQ-010egh (Technical) — Route to PD_JITAI.md

| PD Topic | Source | CD-018 Tier |
|----------|--------|-------------|
| Activity Recognition uses Transition API (push-based) | §1.1 | ESSENTIAL |
| Activity confidence thresholds (STILL=50%, IN_VEHICLE=80%) | §1.2 | VALUABLE |
| V-O weight modifiers (IN_VEHICLE=-0.30, RUNNING=+0.15) | §1.3 | VALUABLE |
| Doze mode priority levels (CRITICAL/HIGH/MEDIUM/LOW) | §1.4 | ESSENTIAL |
| Geofence allocation strategy (Fixed + Active + Dynamic) | §1.5 | VALUABLE |

### From RQ-010cdf (UX) — Route to PD_UX.md

| PD Topic | Source | CD-018 Tier |
|----------|--------|-------------|
| Permission Ladder sequence (Notif → Activity → Location → BG → Calendar) | §1.1 | ESSENTIAL |
| Background Location requires 3 foreground successes first | §1.2 | ESSENTIAL |
| TrustScore gates sensitive permissions (>60 threshold) | §2 | VALUABLE |
| Privacy messaging uses "zones not coordinates" framing | §6 | ESSENTIAL |
| Manual Mode is first-class experience (Context Chips) | §4-5 | VALUABLE |

---

## ROUTING GUIDE (Per MANIFEST.md)

| Domain | Target File |
|--------|-------------|
| Permission UX, Onboarding, Privacy Messaging | `PD_UX.md` |
| Activity Recognition, Geofencing, Doze, JITAI | `PD_JITAI.md` |

---

## SESSION COMPLETION CHECKLIST

Before ending session:

```
PROTOCOL 15 COMPLETION:

□ Read Protocol 15 in AI_AGENT_PROTOCOL.md
□ Read PROTOCOL_PD_EXTRACTION.md
□ Processed RQ-010egh Analysis (Technical)
   □ Element-by-element review for each §
   □ ~4-6 PDs extracted
□ Processed RQ-010cdf Analysis (UX)
   □ Element-by-element review for each §
   □ ~4-6 PDs extracted
□ All PDs checked against CD_INDEX.md — no conflicts
□ All PDs marked 🔵 OPEN
□ PD_INDEX.md updated with new PDs and count
□ PD_UX.md updated with UX PDs
□ PD_JITAI.md updated with Technical PDs
□ AI_HANDOVER.md updated: "PDs awaiting human review"
□ All changes committed and pushed
```

---

## ANTI-PATTERNS — DO NOT

```
❌ Skip element-by-element review (batch processing misses nuance)
❌ Copy entire Analysis paragraphs as PDs (one decision per PD)
❌ Mark any PD as 🟢 CONFIRMED (human must approve)
❌ Create PD for "future consideration" or "nice-to-have" items
❌ Extract implementation code as PDs (code stays in code)
❌ Assume Analysis file sections map 1:1 to PDs (they don't)
❌ Skip CD cross-check (violations cause downstream chaos)
❌ Write implementation code (this is DECIDE phase, not IMPLEMENT)
```

---

## WHEN COMPLETE

Update AI_HANDOVER.md:

```markdown
| **Status** | 🔵 PDs extracted from Analysis files — awaiting human review |
```

List all created PDs in the "Files Modified This Session" table.

Human will then review and mark PDs as 🟢 CONFIRMED before implementation begins.
