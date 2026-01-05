# Product Vision: The Pact (V4)

**Last Updated:** 2026-01-05
**Status:** Living Document

## 1. Brand Identity & URL Schema
- **Decision:** The app is **The Pact**, not "Atomic Habits".
- **Action:** Transition all URL schemas from `atomichabits://` to `thepact://` (e.g., `thepact://c/CODE`).
- **Goal:** Unify branding under "The Pact" roof. Remove legacy "Atomic" references from manifests and deep links.

## 2. The Anti-Identity (Dynamic Shadow)
- **Critique:** "Sherlock" risks confining complex humans into simplistic buckets ("The Procrastinator").
- **Vision:** The Anti-Identity is not a static label but a **Dynamic Shadow Profile** consisting of:
  - **Triggers:** Context-specific failure points (Time, Place, Emotion).
  - **Lies:** The specific narratives used to justify quitting.
  - **Fears:** The deep-seated anxieties driving the behavior.
- **Implementation:** Moving forward, Sherlock output will be treated as an initial "Cluster" hypothesis that evolves with `EvidenceEngine` data, not a permanent diagnosis.

## 3. Loading Insights (Validating Value)
- **Critique:** Generic loading screens are a missed opportunity and potential churn point.
- **Vision:** **Transparent Intelligence.** The "Loading" screen must visualize the work being done.
  - *Example:* "Scanning Calendar... Found 3 conflict zones."
  - *Example:* "Analyzing YouTube History... Detected high-dopamine triggers."
- **Goal:** Validate the strength of the engine *before* the user lands.

## 4. The Pact Reveal (Star Wars Hologram)
- **Vision:** "Hyper-Personalized Identity Card."
- **Concept:** This is the "Aha!" moment. It must feel like a mirror. 
- **Shareability:** While shareability is a secondary loop, the primary function is **Self-Recognition**. If the user sees themselves clearly in the mirror, trust is established.

## 5. Tiers & Value Placement
- **Philosophy:** **Value First, Payment Second.**
- **Rationale:** Placing Sherlock *before* the Paywall increases CAC risk (spending compute on non-payers) BUT serves as the critical "Sales Pitch." Users pay for the *solution* (The Pact), so they must first feel the *diagnosis* (Sherlock).
- **Strategy:** Focus solely on **Tier 2 (AI Accountability)** for MVP. Simplify options.

## 6. The Witness (AI vs Human)
- **Sensitive Goals:** Not all Pacts are public. "Porn Free" or deeply personal goals require privacy.
- **The AI Witness:** For sensitive goals, **The Pact (AI)** itself is the Witness.
- **Solo Mode:** "Go Solo" is actually "AI Witness Mode". The AI holds you accountable with the same rigor (or more) than a human friend.
- **Viral Loop:** The "Invite a Friend" flow is for growth, but it must not be the *only* path.

## 7. Navigation Philosophy
- **Blocking Flows:** Sherlock Interviews and High-Stakes moments block the `Back` button to prevent broken states.
- **Confirm to Exit:** Value Proposition screens require explicit "Are you sure?" confirmation to exit, leveraging Loss Aversion.

---

## Technical Implications & Next Steps
1.  **Tech Debt:** Rename Android/iOS URL schemes.
2.  **Roadmap:** Add `LoadingInsightsScreen` V2 (Streaming Data).
3.  **Refactoring:** Audit `PsychometricProvider` to support "Shadow Clusters" vs simple strings.
4.  **Device Test:** Validate valid navigation flows (`PopScope`) on physical devices.
