# Claude Session Prep — Post-Merge (Permission Architecture PDs)

## Prerequisite
Ensure `claude/claude-md-instructions-RREJE` has been merged to `main`.

---

## Session Context

### What Was Done
- ✅ RQ-010 Permission Architecture — 2 Deep Think prompts created & responses analyzed
- ✅ Protocol 9 reconciliation on both Technical (RQ-010egh) and UX (RQ-010cdf)
- ✅ Analysis files created with approved specifications
- ✅ New RQs added: RQ-010r-w (implementation gaps), RQ-062 (governance)

### What Was NOT Done (Gap)
- ❌ **No PDs created from Permission research** — This is the missing step
- ❌ Workflow says "Research → Document → Decide → Implement" but stopped at Document

---

## Your Task: Create Permission Architecture PDs

### Input Files (Read These First)
1. `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` — Technical specifications
2. `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` — UX specifications

### Output: Create These PDs

| PD ID | Topic | Source |
|-------|-------|--------|
| **PD-XXX** | Permission Ladder Sequence | RQ-010cdf Analysis §1.1 |
| **PD-XXX** | Activity Recognition Confidence Thresholds | RQ-010egh Analysis §1.2 |
| **PD-XXX** | V-O Opportunity Weight Modifiers | RQ-010egh Analysis §1.3 |
| **PD-XXX** | Doze Mode Strategy (Critical/High/Medium/Low) | RQ-010egh Analysis §1.4 |
| **PD-XXX** | TrustScore Framework (gating mechanism) | RQ-010cdf Analysis §2 |
| **PD-XXX** | Geofence Allocation Strategy | RQ-010egh Analysis §1.5 |
| **PD-XXX** | Privacy Messaging ("Zones not coordinates") | RQ-010cdf Analysis §3 |
| **PD-XXX** | Manual Mode First-Class Experience | RQ-010cdf Analysis §4 |

### Format
Add to `docs/CORE/decisions/PD_UX.md` and/or `PD_JITAI.md` per MANIFEST.md routing.

### Constraints
- DO NOT implement any code
- Mark PDs as 🔵 OPEN (awaiting human confirmation) unless directly derived from CD
- Reference source Analysis file and section number
- Update `PD_INDEX.md` with new PDs

---

## Secondary Tasks (If Time Permits)

1. **Start RQ-062 Deep Think Prompt** — Implementation Governance Process
   - How should agents verify implementation matches specs?
   - What checklist ensures PD/CD alignment during coding?

2. **Review RQ-039 readiness** — Token Economy (Gemini may have started this)

---

## Do NOT

- ❌ Write any implementation code
- ❌ Create prompts for RQs already covered (RQ-010 is DONE)
- ❌ Duplicate work from Analysis files — PDs should REFERENCE them, not repeat content
