# Documentation Index — The Pact

> **Last Updated:** 26 December 2025

This directory contains technical documentation for The Pact app.

---

## 📁 Directory Structure

```
docs/
├── README.md                    # This file (index)
│
├── BUILD_PIPELINE.md            # Build commands and pipelines
├── VERIFICATION_CHECKLIST.md    # Testing the Gemini Live connection
├── GOOGLE_OAUTH_SETUP.md        # Google Sign-In configuration
├── ARCHITECTURE_MIGRATION.md    # Provider architecture guide
├── SUPABASE_SCHEMA.md           # Database schema
├── USER_JOURNEY_MAP.md          # UX flows
├── VOICE_COACH_VALIDATION.md    # Voice Coach testing
├── DEV_TOOLS_AUDIT.md           # Developer tools audit
│
├── PHASE_38_LOG_CONSOLE.md      # In-App Log Console
├── PHASE_37_PRODUCTION_READY.md # Headers fix
├── PHASE_36_ERROR_ANALYSIS.md   # 403 Forbidden analysis
│
├── GEMINI_LIVE_API_RESEARCH.md  # API research notes
├── GEMINI_WEBSOCKET_SCHEMA.md   # WebSocket message schema
├── GEMINI_MODEL_RESEARCH.md     # Model documentation
│
└── archive/                     # Legacy documentation (52 files)
    ├── [old phase specs]
    ├── [implementation summaries]
    └── [deprecated feature specs]
```

---

## 🚀 Quick Links

### Getting Started
| Document | Purpose |
|----------|---------|
| [BUILD_PIPELINE.md](./BUILD_PIPELINE.md) | Build the app |
| [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md) | Test voice connection |
| [GOOGLE_OAUTH_SETUP.md](./GOOGLE_OAUTH_SETUP.md) | Configure Google Sign-In |

### Architecture
| Document | Purpose |
|----------|---------|
| [ARCHITECTURE_MIGRATION.md](./ARCHITECTURE_MIGRATION.md) | Provider pattern guide |
| [SUPABASE_SCHEMA.md](./SUPABASE_SCHEMA.md) | Database schema |
| [USER_JOURNEY_MAP.md](./USER_JOURNEY_MAP.md) | UX flows |
| [DEV_TOOLS_AUDIT.md](./DEV_TOOLS_AUDIT.md) | Developer tools audit |

### Gemini Live API
| Document | Purpose |
|----------|---------|
| [PHASE_38_LOG_CONSOLE.md](./PHASE_38_LOG_CONSOLE.md) | In-App Log Console |
| [PHASE_37_PRODUCTION_READY.md](./PHASE_37_PRODUCTION_READY.md) | Headers fix |
| [PHASE_36_ERROR_ANALYSIS.md](./PHASE_36_ERROR_ANALYSIS.md) | 403 analysis |
| [GEMINI_LIVE_API_RESEARCH.md](./GEMINI_LIVE_API_RESEARCH.md) | API research |
| [GEMINI_WEBSOCKET_SCHEMA.md](./GEMINI_WEBSOCKET_SCHEMA.md) | Message schema |

---

## 📋 Core Documentation (Root Level)

These files are in the repository root:

| File | Purpose |
|------|---------|
| [README.md](../README.md) | Project overview |
| [AI_CONTEXT.md](../AI_CONTEXT.md) | AI assistant context |
| [ROADMAP.md](../ROADMAP.md) | Sprint history, priorities |
| [CHANGELOG.md](../CHANGELOG.md) | Version history |
| [CREDITS.md](../CREDITS.md) | Attribution |

---

## 🗄️ Archive

The `archive/` directory contains legacy documentation that is no longer actively maintained but preserved for reference:

- Old phase specs (Phase 19, 24, etc.)
- Implementation summaries
- Deprecated feature specs
- Historical sprint documentation

---

## 📝 Documentation Standards

### File Naming
- Use `SCREAMING_SNAKE_CASE.md` for documentation files
- Use descriptive names that indicate content
- Prefix phase-specific docs with `PHASE_XX_`

### Content Structure
1. Title with last updated date
2. Purpose/overview section
3. Main content with tables where appropriate
4. Code examples in fenced blocks
5. Links to related documentation

### Updating Documentation
1. Update the "Last Updated" date
2. Keep tables aligned and readable
3. Use UK English spelling
4. Commit with descriptive message
