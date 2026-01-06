# The Pact

> **"The Atomic Unit is Identity Evidence."**

A philosophical identity engine that turns daily actions into evidence of who you are becoming.
Built on **Flutter** (Mobile) with a hybrid AI architecture.

**Live URL:** [thepact.co](https://thepact.co)

---

## AI Agents: Start Here

If you are an AI agent (Claude, Gemini, etc.) working on this codebase, you **MUST** follow this protocol.

### Mandatory Reading Order

```
1. README.md (this file) ← YOU ARE HERE
2. docs/CORE/AI_HANDOVER.md (session context from last agent)
3. docs/CORE/index/CD_INDEX.md + PD_INDEX.md (quick decision status — START HERE)
4. docs/CORE/index/RQ_INDEX.md (quick research status — START HERE)
5. docs/CORE/PRODUCT_DECISIONS.md (full details for PENDING decisions only)
6. docs/CORE/RESEARCH_QUESTIONS.md (full details for ACTIVE research only)
7. docs/CORE/GLOSSARY.md (terminology definitions)
8. docs/CORE/AI_AGENT_PROTOCOL.md (mandatory AI behaviors)
9. docs/CORE/IMPACT_ANALYSIS.md (research-to-roadmap traceability)
10. AI_CONTEXT.md (technical architecture — note: may contain stale info)
11. ROADMAP.md (current priorities)
```

**Token Optimization:** Use index files (steps 3-4) for rapid status lookup before reading full files (steps 5-6).

### Before Making ANY Code Changes

- [ ] Read AI_HANDOVER.md completely
- [ ] Check PRODUCT_DECISIONS.md for PENDING items that block your work
- [ ] Understand the terminology in GLOSSARY.md
- [ ] Identify your session scope (docs only? code? both?)

### Before Processing External Research (Deep Think, Claude, Gemini, etc.)

- [ ] **RUN PROTOCOL 9** (`docs/CORE/AI_AGENT_PROTOCOL.md` → Protocol 9)
- [ ] Complete all 6 phases of the Reconciliation Checklist
- [ ] Categorize each proposal: ACCEPT / MODIFY / REJECT / ESCALATE
- [ ] Only extract tasks from ACCEPTED items

**Critical Rule:** Do NOT integrate external research without reconciliation. External AI tools don't have access to locked CDs or platform constraints.

### Before Ending Your Session

- [ ] Update AI_HANDOVER.md with what you accomplished and what remains
- [ ] Update PRODUCT_DECISIONS.md if you discovered new questions
- [ ] Commit your changes with descriptive messages
- [ ] Push to your branch

**Critical Rule:** Do NOT implement features marked as PENDING in PRODUCT_DECISIONS.md. Wait for human confirmation.

---

## Documentation Structure

### Document Hierarchy

Understanding the relationship between documents prevents conflicting decisions:

```
PRODUCT_DECISIONS.md (Philosophy — why we make choices)
    ↓ Confirmed decisions inform
ROADMAP.md (Direction — where we're going)
    ↓ Prioritized work informs
AI_CONTEXT.md (Technical Truth — what exists now)
    ↓ Architecture informs
Code Changes
```

**Key Insight:** Product decisions must be CONFIRMED before they appear in ROADMAP. ROADMAP items must be prioritized before implementation.

### Core Documents (Agent-Critical)

| Document | Type | Purpose | When to Update |
|----------|------|---------|----------------|
| **README.md** | Entry Point | Project overview, AI protocol | When fundamentals change |
| **[AI_CONTEXT.md](./AI_CONTEXT.md)** | Technical Truth | What exists NOW | When architecture changes |
| **[ROADMAP.md](./ROADMAP.md)** | Direction | Where we're going | When priorities change |
| **[CHANGELOG.md](./CHANGELOG.md)** | History | Version history | Every release |

### Core Folder (`/docs/CORE/`)

| Document | Type | Purpose | When to Update |
|----------|------|---------|----------------|
| **[AI_HANDOVER.md](./docs/CORE/AI_HANDOVER.md)** | Session Context | What the last agent did | Every session end |
| **[PRODUCT_DECISIONS.md](./docs/CORE/PRODUCT_DECISIONS.md)** | Philosophy | Why we chose X over Y | When decisions made/needed |
| **[GLOSSARY.md](./docs/CORE/GLOSSARY.md)** | Terminology | Definition of all terms | When new terms introduced |
| **[RESEARCH_QUESTIONS.md](./docs/CORE/RESEARCH_QUESTIONS.md)** | Active Research | Cross-agent research tracking | When research progresses |
| **[AI_AGENT_PROTOCOL.md](./docs/CORE/AI_AGENT_PROTOCOL.md)** | Behavioral Rules | Mandatory AI agent behaviors | When protocols change |
| **[IMPACT_ANALYSIS.md](./docs/CORE/IMPACT_ANALYSIS.md)** | Traceability | Research → Roadmap impacts | After research/decisions |
| **[IDENTITY_COACH_SPEC.md](./docs/CORE/IDENTITY_COACH_SPEC.md)** | Specification | AI identity development coach | When spec evolves |
| **[DEEP_THINK_PROMPT_GUIDANCE.md](./docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md)** | Quality Framework | Prompt engineering for external AI research | When preparing Deep Think prompts |

### Index Folder (`/docs/CORE/index/`)

Quick reference tables for rapid lookup (lightweight, always up-to-date summaries):

| Document | Purpose |
|----------|---------|
| **RQ_INDEX.md** | All Research Questions at a glance with status |
| **CD_INDEX.md** | All Confirmed Decisions at a glance |
| **PD_INDEX.md** | All Pending Decisions at a glance |

### Archive Folder (`/docs/CORE/archive/`)

Full content for COMPLETE/RESOLVED items (reduces main file token count):

| Document | Purpose |
|----------|---------|
| **RQ_ARCHIVE_Q1_2026.md** | Full findings for completed RQs |
| **CD_PD_ARCHIVE_Q1_2026.md** | Full rationale for confirmed/resolved decisions |

### What Makes a Core Document

A document is "Core" if it meets ALL criteria:
1. **Referenced by AI agents** before making decisions
2. **Updated when state changes** (not just initially created)
3. **Clearly labelled** as one of:
   - Truth (what exists now)
   - Direction (where we're going)
   - Philosophy (why we make choices)
   - Context (what happened in past sessions)
4. **Has clear ownership** (who is responsible for updates)

### Why Each Doc Exists (Quick Reference)

| Doc | Exists Because | Without It |
|-----|----------------|------------|
| **AI_HANDOVER.md** | Context is lost between sessions | Agents repeat work, miss context |
| **PRODUCT_DECISIONS.md** | Philosophy drives architecture | Agents make conflicting choices |
| **GLOSSARY.md** | Terms have specific meanings | "Archetype" means different things |
| **RESEARCH_QUESTIONS.md** | Research informs decisions | Decisions made without evidence |
| **AI_AGENT_PROTOCOL.md** | Behaviors must be consistent | Agents skip critical steps |
| **IMPACT_ANALYSIS.md** | Decisions have cascading effects | Downstream impacts missed |
| **DEEP_THINK_PROMPT_GUIDANCE.md** | Research quality depends on prompt quality | Vague, unimplementable research output |

### Doc Maintenance Protocol (Preventing Reality Drift)

**Problem:** Docs become stale when they don't reflect actual code/decisions.

**Solution:** Mandatory update triggers and consistency checks.

#### Update Triggers

| Event | Must Update |
|-------|-------------|
| Code architecture changes | AI_CONTEXT.md |
| Product decision made | PRODUCT_DECISIONS.md |
| Research concludes | RESEARCH_QUESTIONS.md → IMPACT_ANALYSIS.md |
| Session ends | AI_HANDOVER.md |
| New term introduced | GLOSSARY.md |
| Feature implemented | ROADMAP.md (mark complete) |

#### Cross-Doc Consistency Checks

**All 12 Core Documents Categorized by Update Frequency:**

| Doc | Category | Static/Dynamic | Update Trigger |
|-----|----------|----------------|----------------|
| **README.md** | Entry Point | Semi-Static | Only when fundamentals change |
| **CHANGELOG.md** | History | Append-Only | Every release |
| **GLOSSARY.md** | Terminology | Mostly Static | New term introduced |
| **AI_AGENT_PROTOCOL.md** | Behavioral Rules | Mostly Static | Protocol changes |
| **DEEP_THINK_PROMPT_GUIDANCE.md** | Quality Framework | Mostly Static | Prompt engineering practices change |
| **AI_CONTEXT.md** | Technical Truth | Dynamic | Architecture changes |
| **ROADMAP.md** | Direction | Dynamic | Priority changes |
| **PRODUCT_DECISIONS.md** | Philosophy | Dynamic | Decisions made/needed |
| **RESEARCH_QUESTIONS.md** | Research | Dynamic | Research progresses |
| **IMPACT_ANALYSIS.md** | Traceability | Dynamic | After research/decisions |
| **AI_HANDOVER.md** | Session Context | Ephemeral | Every session end |
| **IDENTITY_COACH_SPEC.md** | Specification | Dynamic | Spec evolves |

**Before Ending Session — Full Consistency Check:**

```
□ TIER 1 (Always Check):
  □ AI_HANDOVER.md — Updated with session summary
  □ PRODUCT_DECISIONS.md — Any new decisions documented
  □ RESEARCH_QUESTIONS.md — Status reflects actual state

□ TIER 2 (If Relevant):
  □ IMPACT_ANALYSIS.md — Cascade effects logged (if research/decisions made)
  □ ROADMAP.md — Priorities align with confirmed decisions
  □ AI_CONTEXT.md — Architecture diagrams current (if code changes)
  □ GLOSSARY.md — Contains all terms used in other docs

□ TIER 3 (Rarely):
  □ AI_AGENT_PROTOCOL.md — Only if behavioral rules change
  □ IDENTITY_COACH_SPEC.md — Only if Identity Coach spec evolves
  □ README.md — Only if fundamental project info changes
  □ CHANGELOG.md — Only on release
```

**Cross-Reference Matrix (What Must Stay Aligned):**

| If This Changes... | ...Update These |
|--------------------|-----------------|
| Product Decision confirmed | PRODUCT_DECISIONS.md → ROADMAP.md → IMPACT_ANALYSIS.md |
| Research concludes | RESEARCH_QUESTIONS.md → IMPACT_ANALYSIS.md → PRODUCT_DECISIONS.md |
| Architecture changes | AI_CONTEXT.md → README.md (if fundamental) |
| New term introduced | GLOSSARY.md → All docs using the term |
| Feature implemented | ROADMAP.md (mark complete) → CHANGELOG.md (on release) |
| Session ends | AI_HANDOVER.md (always) |

#### Reality Alignment Rules

1. **Code Changes → Doc Updates:** Any code change affecting architecture must include doc updates
2. **Weekly Audit:** Human reviews docs against codebase weekly
3. **AI Verification:** Each session starts with consistency check
4. **Flag Staleness:** If a doc seems wrong, flag it rather than assuming it's correct

### Other Documentation

| Folder | Purpose |
|--------|---------|
| `/docs/` | Technical guides (build, OAuth, testing) |
| `/docs/archive/` | Historical documents (DEPRECATED — reference only) |
| `/docs/audits/` | Code audit reports |
| `/docs/architecture/` | Architecture decision records |

### Archive Documents Warning

Files in `/docs/archive/` are **DEPRECATED**. They:
- Reference old commits, phases, and approaches
- Should NOT be treated as current truth
- Exist for historical reference only
- Will be audited individually in a future sprint

---

## 📊 Current Status (January 2026)

| Component | Status | Details |
|-----------|--------|---------|
| **Mobile App** | 🟢 Phase 68 | Onboarding Calibration (V4 Navigation + Auth Repair) |
| **Landing Page** | 🟢 Live | [thepact.co](https://thepact.co) |
| **Backend** | 🟢 Live | Supabase + Edge Functions + pgvector |
| **Voice AI** | 🟢 **Stable** | Hybrid Stack: Gemini 3 (Brain) + Gemini 2.5 (Voice) |
| **Text AI** | 🟢 **Ready** | DeepSeek V3 + RAG Vector Memory |
| **Cloud Sync** | 🟢 **Stable** | Hybrid Storage + JITAI State + Evidence Logs |
| **Database** | 🟢 **Aligned** | Schema v2.3.0 (Vector Embeddings) |

> **Last Updated:** 04 January 2026  
> **Current Phase:** Onboarding Calibration (Phase 68 Verified)  
> **Target:** Launch 16 Jan 2026  
> **Language:** UK English (Default)

---

## 🎯 The Augmented Constitution

We are not building a habit tracker. We are building an **Identity Evidence Engine**.

| Principle | Description |
|-----------|-------------|
| **Atomic Unit** | **Identity Evidence**. Not "Checkboxes". |
| **Analysis** | **Gap Analysis**. The AI detects dissonance between your Stated Values and your Observed Behavior. |
| **Interaction** | **Voice & Chat**. Natural conversation with AI coaching personas. |
| **Visuals** | **Living Garden**. A responsive UI (PLANNED — not yet implemented). |
| **Voice First** | **Magic Wand Onboarding**. Sherlock extracts your Core Values and Shadow (Holy Trinity). |

---

## 🛠️ Tech Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Mobile** | Flutter 3.38.4 | The Core Experience |
| **Web** | React + Vite + Tailwind | The Landing Page |
| **Backend** | Supabase | Auth, Database, Realtime, Edge Functions |
| **AI (Interactive)** | Gemini 3 Flash | **The Actor:** Sherlock, Shadow Dialogues, Real-time Interaction. |
| **AI (Voice)** | Gemini 2.5 Flash | **The Mouth:** Lazy TTS (On-Demand Generation). |
| **AI (Analysis)** | DeepSeek-V3 | **The Analyst:** Async Gap Analysis & Psychometrics. |
| **Visualization** | Rive | **The Garden:** Living ecosystem engine. |

---

## 🚀 Quick Start

### Build the App

**Single Command Pipeline:**
```bash
git pull origin main && flutter clean && flutter pub get && flutter build apk --debug --dart-define-from-file=secrets.json
```

**Output:** `build/app/outputs/flutter-apk/app-debug.apk`

### Secrets Configuration

Create `secrets.json` in project root:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your_supabase_anon_key",
  "GOOGLE_WEB_CLIENT_ID": "your-web-client-id.apps.googleusercontent.com",
  "DEEPSEEK_API_KEY": "your_deepseek_key",
  "GEMINI_API_KEY": "your_gemini_key"
}
```

> **Note:** `secrets.json` is in `.gitignore`. Never commit API keys.

---

## 📖 Documentation

> **Note:** See "Documentation Structure" section above for the full hierarchy and reading order.

### Core Documents

| File | Type | Purpose |
|------|------|---------|
| **[AI_CONTEXT.md](./AI_CONTEXT.md)** | Technical Truth | Architecture, feature matrix |
| **[ROADMAP.md](./ROADMAP.md)** | Direction | Current priorities |
| **[CHANGELOG.md](./CHANGELOG.md)** | History | Version history |
| **[docs/CORE/AI_HANDOVER.md](./docs/CORE/AI_HANDOVER.md)** | Session Context | Last agent's work |
| **[docs/CORE/PRODUCT_DECISIONS.md](./docs/CORE/PRODUCT_DECISIONS.md)** | Philosophy | Confirmed & pending decisions |
| **[docs/CORE/GLOSSARY.md](./docs/CORE/GLOSSARY.md)** | Terminology | Term definitions |
| **[docs/CORE/RESEARCH_QUESTIONS.md](./docs/CORE/RESEARCH_QUESTIONS.md)** | Research | Active cross-agent research |

### Technical Guides

| Guide | Purpose |
|-------|---------|
| **[docs/BUILD_PIPELINE.md](./docs/BUILD_PIPELINE.md)** | Build commands and pipelines |
| **[docs/dt.md](./docs/dt.md)** | Device Testing & Golden Command Chain |
| **[docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** | Google Sign-In configuration |
| **[docs/ARCHITECTURE_MIGRATION.md](./docs/ARCHITECTURE_MIGRATION.md)** | Provider architecture guide |
| **[docs/GEMINI_LIVE_API_RESEARCH.md](./docs/GEMINI_LIVE_API_RESEARCH.md)** | Gemini API research notes |

---

## 🏗️ Architecture

### Directory Structure

```
lib/
├── config/                 # App configuration
│   ├── ai_model_config.dart    # AI model settings
│   ├── ai_prompts.dart         # Phase 42: Sherlock Protocol prompts
│   ├── ai_tools_config.dart    # Phase 42: Tool schemas for function calling
│   └── router/
│       ├── app_routes.dart     # Route constants (Phase 41)
│       └── app_router.dart     # GoRouter config (Phase 41)
│
├── core/                   # Core utilities
│   └── logging/
│       └── log_buffer.dart     # Centralized logging (Phase 38)
│
├── data/
│   ├── repositories/       # Infrastructure Layer
│   │   ├── settings_repository.dart
│   │   ├── user_repository.dart
│   │   ├── habit_repository.dart
│   │   └── psychometric_repository.dart
│   │
│   ├── providers/          # State Management
│   │   ├── settings_provider.dart
│   │   ├── user_provider.dart
│   │   ├── habit_provider.dart
│   │   └── psychometric_provider.dart
│   │
│   ├── services/           # External Services
│   │   ├── gemini_live_service.dart     # Phase 42: Tool calling support
│   │   ├── audio_recording_service.dart
│   │   ├── voice_session_manager.dart   # Phase 42: Orchestration
│   │   └── ai/
│   │       └── prompt_factory.dart      # Phase 42: Dynamic prompts
│   │
│   └── app_state.dart      # Legacy (being strangled)
│
├── domain/
│   └── services/           # Domain Logic
│       ├── psychometric_engine.dart
│       └── voice_provider_selector.dart # Diagnostics tool (Phase 46)
│
└── features/
    ├── dev/                # Developer Tools
    │   ├── dev_tools_overlay.dart
    │   └── debug_console_view.dart     # Log viewer (Phase 38)
    │
    └── onboarding/         # Onboarding Flow
        └── voice_coach_screen.dart
```

### Voice Architecture (Phase 42: Tool Calling)

```
User → Voice Coach Screen
         ↓
     Voice Session Manager
         ↓
    VoiceApiService (Interface)
    (Gemini / OpenAI)
         ↓
    Direct WebSocket
  (Edge Fn Removed)
         ↓
    AI Provider API
    + Tool Calling Support
         ↓
   ┌─────┴─────┐
   │           │
Audio     tool_call event
   │           │
   │     PsychometricProvider
   │     → Hive (immediate save)
   │           │
   └─────┬─────┘
         ↓
   tool_response → AI continues
```

---

## 🔧 Developer Tools

### Accessing DevTools

**Triple-tap** any screen title to open the Developer Tools overlay.

### Features

| Feature | Status | Notes |
| :--- | :---: | :--- |
| **Premium Toggle** | Enable/disable Tier 2 (Voice) mode |
| **View Logs** | In-App Voice Log Console |
| **Connection Test** | Pings real servers for latency (Phase 46) |
| **B2C MVP** | 🟢 | **Stable** (iOS/Android) |
| **Sherlock (Voice)** | 🟢 | **Active** (Gemini Live v1beta) |
| **Audio Response** | 🟢 | **Fixed** (Universal Parser) |
| **Psychometrics** | 🟡 | Data Layer Ready, Logic in Progress |
| **Orchestrator** | 🔴 | Planned (Q1 2026) |
| **Quick Navigation** | Jump to any screen |

### Debugging Voice Connection

1. Open DevTools (triple-tap)
2. Enable Premium Mode
3. Navigate to Voice Coach
4. Tap microphone to connect
5. Open "View Gemini Logs" to see connection details
6. Copy logs for debugging

---

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Voice Connection Test

See **[docs/dt.md](./docs/dt.md)** for the full testing protocol.

---

## 🚢 Deployment

### Android

```bash
flutter build appbundle --release --dart-define-from-file=secrets.json
```

### iOS

```bash
flutter build ipa --release --dart-define-from-file=secrets.json
```

### Supabase Edge Functions

```bash
supabase functions deploy get-gemini-ephemeral-token --project-ref lwzvvaqgvcmsxblcglxo
supabase secrets set GEMINI_API_KEY=your_key --project-ref lwzvvaqgvcmsxblcglxo
```

---

## 🔧 Troubleshooting

### Voice Not Connecting

1. **Check DevTools:** Is Premium Mode enabled?
2. **Check API Key:** Is `GEMINI_API_KEY` in `secrets.json`?
3. **Check Logs:** Open "View Gemini Logs" in DevTools
4. **Follow Checklist:** See [docs/dt.md](./docs/dt.md)

### Google Sign-In Failing

See **[docs/GOOGLE_OAUTH_SETUP.md](./docs/GOOGLE_OAUTH_SETUP.md)** for the full setup guide.

**Quick Checklist:**

| Check | Location |
|-------|----------|
| Supabase URL | `secrets.json` |
| Web Client ID | `secrets.json` |
| Package name | Must be `co.thepact.app` |
| SHA-1 fingerprint | `cd android && ./gradlew signingReport` |
| OAuth consent | Add test email in Google Cloud Console |

---

## 📄 Licence

MIT Licence - See LICENCE file for details

---

## 🙏 Acknowledgements

Built with inspiration from James Clear's *Atomic Habits* and the philosophy of social accountability.

**Architecture** guided by the "Council of Five": Martin Fowler, Eric Evans, Robert C. Martin, Casey Muratori, and Remi Rousselet.

**Voice Integration** powered by Google's Gemini Live API.
