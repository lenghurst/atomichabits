# Protocol: PD Extraction from Analysis Files

> **Purpose:** Convert Analysis file findings into actionable Product Decisions
> **When to Use:** After Protocol 9 reconciliation, before implementation
> **Output:** PDs in `PD_INDEX.md` + relevant `PD_*.md` file

---

## Why This Protocol Exists

| Without PDs | With PDs |
|-------------|----------|
| AI decides what to build | Human confirms what to build |
| Scope creep (nice-to-have becomes mandatory) | Scoped to WILL build only |
| "Where's the decision?" — buried in 300 lines | Single source in PD_INDEX.md |
| Cross-agent divergence | Single authoritative reference |

---

## Step 1: Identify Extractable Decisions

For each Analysis file, scan for:

| Pattern | Example | Likely PD? |
|---------|---------|------------|
| "We will use X" | "We will use Transition API (push-based)" | ✅ YES |
| "The approach is Y" | "Frustration-driven permission strategy" | ✅ YES |
| Threshold/config values | "TrustScore > 60 required" | ✅ YES |
| Sequence/order definitions | "Permission Ladder: Notifications → Activity → Location" | ✅ YES |
| "Consider X" / "Could use Y" | "Could add A/B testing" | ❌ NO (research, not decision) |
| "Future work" / "Nice to have" | "Future: cross-device sync" | ❌ NO (out of scope) |

---

## Step 2: Draft PD Using Template

```markdown
| **PD-XXX** | [One-line decision statement] | 🔵 OPEN | [DOMAIN] | [Source RQ] |

**Rationale:** [1-2 sentences WHY this decision]
**Source:** [Analysis file path + section number]
**Alternatives Rejected:** [What we chose NOT to do]
```

### PD Quality Checklist

- [ ] Decision is ACTIONABLE (implementer knows what to do)
- [ ] Decision is SCOPED (no ambiguous "and more")
- [ ] Decision references SOURCE (Analysis file + section)
- [ ] Decision does NOT contradict any CD (check CD_INDEX.md)
- [ ] Decision starts as 🔵 OPEN (human confirms to 🟢)

---

## Step 3: Verify Against Locked Decisions

Before finalizing, cross-check:

| Check | Source | Action if Conflict |
|-------|--------|-------------------|
| Core Decisions (CDs) | `index/CD_INDEX.md` | PD MUST align or be rejected |
| Existing PDs | `index/PD_INDEX.md` | Flag contradiction, escalate |
| CD-018 Threshold | ESSENTIAL/VALUABLE/NICE-TO-HAVE | Tag PD with tier |

---

## Step 4: Categorize and Route

Use MANIFEST.md routing:

| Domain | Target File |
|--------|-------------|
| Permission UX, Onboarding | `PD_UX.md` |
| Activity Recognition, Geofencing, JITAI | `PD_JITAI.md` |
| Witness Intelligence | `PD_WITNESS.md` |
| Identity, Archetypes | `PD_IDENTITY.md` |
| Core/Foundational | `PD_CORE.md` |

---

## Step 5: Update Indexes

1. Add PD row to `PD_INDEX.md`
2. Update PD count in index header
3. Add dependency link if PD depends on another PD/RQ

---

## Example: Extracting PD from Analysis File

**Source:** `DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §1.1

**Analysis Text:**
> "The Permission Ladder sequence: Notifications → Activity Recognition → Fine Location → Background Location → Calendar"

**Extracted PD:**

| **PD-150** | Permission requests follow ladder sequence: Notifications → Activity → Fine Location → Background Location → Calendar | 🔵 OPEN | UX | RQ-010d |

**Rationale:** Frustration-driven approach lets users feel manual friction before offering automation upgrades.
**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md` §1.1
**Alternatives Rejected:** All-at-once permission request (current anti-pattern in `permissions_screen.dart`)

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It's Wrong | Correct Approach |
|--------------|----------------|------------------|
| Copy entire Analysis section as PD | PDs should be single decisions, not prose | Extract ONE decision per PD |
| Mark PD as 🟢 CONFIRMED without human review | Violates approval gate | Always start 🔵 OPEN |
| Create PD for "future consideration" | PDs are for what we WILL build | Leave as RQ or skip |
| Create PD without source reference | Unverifiable | Always cite Analysis file + section |

---

## Completion Checklist

After extraction session:

- [ ] All Analysis files processed
- [ ] Each PD has source reference
- [ ] No CD conflicts detected
- [ ] PD_INDEX.md updated with new count
- [ ] All PDs marked 🔵 OPEN for human review
- [ ] AI_HANDOVER.md updated with "PDs awaiting review"
