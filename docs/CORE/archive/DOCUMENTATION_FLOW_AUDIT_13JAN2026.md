# Documentation Flow Audit — Direction of Travel

> **Purpose:** Map current navigation flow against best practices, identify gaps, ensure alignment to end goal
> **Date:** 13 January 2026
> **End Goal:** Efficient AI agent onboarding with zero context loss, no duplicate work, minimal token usage

---

## Current Flow vs Best Practice

### The Journey: Entry → Task → Exit

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     CURRENT DOCUMENTATION FLOW                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ENTRY PHASE                                                                │
│  ───────────────────────────────────────────────────────────────────────── │
│  Step 0: git status/log         → Detect stuck sessions        ✅ GOOD     │
│  Step 1: AI_HANDOVER.md         → Session context (142 lines)  ✅ FIXED    │
│  Step 2: MANIFEST.md            → Domain routing               ✅ GOOD     │
│                                                                             │
│  CONTEXT LOADING PHASE                                                      │
│  ───────────────────────────────────────────────────────────────────────── │
│  Step 3: PD_CORE.md             → Core decisions               ✅ GOOD     │
│  Step 4: Domain PD_*.md         → Per-task context             ✅ GOOD     │
│  Step 5: index/*.md             → Status lookups               ✅ GOOD     │
│  Step 6: IMPLEMENTATION_ACTIONS → Blocked tasks                ✅ GOOD     │
│  Step 7: Reality check          → Schema verification          ✅ GOOD     │
│                                                                             │
│  TASK EXECUTION PHASE                                                       │
│  ───────────────────────────────────────────────────────────────────────── │
│  [Task-specific loading]        → Unclear guidance             ⚠️ GAP      │
│  [Large file handling]          → Added, but no frontmatter    ⚠️ GAP      │
│  [Cross-domain tasks]           → Listed but no automation     ⚠️ GAP      │
│                                                                             │
│  EXIT PHASE                                                                 │
│  ───────────────────────────────────────────────────────────────────────── │
│  Update AI_HANDOVER.md          → Session summary              ✅ GOOD     │
│  Tier 3 verification            → Cross-file consistency       ✅ GOOD     │
│  Commit/push                    → Git workflow                 ✅ GOOD     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Best Practice Comparison

### Pattern 1: Three-Tier Progressive Disclosure

**Best Practice (Anthropic Agent Skills):**
| Tier | Content | Load Timing |
|------|---------|-------------|
| Level 1 | Metadata (name, summary, triggers) | At startup |
| Level 2 | Core instructions | On first use |
| Level 3 | Supplements, examples | On specific scenarios |

**Current State:**
| Tier | Current Implementation | Gap |
|------|------------------------|-----|
| Level 1 | MANIFEST.md has routing tables | ⚠️ No machine-readable frontmatter |
| Level 2 | PD_*.md domain files | ✅ Working |
| Level 3 | Large files (GLOSSARY, RQ) | ⚠️ No clear supplement markers |

**Gap:** MANIFEST.md routes to files but doesn't provide:
- Token estimates per file
- Machine-readable triggers
- Load priority ordering

---

### Pattern 2: Context Engineering (Google ADK Handle Pattern)

**Best Practice:**
- Large docs live in artifact store, not prompt
- Agents see lightweight references (name + summary)
- Fetch raw content only when needed

**Current State:**
- ✅ Index files provide lightweight status
- ⚠️ No token estimates in file headers
- ⚠️ No "on-demand fetch" pattern formalized

**Gap:** Files don't declare their token cost upfront.

---

### Pattern 3: Self-Contained Documentation

**Best Practice (LLM-Friendly Docs):**
- Each page stands alone
- All relevant background included
- Cross-references explicit
- Consistent terminology

**Current State:**
| Requirement | Status | Evidence |
|-------------|--------|----------|
| Self-contained pages | ⚠️ PARTIAL | Some files assume prior context |
| Explicit cross-refs | ✅ GOOD | "See MANIFEST.md" patterns |
| Consistent terminology | ⚠️ PARTIAL | GLOSSARY exists but not enforced |
| Heading hierarchy | ✅ GOOD | H1 → H2 → H3 maintained |

**Gap:** No automated terminology enforcement (synonyms slip through).

---

### Pattern 4: Metadata Registry with Dependencies

**Best Practice:**
```yaml
decision_id: CD-015
depends_on: [CD-012, CD-013]
triggers: ["energy", "state"]
token_estimate: 450
```

**Current State:**
- MANIFEST.md has domain → PD mapping
- Cross-cutting decisions section exists
- ⚠️ No YAML frontmatter
- ⚠️ No dependency graph
- ⚠️ No trigger keywords

**Gap:** Relationships are documented in prose, not machine-readable format.

---

## Identified Gaps

### Gap 1: No Frontmatter Metadata (HIGH)

**Problem:** Files don't declare token cost, dependencies, or triggers.

**Impact:** Agents can't budget context or auto-load related files.

**Fix:**
```yaml
---
id: PD_IDENTITY
token_estimate: 5500
depends_on: [PD_CORE]
triggers: ["identity", "archetype", "facet", "sherlock"]
priority: 2
---
```

---

### Gap 2: No Context Map (MEDIUM)

**Problem:** Dependencies are scattered across MANIFEST.md and IMPACT_ANALYSIS.md.

**Impact:** Cross-domain tasks require manual discovery of related files.

**Fix:** Create `docs/CORE/CONTEXT_MAP.md`:
```markdown
## Decision Dependencies
CD-015 → requires [CD-012, CD-013]
PD-134 → affects [PD_WITNESS, PD_JITAI]

## Keyword Triggers
"witness" → load [PD_WITNESS.md, CD-002]
"energy" → load [CD-015, PD_JITAI.md]
"treaty" → load [RQ-020, RQ-021, PD-115]
```

---

### Gap 3: Large Files Lack Pagination Markers (MEDIUM)

**Problem:** RESEARCH_QUESTIONS.md (4298 lines) has no internal navigation aids.

**Impact:** Agents searching for specific RQ must grep, not navigate.

**Fix:** Add section markers every 500 lines:
```markdown
<!-- SECTION: RQ-001 to RQ-010 | Lines 1-500 | Token estimate: 8k -->
...
<!-- SECTION: RQ-011 to RQ-020 | Lines 501-1000 | Token estimate: 8k -->
```

---

### Gap 4: No Sub-Agent Architecture Formalization (LOW)

**Problem:** MANIFEST.md hints at domain specialization but no AGENTS.md per domain.

**Impact:** Future multi-agent orchestration has no specification.

**Fix:** Create domain-specific agent capabilities:
```markdown
# docs/CORE/agents/IDENTITY_AGENT.md
## Capabilities
- Archetype analysis
- Sherlock prompt optimization
- Dimension scoring

## Required Context
- PD_CORE.md (always)
- PD_IDENTITY.md (always)
- GLOSSARY.md (search: "facet", "archetype", "dimension")
```

---

### Gap 5: Terminology Drift Detection (LOW)

**Problem:** No automated check for synonym usage.

**Impact:** "energy state" vs "energy level" creates LLM confusion.

**Fix:** Add TERMINOLOGY_ENFORCEMENT.md:
```markdown
## Canonical Terms
| Canonical | Forbidden Synonyms |
|-----------|-------------------|
| energy_state | energy level, energy mode |
| identity_facet | identity aspect, persona |
| treaty | agreement, pact, contract |
```

---

## Flow Optimization Recommendations

### Immediate (This Session)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 1 | Add token estimates to MANIFEST.md | HIGH | 15 min |
| 2 | Add triggers/dependencies to MANIFEST.md | HIGH | 20 min |
| 3 | Create CONTEXT_MAP.md | MEDIUM | 15 min |

### Short-Term (This Week)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 4 | Add YAML frontmatter to PD_*.md files | HIGH | 30 min |
| 5 | Add section markers to RESEARCH_QUESTIONS.md | MEDIUM | 20 min |
| 6 | Create TERMINOLOGY_ENFORCEMENT.md | LOW | 15 min |

### Medium-Term (Future)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 7 | Create agents/*.md per domain | LOW | 1 hour |
| 8 | Implement llms.txt convention | LOW | 30 min |
| 9 | Add GitHub Action for terminology lint | LOW | 2 hours |

---

## Updated Optimal Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     RECOMMENDED DOCUMENTATION FLOW                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TIER 1: METADATA (Always load, <5k tokens total)                           │
│  ───────────────────────────────────────────────────────────────────────── │
│  • git status/log           → Stuck session detection                       │
│  • CLAUDE.md                → Entry point, constraints (74 lines)           │
│  • AI_HANDOVER.md           → Session context (142 lines)                   │
│  • MANIFEST.md              → File index with token estimates               │
│  • index/RQ_INDEX.md        → Research status (228 lines)                   │
│  • index/PD_INDEX.md        → Decision status (170 lines)                   │
│                                                                             │
│  TIER 2: CORE CONTEXT (Load per task, <15k tokens)                          │
│  ───────────────────────────────────────────────────────────────────────── │
│  • PD_CORE.md               → Always load (5k tokens)                       │
│  • Domain PD_*.md           → Per MANIFEST.md triggers (3-6k each)          │
│  • IMPLEMENTATION_ACTIONS   → Lines 1-50 only (blocked tasks)               │
│                                                                             │
│  TIER 3: SUPPLEMENTS (On-demand, use search not full-read)                  │
│  ───────────────────────────────────────────────────────────────────────── │
│  • RESEARCH_QUESTIONS.md    → Search by RQ-XXX                              │
│  • PRODUCT_DECISIONS.md     → Use domain files instead                      │
│  • GLOSSARY.md              → Search by term                                │
│  • AI_AGENT_PROTOCOL.md     → Search by Protocol X                          │
│                                                                             │
│  EXIT PROTOCOL                                                              │
│  ───────────────────────────────────────────────────────────────────────── │
│  • Update AI_HANDOVER.md    → What was done, what remains                   │
│  • Tier 3 verification      → Cross-file consistency                        │
│  • Commit/push              → Descriptive message                           │
│                                                                             │
│  TOTAL BUDGET: <20k tokens for Tier 1+2 (fits in any context window)        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Alignment to End Goal

| End Goal | Current State | After Fixes |
|----------|---------------|-------------|
| Zero context loss | ✅ AI_HANDOVER.md restructured | ✅ Maintained |
| No duplicate work | ✅ git state check added | ✅ Maintained |
| Minimal token usage | ⚠️ No token budgeting | ✅ Token estimates in MANIFEST |
| Fast onboarding | ⚠️ 7-step process | ✅ 3-tier reduces to essentials |
| Cross-domain awareness | ⚠️ Manual discovery | ✅ CONTEXT_MAP automates |
| Terminology consistency | ⚠️ GLOSSARY exists | ✅ Enforcement added |

---

## Next Steps

Proceed with Gap 1-3 fixes (immediate)?

- [ ] Add token estimates to MANIFEST.md
- [ ] Add trigger keywords to MANIFEST.md
- [ ] Create CONTEXT_MAP.md

---

*Audit complete. Flow is 80% optimized; remaining 20% is metadata enrichment.*
