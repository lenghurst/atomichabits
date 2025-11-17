# End-to-End Testing & Debugging Guide

Complete guide for running and verifying the entire Atomic Habits system: **Flutter app + Node.js backend + OpenAI LLM integration**.

This guide is designed for developers, testers, and anyone who wants to understand how the pieces fit together and verify everything works end-to-end.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Running the Backend (Heuristics-Only Mode)](#running-the-backend-heuristics-only-mode)
3. [Running the Backend (LLM Mode with OpenAI)](#running-the-backend-llm-mode-with-openai)
4. [Running the Flutter App Against the Backend](#running-the-flutter-app-against-the-backend)
5. [Test Scenarios](#test-scenarios)
   - [Scenario A: Basic Heuristics-Only Flow](#scenario-a-basic-heuristics-only-flow)
   - [Scenario B: LLM-Powered Suggestions](#scenario-b-llm-powered-suggestions)
   - [Scenario C: OpenAI Failure / Fallback](#scenario-c-openai-failure--fallback)
   - [Scenario D: Backend Unreachable (Frontend Fallback)](#scenario-d-backend-unreachable-frontend-fallback)
6. [Debugging](#debugging)

---

## Prerequisites

To run the full system locally, you'll need:

### Software Requirements

- **Node.js** (v18 or later) and **npm** (for the backend)
  - Check: `node --version` and `npm --version`
  - Download: https://nodejs.org/

- **Flutter SDK** (for the client app)
  - Check: `flutter --version`
  - Download & setup: https://docs.flutter.dev/get-started/install

- **OpenAI API Key** (optional, for LLM mode)
  - Get one at: https://platform.openai.com/api-keys
  - Not required if you just want to test with heuristic suggestions

### Repository Structure

```
atomichabits/
├── backend/              # Node.js/TypeScript backend
│   ├── src/
│   │   ├── server.ts
│   │   ├── routes/habitSuggestions.ts
│   │   └── services/suggestionService.ts
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
├── lib/                  # Flutter app source
│   └── data/
│       └── ai_suggestion_service.dart  # Client-side API integration
├── pubspec.yaml          # Flutter dependencies
└── E2E_TESTING_AND_DEBUGGING.md  # This file
```

---

## Running the Backend (Heuristics-Only Mode)

The simplest way to get started is to run the backend **without OpenAI** - it will use local heuristic suggestions only.

### Commands

```bash
cd backend
npm install
npm run dev
```

### What to Expect

When the server starts, you'll see:

```
============================================================
🚀 Atomic Habits Backend Server
============================================================
📍 Server running on: http://localhost:3000
🔑 OpenAI API Key: ❌ Not set (will use heuristics only)
💡 Health check: http://localhost:3000/health
📡 API endpoint: http://localhost:3000/api/habit-suggestions
============================================================
```

**Key indicator:** `🔑 OpenAI API Key: ❌ Not set (will use heuristics only)`

When you make a request, the backend will log:

```
⚠️  OPENAI_API_KEY not set – using heuristic suggestions only
```

### Testing with curl

Test the endpoint directly:

```bash
curl -X POST http://localhost:3000/api/habit-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "suggestion_type": "temptation_bundle",
    "habit_name": "Read for 10 minutes",
    "identity": "a person who reads daily",
    "time": "22:00",
    "location": "In bed before sleep"
  }'
```

**Expected response:**

```json
{
  "suggestions": [
    "Have a cup of herbal tea while reading",
    "Light a candle and read with soft lighting",
    "Listen to calm instrumental music while you read"
  ]
}
```

**Backend logs:**

```
📥 Received suggestion request: temptation_bundle for "Read for 10 minutes"
⚠️  OPENAI_API_KEY not set – using heuristic suggestions only
📤 Returning 3 suggestions
```

---

## Running the Backend (LLM Mode with OpenAI)

To use real AI-powered suggestions, configure your OpenAI API key.

### Setup

**Option 1: Using .env file (recommended)**

```bash
cd backend
cp .env.example .env
# Edit .env and add your real API key:
# OPENAI_API_KEY=sk-your-actual-key-here
npm run dev
```

**Option 2: Using environment variable**

```bash
cd backend
export OPENAI_API_KEY=sk-your-actual-key-here
npm run dev
```

### What to Expect

Server startup with API key configured:

```
============================================================
🚀 Atomic Habits Backend Server
============================================================
📍 Server running on: http://localhost:3000
🔑 OpenAI API Key: ✅ Configured
💡 Health check: http://localhost:3000/health
📡 API endpoint: http://localhost:3000/api/habit-suggestions
============================================================
```

**Key indicator:** `🔑 OpenAI API Key: ✅ Configured`

### Testing with curl

Use the same curl command as before:

```bash
curl -X POST http://localhost:3000/api/habit-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "suggestion_type": "pre_habit_ritual",
    "habit_name": "Meditate for 5 minutes",
    "identity": "a calm and mindful person",
    "time": "07:00",
    "location": "Living room corner"
  }'
```

**Backend logs (successful OpenAI call):**

```
📥 Received suggestion request: pre_habit_ritual for "Meditate for 5 minutes"
🤖 Attempting OpenAI LLM call for pre_habit_ritual...
✅ OpenAI returned 3 suggestions
📤 Returning 3 suggestions
```

**Expected response:**

```json
{
  "suggestions": [
    "Light a candle or incense stick before sitting down to create a calming atmosphere",
    "Take three deep breaths and roll your shoulders back to release tension",
    "Set your phone to airplane mode and place it face-down across the room"
  ]
}
```

The suggestions will be generated by OpenAI and tailored to your specific context (morning meditation, identity, location).

### Recognizing LLM vs Heuristic Suggestions in Logs

| Log Message | Meaning |
|------------|---------|
| `🤖 Attempting OpenAI LLM call for ...` | Backend is trying OpenAI |
| `✅ OpenAI returned N suggestions` | OpenAI succeeded, using AI suggestions |
| `❌ OpenAI call failed: ...` | OpenAI failed (network, timeout, error) |
| `🔄 Falling back to heuristic suggestions` | Using local heuristics as fallback |
| `⚠️ OPENAI_API_KEY not set – using heuristic suggestions only` | No API key, skipping OpenAI entirely |

### Testing the Weekly Review Endpoint

The backend also provides `/api/habit-review` for generating AI-powered weekly reviews based on completion history.

**Example request:**

```bash
curl -X POST http://localhost:3000/api/habit-review \
  -H "Content-Type: application/json" \
  -d '{
    "habit": {
      "habit_name": "Read for 10 minutes",
      "identity": "a person who reads daily",
      "time": "22:00",
      "location": "In bed"
    },
    "history": [
      { "date": "2025-11-10", "completed": true },
      { "date": "2025-11-09", "completed": false },
      { "date": "2025-11-08", "completed": true },
      { "date": "2025-11-07", "completed": true },
      { "date": "2025-11-06", "completed": false },
      { "date": "2025-11-05", "completed": true },
      { "date": "2025-11-04", "completed": true }
    ]
  }'
```

**Expected response (with OpenAI):**

```json
{
  "summary": "You completed 'Read for 10 minutes' 5 out of 7 days this week (71%). Good progress! Keep building momentum.",
  "insights": [
    "Your longest streak was 3 days - you can maintain consistency!",
    "Weekdays are stronger than weekends - your routine helps consistency."
  ],
  "suggested_adjustments": [
    "Make it obvious: Set up a clear visual cue in your space.",
    "Keep your current system - it's working well!"
  ]
}
```

The same LLM + fallback pattern applies: if `OPENAI_API_KEY` is set, it tries OpenAI; otherwise it uses heuristic review logic based on completion statistics and patterns.

---

## Running the Flutter App Against the Backend

The Flutter app is already configured to call `http://localhost:3000/api/habit-suggestions` in development mode.

### Commands

From the repository root:

```bash
flutter pub get
flutter run -d chrome
```

Or run on a specific device:

```bash
flutter devices               # List available devices
flutter run -d macos          # Run on macOS
flutter run -d windows        # Run on Windows
flutter run                   # Run on default device
```

### Prerequisites

1. **Backend must be running first**
   - Start the backend: `cd backend && npm run dev`
   - Verify it's running: `curl http://localhost:3000/health`

2. **Endpoint is correctly configured**
   - The Flutter app points to: `http://localhost:3000/api/habit-suggestions`
   - Defined in: `lib/data/ai_suggestion_service.dart` line 27

### What to Expect

When the Flutter app makes a suggestion request, you'll see:

**Flutter debug console:**
```
📡 Attempting remote LLM call for temptation_bundle...
✅ Using remote LLM suggestions for temptation bundle
```

**Backend console (simultaneously):**
```
📥 Received suggestion request: temptation_bundle for "Read for 10 minutes"
🤖 Attempting OpenAI LLM call for temptation_bundle...
✅ OpenAI returned 3 suggestions
📤 Returning 3 suggestions
```

### If Backend is Down

If the backend is not running or unreachable, the Flutter app will:

1. Attempt to connect for 5 seconds (timeout)
2. Log an error: `⚠️ Remote LLM failed for temptation_bundle: ...`
3. Fall back to local Dart heuristics: `🔄 Using local fallback for temptation bundle`
4. **Still show suggestions to the user** (no crash)

---

## Test Scenarios

Complete end-to-end test scenarios with steps, expected logs, and expected behavior.

---

### Scenario A: Basic Heuristics-Only Flow

**Objective:** Verify the entire system works without OpenAI, using only heuristic suggestions.

#### Setup
1. **Backend:** Run without `OPENAI_API_KEY`
   ```bash
   cd backend
   unset OPENAI_API_KEY  # or just don't set it
   npm run dev
   ```

2. **Flutter:** Start the app
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. Open the app in your browser
2. Go through the onboarding flow:
   - **Identity:** "a person who reads daily"
   - **Habit:** "Read one page"
   - **Two-minute version:** "Open book to bookmark"
   - **Time:** 22:00
   - **Location:** "In bed before sleep"

3. On each suggestion step, tap the **"Ideas 💡"** button:
   - Step 4: **Temptation Bundling** → Tap "Ideas 💡"
   - Step 5: **Pre-habit Ritual** → Tap "Ideas 💡"
   - Step 6: **Environment Cue** → Tap "Ideas 💡"
   - Step 7: **Environment Distraction** → Tap "Ideas 💡"

#### Expected Backend Logs

For each "Ideas 💡" button tap:

```
📥 Received suggestion request: temptation_bundle for "Read one page"
⚠️  OPENAI_API_KEY not set – using heuristic suggestions only
📤 Returning 3 suggestions

📥 Received suggestion request: pre_habit_ritual for "Read one page"
⚠️  OPENAI_API_KEY not set – using heuristic suggestions only
📤 Returning 3 suggestions

📥 Received suggestion request: environment_cue for "Read one page"
⚠️  OPENAI_API_KEY not set – using heuristic suggestions only
📤 Returning 3 suggestions

📥 Received suggestion request: environment_distraction for "Read one page"
⚠️  OPENAI_API_KEY not set – using heuristic suggestions only
📤 Returning 3 suggestions
```

#### Expected App Behavior

- ✅ Suggestions appear within ~1-2 seconds (no network delay, local heuristics)
- ✅ Each suggestion is concrete and actionable
- ✅ Suggestions are context-aware:
  - Time: 22:00 → evening/night suggestions (herbal tea, candles, calm music)
  - Habit: "Read" → reading-specific suggestions (book on pillow, tea while reading)
  - No OpenAI calls were made (check backend logs)

#### Example Suggestions

**Temptation Bundle (22:00, reading):**
- "Have a cup of herbal tea while reading"
- "Light a candle and read with soft lighting"
- "Listen to calm instrumental music while you read"

**Pre-habit Ritual:**
- "Take 3 slow breaths and open your book to the bookmark"
- "Put your phone in another room, then sit in your reading chair"
- "Write down one thing you're curious about, then start reading"

**Environment Cue:**
- "Put your book on your pillow at 21:45"
- "Leave your book open on your nightstand"
- "Place your book on top of your phone charger"

**Environment Distraction:**
- "Charge your phone in another room during this time"
- "Log out of social media apps or use website blockers"
- "Turn off TV and close all browser tabs"

---

### Scenario B: LLM-Powered Suggestions

**Objective:** Verify OpenAI integration works and returns richer, AI-generated suggestions.

#### Setup

1. **Backend:** Run with `OPENAI_API_KEY` set
   ```bash
   cd backend
   export OPENAI_API_KEY=sk-your-actual-key
   npm run dev
   ```
   Verify: `🔑 OpenAI API Key: ✅ Configured`

2. **Flutter:** Start the app
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. Go through the same onboarding flow as Scenario A:
   - Habit: "Write in my journal"
   - Time: 21:00
   - Location: "Desk in bedroom"

2. Tap each **"Ideas 💡"** button and observe

#### Expected Backend Logs

```
📥 Received suggestion request: temptation_bundle for "Write in my journal"
🤖 Attempting OpenAI LLM call for temptation_bundle...
✅ OpenAI returned 3 suggestions
📤 Returning 3 suggestions

📥 Received suggestion request: pre_habit_ritual for "Write in my journal"
🤖 Attempting OpenAI LLM call for pre_habit_ritual...
✅ OpenAI returned 3 suggestions
📤 Returning 3 suggestions

📥 Received suggestion request: environment_cue for "Write in my journal"
🤖 Attempting OpenAI LLM call for environment_cue...
✅ OpenAI returned 3 suggestions
📤 Returning 3 suggestions

📥 Received suggestion request: environment_distraction for "Write in my journal"
🤖 Attempting OpenAI LLM call for environment_distraction...
✅ OpenAI returned 3 suggestions
📤 Returning 3 suggestions
```

**Key indicators:**
- `🤖 Attempting OpenAI LLM call...` confirms API calls
- `✅ OpenAI returned 3 suggestions` confirms success
- No fallback messages

#### Expected App Behavior

- ✅ Suggestions appear within ~2-5 seconds (includes OpenAI API latency)
- ✅ Suggestions are contextual and may be more creative/varied than heuristics
- ✅ All suggestions are still short, concrete, and actionable
- ✅ Response format is identical: `{ "suggestions": [...] }`

#### Example AI-Generated Suggestions

**Temptation Bundle (21:00, journaling at desk):**
- "Light your favorite scented candle and play soft lo-fi music while you write"
- "Brew a cup of chamomile tea and keep it beside your journal"
- "Use your nicest pen and a fresh page—make it feel special"

**Pre-habit Ritual:**
- "Close your eyes, take three deep breaths, and set an intention for your journaling"
- "Write the date at the top of the page and read your last entry"
- "Put your phone on Do Not Disturb and place it face-down across the room"

**Environment Cue:**
- "Leave your journal open to a blank page on your desk at 20:45"
- "Place your favorite pen on top of your journal where you can't miss it"
- "Set a phone reminder for 21:00 labeled 'Journal time at desk'"

**Environment Distraction:**
- "Close all browser tabs except your writing app before 21:00"
- "Turn off desktop notifications and put your phone in another room"
- "Use a website blocker to prevent social media access from 21:00-21:30"

---

### Scenario C: OpenAI Failure / Fallback

**Objective:** Verify graceful degradation when OpenAI fails - the system should fall back to heuristics automatically.

#### Setup

1. **Backend:** Run with an **invalid** `OPENAI_API_KEY`
   ```bash
   cd backend
   export OPENAI_API_KEY=sk-invalid-key-12345
   npm run dev
   ```

2. **Flutter:** Start the app
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. Go through onboarding with any habit
2. Tap **"Ideas 💡"** on any suggestion step

#### Expected Backend Logs

```
📥 Received suggestion request: temptation_bundle for "Meditate for 5 minutes"
🤖 Attempting OpenAI LLM call for temptation_bundle...
❌ OpenAI call failed: Request failed with status code 401
🔄 Falling back to heuristic suggestions
📤 Returning 3 suggestions
```

**Key indicators:**
- `❌ OpenAI call failed: ...` shows the error
- `🔄 Falling back to heuristic suggestions` shows automatic fallback
- `📤 Returning 3 suggestions` confirms suggestions were still returned

#### Expected App Behavior

- ✅ Suggestions still appear (no crash or blank screen)
- ✅ The user sees suggestions from heuristics (seamless experience)
- ✅ There may be a ~5 second delay (timeout before fallback)
- ✅ Flutter logs may show: `✅ Using remote LLM suggestions` (Flutter doesn't know the backend used fallback)

#### Other Ways to Trigger Fallback

**Network disconnect:**
```bash
# Temporarily disable network for backend process
# (OS-specific, or just unplug Ethernet/turn off Wi-Fi)
```

**OpenAI API timeout (simulate slow network):**
- The backend has a 5-second timeout
- If OpenAI takes longer, it will automatically fall back

**OpenAI service outage:**
- Check https://status.openai.com
- During an outage, all requests will fall back to heuristics

---

### Scenario D: Backend Unreachable (Frontend Fallback)

**Objective:** Verify the Flutter app gracefully handles backend failure by using local Dart heuristics.

#### Setup

1. **Backend:** **DO NOT START IT** (or stop it if running)
   ```bash
   # Make sure backend is NOT running on port 3000
   curl http://localhost:3000/health  # Should fail
   ```

2. **Flutter:** Start the app
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. Go through onboarding with any habit
2. Tap **"Ideas 💡"** button on any suggestion step

#### Expected Flutter Debug Logs

```
📡 Attempting remote LLM call for temptation_bundle...
❌ Remote LLM error: Failed host lookup: 'localhost'
⚠️ Remote LLM failed for temptation bundle: Failed host lookup: 'localhost'
🔄 Using local fallback for temptation bundle
```

**Or:**

```
📡 Attempting remote LLM call for pre_habit_ritual...
⏱️ Remote LLM timeout after 5s
⚠️ Remote LLM failed for pre-habit ritual: TimeoutException after 5 seconds
🔄 Using local fallback for pre-habit ritual
```

**Key indicators:**
- `❌ Remote LLM error: ...` or `⏱️ Remote LLM timeout`
- `🔄 Using local fallback for ...` confirms Dart-side heuristics

#### Expected App Behavior

- ✅ Suggestions still appear after ~5 seconds (timeout delay)
- ✅ Suggestions are from Flutter's local heuristic logic (identical to backend heuristics)
- ✅ No crash, no blank screen
- ✅ User experience is degraded (slower) but functional

#### Expected Backend Logs

**None** - the backend is not running, so there will be no logs.

---

### Scenario E: Coach Onboarding Flow (LLM Mode)

**Objective:** Test the "Talk to the Coach" conversational onboarding feature which generates a complete habit plan from user answers.

#### Setup

1. **Backend:** Run with valid `OPENAI_API_KEY`
   ```bash
   cd backend
   export OPENAI_API_KEY=sk-your-real-key-here
   npm run dev
   ```

2. **Flutter:** Start the app
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. **Start the app** and land on the onboarding screen
2. **Tap "Start Coach Conversation"** button (purple card at the top)
3. **Answer the 5 coach questions:**
   - Q1: "What type of person are you trying to become?"
     - Example: "a reader"
   - Q2: "What's one small habit that would support that?"
     - Example: "read more books"
   - Q3: "When in your day does this realistically fit?"
     - Example: "before bed around 9pm"
   - Q4: "Where will you usually be when doing it?"
     - Example: "in bed"
   - Q5: "What would make this more enjoyable or obvious?"
     - Example: "having herbal tea"
4. **Tap "Generate My Plan"** and wait for the loading state
5. **Review the generated plan** in the summary dialog
6. **Tap "Apply to My Setup"** to populate the form

#### Expected Backend Logs

```
📞 POST /api/coach/onboarding - Received request
📝 Coach context: ✓ ✓ ✓ ✓ ✓
🤖 Attempting OpenAI LLM call for coach onboarding...
✅ Generated habit plan: "Read every day" (confidence: 0.85)
```

**Key indicators:**
- `🤖 Attempting OpenAI LLM call for coach onboarding...` confirms API call
- `✅ Generated habit plan:` confirms success
- Confidence score shown (typically 0.7-0.95)

#### Expected App Behavior

- ✅ Loading dialog appears: "The coach is designing your habit plan..."
- ✅ Plan summary dialog appears within 2-5 seconds
- ✅ Plan shows all fields:
  - Identity: "I am a reader"
  - Habit: "Read every day"
  - Tiny Version: "Read one page"
  - Time & Location: "21:00 at In bed"
  - Optional fields: temptation bundle, pre-habit ritual, environment cue, distraction
- ✅ After "Apply to My Setup", onboarding form is fully populated
- ✅ Green snackbar: "AI-generated plan. Review and adjust as needed."
- ✅ All fields are editable - user can modify before saving

#### Testing the Coach Endpoint Directly (curl)

```bash
curl -X POST http://localhost:3000/api/coach/onboarding \
  -H "Content-Type: application/json" \
  -d '{
    "desired_identity": "a reader",
    "habit_idea": "read more books",
    "when_in_day": "before bed around 9pm",
    "where_location": "in bed",
    "what_makes_it_enjoyable": "having herbal tea"
  }'
```

**Expected Response:**
```json
{
  "habit_plan": {
    "identity": "I am a reader",
    "habit_name": "Read every day",
    "tiny_version": "Read one page",
    "implementation_time": "21:00",
    "implementation_location": "In bed",
    "temptation_bundle": "Have herbal tea while reading",
    "pre_habit_ritual": "Take 3 deep breaths and open book",
    "environment_cue": "Put book on pillow at 20:45",
    "environment_distraction": "Charge phone in the kitchen"
  },
  "metadata": {
    "confidence": 0.85,
    "missing_fields": null,
    "notes": "AI-generated plan. Review and adjust as needed."
  }
}
```

---

### Scenario F: Coach Onboarding Fallback (Heuristics)

**Objective:** Verify the coach works without OpenAI using heuristic plan generation.

#### Setup

1. **Backend:** Run WITHOUT `OPENAI_API_KEY`
   ```bash
   cd backend
   unset OPENAI_API_KEY
   npm run dev
   ```

2. **Flutter:** Start the app
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. Follow the same coach conversation flow as Scenario E
2. Observe the backend logs

#### Expected Backend Logs

```
📞 POST /api/coach/onboarding - Received request
📝 Coach context: ✓ ✓ ✓ ✓ ✓
⚠️  OPENAI_API_KEY not set – using heuristic habit plan generation
🔄 Generating heuristic habit plan from context
✅ Generated habit plan: "Read every day" (confidence: 0.7)
```

**Key indicators:**
- `⚠️  OPENAI_API_KEY not set` confirms no LLM
- `🔄 Generating heuristic habit plan` confirms fallback
- Lower confidence (typically 0.4-0.7)
- Plan still generated successfully

#### Expected App Behavior

- ✅ Works identically to Scenario E from user's perspective
- ✅ Plan may be less personalized but still valid
- ✅ All required fields populated
- ✅ Confidence may be lower (shown in metadata)
- ✅ No error, no crash

---

### Scenario G: Coach Onboarding Error Handling

**Objective:** Verify graceful error handling when coach service fails.

#### Setup

1. **Backend:** Stop the backend completely

2. **Flutter:** Start the app
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. Start coach conversation
2. Answer all 5 questions
3. Tap "Generate My Plan"

#### Expected App Behavior

- ✅ Loading dialog appears
- ✅ After timeout (~5 seconds), error dialog appears:
  - "The coach is temporarily unavailable. You can continue with the manual form or try again."
- ✅ User can close dialog and continue with manual form
- ✅ No crash, no blank screen
- ✅ Previously entered name is preserved in manual form if user typed it before opening coach

---

### Scenario H: Daily Reflection Coach

**Objective:** Test the "Reflect on today" feature which helps users understand why their habit succeeded or failed and get personalized coaching for tomorrow.

#### Setup

1. **Backend:** Run with valid `OPENAI_API_KEY`
   ```bash
   cd backend
   export OPENAI_API_KEY=sk-your-real-key-here
   npm run dev
   ```

2. **Flutter:** Start the app and complete onboarding to reach Today screen
   ```bash
   flutter run -d chrome
   ```

#### Steps

1. **Complete onboarding** with any habit (or use existing habit)
2. **Navigate to Today screen** (should show your habit and streak)
3. **Locate the "Reflect on today" card** (purple card, after the completion status)
4. **Tap the card** to open the Daily Coach Dialog
5. **Step 1 - Select status:**
   - Choose one of: "I did it! ✅", "Partial progress 🟡", or "Didn't happen today ⭕"
   - Tap "Next"
6. **Step 2 - Provide context (all optional):**
   - "What happened?" → e.g., "I was too tired after work"
   - "What helped or blocked you?" → e.g., "My phone distracted me"
   - "What would make it 1% easier tomorrow?" → e.g., "Charge phone in kitchen"
   - Tap "Get coach insights"
7. **Wait for coach response** (loading state, 2-5 seconds)
8. **Review coach insights:**
   - Coach message (identity-affirming)
   - Patterns noticed
   - Tiny adjustments to try
   - Tomorrow's experiment
9. **Save reflection** (checkbox should be checked by default)
10. **Tap "Done"** to close dialog

#### Expected Backend Logs

```
📘 POST /api/coach/daily-reflection - Received request
📝 Reflection for: Read for 10 minutes (missed)
🤖 Attempting OpenAI LLM call for daily reflection...
✅ Generated daily reflection (coach + insights + adjustments)
✅ Generated reflection with 3 insights
```

**Key indicators:**
- `🤖 Attempting OpenAI LLM call for daily reflection...` confirms API call
- `✅ Generated daily reflection` confirms success
- Number of insights shown

#### Expected App Behavior

- ✅ **Step 1:** Radio buttons work, "Next" button enabled only after selecting status
- ✅ **Step 2:** All text fields optional, can skip all questions and still get insights
- ✅ **Loading state:** Shows "The coach is reflecting on your day..."
- ✅ **Results screen:** Shows all 4 sections:
  - Coach message (2-3 sentences, non-judgmental, identity-first)
  - Insights (2-4 bullet points with lightbulb icons)
  - Suggested adjustments (2-4 bullet points with tune icons)
  - Tomorrow's experiment (yellow card with science icon)
- ✅ **Save checkbox:** Enabled by default, can be unchecked
- ✅ **After closing:** Reflection note saved to habit history (check in AppState)

#### Testing Different Statuses

**Test with "completed" status:**
```
Expected coach message tone:
- Affirming: "You showed up as [identity] today."
- Celebrating systems: "That's proof your identity is becoming real."
- Encouraging consistency: "This is how habits become automatic."
```

**Test with "missed" status:**
```
Expected coach message tone:
- Identity-first: "You're still [identity], even when you miss."
- Non-judgmental: "Missing once doesn't undo your identity."
- Systems focus: "It's the pattern that matters, not single days."
```

**Test with "partial" status:**
```
Expected coach message tone:
- Validating effort: "Partial progress is still progress."
- Reducing friction: "What made it hard to finish today?"
```

#### Testing the Reflection Endpoint Directly (curl)

**Missed habit:**
```bash
curl -X POST http://localhost:3000/api/coach/daily-reflection \
  -H "Content-Type: application/json" \
  -d '{
    "habit": {
      "habit_name": "Read for 10 minutes",
      "identity": "I am a reader",
      "time": "22:00",
      "location": "In bed"
    },
    "date": "2025-11-17",
    "status": "missed",
    "reflection": {
      "what_happened": "I scrolled my phone and fell asleep.",
      "what_helped_or_blocked": "I was exhausted after work.",
      "what_might_help_tomorrow": "Charge my phone outside the bedroom."
    }
  }'
```

**Expected Response:**
```json
{
  "coach_message": "Today didn't go as planned, but you're still a reader. Missing once doesn't undo your identity—it's the pattern that matters.",
  "insights": [
    "Phone scrolling competes with reading at bedtime.",
    "Work exhaustion often blocks evening habits.",
    "You've identified a clear solution: charge phone elsewhere."
  ],
  "suggested_adjustments": [
    "Move your phone charger to the kitchen before 21:30.",
    "Put your book on your pillow at 21:00 as a visual cue.",
    "Start reading 30 minutes earlier, before exhaustion peaks."
  ],
  "suggested_tomorrow_experiment": "Tomorrow: Plug phone in kitchen at 21:15, read one page in bed."
}
```

**Completed habit:**
```bash
curl -X POST http://localhost:3000/api/coach/daily-reflection \
  -H "Content-Type: application/json" \
  -d '{
    "habit": {
      "habit_name": "Meditate for 5 minutes",
      "identity": "I am a calm person",
      "time": "07:00"
    },
    "date": "2025-11-17",
    "status": "completed",
    "reflection": {
      "what_happened": "I meditated right after my alarm went off.",
      "what_helped_or_blocked": "My meditation cushion was already visible."
    }
  }'
```

**Expected Response:**
```json
{
  "coach_message": "You showed up as a calm person today. That's proof your identity is becoming real.",
  "insights": [
    "Starting immediately after your alarm works well.",
    "Having your meditation cushion visible makes it easier to start."
  ],
  "suggested_adjustments": [
    "Keep your meditation cushion in the same spot permanently.",
    "Consider adding a morning ritual before meditating (e.g., 3 deep breaths)."
  ],
  "suggested_tomorrow_experiment": "Tomorrow: Try the same routine. Consistency builds automaticity."
}
```

#### Testing Without OpenAI (Heuristic Fallback)

1. **Stop backend and restart without API key:**
   ```bash
   unset OPENAI_API_KEY
   npm run dev
   ```

2. **Follow same steps** as above

#### Expected Backend Logs (Heuristics)

```
📘 POST /api/coach/daily-reflection - Received request
📝 Reflection for: Read for 10 minutes (missed)
⚠️  OPENAI_API_KEY not set – using heuristic daily reflection
🔄 Generating heuristic daily reflection
✅ Generated reflection with 2 insights
```

**Key indicators:**
- `⚠️  OPENAI_API_KEY not set` confirms no LLM
- `🔄 Generating heuristic daily reflection` confirms fallback
- Still generates valid response

#### Expected App Behavior (Heuristics)

- ✅ Works identically from user's perspective
- ✅ Coach messages are templated but still identity-first and non-judgmental
- ✅ Insights are pattern-based (e.g., "Weekdays are often easier", "Evening habits can be blocked by tiredness")
- ✅ Adjustments are generic but still aligned with Atomic Habits (make it obvious, easy, attractive)
- ✅ No error, no crash

#### Testing Error Handling

1. **Stop backend completely**
2. **Tap "Reflect on today"** and complete the flow
3. **Tap "Get coach insights"**

#### Expected App Behavior (Backend Offline)

- ✅ Loading dialog appears
- ✅ After timeout (~5 seconds), error dialog appears:
  - "Coach is currently offline"
  - "Something went wrong while generating your reflection."
  - "Your habit data is still saved. You can try reflecting again later."
- ✅ Button: "OK" → Closes both dialogs
- ✅ No crash, reflection not saved

#### Verifying Saved Reflections

To verify reflections are being saved to the Habit model:

1. **Open the reflection dialog** and complete it with "Save this reflection" checked
2. **Check Flutter debug console** for:
   ```
   💾 Saving reflection note
   📝 Saved reflection for 2025-11-17
   ```
3. **Check Hive storage** (if using Flutter DevTools):
   - Open DevTools → "Hive" tab
   - Look for `habit_data` box
   - Check `currentHabit` → `reflectionNotes` map
   - Should see entry: `"2025-11-17": "Status: missed\nWhat happened: ..."`

---

## Debugging

Common issues and how to fix them.

---

### Backend Issues

#### `npm install` fails

**Symptoms:**
```
npm ERR! code ENOTFOUND
npm ERR! network request to https://registry.npmjs.org/express failed
```

**Fixes:**
- Check your internet connection
- Verify npm registry: `npm config get registry`
- Try using a different registry or VPN
- Check Node.js version: `node --version` (should be v18+)

---

#### `npm run dev` says "Port in use"

**Symptoms:**
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Fixes:**

**Option 1: Kill the process using port 3000**
```bash
# macOS/Linux
lsof -ti:3000 | xargs kill -9

# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

**Option 2: Change the port**

Edit `backend/.env`:
```env
PORT=3001
```

Then restart: `npm run dev`

Update Flutter endpoint in `lib/data/ai_suggestion_service.dart`:
```dart
static const String _remoteLlmEndpoint = 'http://localhost:3001/api/habit-suggestions';
```

---

#### Backend crashes with "Cannot read property X of undefined"

**Symptoms:**
```
TypeError: Cannot read property 'suggestion_type' of undefined
```

**Likely cause:** Malformed JSON in the request body

**Fixes:**
- Verify the JSON payload matches the contract (see below)
- Check for typos in field names (must be snake_case)
- Ensure `Content-Type: application/json` header is set

**Correct payload format:**
```json
{
  "suggestion_type": "temptation_bundle",
  "habit_name": "Read for 10 minutes",
  "time": "22:00"
}
```

**Incorrect (will fail):**
```json
{
  "suggestionType": "temptation_bundle",  // ❌ Wrong: camelCase
  "habit_name": "Read for 10 minutes",
  "time": "22:00"
}
```

---

### Flutter Issues

#### "Network error" when tapping "Ideas 💡"

**Symptoms:**
- Flutter debug console shows:
  ```
  ❌ Remote LLM error: Failed host lookup: 'localhost'
  ```

**Fixes:**

1. **Check backend is running:**
   ```bash
   curl http://localhost:3000/health
   ```
   Should return: `{"status":"ok",...}`

2. **Verify endpoint URL** in `lib/data/ai_suggestion_service.dart`:
   ```dart
   static const String _remoteLlmEndpoint = 'http://localhost:3000/api/habit-suggestions';
   ```

3. **Restart both backend and Flutter app:**
   ```bash
   # Terminal 1
   cd backend && npm run dev

   # Terminal 2
   flutter run
   ```

---

#### Suggestions are all generic / not context-aware

**Symptoms:**
- Suggestions don't match the habit/time/location
- Same suggestions appear for all habits

**Likely cause:**
- Backend is using heuristics but the logic isn't matching your input
- Or OpenAI is returning generic suggestions

**Fixes:**

1. **Check backend logs** to see if OpenAI was called:
   - If you see `⚠️ OPENAI_API_KEY not set`, the backend is using heuristics only
   - Heuristics use keyword matching (e.g., "read", "meditate", "exercise")

2. **Try more specific habit names:**
   - ✅ "Read for 10 minutes before bed"
   - ❌ "Do my habit"

3. **Verify time is in HH:MM format:**
   - ✅ "22:00", "08:30"
   - ❌ "10pm", "8:30 AM"

---

### OpenAI Issues

#### 401 Unauthorized

**Symptoms:**
```
❌ OpenAI call failed: Request failed with status code 401
🔄 Falling back to heuristic suggestions
```

**Fixes:**
- Invalid API key → Check your `OPENAI_API_KEY` in `.env`
- Get a new key: https://platform.openai.com/api-keys
- Verify the key starts with `sk-`

---

#### 429 Rate Limit Exceeded

**Symptoms:**
```
❌ OpenAI call failed: Request failed with status code 429
🔄 Falling back to heuristic suggestions
```

**Fixes:**
- You've hit OpenAI's rate limit
- Wait a few minutes before trying again
- Check your usage: https://platform.openai.com/usage
- Consider upgrading your OpenAI plan for higher limits

---

#### OpenAI timeout after 5 seconds

**Symptoms:**
```
❌ OpenAI call failed: OpenAI request timeout after 5s
🔄 Falling back to heuristic suggestions
```

**Fixes:**
- Check your internet connection
- Check OpenAI status: https://status.openai.com
- The 5s timeout is intentional to prevent hanging
- The system will automatically fall back to heuristics

---

### Where to Look for Logs

**Backend logs:** Node.js console where you ran `npm run dev`
- All backend activity (requests, OpenAI calls, errors)

**Flutter logs:** Terminal where you ran `flutter run`
- Client-side activity (remote calls, fallbacks, UI events)
- Use `flutter run -v` for verbose logging

**Browser console (if running Flutter web):**
- Open DevTools (F12 or Cmd+Option+I)
- Check Console tab for Flutter debug prints
- Check Network tab to see actual HTTP requests

---

### Contract Reference Files

If you need to verify the API contract between Flutter and backend, check these files:

**Flutter client (request sender):**
- `lib/data/ai_suggestion_service.dart`
  - Line 27: `_remoteLlmEndpoint` (endpoint URL)
  - Lines 265-276: Request payload construction
  - Lines 233-246: Contract documentation

**Backend route handler (request receiver):**
- `backend/src/routes/habitSuggestions.ts`
  - Lines 6-32: API documentation
  - Lines 33-73: Request validation and parsing

**Backend suggestion service (LLM + heuristics):**
- `backend/src/services/suggestionService.ts`
  - Lines 9-19: `HabitContext` interface
  - Lines 115-145: `generateSuggestions()` (LLM + fallback logic)
  - Lines 147-201: `callOpenAI()` (OpenAI integration)
  - Lines 203-233: Heuristic fallback functions

---

### Still Stuck?

If you're still having issues:

1. **Check the contract is aligned:**
   - Compare the JSON payload Flutter sends with what the backend expects
   - Field names must be snake_case (`suggestion_type`, not `suggestionType`)
   - Time must be HH:MM format ("22:00", not "10pm")

2. **Enable verbose logging:**
   ```bash
   # Backend: Already verbose by default

   # Flutter: Run with -v flag
   flutter run -v -d chrome
   ```

3. **Test backend independently with curl:**
   ```bash
   curl -X POST http://localhost:3000/api/habit-suggestions \
     -H "Content-Type: application/json" \
     -d '{"suggestion_type":"temptation_bundle","habit_name":"Test","time":"12:00"}'
   ```

4. **Check GitHub issues:**
   - Search for similar problems in the repository issues

5. **Review recent commits:**
   - Check if recent changes broke the contract
   - Use `git log` to see recent changes to the API files

---

## Summary

You now have a complete testing and debugging workflow:

1. ✅ **Backend heuristics-only** → Fast local suggestions
2. ✅ **Backend with OpenAI** → AI-powered suggestions with fallback
3. ✅ **Flutter app integration** → End-to-end flow
4. ✅ **Test scenarios** → Verify all paths (success, fallback, failure)
5. ✅ **Debugging guide** → Fix common issues

The system is designed with **multiple layers of fallback**:
1. OpenAI → Backend heuristics (if OpenAI fails)
2. Backend → Flutter heuristics (if backend unreachable)

This ensures the user always gets suggestions, regardless of network or API availability.
