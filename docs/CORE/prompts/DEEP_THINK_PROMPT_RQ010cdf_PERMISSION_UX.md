# Deep Think Prompt: RQ-010cdf — Permission Experience (UX/Privacy)

> **Parent RQ:** RQ-010 — Permission Data Philosophy
> **This Sub-RQ Group:** RQ-010c, RQ-010d, RQ-010f
> **SME Domain:** Mobile UX Design & Privacy Research
> **Prepared:** 15 January 2026
> **For:** Google Deep Think / Claude Projects
> **App Name:** The Pact

---

## Your Role

You are a **Lead Mobile UX Designer & Privacy Researcher** specializing in:
- Android 13+ runtime permission flows
- "Privacy by Design" UI patterns
- Progressive disclosure strategies
- User trust & transparency

Your approach: Think step-by-step. Balance the system's need for data (to power the "Agency Engine") with the user's need for autonomy and privacy. Avoid "all-or-nothing" gating.

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Writer," "The Parent") that negotiate for attention via a "Parliament of Selves." Users create "pacts" — commitments to become a certain type of person.

### Core Philosophy: "psyOS" (Psychological Operating System)

The app isn't just a tool; it's an operating system for the user's psyche.
- **Parliament of Selves:** We model the user not as a monolith, but as a diverse team of "facets" (e.g., The Athlete, The Founder).
- **JITAI (Just-In-Time Adaptive Intervention):** The engine monitors context (location, time, energy) to recommend the *right* habit for the *current* facet.
- **Council AI:** An AI simulation that mediates disputes between facets (e.g., "The Founder" wants to work late, "The Parent" wants to go home).

### Key Terminology

| Term | Definition |
|------|------------|
| **JITAI** | Just-In-Time Adaptive Intervention. The system that says "Do X now." |
| **Passive Energy Detection** | Using sensors (Activity, HR) to guess if user is Focused, Physical, Social, or Recovering (RQ-014). |
| **Context Agency** | The app's ability to act on the user's behalf based on sensor data. |
| **Degradated Experience** | How the app functions when permissions are denied (graceful failure). |
| **Progressive Disclosure** | Asking for permissions *only when needed*, not at launch. |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning, Gemini for embeddings/TTS

---

## Mandatory Context: Locked Architecture

The following decisions are **LOCKED** and constrain your research:

### CD-010: No Dark Patterns ✅
- **Constraint:** We NEVER use guilt, shame, false urgency, or hidden costs to force compliance. Permission requests must be honest and value-driven.

### CD-017: Android-First ✅
- **Constraint:** Design specifically for Android 13+ permission models (runtime requests, "One-time" vs "While using").

### RQ-010a/b: Accuracy & Grant Rates ✅
- **Finding:** We can achieve ~85% energy state detection accuracy with full permissions (Biometric + Activity + Calendar).
- **Finding:** Grant rates drop significantly if asked all at once (~30% for full stack).
- **Implication:** We MUST assume users will deny some permissions. The app cannot break; it must degrade gracefully.

### RQ-014: Passive Energy Detection ✅
- **Dependency:** The "State Economics" engine (detecting if you are in `high_focus` vs `social`) RELIES on these permissions. Without them, the AI is blind.
- **Specific Scenarios (Use these to test design):**
    - **Scenario A (Gym):** User enters Gym. AI needs `Location` to switch to "Athlete." If denied: AI stays in "Worker", sends Slack notification. User is annoyed.
    - **Scenario B (Commute):** User driving. AI needs `Activity` to switch to "Recovery." If denied: AI suggests "Deep Work" while driving. Dangerous/Bad UX.

---

## Research Question Group: RQ-010cdf — Permission Experience

### Core Problem
The "Agency Engine" (JITAI) needs data (Location, Activity, Calendar) to work magic. Users are rightly suspicious of data graphs. If we ask for everything upfront, they bounce. If we ask for nothing, the AI is stupid.

**We need a UX strategy that maximizes trust and grant rates through transparency and value-for-exchange.**

### Sub-Questions (Answer Each Explicitly)

| # | ID | Question | Your Task |
|---|----|----------|-----------|
| 1 | **RQ-010c** | **Degradation Strategy:** How should the experience degrade when permissions are denied? | Define the "Tiers of Agency." What features break? What MANUAL fallbacks appear? (e.g., "AI can't see energy" -> "User must manually log energy"). |
| 2 | **RQ-010d** | **Progressive Disclosure:** What is the optimal strategy for *when* to ask? | Create a "Trigger Map." Use the **"I Told You So" Scenario**: User denies permission -> Feature fails -> User acts -> We ask again. |
| 3 | **RQ-010f** | **Transparency Surfacing:** How do we show the user *exactly* what the AI sees? | **Focus on In-Situ Indicators** (e.g., Status Bar pills), NOT just "Settings Dashboards." How does the user know *right now* that the AI is watching? |

### Anti-Patterns to Avoid
- ❌ **The "Wall of Permissions"**: Asking for 5 things at startup.
- ❌ **"Allow to continue"**: Blocking core value behind permissions.
- ❌ **Silent Tracking**: Collecting data without explicit, visible indicators.
- ❌ **Vague Copy**: "We need this for better experience." (Be specific: "We need Location to detect when you leave Work.")

---

## Output Required

1.  **The "Tiers of Agency" Matrix (RQ-010c)**
    - Table mapping: Permission Set → Functionality Level → Fallback UI.
    - Example: `No Permissions` → `Manual Only` → `User logs every state change`.

2.  **The Progressive Trigger Map (RQ-010d)**
    - Timeline/Flowchart: Event → Value Prop -> Request.
    - Example: "User complains about manual logging" → "Offer Auto-Detect (Activity Permission)."

3.  **Transparency UI Concept (RQ-010f)**
    - Description of the "Data Mirror" or "Sensor HUD."
    - How does the user see "The AI thinks I am Running"?

4.  **Confidence Assessment**
    - Rate each recommendation HIGH/MEDIUM/LOW.

---

## UX Constraints (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Android 13+** | Must handle "Approximate Location" vs "Precise." Must handle "One Time." |
| **CD-010** | No nagging. If denied twice, don't ask again until user explicitly acts. |
| **Material 3** | Use Material Design 3 patterns for dialogs and snackbars. |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Could a Flutter dev build the "Trigger Map"? |
| **Honest** | Does the copy respect the user's intelligence? |
| **Resilient** | Does the app still offer value with ZERO permissions? |

---

## Final Checklist Before Submitting

- [ ] "Tiers of Agency" covers logic for 0%, 50%, and 100% permissions.
- [ ] Trigger Map links specific User Pain (manual entry) to specific Permission Gain.
- [ ] Transparency UI allows revocation.
- [ ] All Android 13+ states (Denied, Just Once, Always) considered.

---
*End of Prompt*
