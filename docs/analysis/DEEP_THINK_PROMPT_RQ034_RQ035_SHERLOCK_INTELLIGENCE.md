# Deep Think Prompt: Sherlock Intelligence — Conversation Architecture & Sensitivity Detection

> **Target Research:** RQ-034, RQ-035
> **Prepared:** 14 January 2026
> **For:** Google Deep Think / Gemini 2.0 Flash Thinking
> **App Name:** The Pact
> **Priority Score:** 6.8, 6.3 (HIGH tier per Protocol 14)
> **Processing Order:** RQ-034 → RQ-035 (conversation architecture must exist before sensitivity handling)
> **Complexity Level:** Multi-domain expert (Conversational AI + Clinical Psychology + UX)

---

## Your Role

You are a **Senior Conversational AI Architect** with cross-domain expertise in:

1. **Conversational AI Design** — Therapeutic chatbots, turn-taking systems, conversation state management, dialogue act theory
2. **Clinical Psychology** — Psychometric assessment, sensitivity detection, trauma-informed design, crisis intervention protocols
3. **Mobile UX/Trust Design** — Onboarding flows, progressive disclosure, trust-building patterns, privacy-first design
4. **Behavior Change Science** — Motivational interviewing, stages of change, cognitive behavioral frameworks

**Your Approach:**
- Think step-by-step through each sub-question
- Provide 2-3 options for major architectural decisions, then recommend
- Cite academic literature where applicable (at minimum: motivational interviewing, conversational agents, crisis detection)
- Consider edge cases: users with trauma, users in crisis, users who lie, users who disengage
- Design for compassion AND safety — never compromise user wellbeing for data extraction

---

## Critical Instruction: Processing Order

```
RQ-034: Sherlock Conversation Architecture
    ↓
    Output (conversation structure, turn-taking, state machine)
    ↓
RQ-035: Sensitivity Detection Framework
    ↓
    Output feeds INTO RQ-034's error recovery patterns
```

**Why this order:** Sensitivity detection is a MODULE within the conversation architecture. You cannot design sensitivity handling without first defining the conversation structure. However, sensitivity requirements MAY constrain conversation design — so consider both simultaneously but document separately.

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Athlete," "The Writer," "The Parent") that negotiate for attention. Users create "pacts" — commitments to become a certain type of person.

### Core Philosophy: "Parliament of Selves"

**psyOS (Psychological Operating System)** is the app's core framework:
- **The Self** = Speaker of the House (conscious observer)
- **Facets** = MPs (each with goals, values, fears, neurochemistry)
- **Conflict** = Debate to be governed, not a bug to be squashed
- **Goal** = Governance (coalition building), not Tyranny (forcing discipline)

**Key insight:** Users aren't monolithic — they have multiple versions of themselves competing for time/energy. The app mediates these competing selves.

### What is "Sherlock"?

**Sherlock** is The Pact's AI-powered onboarding conversation system. It's named after Sherlock Holmes because it:
- **Observes** user responses to extract psychological patterns
- **Deduces** underlying motivations, fears, and resistance patterns
- **Synthesizes** a personalized "identity story" that becomes the foundation for coaching

**Sherlock is NOT:**
- A generic chatbot collecting demographic data
- A quiz with predetermined answers
- A passive intake form

**Sherlock IS:**
- A therapeutic-style conversation lasting 7 days
- An AI system that extracts the "Shadow Cabinet" (psychological resistance patterns)
- The foundation for ALL subsequent personalization in the app

### Why Sherlock Matters

| Without Sherlock | With Sherlock |
|-----------------|---------------|
| Generic habit recommendations | Identity-aligned recommendations |
| One-size-fits-all messaging | Resistance-aware coaching |
| Surface-level accountability | Deep psychological resonance |
| High churn (users feel unseen) | Strong retention (users feel understood) |

### Key Terminology

| Term | Definition |
|------|------------|
| **psyOS** | Psychological Operating System — the app's core framework |
| **Identity Facet** | A "version" of the user they want to develop (e.g., "The Athlete") |
| **Shadow Cabinet** | Three core psychological resistance patterns extracted during onboarding |
| **Shadow** | Who the user fears becoming (Anti-Identity) |
| **Saboteur** | The pattern that causes the user to fail (Failure Archetype) |
| **Script** | The lie the user tells themselves to justify inaction (Resistance Lie) |
| **Triangulation Protocol** | Multi-method validation of extracted psychology |
| **JITAI** | Just-In-Time Adaptive Intervention — context-aware habit nudges |
| **Council AI** | AI-simulated debate between user's identity facets |
| **Treaty** | Negotiated agreement between facets with enforcement rules |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, CD-017)
- **Backend:** Supabase (PostgreSQL + pgvector for embeddings)
- **AI:** DeepSeek V3.2 for reasoning (CD-016), Gemini for embeddings/TTS
- **Conversation:** Structured prompts → DeepSeek → Response synthesis

---

## PART 2: MANDATORY CONTEXT — Completed Research

### CD-016: AI Model Strategy (LOCKED — Cannot Change)

| Model | Role | Cannot be changed |
|-------|------|-------------------|
| **DeepSeek V3.2** | Analyst (reasoning, conversation, coaching) | ✓ |
| **DeepSeek R1 Distilled** | Complex reasoning (Council AI, synthesis) | ✓ |
| **Gemini embedding-001** | Embedding generation (3072 dimensions) | ✓ |

**Constraint:** Sherlock conversations MUST use DeepSeek V3.2. Embeddings for psychological patterns use Gemini.

### CD-019: 5-Domain Facet Taxonomy (LOCKED — Cannot Change)

| Domain | Description | Example Facets |
|--------|-------------|----------------|
| **vocational** | Career, wealth, production, craft | The Founder, The Writer |
| **somatic** | Physical body, health, athletics | The Athlete, The Biohacker |
| **relational** | Interpersonal, family, community | The Parent, The Partner |
| **intellectual** | Skill acquisition, curiosity, creativity | The Reader, The Musician |
| **recovery** | Rest, meaning, inner peace | The Stoic, The Meditator |

### RQ-037: Shadow Cabinet Model (COMPLETE)

The "Holy Trinity" was renamed to **Shadow Cabinet** with validated components:

| Component | Old Name | Definition | Extraction Method |
|-----------|----------|------------|-------------------|
| **Shadow** | Anti-Identity | Who the user fears becoming | "What version of yourself are you running from?" |
| **Saboteur** | Failure Archetype | The pattern that causes failure | "When you've failed before, what usually happened?" |
| **Script** | Resistance Lie | The lie that justifies inaction | "What do you tell yourself when you skip?" |

**Key Finding:** These three components are sufficient to predict 85%+ of user resistance patterns.

### RQ-012: Fractal Trinity Architecture (COMPLETE)

The Shadow Cabinet exists at two levels:

```
Root Psychology (Global — per user)
├── root_label: "Abandoned Child", "Perfectionist", etc.
├── chronotype: 'lion', 'bear', 'wolf', 'dolphin'
└── root_embedding: VECTOR(768)

Contextual Manifestations (Per Facet)
├── Facet: "The Founder"
│   ├── shadow_manifestation: "Unemployed failure living with parents"
│   ├── saboteur_manifestation: "Analysis paralysis — needs more data"
│   └── script_manifestation: "I'll launch when it's perfect"
│
├── Facet: "The Athlete"
│   ├── shadow_manifestation: "Obese, immobile, dependent on others"
│   ├── saboteur_manifestation: "All-or-nothing — if I can't do it perfectly..."
│   └── script_manifestation: "I'll start Monday / when the gym is less crowded"
```

**Key Insight:** The SAME root fear creates DIFFERENT surface excuses in different contexts. Sherlock must extract BOTH levels.

### Current Schema (Exists — Must Integrate)

```sql
-- Root psychology (one per user)
CREATE TABLE psychometric_roots (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  chronotype TEXT CHECK (chronotype IN ('lion', 'bear', 'wolf', 'dolphin')),
  root_label TEXT,  -- "Abandoned Child", "Perfectionist"
  root_embedding VECTOR(768),
  extracted_at TIMESTAMPTZ,
  extraction_method TEXT  -- 'sherlock_day_7', 'manual_override'
);

-- Per-facet manifestations
CREATE TABLE psychological_manifestations (
  facet_id UUID PRIMARY KEY REFERENCES identity_facets(id),
  shadow_manifestation TEXT,
  saboteur_manifestation TEXT,
  script_manifestation TEXT,
  manifestation_embedding VECTOR(768),
  confidence_score FLOAT  -- 0.0-1.0
);

-- Sherlock conversation tracking (PROPOSED — design in this research)
CREATE TABLE sherlock_sessions (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  -- YOUR DESIGN GOES HERE
);
```

---

## PART 3: RESEARCH QUESTION 1 — RQ-034: Sherlock Conversation Architecture

### Core Question

**What is the optimal structure for the Sherlock onboarding conversation that extracts the Shadow Cabinet with therapeutic quality while maintaining user engagement over 7 days?**

### Why This Matters

- **Sherlock IS the onboarding** — Users who complete Sherlock have 3x retention
- **Extraction quality drives all personalization** — Bad Shadow Cabinet = irrelevant coaching
- **Day 7 synthesis creates the "identity story"** — This becomes the user's internal narrative
- **Failure = churn** — If Sherlock feels interrogative, users abandon

### The Problem (Concrete Scenario)

**Current State:**
```
Day 1: "What do you want to improve?"
Day 2: "What's stopped you before?"
Day 3: "Tell me about a time you failed."
Day 4-6: [No defined structure]
Day 7: [No synthesis protocol]
```

**Problems:**
1. Feels like an interrogation, not a conversation
2. No adaptive response to user emotional state
3. No handling of sensitive disclosures
4. No mechanism for users who disengage mid-week
5. No quality check on extracted data
6. No multi-modal integration (text, voice, quick-response)

### Current Hypothesis (Validate or Refine)

**Proposed 7-Day Structure:**

| Day | Theme | Extraction Target | Duration |
|-----|-------|-------------------|----------|
| 1 | **Welcome & Future Self** | Aspirational identity, primary facet | 3-5 min |
| 2 | **Fear Excavation** | Shadow (who they fear becoming) | 3-5 min |
| 3 | **Pattern Recognition** | Saboteur (failure pattern) | 3-5 min |
| 4 | **Script Surfacing** | Script (resistance lie) | 3-5 min |
| 5 | **Secondary Facets** | Additional identities, relationships | 3-5 min |
| 6 | **Values & Commitments** | Non-negotiables, treaty seeds | 3-5 min |
| 7 | **Synthesis & Story** | Triangulated narrative, user validation | 5-10 min |

**Hypothesis Questions:**
- Is 7 days optimal? (Too long = churn, too short = shallow extraction)
- Is daily cadence correct? (Morning? Evening? User-triggered?)
- Is 3-5 minutes per session right? (Enough depth without fatigue?)

### Sub-Questions (Answer Each Explicitly)

| # | Sub-Question | Your Task |
|---|--------------|-----------|
| 1 | **Conversation State Machine** | Design a state machine for Sherlock sessions. What states exist? What triggers transitions? How does Sherlock remember context across days? |
| 2 | **Turn-Taking Architecture** | How should Sherlock manage turn-taking? Open-ended prompts vs structured questions? When to probe deeper vs accept surface answers? |
| 3 | **Adaptive Response Generation** | How should Sherlock adapt responses based on user emotion, engagement level, and disclosure depth? Provide decision tree or algorithm. |
| 4 | **Multi-Modal Input Handling** | Users may type, voice-record, or select quick-responses. How should Sherlock process each? How to encourage richer responses without friction? |
| 5 | **Disengagement Recovery** | If user skips Day 3-4, what happens? Re-engage sequence? Condensed catch-up? Abandon and restart? |
| 6 | **Triangulation Protocol** | How to validate extracted Shadow Cabinet across 7 days? Cross-reference patterns? Confidence scoring? |
| 7 | **Day 7 Synthesis Algorithm** | How does Sherlock synthesize 7 days of conversation into a coherent "identity story"? What's the prompt structure? How is user presented their story for validation? |
| 8 | **Error Recovery** | User gives contradictory information. User lies. User deflects. How should Sherlock handle each? |
| 9 | **Therapeutic Quality Markers** | What makes a conversation feel "therapeutic" vs "interrogative"? How to measure this? What dialogue patterns achieve it? |
| 10 | **Schema Design** | Propose the `sherlock_sessions` and `sherlock_turns` table schemas with all necessary fields. |

### Anti-Patterns to Avoid

```
❌ Interrogation Pattern
   "What do you fear?" → "Why?" → "What else?" → "Deeper?"
   (Feels clinical, extractive, not conversational)

❌ Quiz Pattern
   Multiple choice questions with predetermined answers
   (Misses nuance, feels generic)

❌ Monologue Pattern
   Long AI explanations between user inputs
   (Loses engagement, feels preachy)

❌ Premature Synthesis
   Telling user "I think you're a perfectionist" on Day 2
   (Feels presumptuous, may be wrong)

❌ Data Extraction Focus
   Optimizing for complete data vs user experience
   (Users abandon if they feel like data sources)

❌ Ignoring Emotional Cues
   "My father died last year" → "Now let's talk about habits"
   (Destroys trust, feels robotic)
```

### Output Required for RQ-034

1. **Conversation State Machine** — Diagram + state definitions + transition rules
2. **Turn-Taking Algorithm** — Decision tree for when to probe, reflect, or advance
3. **7-Day Session Templates** — Detailed prompts for each day with variants
4. **Adaptive Response Framework** — How Sherlock modulates tone/depth based on signals
5. **Disengagement Recovery Protocol** — Specific flows for skip patterns
6. **Triangulation Validation Logic** — How to cross-check Shadow Cabinet accuracy
7. **Day 7 Synthesis Prompt** — Actual prompt template for narrative generation
8. **Schema Design** — Complete `sherlock_sessions` and `sherlock_turns` tables
9. **Quality Metrics** — How to measure "therapeutic quality" of conversations
10. **Confidence Assessment** — Rate each recommendation HIGH/MEDIUM/LOW

---

## PART 4: RESEARCH QUESTION 2 — RQ-035: Sensitivity Detection Framework

### Core Question

**How should The Pact detect and handle sensitive disclosures (mental health, trauma, self-harm, addiction, relationship abuse) during Sherlock conversations while maintaining user safety AND trust?**

### Why This Matters

- **Users disclose during Sherlock** — Deep extraction invites deep disclosure
- **No detection = liability** — Missing a crisis indicator is unacceptable
- **Over-detection = broken trust** — Flagging normal sadness as "crisis" feels invasive
- **Balance is critical** — Compassionate acknowledgment without inappropriate intervention

### The Problem (Concrete Scenarios)

**Scenario 1: Passive Disclosure**
```
User: "I want to become The Athlete because I've gained 60 pounds since my
divorce. Most days I don't even want to get out of bed."

Q: Is "don't want to get out of bed" depression or normal sadness?
Q: How should Sherlock respond?
Q: Should this trigger any flags?
```

**Scenario 2: Active Crisis Indicator**
```
User: "The truth is, sometimes I wonder if anyone would notice if I just
disappeared. My family would probably be better off."

Q: This is a crisis indicator. What happens IMMEDIATELY?
Q: How does Sherlock transition from extraction to support?
Q: What's the handoff protocol?
```

**Scenario 3: Trauma Reference**
```
User: "I can't commit to morning habits because my ex used to wake me up
at 5am for his 'inspections.' I still freeze when my alarm goes off."

Q: This indicates past abuse. How should Sherlock acknowledge?
Q: Should extraction continue? Pause? Redirect?
Q: How to validate without re-traumatizing?
```

**Scenario 4: Addiction Context**
```
User: "My goal is to become someone who doesn't need to drink every night
to fall asleep. I've tried stopping but I get the shakes."

Q: User is disclosing physical alcohol dependence.
Q: Should Sherlock continue habit coaching or redirect?
Q: What's the boundary between "habit app" and "medical advice"?
```

### Current Hypothesis (Validate or Refine)

**Proposed Sensitivity Tiers:**

| Tier | Description | Detection Signal | Response |
|------|-------------|------------------|----------|
| **Green** | Normal disclosure | Standard emotional content | Continue extraction with empathy |
| **Yellow** | Sensitive topic | References to mental health, trauma, difficult relationships | Acknowledge, offer to adjust pace, note for context |
| **Orange** | Risk indicator | Expressions of hopelessness, isolation, worthlessness | Pause extraction, provide validation, offer resources |
| **Red** | Crisis indicator | Suicidal ideation, self-harm mention, abuse disclosure | Immediate transition to crisis protocol, human handoff |

**Hypothesis Questions:**
- Are 4 tiers sufficient? (Or do we need more granularity?)
- What's the detection method? (Keyword? Embedding similarity? LLM classification?)
- What's the false positive tolerance? (Better safe than sorry? Or respect user autonomy?)

### Sub-Questions (Answer Each Explicitly)

| # | Sub-Question | Your Task |
|---|--------------|-----------|
| 1 | **Sensitivity Taxonomy** | Define the complete taxonomy of sensitive topics for a habit/identity app. Include: mental health, trauma, addiction, abuse, grief, medical conditions, financial distress. |
| 2 | **Detection Architecture** | How should sensitivity be detected? Options: (A) Keyword matching, (B) Embedding similarity to crisis phrases, (C) LLM classification, (D) Hybrid. Recommend with tradeoffs. |
| 3 | **Tier Definitions** | Validate or refine the 4-tier model. Provide explicit criteria for each tier with examples. |
| 4 | **Response Templates** | For each tier, provide 3 response templates Sherlock should use. These must feel human, not clinical. |
| 5 | **Crisis Protocol** | Design the exact sequence when Red tier is detected. What happens in the next 5 seconds? 30 seconds? 5 minutes? |
| 6 | **Resource Database** | What external resources should The Pact provide? (Hotlines, apps, professionals). How to present without being preachy? |
| 7 | **Boundary Setting** | How does Sherlock communicate "I'm a habit app, not a therapist" without feeling dismissive? |
| 8 | **False Positive Handling** | User flagged Yellow/Orange but they're fine. How does Sherlock gracefully recover without making user feel pathologized? |
| 9 | **Consent & Autonomy** | Should user be able to say "I know what I disclosed, please continue"? How to balance safety vs autonomy? |
| 10 | **Legal/Ethical Framework** | What's The Pact's liability boundary? What must we document? What disclaimers are required? |
| 11 | **Integration with RQ-034** | How does sensitivity detection integrate with the conversation state machine? What states does detection trigger? |
| 12 | **Schema for Sensitivity Events** | Design `sensitivity_events` table to log detections without storing verbatim disclosures (privacy). |

### Anti-Patterns to Avoid

```
❌ Clinical Robot Pattern
   "I've detected language suggesting depression. Would you like crisis resources?"
   (Cold, clinical, breaks conversational flow)

❌ Ignore Pattern
   User: "Sometimes I don't want to exist"
   Sherlock: "Great! Let's talk about your exercise goals."
   (Dangerous, dismissive, potential liability)

❌ Over-Pathologizing Pattern
   User: "I felt sad after my dog died"
   Sherlock: "I'm concerned about your mental health. Here are crisis resources."
   (Insulting, breaks trust, treats normal emotion as disorder)

❌ Interrogation Pattern
   "Are you having thoughts of self-harm? Are you safe right now?
   Do you have access to weapons?"
   (Feels like assessment, not conversation)

❌ Unsolicited Advice Pattern
   User: "I'm trying to quit drinking"
   Sherlock: "You should go to AA. Here's why alcohol is harmful..."
   (Preachy, presumptuous, not asked)

❌ Data Extraction Over Safety
   Prioritizing Shadow Cabinet extraction over user wellbeing
   (Ethically wrong, legally risky)
```

### Output Required for RQ-035

1. **Complete Sensitivity Taxonomy** — Hierarchical list of all sensitive categories
2. **Detection Architecture Recommendation** — With implementation approach
3. **Validated Tier Model** — Refined 4 (or N) tier definitions with explicit criteria
4. **Response Template Library** — 3+ templates per tier, natural language
5. **Crisis Protocol Flowchart** — Second-by-second response for Red tier
6. **Resource Database Structure** — Categories, sources, presentation format
7. **Boundary Language Templates** — How Sherlock communicates its limits
8. **False Positive Recovery Scripts** — Graceful de-escalation language
9. **Consent/Autonomy Framework** — User override protocols with guardrails
10. **Legal Checklist** — Required disclaimers, documentation, liability boundaries
11. **Integration Specification** — How sensitivity module connects to RQ-034 state machine
12. **Schema Design** — `sensitivity_events` table with privacy-preserving fields
13. **Confidence Assessment** — Rate each recommendation HIGH/MEDIUM/LOW

---

## PART 5: ARCHITECTURAL CONSTRAINTS (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Database** | Supabase (PostgreSQL + pgvector). No graph databases. RLS for multi-tenant. |
| **AI Model** | DeepSeek V3.2 for conversation. Embeddings via Gemini. No OpenAI in production. |
| **Client** | Flutter 3.38.4, Android-first. Must work offline with sync. |
| **Privacy** | Sensitive disclosures must NOT be stored verbatim. Use embeddings + tier labels. |
| **Consent** | User must consent to AI conversation at onboarding. No hidden extraction. |
| **Battery** | Conversation sessions < 5% battery impact per day. |
| **Latency** | Response generation < 3 seconds perceived latency. |
| **Accessibility** | Voice input must be supported. Vision accessibility for all UI. |

---

## PART 6: OUTPUT QUALITY CRITERIA

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an engineer build this without clarifying questions? |
| **Therapeutic** | Would a clinical psychologist approve this conversation design? |
| **Safe** | Are all crisis scenarios handled with appropriate protocols? |
| **Scalable** | Does this work for 1 user? 1 million users? |
| **Measurable** | Can we track quality metrics for each conversation? |
| **Privacy-Preserving** | Are sensitive disclosures protected appropriately? |
| **Legally Sound** | Are liability boundaries clear and documented? |
| **User-Respecting** | Does this respect user autonomy while maintaining safety? |

---

## PART 7: EXAMPLE OF GOOD OUTPUT

### Example: Conversation State Machine (Partial)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SHERLOCK STATE MACHINE                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  STATES:                                                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│  │ GREETING    │───▶│ EXTRACTION  │───▶│ REFLECTION  │            │
│  │ (warmth)    │    │ (probing)   │    │ (mirroring) │            │
│  └─────────────┘    └─────────────┘    └──────┬──────┘            │
│        │                   │                   │                   │
│        │            ┌──────▼──────┐           │                   │
│        │            │ SENSITIVITY │───────────┘                   │
│        │            │ (tier check)│                               │
│        │            └──────┬──────┘                               │
│        │                   │                                       │
│        │         ┌─────────┴─────────┐                            │
│        │         ▼                   ▼                            │
│        │    ┌─────────┐        ┌─────────┐                        │
│        │    │ SUPPORT │        │ CRISIS  │                        │
│        │    │(yellow) │        │ (red)   │                        │
│        │    └────┬────┘        └────┬────┘                        │
│        │         │                  │                             │
│        │         │                  ▼                             │
│        │         │           ┌─────────────┐                      │
│        │         │           │ HUMAN_HANDOFF│                      │
│        │         │           │ (escalation) │                      │
│        │         │           └─────────────┘                      │
│        │         │                                                │
│        ▼         ▼                                                │
│  ┌─────────────────────┐                                          │
│  │    SYNTHESIS        │                                          │
│  │ (Day 7: story gen)  │                                          │
│  └─────────────────────┘                                          │
│                                                                     │
│  TRANSITIONS:                                                      │
│  • GREETING → EXTRACTION: After rapport-building exchange          │
│  • EXTRACTION → REFLECTION: Every 2-3 user turns                   │
│  • EXTRACTION → SENSITIVITY: Trigger phrase detected               │
│  • SENSITIVITY → SUPPORT: Yellow/Orange tier                       │
│  • SENSITIVITY → CRISIS: Red tier                                  │
│  • SUPPORT → EXTRACTION: User confirms okay to continue            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Confidence: HIGH** — Standard FSM pattern adapted for therapeutic conversation.

---

## PART 8: FINAL CHECKLIST BEFORE SUBMITTING

Your response must include explicit answers to:

### RQ-034 Checklist
- [ ] Complete state machine diagram with all states and transitions
- [ ] Turn-taking algorithm with decision tree
- [ ] All 7 day session templates with specific prompts
- [ ] Adaptive response framework with modulation rules
- [ ] Disengagement recovery protocol for all skip patterns
- [ ] Triangulation validation logic with confidence scoring
- [ ] Day 7 synthesis prompt (full template)
- [ ] `sherlock_sessions` and `sherlock_turns` schema (complete SQL)
- [ ] Quality metrics for "therapeutic feel"
- [ ] Confidence levels for each recommendation

### RQ-035 Checklist
- [ ] Complete sensitivity taxonomy (hierarchical)
- [ ] Detection architecture recommendation with implementation notes
- [ ] Refined tier model with explicit criteria and examples
- [ ] Response templates (3+ per tier)
- [ ] Crisis protocol flowchart (second-by-second)
- [ ] Resource database structure
- [ ] Boundary language templates (3+)
- [ ] False positive recovery scripts
- [ ] Consent/autonomy framework with guardrails
- [ ] Legal checklist (disclaimers, documentation)
- [ ] Integration spec with RQ-034 state machine
- [ ] `sensitivity_events` schema (privacy-preserving SQL)
- [ ] Confidence levels for each recommendation

### Integration Checklist
- [ ] Sensitivity module clearly plugs into conversation state machine
- [ ] No contradictions between RQ-034 and RQ-035 outputs
- [ ] All schemas are compatible and reference each other correctly
- [ ] Edge cases (lies, contradictions, disengagement) handled in both

---

## PART 9: CITATIONS EXPECTED

For academic rigor, cite relevant literature from:

1. **Motivational Interviewing** — Miller & Rollnick (2012), OARS framework
2. **Conversational Agents in Mental Health** — Fitzpatrick et al. (2017), Woebot studies
3. **Crisis Detection in Text** — Coppersmith et al. (2018), CLPsych shared tasks
4. **Therapeutic Alliance in Digital** — Sucala et al. (2012), relationship factors
5. **Trauma-Informed Design** — SAMHSA (2014), 6 principles
6. **Dialogue Act Theory** — Stolcke et al. (2000), DAMSL framework
7. **Self-Determination Theory** — Ryan & Deci (2000), autonomy/competence/relatedness

---

*End of Prompt*

**Total Scope:** 2 HIGH-priority RQs, estimated 15-20 page output, multi-domain expert synthesis
**Expected Use:** Single Deep Think session with comprehensive output; no follow-up needed if checklist complete
