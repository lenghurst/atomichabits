# Protocol 10: Bias Analysis — RQ-035 Sensitivity Detection Framework

> **Analyzed:** 12 January 2026
> **Prompt Version:** 1.0
> **Target:** `docs/prompts/DEEP_THINK_PROMPT_SENSITIVITY_DETECTION_RQ035.md`

---

## Trigger Verification (Quick Filter)

| Criteria | Assessment | Applies? |
|----------|------------|----------|
| Affects 3+ stakeholder groups? | Users, witnesses, engineering, legal/compliance | **YES** |
| HIGH reversibility cost? | Schema changes, user-facing terminology | **YES** |
| Requires >5 implementation tasks? | ~20+ tasks expected | **YES** |
| Contested alternatives? | Multiple detection methods presented | **YES** |

**Result:** Protocol 10 REQUIRED (4/4 criteria met)

---

## Step 1: Assumption Inventory

### Assumptions in Prompt Structure

| # | Assumption | Location | Statement |
|---|------------|----------|-----------|
| A1 | Sensitivity categories are correct | Part 7 | Listed 6 categories: Addiction, Mental Health, Trauma, Eating/Body, Relationship Safety, Sexual/Identity |
| A2 | 4-tier sensitivity levels are appropriate | Schema | `normal`, `private`, `sensitive`, `crisis_risk` |
| A3 | System detection precedes user override | RQ-035.3 | "System flags → user confirms/overrides" |
| A4 | Witnesses should NOT see sensitive habits by default | RQ-035.4 | Options all assume privacy-first |
| A5 | Crisis response requires resource display | RQ-035.6 | Assumes showing hotlines is appropriate |
| A6 | App has ethical (not legal) duty of care | Part 5 | "We are NOT legally obligated... But we are ethically obligated" |
| A7 | AI can detect sensitivity via keywords/language | RQ-035.2 | Options A, B assume text analysis works |
| A8 | Users want privacy controls | Throughout | Assumes privacy is a feature, not a burden |
| A9 | Cultural sensitivity varies | RQ-035.8 | Assumes one-size-fits-all won't work |
| A10 | Sherlock conversations surface sensitive content | Part 1 | Assumes onboarding probing causes disclosure |
| A11 | Hybrid detection is optimal | RQ-035.2 Option E | Presented as "Recommended for Analysis" |
| A12 | Clinical psychology is the right SME domain | Part 2 | Expert role defined as clinical psychologist |

### Assumptions in Anti-Pattern Framing

| # | Assumption | Statement |
|---|------------|-----------|
| A13 | Over-flagging is bad | Anti-patterns list "surveillance culture" |
| A14 | Under-flagging is bad | Anti-patterns list "missing crisis indicators" |
| A15 | Keywords alone are insufficient | Option A framed as having "high false positive/negative rate" |
| A16 | Financial/legal liability is not the primary driver | Part 5 explicitly states ethical > legal |

---

## Step 2: Validity Rating

| # | Assumption | Validity | Basis |
|---|------------|----------|-------|
| A1 | 6 sensitivity categories | **MEDIUM** | Categories from common mental health apps (Headspace, Calm, BetterHelp) but not validated for habit context |
| A2 | 4-tier levels | **MEDIUM** | Common pattern, but thresholds unvalidated |
| A3 | System-first detection | **MEDIUM** | Privacy literature suggests user-first is more autonomous, but safety literature suggests system-first for risk |
| A4 | Witnesses hidden by default | **HIGH** | Aligns with privacy-by-design (GDPR), CD-010 user protection |
| A5 | Crisis resources appropriate | **HIGH** | Industry standard (Instagram, Facebook, TikTok all show hotlines) |
| A6 | Ethical not legal duty | **HIGH** | Legally accurate for non-medical apps in most jurisdictions |
| A7 | AI text detection works | **MEDIUM** | NLP has limitations; euphemisms, context, sarcasm are hard |
| A8 | Users want privacy controls | **HIGH** | Extensive UX research supports this (Pew, Nielsen Norman) |
| A9 | Cultural sensitivity varies | **HIGH** | Well-documented in cross-cultural psychology |
| A10 | Sherlock surfaces sensitive content | **MEDIUM** | Plausible but unvalidated for this specific app |
| A11 | Hybrid detection is optimal | **LOW** | Presented without evidence; may be over-engineered |
| A12 | Clinical psychology is right SME | **HIGH** | Appropriate for crisis detection and therapeutic boundaries |
| A13 | Over-flagging is bad | **MEDIUM** | True but threshold unclear |
| A14 | Under-flagging is bad | **HIGH** | Safety-critical; false negatives have real harm potential |
| A15 | Keywords insufficient | **MEDIUM** | True for nuance, but may be sufficient for MVP |
| A16 | Ethics > liability | **HIGH** | Aligns with CD-010 philosophy |

---

## Step 3: SME Domain Analysis

| Domain | Relevance | Coverage in Prompt |
|--------|-----------|-------------------|
| **Clinical Psychology** | Crisis detection, therapeutic boundaries | **STRONG** — Expert role defined |
| **Privacy Engineering** | Data protection, RLS, encryption | **STRONG** — Part 6, RQ-035.7 |
| **Content Moderation** | Detection systems, false positive/negative | **MEDIUM** — Options listed but no deep expertise |
| **Legal/Compliance** | GDPR, duty of care, liability | **MEDIUM** — Part 5 covers basics |
| **UX Design** | Override flows, witness visibility | **WEAK** — No UX expertise requested |
| **Cultural Psychology** | Cross-cultural sensitivity | **WEAK** — Mentioned but not expert domain |
| **Trauma-Informed Design** | Non-retraumatizing systems | **MEDIUM** — Listed in expertise but not detailed |

**Gap Identified:** UX Design and Cultural Psychology are under-represented in expert role.

---

## Step 4: Confidence Decision

### LOW-Validity Count

| Validity | Count | Assumptions |
|----------|-------|-------------|
| HIGH | 8 | A4, A5, A6, A8, A9, A12, A14, A16 |
| MEDIUM | 7 | A1, A2, A3, A7, A10, A13, A15 |
| LOW | 1 | A11 |

**Total:** 16 assumptions identified
**LOW-Validity Count:** 1
**LOW Percentage:** 6.25% (well below 50%)

### Decision Rule Application

| Rule | Threshold | Actual | Result |
|------|-----------|--------|--------|
| 4+ LOW assumptions | 4 | 1 | **PASS** |
| >50% LOW (min 3) | 50% | 6.25% | **PASS** |

**Decision:** PROCEED with HIGH confidence

---

## Step 5: Bias Analysis Summary

### Identified Biases

| Bias Type | Description | Impact | Mitigation |
|-----------|-------------|--------|------------|
| **Hybrid Preference** | Prompt presents hybrid detection as "recommended" before research | May anchor Deep Think toward hybrid | Added "for Analysis" qualifier; not "recommended" |
| **Western Framing** | Crisis resources (988, 741741) are US-centric | May produce US-focused recommendations | Prompt mentions "International Association for Suicide Prevention" |
| **Privacy-First** | All witness visibility options assume privacy default | May under-explore accountability benefits | RQ-035.4 explicitly asks about users who WANT to share |
| **Text-Centric** | Detection assumes text input (habit names, reflections) | May miss behavioral/contextual signals | Option D (behavioral signals) included |

### Unexamined Assumptions

1. **Detection timing:** When should detection occur? (On input? On save? Background analysis?)
2. **Notification to user:** Should users be told when their content is flagged?
3. **Human review:** Should any flags trigger human support review?
4. **Witness notification:** Should witnesses be told a habit was hidden from them?
5. **Professional integration:** Should therapists get different access than friends?

**Recommendation:** Add sub-questions for timing, notification, and professional integration in V2 if Deep Think response is sparse on these.

---

## Step 6: Final Assessment

| Metric | Value |
|--------|-------|
| **Assumptions Identified** | 16 |
| **LOW-Validity Count** | 1 |
| **Confidence Level** | HIGH |
| **Proceed/Defer** | **PROCEED** |
| **SME Gaps** | UX Design, Cultural Psychology (minor) |
| **Anchoring Risk** | LOW (hybrid option labeled "for Analysis") |

### Prompt Quality Score

| Dimension | Score | Notes |
|-----------|-------|-------|
| Self-Containment | 9/10 | Full context, terminology, schema included |
| Bias Mitigation | 8/10 | One low-validity assumption (hybrid preference) |
| SME Coverage | 7/10 | UX and cultural expertise could be stronger |
| Safety Focus | 10/10 | CD-010 compliance central throughout |
| **Overall** | **8.5/10** | Meets quality threshold |

---

## Recommendations

1. **Proceed with V1 prompt** — Bias analysis shows acceptable risk
2. **Monitor hybrid preference** — Check if Deep Think over-indexes on hybrid detection
3. **Supplement UX expertise** — Consider UX-focused follow-up if response lacks usability depth
4. **Add timing sub-question** — Detection timing is a gap worth addressing

---

*Protocol 10 Complete — RQ-035 Cleared for Deep Think Submission*
