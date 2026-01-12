# Deep Think Prompt: Sensitivity Detection Framework (RQ-035)

> **Target Research:** RQ-035 (Sensitivity Detection Framework)
> **Version:** 1.0
> **Prepared:** 12 January 2026
> **For:** Google Deep Think / Gemini 2.0 Flash Thinking
> **App Name:** The Pact
> **Self-Containment Score:** Target 8.5+

---

## PART 1: WHAT IS "THE PACT"? (Essential Context — You Have No Prior Knowledge)

### The App in One Paragraph

The Pact is a mobile habit-building app (Flutter, Android-first) for adults 25-45 who have repeatedly failed with traditional habit trackers. Unlike Habitica (gamification), Streaks (minimalism), or Beeminder (financial stakes), The Pact uses psychological insight to help users understand WHY they fail — treating habit formation as identity development, not task completion. The atomic unit is "identity evidence" — observable proof that the user is becoming who they want to be.

### Target Users

| Demographic | Psychographic |
|-------------|---------------|
| Adults 25-45 | "I know what to do, I just can't make myself do it" |
| Professionals with competing priorities | High self-awareness, low follow-through |
| Previously tried 3+ habit apps | Skeptical of gamification, tired of streaks |
| Value depth over simplicity | Willing to invest in understanding themselves |

### Core Philosophy: "Parliament of Selves" (psyOS)

Traditional habit apps assume users are a single person needing discipline. The Pact rejects this.

**The psyOS Model:**

Users have multiple **identity facets** — different versions of themselves competing for limited time and energy. These aren't "goals" or "habits" but psychological identities with their own values, fears, and desires.

**Example:**
```
User: Maya, 38, product manager + mother + aspiring novelist

Identity Facets:
├── "The Strategist" — wants deep work mornings, values competence
├── "The Mother" — wants present parenting, values connection
├── "The Writer" — wants creative expression, values authenticity
└── "The Athlete" — wants physical vitality, values energy

Conflicts:
- "The Strategist" vs "The Writer" — both want morning focus time
- "The Mother" vs "The Athlete" — both want weekend hours

These conflicts cause FAILURE. Maya starts writing, feels guilt about strategy work,
abandons both. This isn't laziness — it's unresolved identity conflict.
```

### The "Sherlock" Conversation System

**Sherlock** is an AI-powered onboarding experience that extracts the user's psychological profile through natural conversation. During Day 1 onboarding:

1. User has a ~10-15 minute voice/text conversation with "Sherlock"
2. Sherlock asks probing questions about identity, goals, fears, past failures
3. Sherlock extracts: Aspirational Identity, Identity Facets, Shadow Cabinet
4. This data personalizes the entire app experience

**The Shadow Cabinet:**
- **Shadow:** Who the user fears becoming ("the person who gives up")
- **Saboteur:** The pattern that causes failure ("procrastination under stress")
- **Script:** The lie that justifies inaction ("I'll start Monday")

**THE PROBLEM THIS RESEARCH SOLVES:**

During Sherlock conversations, users may disclose:
- **Mental health struggles** — depression, anxiety, eating disorders
- **Addiction** — substance abuse, behavioral addictions (gambling, porn)
- **Trauma** — abuse, loss, PTSD-related experiences
- **Self-harm indicators** — explicit or implicit references
- **Relationship distress** — domestic abuse, extreme isolation

The Pact is **NOT** a therapy app. It has no licensed clinicians. But users don't know this boundary — they may share deeply sensitive content expecting support.

**We need a framework to:**
1. Detect sensitive disclosures (without invasive surveillance)
2. Respond appropriately (not ignore, not pretend to treat)
3. Set clear boundaries (what the app can/cannot do)
4. Provide professional referrals (when warranted)
5. Protect sensitive data (privacy engineering)
6. Handle witness visibility (should witnesses see sensitive habits?)

### The "Witness" Feature

Users can invite real humans (friends, family, coaches) to **witness** their journey:
- See selected habit completions and reflections
- Receive weekly summary notifications
- Send encouragement messages

**The Privacy Problem:**

If a user's habit is "Stay sober" or "Don't binge," they may NOT want their mother-in-law (a witness) to see this. Sensitivity detection must inform:
- Default witness visibility settings
- Warning prompts before sharing sensitive habits
- Automatic privacy protections for certain habit types

### Tech Stack

| Layer | Technology | Relevance to This Research |
|-------|------------|---------------------------|
| Frontend | Flutter 3.38.4 (Android-first) | UI for sensitivity prompts |
| Backend | Supabase (PostgreSQL, RLS) | Row-level security for sensitive data |
| AI | DeepSeek V3.2 | Powers Sherlock conversations |
| Analytics | Local-first (privacy) | No sensitive data to external services |

---

## PART 2: YOUR ROLE

You are a **Clinical Psychologist specializing in Digital Mental Health & Safety Design** with expertise in:

1. **Crisis Detection** — Identifying risk indicators in natural language
2. **Therapeutic Boundaries** — What apps can/cannot appropriately address
3. **Privacy Engineering** — Protecting sensitive personal data
4. **Content Moderation** — Designing safe classification systems
5. **Harm Reduction** — When professional referral is warranted
6. **Trauma-Informed Design** — Building systems that don't re-traumatize

Your approach:
1. Think step-by-step through each question
2. Present 2-3 options with explicit tradeoffs before recommending
3. Cite peer-reviewed research (author, year) for each major claim
4. Consider BOTH false positives (over-flagging) AND false negatives (missing real risk)
5. Rate confidence HIGH/MEDIUM/LOW for each recommendation
6. Flag ethical and legal concerns explicitly
7. Design for emotional safety AND user autonomy

---

## PART 3: KEY TERMINOLOGY

| Term | Definition |
|------|------------|
| **psyOS** | Psychological Operating System — the app's core framework treating users as multiple selves |
| **Sherlock** | AI-powered onboarding conversation that extracts psychological profile |
| **Shadow Cabinet** | Three psychological traits: Shadow (fear), Saboteur (pattern), Script (lie) |
| **Identity Facet** | A "version" of the user they want to develop |
| **Witness** | Human (friend/family) who observes user's habit journey |
| **Sensitive Habit** | A habit touching mental health, addiction, trauma, or private matters |
| **Crisis Indicator** | Language suggesting immediate risk (self-harm, suicidal ideation) |
| **Professional Referral** | Suggesting the user seek licensed mental health support |
| **RLS** | Row-Level Security — PostgreSQL feature restricting data access |
| **False Positive** | Incorrectly flagging non-sensitive content as sensitive |
| **False Negative** | Missing genuinely sensitive content |

---

## PART 4: LOCKED DECISIONS (Cannot Violate)

### CD-010: No Dark Patterns — CRITICAL CONSTRAINT

**Full Text:**
> "Track retention from DUAL perspectives (App + User). NO DARK PATTERNS — User success > App engagement. 'Graduation rate' is positive (user achieved goal)."

**Implications for Sensitivity:**
- Cannot use sensitive data to increase engagement
- Cannot manipulate users via their vulnerabilities
- Must prioritize user SAFETY over app metrics
- If a user discloses crisis, app engagement is IRRELEVANT
- User success may mean referring them OUT of the app to real help

### CD-015: psyOS Architecture

**Full Text:**
> "Parliament of Selves, Identity Facets, Council AI. 4-state energy model."

**Implication:** Sensitive habits are still habits within the facet system. Sensitivity is a property OF habits, not a separate system.

### CD-017: Android-First

**Full Text:**
> "All features must work on Android without iOS-specific APIs."

**Implication:** Any crisis hotline integration must work on Android.

### CD-018: Engineering Threshold

**Full Text:**
> "Apply ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED classification."

**Implication:** Complex ML-based sensitivity detection may be OVER-ENGINEERED. Simple keyword + user-override may suffice.

---

## PART 5: LEGAL & ETHICAL CONTEXT

### The Pact is NOT a Medical Device

The Pact is a **consumer wellness app**, not:
- A medical device (no FDA/CE regulation)
- A mental health provider (no licensed clinicians)
- A crisis intervention service (no 24/7 monitoring)
- A HIPAA-covered entity (no protected health information)

**Legal Obligation:** We are NOT required to detect or report mental health crises in most jurisdictions. However, we have an **ethical obligation** to:
1. Not make things worse (do no harm)
2. Provide resources when users disclose risk
3. Set clear expectations about what the app is/isn't

### Duty of Care (Ethical, Not Legal)

If a user says "I want to kill myself," we are not legally obligated to intervene (unlike a therapist). But we are **ethically obligated** to:
1. NOT ignore the statement
2. Provide crisis resources (hotlines, websites)
3. NOT pretend to provide therapy
4. NOT over-promise ("the app will help you")

### Data Protection

Sensitive personal data (health, mental health) has enhanced protection under:
- GDPR Article 9 (EU)
- CCPA (California)
- Various state laws (US)

**Implication:** Sensitive habit data needs:
- Explicit consent for processing
- Minimal collection (only what's needed)
- No third-party sharing
- User deletion rights

---

## PART 6: PROPOSED DATA MODEL

Deep Think should reason about this schema:

```sql
-- Habit sensitivity metadata
CREATE TABLE habit_sensitivity (
  habit_id UUID PRIMARY KEY REFERENCES habits(id),

  -- Classification
  sensitivity_level TEXT NOT NULL DEFAULT 'normal',  -- 'normal', 'private', 'sensitive', 'crisis_risk'
  sensitivity_category TEXT,                         -- 'addiction', 'mental_health', 'trauma', 'relationship', 'other'

  -- Detection source
  detected_by TEXT NOT NULL,                         -- 'system', 'user_marked', 'ai_flagged'
  detection_confidence FLOAT,                        -- 0.0-1.0 for AI detection

  -- User overrides
  user_override BOOLEAN DEFAULT false,               -- Did user change the classification?
  user_sensitivity_level TEXT,                       -- User's chosen level (if override)

  -- Privacy controls (user-controlled)
  exclude_from_witnesses BOOLEAN DEFAULT false,      -- Never show to witnesses
  exclude_from_analytics BOOLEAN DEFAULT true,       -- Never include in analytics
  exclude_from_ai_training BOOLEAN DEFAULT true,     -- Never use for model improvement

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crisis detection log (for safety review)
CREATE TABLE crisis_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,

  -- Detection context
  source TEXT NOT NULL,                              -- 'sherlock', 'reflection', 'habit_name', 'council'
  source_content TEXT,                               -- The text that triggered detection (encrypted)

  -- Classification
  indicator_type TEXT NOT NULL,                      -- 'suicidal_ideation', 'self_harm', 'severe_distress', 'other'
  severity TEXT NOT NULL,                            -- 'low', 'medium', 'high', 'critical'

  -- Response
  resources_shown BOOLEAN DEFAULT false,             -- Did we show crisis resources?
  user_acknowledged BOOLEAN DEFAULT false,           -- Did user acknowledge the resources?

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Witness visibility rules (extends witness_stakes)
ALTER TABLE witness_stakes ADD COLUMN IF NOT EXISTS
  sensitive_habits_visible BOOLEAN DEFAULT false;    -- Does witness see sensitive habits?
```

---

## PART 7: SENSITIVITY CATEGORIES

### Category 1: Addiction

**Examples:**
- "Stop drinking alcohol"
- "Quit smoking"
- "No more gambling"
- "Reduce cannabis use"
- "Stop watching porn"

**Detection Challenge:**
- "Have a beer" vs "Stop drinking" — context matters
- "Gambling" could be hobby (poker night) or addiction
- User may not use explicit addiction language

**Privacy Concern:** HIGH — Social stigma, employment implications

### Category 2: Mental Health

**Examples:**
- "Take my medication" (implies condition)
- "Practice anxiety coping"
- "Depression management routine"
- "Stay out of bed during day" (depression signal)

**Detection Challenge:**
- Many mental health habits use euphemistic language
- "Self-care" could be mental health or spa day
- Over-flagging creates patronizing experience

**Privacy Concern:** HIGH — Stigma, insurance implications

### Category 3: Trauma Recovery

**Examples:**
- "Attend EMDR therapy"
- "Practice grounding exercises"
- "Process childhood memories"
- "Healing from [specific trauma]"

**Detection Challenge:**
- User may disclose trauma in Sherlock without habit
- Sherlock's probing questions may surface trauma unexpectedly
- "Shadow" extraction may touch traumatic content

**Privacy Concern:** CRITICAL — Re-traumatization risk

### Category 4: Eating & Body

**Examples:**
- "No purging"
- "Eat three meals"
- "Don't weigh myself obsessively"
- "Body acceptance practice"

**Detection Challenge:**
- "Eat healthy" vs eating disorder recovery — thin line
- Weight loss habits (normal) vs ED recovery (sensitive)
- Cultural context matters

**Privacy Concern:** HIGH — Stigma, health implications

### Category 5: Relationship Safety

**Examples:**
- "Leave abusive relationship" (explicit)
- "Stay away from [person]"
- "Don't respond to ex" (could be healthy or dangerous)
- "Document incidents" (implies abuse)

**Detection Challenge:**
- Domestic abuse victims may not use explicit language
- "Boundary setting" is healthy OR safety-critical
- False positives create alarm; false negatives risk harm

**Privacy Concern:** CRITICAL — Physical safety implications

### Category 6: Sexual & Identity

**Examples:**
- "Coming out practice"
- "Sexual health habits"
- "Gender affirmation routine"
- "Explore sexuality"

**Detection Challenge:**
- Not sensitive for everyone; cultural context varies
- Over-flagging is patronizing/othering
- Under-flagging may expose to hostile witnesses

**Privacy Concern:** VARIES — Family/cultural context dependent

---

## PART 8: RESEARCH QUESTIONS

### RQ-035.1: Sensitivity Category Taxonomy

**Question:** What categories of goals should be flagged as sensitive, and what sensitivity LEVELS should exist?

**Your Task:**
1. Evaluate the 6 categories above — are they complete? Missing any?
2. Design sensitivity LEVELS (e.g., normal → private → sensitive → crisis_risk)
3. Define what each level means for system behavior
4. Consider: Should users see these categories, or are they internal-only?

**Tradeoffs to Address:**
- Granular categories (accurate) vs simple categories (usable)
- System-defined (consistent) vs user-defined (autonomous)
- Explicit labeling (clear) vs implicit handling (non-stigmatizing)

---

### RQ-035.2: Detection Methodology

**Question:** How should the app detect sensitive content without invasive surveillance?

**Options to Evaluate:**

**Option A: Keyword/Phrase Matching**
- Maintain list of sensitive terms ("sobriety", "purging", "abuse")
- Match against habit names, reflection text, Sherlock transcripts
- Pros: Simple, fast, transparent
- Cons: Easily bypassed, high false positive/negative rate

**Option B: AI Classification (On-Device or Cloud)**
- Use language model to classify sensitivity
- Can understand context, not just keywords
- Pros: More accurate, handles euphemisms
- Cons: Privacy concern (sending text to AI), expensive, complex

**Option C: User Self-Declaration**
- Ask users to mark sensitive habits themselves
- Provide prompts like "This habit seems personal. Would you like extra privacy?"
- Pros: Respects autonomy, accurate
- Cons: Users may not know to mark, burden on user

**Option D: Behavioral Signals**
- Infer from behavior: edited habit name multiple times, hesitated before sharing
- Pros: Non-invasive, no text analysis
- Cons: Weak signal, speculation

**Option E: Hybrid (Recommended for Analysis)**
- Keyword flags SUGGEST sensitivity
- AI refines classification
- User confirms or overrides
- Pros: Balance accuracy and autonomy
- Cons: Complexity

**Your Task:**
1. Analyze each option with accuracy, privacy, and autonomy tradeoffs
2. Consider false positive impact (user feels surveilled/patronized)
3. Consider false negative impact (sensitive content exposed)
4. Recommend approach with CD-010 compliance analysis

---

### RQ-035.3: User Override & Autonomy

**Question:** How should users be able to override system sensitivity classifications?

**Sub-Questions:**
1. Should users be able to REMOVE sensitivity flags? (Mark as "not sensitive")
2. Should users be able to ADD sensitivity flags? (Mark as "private")
3. What happens if user marks crisis-level content as "not sensitive"?
4. How to balance user autonomy with safety obligations?

**Key Tension:**
- Autonomy (CDT-010 principle): User controls their data
- Safety: System has ethical obligation for certain risks
- Legal: System has no legal obligation (see Part 5)

**Your Task:**
1. Design override UX that respects autonomy
2. Define what can/cannot be overridden
3. Handle the edge case: User marks "suicidal thoughts" habit as "normal"
4. Cite research on autonomy vs paternalism in digital health

---

### RQ-035.4: Witness Visibility Rules

**Question:** What default visibility rules should apply to sensitive habits shared with witnesses?

**Options:**

**Option A: All Hidden by Default**
- Sensitive habits never visible to witnesses unless user explicitly shares
- Pros: Maximum privacy
- Cons: User may want accountability for sensitive habits

**Option B: Summary Only**
- Witnesses see "1 private habit tracked" but no details
- Pros: Balance privacy + accountability
- Cons: May prompt questions ("what are you hiding?")

**Option C: Witness-Specific Rules**
- User chooses per-witness what to share
- Pros: Granular control
- Cons: Complex UX, burden on user

**Option D: Category-Based Defaults**
- Addiction: Hidden by default
- Mental health: Summary only
- Trauma: Hidden by default
- Eating: Hidden by default
- Relationship safety: Hidden by default (safety concern)
- Sexual/identity: User choice (no default)

**Your Task:**
1. Recommend default visibility per sensitivity category
2. Design override UX for users who WANT to share
3. Consider: What if witness is the user's therapist? (different rules)
4. Address relationship safety: Abuser as witness scenario

---

### RQ-035.5: Sherlock Conversation Handling

**Question:** How should Sherlock (AI onboarding) handle sensitive disclosures in real-time?

**Scenarios:**

**Scenario A: User mentions addiction**
- "I've been struggling with alcohol for years"
- Sherlock should: Acknowledge, not probe deeply, continue appropriately

**Scenario B: User discloses trauma**
- "My father was abusive"
- Sherlock should: Acknowledge with care, not probe for details, flag for sensitivity

**Scenario C: User indicates crisis**
- "Sometimes I think about ending it all"
- Sherlock should: Pause extraction, show crisis resources, offer to continue or stop

**Scenario D: User uses euphemisms**
- "I have a complicated relationship with food"
- Sherlock should: Recognize potential sensitivity, probe gently, not assume

**Your Task:**
1. Design Sherlock response templates for each scenario
2. Define "escalation triggers" that pause normal conversation
3. Balance: Information extraction (app value) vs emotional safety
4. What does Sherlock say AFTER showing crisis resources?
5. Should Sherlock continue or end session after crisis disclosure?

---

### RQ-035.6: Crisis Response Protocol

**Question:** When crisis indicators are detected, what should the app do?

**Crisis Indicators:**
- Explicit suicidal ideation ("I want to kill myself")
- Self-harm references ("I cut myself last night")
- Severe distress signals ("I can't go on")
- Immediate danger ("He's going to hurt me")

**Response Components:**

**Immediate Display:**
- Pause current flow (Sherlock, Council, etc.)
- Show crisis resources modal
- Include: National hotline, text line, international resources
- Include: "This app is not a crisis service"

**Resources to Show:**
- 988 Suicide & Crisis Lifeline (US)
- Crisis Text Line (text HOME to 741741)
- International Association for Suicide Prevention list
- Local emergency services (911)

**Post-Resource Options:**
- "I'm okay, continue" (acknowledge resources, return to app)
- "I need to stop" (close app gracefully)
- "Save these resources" (bookmark for later)

**Your Task:**
1. Design crisis detection sensitivity (when to trigger)
2. Design crisis modal UX (what to show)
3. Define post-crisis app behavior (what happens after?)
4. Handle false positive: User says "this project is killing me" (metaphor)
5. Handle edge case: User dismisses resources, continues with crisis content

---

### RQ-035.7: Data Privacy Architecture

**Question:** What technical privacy protections should apply to sensitive habit data?

**Considerations:**

**Storage:**
- Should sensitive habit names be encrypted at rest?
- Should Sherlock transcripts with sensitive content be stored?
- Retention period for crisis indicator logs?

**Access:**
- RLS policies: Who can query sensitive habits?
- Analytics exclusion: Never include in aggregate metrics?
- Support access: Can support staff see sensitive data?

**Deletion:**
- Right to erasure: How to delete sensitive data completely?
- Cascade rules: Delete sensitivity metadata with habit?
- Audit trail: Keep log that data existed but was deleted?

**Third Parties:**
- AI providers: Do sensitive texts go to DeepSeek?
- Analytics: Do sensitive events go to any analytics?
- Crash reporting: Exclude sensitive data from crash logs?

**Your Task:**
1. Recommend encryption strategy for sensitive data
2. Define RLS policies for sensitivity levels
3. Design deletion flow for sensitive data
4. Recommend third-party data sharing policy
5. Consider GDPR Article 9 compliance for "special category" data

---

### RQ-035.8: Demographic & Contextual Signals

**Question:** What demographic or contextual signals should inform sensitivity classification?

**Potential Signals:**
- **Age:** Younger users may need different protections
- **Location:** Some topics more sensitive in certain regions/cultures
- **Time of day:** Crisis indicators more concerning at 3 AM
- **Historical patterns:** User with history of crisis disclosures
- **Facet context:** "The Recovering Addict" facet implies addiction sensitivity

**Your Task:**
1. Which signals are appropriate to use? (Privacy vs accuracy)
2. Which signals are inappropriate? (Discrimination risk)
3. How to handle cultural sensitivity differences?
4. Should historical crisis indicators affect future classification?

---

### RQ-035.9: AI Coaching Boundaries

**Question:** What should AI coaching (Identity Coach, Council AI) NOT do for sensitive topics?

**Boundary Principles:**
1. NOT provide therapy ("Let's explore your childhood trauma")
2. NOT diagnose ("This sounds like depression")
3. NOT prescribe ("You should try meditation for anxiety")
4. NOT minimize ("Everyone feels that way sometimes")
5. NOT catastrophize ("This is very serious, you need help immediately")

**Appropriate Responses:**
1. Acknowledge ("I hear that this is important to you")
2. Normalize seeking help ("Many people find professional support helpful")
3. Stay in lane ("I can help with habit tracking; for deeper support...")
4. Maintain consistency (don't suddenly become "therapeutic")

**Your Task:**
1. Design AI prompt guardrails for sensitive topics
2. Create example responses for common sensitive disclosures
3. Define what AI SHOULD do vs SHOULD NOT do
4. How to train/prompt AI to stay in lane without being cold?

---

### RQ-035.10: MVP vs Full Implementation

**Question:** What's the minimum viable sensitivity detection that should ship first?

**MVP Candidates:**
1. User self-marking only (no auto-detection)
2. Keyword list + user override
3. Crisis keywords only (ignore other sensitivity)
4. Default all habits to "private from witnesses" (no categorization)

**Full Implementation:**
1. Hybrid detection (keyword + AI + user)
2. Full category taxonomy
3. Sherlock real-time handling
4. Crisis response protocol
5. Contextual signals

**Your Task:**
1. Recommend MVP scope (shippable in 1-2 weeks)
2. Sequence features for iterative rollout
3. What's the minimum SAFE implementation? (Ethics, not features)
4. What data should MVP collect to inform full implementation?

---

## PART 9: ANTI-PATTERNS TO AVOID

- ❌ **Surveillance culture:** Making users feel watched/analyzed
- ❌ **Over-flagging:** Every habit about health becomes "sensitive"
- ❌ **Under-flagging:** Missing genuine crisis indicators
- ❌ **Paternalism:** Preventing users from controlling their own data
- ❌ **False expertise:** App pretending to provide clinical support
- ❌ **Liability avoidance:** Designing primarily to avoid lawsuits vs help users
- ❌ **One-size-fits-all:** Ignoring cultural/contextual sensitivity differences
- ❌ **Keyword overreach:** "Kill" in "kill this bad habit" flagged as crisis

---

## PART 10: REQUIRED OUTPUT

Structure your response with:

### 1. Sensitivity Taxonomy

| Category | Subcategories | Default Level | Detection Signal |
|----------|---------------|---------------|------------------|
| [Category] | [Types] | [Level] | [How detected] |

### 2. Detection Methodology Recommendation

- Recommended approach with full analysis
- False positive/negative tradeoff analysis
- Privacy impact assessment
- CD-010 compliance verification

### 3. User Override Design

- What users can/cannot override
- Override UX flow
- Edge case handling

### 4. Witness Visibility Matrix

| Sensitivity Level | Default Visibility | Override Available |
|-------------------|--------------------|--------------------|
| [Level] | [Setting] | [Yes/No] |

### 5. Sherlock Response Templates

- Template per scenario (addiction, trauma, crisis, euphemism)
- Escalation criteria
- Post-escalation flow

### 6. Crisis Response Protocol

- Detection triggers
- Resource display design
- Post-crisis flow
- False positive handling

### 7. Privacy Architecture

- Encryption recommendations
- RLS policy recommendations
- Third-party data rules
- Deletion flow

### 8. AI Coaching Guardrails

- Prompt instructions for sensitive topics
- Example responses
- Boundary definitions

### 9. MVP Specification

- Scope (1-2 weeks)
- Minimum safe implementation
- Data collection for learning

### 10. Confidence Summary

| Recommendation | Confidence | Key Uncertainty |
|----------------|------------|-----------------|
| [Rec] | HIGH/MED/LOW | [What would change this?] |

### 11. Ethical Flags

| Concern | Mitigation | Residual Risk |
|---------|------------|---------------|
| [Concern] | [How addressed] | [What remains] |

---

## PART 11: FINAL CHECKLIST

Before submitting response, verify:

**Structure:**
- [ ] All 10 sub-questions (RQ-035.1 through RQ-035.10) answered
- [ ] 2-3 options presented for every detection method
- [ ] MVP and full implementation distinguished

**Safety:**
- [ ] Crisis response protocol complete
- [ ] AI boundaries defined
- [ ] False positive/negative tradeoffs analyzed
- [ ] User autonomy preserved where appropriate

**Privacy:**
- [ ] Data protection recommendations complete
- [ ] Third-party sharing addressed
- [ ] GDPR Article 9 considerations noted
- [ ] Deletion rights addressed

**Ethics:**
- [ ] CD-010 compliance verified for all recommendations
- [ ] Liability vs user benefit balance addressed
- [ ] Cultural sensitivity considered
- [ ] Paternalism avoided

**Quality:**
- [ ] Peer-reviewed citations for major claims (author, year)
- [ ] Confidence levels stated
- [ ] Anti-patterns explicitly avoided
- [ ] Edge cases addressed

---

*End of Prompt — RQ-035 Sensitivity Detection Framework*
