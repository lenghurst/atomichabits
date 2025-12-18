# LEXICON_SPEC.md

> **Status:** DRAFT (v1.0.0)  
> **Feature:** "The Lexicon" (Social Grimoire)  
> **Phase:** 25.9  
> **Owner:** Engineering Team

---

## 1. Overview

**The Lexicon** is a repository of "Power Words" that reinforce the user's chosen identity. It is not a dictionary; it is a tool for cognitive reframing.

**Philosophy:** "To change your life, change your language."

---

## 2. User Stories

1.  **Capture:** As a user, I want to quickly save a word I hear or read (e.g., "Antifragile") so I don't forget it.
2.  **Enrich:** As a user, I want the AI to tell me what this word means *for me* (e.g., "How does a Stoic use this?").
3.  **Practice:** As a user, I want daily challenges to use my collected words in conversation.
4.  **Share:** As a user, I want to see what words my friends (Witnesses) are collecting.

---

## 3. Architecture

### Database Schema (Supabase)

```sql
create table lexicon_entries (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  word text not null,
  definition text,
  etymology text,
  identity_tag text, -- e.g., 'Stoic', 'Builder', 'Athlete'
  mastery_level int default 0, -- 0=New, 1=Seen, 3=Used, 5=Mastered
  last_practiced_at timestamptz,
  created_at timestamptz default now()
);

-- RLS Policies
create policy "Users can view their own lexicon" on lexicon_entries
  for select using (auth.uid() = user_id);

create policy "Witnesses can view friend's lexicon" on lexicon_entries
  for select using (
    exists (
      select 1 from contracts
      where (owner_id = lexicon_entries.user_id and witness_id = auth.uid())
      or (witness_id = lexicon_entries.user_id and owner_id = auth.uid())
    )
  );
```

### AI Service (`LexiconEnricher`)

**Model:** Gemini 3 Flash (Tier 2)

**Prompt Template:**
```text
You are a wise mentor helping a user build their identity as a {{identity}}.
The user has added the word: "{{word}}".

1. Define it briefly.
2. Explain its etymology.
3. Explain why this word is a "Power Word" for a {{identity}}.
4. Give a practical challenge to use it today.

Output JSON:
{
  "definition": "...",
  "etymology": "...",
  "power_reason": "...",
  "challenge": "..."
}
```

---

## 4. UI/UX

### The Lexicon Screen
- **List View:** Cards with the word and a short definition.
- **Filter:** By Identity Tag (e.g., "Stoic Words", "Runner Words").
- **Add Button:** Floating Action Button (FAB) → Text Input or Voice Input.

### Word Detail Sheet
- **Hero:** The Word (Large Typography).
- **Body:** Etymology & "Power Reason".
- **Action:** "Mark as Used Today" (Increments mastery).

### Lock Screen (Wallet Integration)
- If the user has the **Pact Identity Card** (Phase 25.8), we update the `back_of_card` field with the "Word of the Day".

---

## 5. Implementation Plan

1.  **Database:** Run SQL migration to create `lexicon_entries`.
2.  **Backend:** Create `LexiconService` in Flutter to handle CRUD.
3.  **AI:** Implement `enrichWord()` in `GeminiLiveService` (or separate `LexiconEnricher`).
4.  **UI:** Build `LexiconScreen` and `WordDetailSheet`.
5.  **Wallet:** Connect `LexiconService` to `WalletService` to update the pass.

---

**End of Spec.**
