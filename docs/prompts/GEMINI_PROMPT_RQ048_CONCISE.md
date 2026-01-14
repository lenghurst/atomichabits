# Gemini Prompt: RQ-048 Schema Validation (Concise)

> **For:** Gemini 2.0 Flash / Deep Think
> **Task:** Validate 3 schema parameters for identity-based habit app

---

## Context (60 seconds)

**App:** The Pact — identity-based habit tracker (Flutter/Android)
**Model:** Users have multiple "identity facets" (e.g., "The Writer", "The Athlete") with 4 energy states (high_focus, high_physical, social, recovery)

**Problem:** Three schema defaults were set without research citations:

| Parameter | Current Value | Confidence |
|-----------|---------------|------------|
| Domain ENUM | 4 types (professional, physical, relational, temporal) | LOW |
| Active facet cap | 10 (soft limit 5 in UI) | LOW |
| Switching cost default | 30 minutes | MEDIUM ✅ (now validated) |

---

## Questions

### Q1: Domain Taxonomy (RQ-048a)

**What identity domain categories appear in psychology literature?**

Cite: Markus & Nurius (Possible Selves), Oyserman (Identity-Based Motivation), or similar.

**Deliverable:** Recommended ENUM list (4-7 domains) with rationale for each.

### Q2: Facet Capacity (RQ-048b)

**What's the cognitive limit for managing multiple identity goals?**

Consider: Working memory (Cowan's 4), goal management (Locke & Latham), identity integration research.

**Deliverable:**
- Soft limit (UI display): ___
- Hard cap (database): ___
- With citation support

---

## Constraints

- PostgreSQL ENUM types
- Android-first (no wearables)
- Users should NOT manually configure complex values

---

## Output Format

```
### Domain Taxonomy
Recommended: [list]
Rationale: [1-2 sentences per domain]
Confidence: HIGH/MEDIUM/LOW

### Facet Limits
Soft limit: X (cite)
Hard cap: Y (cite)
Confidence: HIGH/MEDIUM/LOW
```

---

*~500 words. Focus on citations over explanation.*
