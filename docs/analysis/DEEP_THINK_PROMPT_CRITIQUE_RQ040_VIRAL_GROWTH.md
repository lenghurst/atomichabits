# Deep Think Prompt Critique: RQ-040 Viral Witness Growth Strategy

> **Purpose:** Rigorous gap analysis against DEEP_THINK_PROMPT_GUIDANCE.md quality framework
> **Target Prompt:** `docs/prompts/DEEP_THINK_PROMPT_VIRAL_WITNESS_GROWTH_RQ040.md`
> **Date:** 11 January 2026
> **Reviewer:** Claude (Opus 4.5)
> **Method:** Line-by-line comparison against mandatory framework requirements + Protocol 10 Bias Analysis

---

## Part 1: Framework Requirements Audit

### 1. Rich Context (MANDATORY)

| Requirement | Present | Gap Analysis |
|-------------|---------|--------------|
| **Prior Research Summary** | ⚠️ PARTIAL | Lists User Journey Map, RQ-021, RQ-037 but MISSING: RQ-001 (6-dimension model relevant for witness persona matching), RQ-005/6/7 (recommendation algorithms could apply to witness-to-creator conversion), RQ-012 (Fractal Trinity - witness sees different facets?) |
| **Locked Decisions** | ✅ | CD-002, CD-010, CD-015, CD-017, CD-018 all included with implications |
| **Schema Examples** | ✅ | Proposed `witness_relationships` and `witness_events` tables with SQL |
| **Current State** | ✅ | Clear current K-factor (0.24), current invitation rate (42%), conversion rate (22%) |

**Critical Gap #1:** Missing prior RQ summaries that directly inform witness mechanics:
- **RQ-001 (6-Dimension Model):** How do dimensions affect witness selection? Should users invite witnesses who share their archetype or complement it?
- **RQ-005 (Proactive Recommendations):** The "Architect" recommendation engine could recommend WHO to invite as witnesses
- **RQ-012 (Fractal Trinity):** Do witnesses see the same facets as the creator? Privacy implications?

### 2. Structured Sub-Questions (MANDATORY)

| Requirement | Present | Gap Analysis |
|-------------|---------|--------------|
| **Tabular Format** | ✅ | All 7 sub-RQs use table format |
| **Explicit Numbering** | ✅ | a1-a7, b1-b7, etc. clearly numbered |
| **Task Clarity** | ✅ | "Your Task" column with specific actions |
| **Tradeoff Framing (⚖️)** | ⚠️ PARTIAL | Some questions have ⚖️ markers but NOT ENOUGH — see below |

**Critical Gap #2:** Insufficient tradeoff framing. The following questions should be reframed as explicit tradeoffs:

| Current Question | Should Be Tradeoff |
|------------------|-------------------|
| a1: "What do witnesses ACTUALLY want?" | ⚖️ "Witness value (engagement) vs creator privacy (data exposure) — where's the balance?" |
| b1: "Optimal primary invitation channel by geography" | ⚖️ "Reach (SMS) vs rich content (WhatsApp/email) vs conversion rate — prioritize which?" |
| c1: "Top 5 conversion triggers by effectiveness" | ⚖️ "Conversion pressure (higher K) vs relationship preservation (user trust) — how aggressive?" |
| e3: "What K target should we set?" | Already has ⚖️ ✅ |
| f3: "Should we have a 'witness-only' mode?" | Already has ⚖️ ✅ |

**Only 6 of ~45 sub-questions have explicit tradeoff markers. Target: 15+ should have ⚖️.**

### 3. Constraints Section (MANDATORY)

| Requirement | Present | Gap Analysis |
|-------------|---------|--------------|
| **Technical Constraints** | ✅ | Android-first, Supabase, attribution tracking |
| **UX Constraints** | ✅ | Optional witnesses (CD-002), no dark patterns (CD-010) |
| **Resource Constraints QUANTIFIED** | ❌ MISSING | **NO QUANTIFIED RESOURCE CONSTRAINTS** |
| **Anti-Patterns section** | ✅ | 5+ anti-patterns per sub-RQ |

**Critical Gap #3:** Missing quantified resource constraints:

| Missing Constraint | Should Be |
|-------------------|-----------|
| **Notification budget** | "Target: < 5 notifications/week to witnesses to avoid fatigue" |
| **Invitation friction time** | "Target: < 30 seconds to complete invitation flow" |
| **Witness onboarding time** | "Target: < 60 seconds from link click to seeing creator's journey" |
| **Engineering effort budget** | "Target: < 3 weeks engineering for MVP viral loop" |
| **K-factor measurement latency** | "Target: K must be calculable within 7-day cohort windows" |

### 4. Output Format Specification (MANDATORY)

| Requirement | Present | Gap Analysis |
|-------------|---------|--------------|
| **Markdown Structure** | ✅ | 9 deliverables clearly specified |
| **Code Expectations** | ✅ | Dart pseudocode requested throughout |
| **Confidence Levels** | ✅ | Confidence assessment template at end |
| **Deliverables List** | ✅ | Numbered deliverables per sub-RQ |

**Minor Gap:** Could add SQL output expectations for analytics queries (K-factor calculation queries, cohort analysis queries).

### 5. Weaknesses to Avoid (From Guidance)

| Anti-Pattern | Status | Notes |
|--------------|--------|-------|
| No Expert Role | ✅ AVOIDED | "Senior Growth Architect & Viral Loop Designer" |
| Missing Think-Chain | ✅ AVOIDED | "Think through this as a systems design problem" |
| No Priority Sequence | ✅ AVOIDED | Clear RQ-040a → RQ-040b → ... processing order |
| No Examples | ✅ AVOIDED | "Invitation Message A/B Test" example included |
| No Anti-Patterns | ✅ AVOIDED | 5+ anti-patterns per sub-RQ |
| No Confidence Levels | ✅ AVOIDED | Template at end |
| **Single Solution** | ⚠️ PARTIALLY VIOLATED | Some sub-questions request options (e.g., economy models) but MOST ask for "top 5" or "optimal" without requiring alternatives |
| Weak Interdependencies | ✅ AVOIDED | ASCII dependency diagram included |
| No User Scenarios | ✅ AVOIDED | "Maya/Marcus" end-to-end scenario |
| No Literature Guidance | ⚠️ PARTIAL | Industry references (Strava, Duolingo) but no ACADEMIC literature |
| No Validation Checklist | ✅ AVOIDED | 16-item final checklist |

**Critical Gap #4:** Insufficient multi-option requests. The guidance says "Present 2-3 options with tradeoffs, then recommend" but most questions ask for single answers.

**Affected Questions:**
- a1: Should request 3 witness value prop models
- a4: Should request 3 witness interaction models (passive/reactive/active)
- b2: Should request 3+ invitation message variants (already does ✅)
- c1: Should request 3 conversion trigger strategies, not just "top 5"
- d1: Should request 3 witness count strategies (1 vs 2 vs 3+) — partially does
- e2: Should request 3 K-improvement strategies with ROI analysis

**Critical Gap #5:** No academic/research literature guidance. Industry comparisons (Strava, Duolingo) are good but should also include:
- Viral coefficient research (Kang et al., 2009 — viral loops in social networks)
- Social accountability research (Latane & Darley — bystander effect implications for multi-witness)
- Habit formation research (Lally et al., 2010 — 66-day automaticity and witness role)
- Self-Determination Theory (Deci & Ryan) — witness as autonomy support vs control

---

## Part 2: Checklist Scoring (From DEEP_THINK_PROMPT_GUIDANCE.md)

### Context Verification

| Item | Present | Score |
|------|---------|-------|
| All relevant completed RQs summarized | ⚠️ Partial | 0.5/1 |
| All constraining CDs listed | ✅ | 1/1 |
| Existing schemas/code included | ✅ | 1/1 |
| Current state vs desired state clear | ✅ | 1/1 |
| **Context Subtotal** | | **3.5/4** |

### Structure Verification

| Item | Present | Score |
|------|---------|-------|
| Expert role defined | ✅ | 1/1 |
| Processing order specified | ✅ | 1/1 |
| Sub-questions in tabular format | ✅ | 1/1 |
| Each sub-question has explicit task | ✅ | 1/1 |
| **Structure Subtotal** | | **4/4** |

### Constraints Verification

| Item | Present | Score |
|------|---------|-------|
| Technical constraints listed | ✅ | 1/1 |
| UX constraints listed | ✅ | 1/1 |
| Resource constraints QUANTIFIED | ❌ Missing | 0/1 |
| Anti-patterns section included | ✅ | 1/1 |
| **Constraints Subtotal** | | **3/4** |

### Output Verification

| Item | Present | Score |
|------|---------|-------|
| Markdown structure specified | ✅ | 1/1 |
| Deliverables numbered | ✅ | 1/1 |
| Confidence levels requested | ✅ | 1/1 |
| Example of good output included | ✅ | 1/1 |
| **Output Subtotal** | | **4/4** |

### Validation Verification

| Item | Present | Score |
|------|---------|-------|
| Final checklist included | ✅ | 1/1 |
| Quality criteria table included | ✅ | 1/1 |
| Integration points explicit | ⚠️ Partial | 0.5/1 |
| **Validation Subtotal** | | **2.5/3** |

### Additional Quality Factors

| Factor | Present | Score |
|--------|---------|-------|
| User Scenarios | ✅ Maya/Marcus journey | 1/1 |
| Literature Guidance | ⚠️ Industry only, no academic | 0.5/1 |
| Concrete Scenario | ✅ Day-by-day walkthrough | 1/1 |
| Current Schema Reference | ✅ Proposed witness_relationships | 1/1 |
| Anti-Patterns Specific | ✅ Per sub-RQ | 1/1 |
| Industry Comparison | ✅ 7 companies analyzed | 1/1 |
| Multi-Option Requests | ⚠️ Partial (only some questions) | 0.5/1 |
| Tradeoff Framing | ⚠️ Partial (only 6 of ~45 questions) | 0.5/1 |
| **Additional Subtotal** | | **6.5/8** |

### Total Score

| Category | Score | Max |
|----------|-------|-----|
| Context | 3.5 | 4 |
| Structure | 4 | 4 |
| Constraints | 3 | 4 |
| Output | 4 | 4 |
| Validation | 2.5 | 3 |
| Additional | 6.5 | 8 |
| **TOTAL** | **23.5** | **27** |

### **Score: 8.7/10**

---

## Part 3: Protocol 10 — Bias Analysis

Since this prompt makes strategic recommendations about growth strategy, Protocol 10 (Bias Analysis) must be applied.

### Identified Biases in Prompt Construction

| # | Bias | Description | Validity | Risk |
|---|------|-------------|----------|------|
| **B1** | Pro-Viral Assumption | Assumes K > 1 is achievable and desirable | MEDIUM | K > 1 may not be sustainable without spam-like behavior |
| **B2** | Witness-Positive Framing | Assumes witnesses WANT to be engaged | LOW | Many witnesses may prefer minimal interaction |
| **B3** | Network Effect Optimism | Assumes network effects will be positive | MEDIUM | Network effects can also be negative (witness fatigue at scale) |
| **B4** | Conversion-First Bias | Prioritizes witness-to-creator conversion over witness experience | HIGH | May damage witness experience if conversion is over-optimized |
| **B5** | Tech-Solutionism | Assumes technical optimizations (channels, triggers) drive growth | MEDIUM | Product-market fit and word-of-mouth may matter more |
| **B6** | Single Funnel Assumption | Treats all witnesses as potential creators | LOW | Some witnesses may never convert and that's OK |
| **B7** | Measurability Bias | Focuses on measurable K-factor over qualitative relationship quality | HIGH | K-factor is gameable; relationship quality is not |
| **B8** | Short-Term Optimization | Focus on 90-day simulations may miss long-term dynamics | MEDIUM | Viral mechanics can burn out; sustainable growth is different |

### Bias Validity Assessment

| Bias | Validity Post-Analysis | Action |
|------|------------------------|--------|
| B1 (Pro-Viral) | 40% — K > 1 is rare and may require aggressive tactics | Add question: "What if K > 1 is not achievable ethically? What's the fallback?" |
| B2 (Witness-Positive) | 60% — Some witnesses genuinely want to help | Add question: "What % of witnesses are passive vs active? Design for both." |
| B3 (Network Effect Optimism) | 50% — Network effects can go either way | Add question: "What are the negative network effects and how do we prevent them?" |
| B4 (Conversion-First) | 30% — Overweighted in current prompt | **REBALANCE:** Add equal focus on witness experience metrics |
| B5 (Tech-Solutionism) | 40% — Channels matter but product quality matters more | Add question: "What product improvements would drive more invitations organically?" |
| B6 (Single Funnel) | 70% — Valid to have non-converting witnesses | Already addressed in RQ-040f |
| B7 (Measurability) | 30% — Overweighted | **ADD:** "How do we measure relationship quality, not just conversion?" |
| B8 (Short-Term) | 50% — 90 days is short for habit apps | Add question: "What's the 1-year viral loop projection? What changes?" |

### Biases Requiring Prompt Revision

| Priority | Bias | Fix |
|----------|------|-----|
| **HIGH** | B4 (Conversion-First) | Add witness experience KPIs that are NOT conversion: satisfaction, continued engagement, relationship quality |
| **HIGH** | B7 (Measurability) | Add qualitative metrics: witness NPS, creator feedback on witness helpfulness |
| **MEDIUM** | B1 (Pro-Viral) | Add contingency question: "If K cannot exceed 0.5 ethically, what's the alternative growth strategy?" |
| **MEDIUM** | B8 (Short-Term) | Extend simulation to 12 months; ask about sustainability |

---

## Part 4: Prompt-Specific Deep Gaps

### Gap 1: Missing "What If Viral Fails" Contingency

The entire prompt assumes viral growth is the strategy. But what if:
- K cannot exceed 0.5 without spam-like behavior?
- Witnesses churn faster than they convert?
- Network effects are negative (witness fatigue)?

**Fix:** Add contingency section:
```markdown
### Contingency: Non-Viral Growth
If ethical constraints (CD-010) prevent K > 0.5:
1. What's the alternative growth strategy?
2. What witness features still have value without viral growth?
3. What retention improvements could offset lower acquisition?
```

### Gap 2: Missing Witness Experience Metrics (Non-Conversion)

Current prompt focuses heavily on conversion metrics but not witness satisfaction independent of conversion.

**Missing Metrics:**
- Witness satisfaction score (survey)
- Witness engagement duration before churn
- Witness helpfulness rating (from creator)
- Witness relationship deepening (do they talk more?)

**Fix:** Add to RQ-040f:
```markdown
### Witness Success Metrics (Independent of Conversion)
| Metric | Definition | Target |
|--------|------------|--------|
| Witness Satisfaction | Survey score | > 4.0/5.0 |
| Engagement Duration | Days before churn | > 30 days |
| Helpfulness Rating | Creator rates witness | > 4.0/5.0 |
| Relationship Impact | Self-reported closeness | Increase |
```

### Gap 3: Missing Privacy Implications

Witnesses see creator's habit data. What are the privacy boundaries?

**Missing Questions:**
- What data can witnesses see by default?
- What data can creators hide from witnesses?
- Can witnesses see other witnesses?
- What happens to witness data if relationship ends?
- GDPR/CCPA implications for witness data

**Fix:** Add sub-question to RQ-040a:
```markdown
| a8 | What are the privacy boundaries for witness data access? | Define default visibility, creator controls, and data deletion rights. GDPR/CCPA compliance required. |
```

### Gap 4: Missing Negative Network Effects Analysis

Prompt assumes network effects are positive. But:
- Witness fatigue at scale (too many notifications)
- Witness overlap (User A and User B both invite User C)
- Accountability pressure causing relationship strain
- Viral mechanics feeling "spammy"

**Fix:** Add to RQ-040d:
```markdown
### Negative Network Effects to Prevent
| Effect | Risk | Prevention |
|--------|------|------------|
| Witness Fatigue | Overloaded with notifications from multiple creators | Notification aggregation, opt-out |
| Witness Overlap | Same person invited by multiple creators | Soft cap on witnessing relationships |
| Relationship Strain | Accountability pressure damages friendship | "Pause" and "Mute" controls for witnesses |
| Spam Perception | Too many invitations feels MLM-like | Invitation rate limits, organic-first messaging |
```

### Gap 5: Missing Creator Perspective on Witness Selection

Prompt focuses on witness experience but not creator decision-making:
- How do creators CHOOSE who to invite?
- What hesitations prevent invitation?
- Should the app recommend witnesses?

**Fix:** Add sub-questions:
```markdown
| b8 | What hesitations prevent creators from inviting witnesses? | Research barriers: fear of judgment, relationship risk, not wanting to "bother" people. |
| b9 | Should the app recommend specific contacts as witnesses? | Analyze: ML-based suggestions vs user choice. Privacy and autonomy tradeoffs. |
```

---

## Part 5: Critical Gaps Summary

| # | Gap | Impact | Fix Required |
|---|-----|--------|--------------|
| **1** | Missing prior RQ summaries (RQ-001, RQ-005/6/7, RQ-012) | Model can't reason about existing psyOS architecture | Add "Prior Research: Completed RQs" section |
| **2** | Insufficient tradeoff framing (6 of ~45 questions) | Gets binary answers instead of nuanced analysis | Add ⚖️ markers to 15+ questions |
| **3** | No quantified resource constraints | Can't make cost-aware recommendations | Add notification budget, friction time, engineering effort |
| **4** | Insufficient multi-option requests | Gets single solutions instead of tradeoff analysis | Request 2-3 options for each major question |
| **5** | No academic literature guidance | Missing behavioral science grounding | Add Kang et al., Lally et al., Deci & Ryan citations |
| **6** | Missing "viral fails" contingency | No fallback strategy | Add contingency section |
| **7** | Missing witness experience metrics (non-conversion) | Over-optimizes for conversion | Add satisfaction, helpfulness, relationship metrics |
| **8** | Missing privacy implications | Data governance gap | Add privacy sub-question |
| **9** | Missing negative network effects | Assumes positive effects only | Add negative effects analysis |
| **10** | Missing creator perspective on witness selection | One-sided witness focus | Add creator decision-making questions |

---

## Part 6: Score Before vs After Fixes

| Metric | Current | After Fixes |
|--------|---------|-------------|
| **Overall Score** | 8.7/10 | 9.4/10 (projected) |
| **Prior RQ Context** | Partial | Complete |
| **Tradeoff Framing** | 6/45 (13%) | 18/45 (40%) |
| **Resource Constraints** | Missing | Quantified |
| **Multi-Option Requests** | Partial | Systematic |
| **Literature** | Industry only | Industry + Academic |
| **Bias Mitigation** | None | Protocol 10 applied |

---

## Part 7: Recommendations

### Immediate Fixes (Before Sending to Deep Think)

1. **Add Prior RQ Summaries:**
   - RQ-001: How 6-dimension model affects witness matching
   - RQ-005/6/7: Can recommendation engine suggest witnesses?
   - RQ-012: Facet visibility to witnesses

2. **Add Quantified Resource Constraints:**
   - Notification budget: < 5/week
   - Invitation friction: < 30 seconds
   - Witness onboarding: < 60 seconds
   - Engineering effort: < 3 weeks MVP

3. **Add Tradeoff Markers (⚖️) to:**
   - a1, a4 (witness value vs creator privacy)
   - b1, c1 (reach vs conversion vs trust)
   - e2 (K-improvement ROI)

4. **Add Contingency Section:**
   - "If K cannot exceed 0.5 ethically..."

5. **Add Privacy Sub-Question (a8):**
   - Data visibility defaults
   - Creator controls
   - GDPR/CCPA compliance

6. **Add Negative Network Effects Analysis to d7**

7. **Add Creator Perspective Questions (b8, b9):**
   - Invitation hesitations
   - App-recommended witnesses

8. **Add Academic Literature:**
   - Viral coefficient research
   - Social accountability research
   - Self-Determination Theory

### Optional Enhancements

- Add 12-month simulation request (not just 90 days)
- Add witness NPS survey design
- Add A/B test framework for invitation messages
- Add cohort analysis SQL queries

---

## Conclusion

**Current Score: 8.7/10** — MEETS the 8.5/10 quality threshold but has significant gaps.

**Key Weaknesses:**
1. Missing prior RQ context (affects reasoning quality)
2. Insufficient tradeoff framing (affects analysis depth)
3. No resource constraints (affects feasibility assessment)
4. Conversion-first bias (affects witness experience)
5. No contingency for viral failure (affects strategic completeness)

**Verdict:** Prompt is usable but should be revised before sending to Deep Think for optimal output quality.

---

*Critique completed following DEEP_THINK_PROMPT_GUIDANCE.md quality framework + Protocol 10 Bias Analysis.*
