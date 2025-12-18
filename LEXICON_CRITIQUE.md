# Critique & Adaptation: The Word Repository

> **Context:** The user proposed a CSV/SQLite-based "Word Repository" for tracking user vocabulary.
> **Verdict:** The core idea is solid (tracking identity-forming language), but the proposed implementation (local CSVs) is too low-tech for **The Pact**. We need to elevate this to a cloud-synced, AI-enriched **"Lexicon"**.

---

## 1. Critique of Proposed Approach

| Proposed Element | Critique | The Pact Adaptation |
|------------------|----------|---------------------|
| **Storage:** SQLite/CSV | **Too Fragile.** Local files don't sync across devices and are hard to query socially. | **Supabase PostgreSQL.** Use a `lexicon` table linked to `users`. Enables real-time sync and "Community Words". |
| **Input:** Manual Entry | **High Friction.** Users won't type metadata (tags, dates) manually. | **AI Enrichment.** User types "Equanimity" → Gemini 3 auto-fills definition, etymology, and usage examples. |
| **Scale:** CSV Exports | **Passive.** A CSV file is just data. It doesn't drive behavior. | **Active Pacts.** "Word of the Day" challenges. "Use *Amor Fati* in a sentence today." |
| **Privacy:** Anonymized Aggregation | **Standard.** Good for research, but misses the social loop. | **Social Signals.** "Your friend Magnus just added *Antifragile* to their Lexicon." |

---

## 2. The Strategic Pivot: "The Lexicon" (Phase 25.9)

We are not building a dictionary. We are building a **Grimoire of Identity**.
* *Philosophy:* "To change your life, change your language."
* *Mechanism:* Users collect "Power Words" that reinforce their desired identity.

### Core Features

1.  **The Collection:**
    *   User captures a word (Voice or Text).
    *   Gemini 3 "Enriches" it: Definition, Etymology, "Why it matters to a [Builder/Stoic]".
    *   Stored in Supabase: `lexicon` table.

2.  **The Practice:**
    *   **Word Pacts:** A micro-habit to use a specific word 3 times today.
    *   **Lock Screen:** Google Wallet integration (from Phase 25.8) can display the "Word of the Day" on the back of the Identity Card.

3.  **The Community:**
    *   **Trending Words:** "What are the Stoics saying this week?"
    *   **Word Gifting:** Send a word to a friend who needs it.

---

## 3. Technical Architecture

### Database Schema (Supabase)

```sql
create table lexicon_entries (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users,
  word text not null,
  definition text,
  etymology text,
  identity_tag text, -- e.g., 'Stoic', 'Builder'
  mastery_level int default 0, -- 0=New, 1=Used, 5=Mastered
  created_at timestamptz default now()
);
```

### AI Service (`LexiconEnricher`)

*   **Input:** "Amor Fati"
*   **Prompt:** "Analyze this word for a [Stoic] persona. Give me the definition, origin, and a practical challenge to use it today."
*   **Output:** JSON with enriched metadata.

---

## 4. Integration with Roadmap

*   **Phase 25.9:** The Lexicon (Database + AI Enrichment)
*   **Phase 25.10:** Word Pacts (Micro-Habits)
*   **Phase 25.11:** Wallet Integration (Display Word on Pass)

---

**Recommendation:** Proceed with "The Lexicon" as a Supabase-first feature, rejecting the local CSV approach in favor of a cloud-native, AI-powered solution.
