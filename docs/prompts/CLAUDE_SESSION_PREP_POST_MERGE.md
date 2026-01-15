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

### Why This Matters (Risk Matrix)

| If We Skip PDs | Consequence |
|----------------|-------------|
| No human sign-off | AI decides what to build — violates governance |
| No scope control | Implementer builds EVERYTHING including optional items |
| No single source of truth | "Where's the decision?" — buried in 300-line Analysis file |
| Cross-agent confusion | Gemini reads one section, Claude another — divergent implementations |

---

## Your Task: Extract PDs Using Protocol

### Step 0: Read the Protocol
**MANDATORY:** Read `docs/CORE/protocols/PROTOCOL_PD_EXTRACTION.md` FIRST.

This protocol defines:
- What patterns indicate extractable decisions
- PD template format
- Quality checklist
- Anti-patterns to avoid

### Step 1: Read Analysis File Summaries

| File | Focus |
|------|-------|
| `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` | Technical (Activity Recognition, Doze, Geofencing) |
| `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` | UX (Permission Ladder, TrustScore, Privacy Messaging) |

**Scan for these patterns:**
- "We will use X" → ✅ Extract as PD
- Threshold/config values → ✅ Extract as PD
- Sequence definitions → ✅ Extract as PD
- "Consider X" / "Future work" → ❌ Skip (not a decision)

### Step 2: Draft PDs Using Template

Each PD must have:
```markdown
| **PD-XXX** | [One-line decision] | 🔵 OPEN | [DOMAIN] | [Source RQ] |

**Rationale:** [WHY this decision]
**Source:** [Analysis file + section]
**Alternatives Rejected:** [What we chose NOT to do]
```

### Step 3: Expected PDs (~8-10)

| Topic | Source | Route To |
|-------|--------|----------|
| Permission Ladder Sequence | RQ-010cdf §1.1 | PD_UX.md |
| Activity Recognition Confidence Thresholds | RQ-010egh §1.2 | PD_JITAI.md |
| V-O Opportunity Weight Modifiers | RQ-010egh §1.3 | PD_JITAI.md |
| Doze Mode Strategy (Critical/High/Medium/Low) | RQ-010egh §1.4 | PD_JITAI.md |
| TrustScore Framework (gating mechanism) | RQ-010cdf §2 | PD_UX.md |
| Geofence Allocation Strategy | RQ-010egh §1.5 | PD_JITAI.md |
| Privacy Messaging ("Zones not coordinates") | RQ-010cdf §3 | PD_UX.md |
| Manual Mode First-Class Experience | RQ-010cdf §4 | PD_UX.md |
| PermissionGlassPane Configs (benefit + privacyNote) | RQ-010cdf §3.1 | PD_UX.md |

### Step 4: Verify and Update Indexes

- [ ] Cross-check each PD against `CD_INDEX.md` — no conflicts
- [ ] Add all PDs to `PD_INDEX.md`
- [ ] Update PD count in index header
- [ ] Mark all PDs as 🔵 OPEN (human confirms to 🟢)

---

## Quality Checklist (Per PD)

- [ ] Decision is ACTIONABLE (implementer knows exactly what to do)
- [ ] Decision is SCOPED (no ambiguous "and more")
- [ ] Decision references SOURCE (Analysis file + section)
- [ ] Decision does NOT contradict any CD
- [ ] Decision starts as 🔵 OPEN

---

## Session Completion Checklist

- [ ] All Analysis files processed
- [ ] ~8-10 PDs created with source references
- [ ] No CD conflicts detected
- [ ] PD_INDEX.md updated
- [ ] AI_HANDOVER.md updated: "PDs created, awaiting human review"
- [ ] All changes committed and pushed

---

## Do NOT

- ❌ Write any implementation code
- ❌ Copy entire Analysis sections as PDs (extract ONE decision per PD)
- ❌ Mark any PD as 🟢 CONFIRMED (human must approve)
- ❌ Create PDs for "future consideration" items
- ❌ Duplicate prose from Analysis files — PDs should REFERENCE, not repeat
