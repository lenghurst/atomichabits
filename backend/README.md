# Atomic Habits Backend - AI Suggestion Service

Backend API service for generating Atomic Habits-based suggestions using OpenAI LLM integration with automatic fallback to local heuristics.

> **📚 For complete end-to-end testing instructions** (backend + Flutter app + OpenAI integration), see [E2E_TESTING_AND_DEBUGGING.md](../E2E_TESTING_AND_DEBUGGING.md)

## Features

- **OpenAI LLM Integration**: Uses GPT-3.5-turbo for intelligent, context-aware suggestions
- **Automatic Fallback**: Seamlessly falls back to heuristic suggestions if OpenAI fails or is not configured
- **4 Suggestion Types**:
  - **Temptation Bundling**: Pair habits with enjoyable activities
  - **Pre-Habit Rituals**: 10-30 second rituals to prime the habit
  - **Environment Cues**: Visual triggers to make habits obvious
  - **Environment Distractions**: Friction to remove competing behaviors
- **Robust Error Handling**: 5-second timeout, comprehensive error handling, always returns suggestions
- **TypeScript**: Full type safety and IDE support

## Real LLM Integration

### How it Works

The backend reads `OPENAI_API_KEY` from the environment:

**If OPENAI_API_KEY is set:**
- Attempts to call OpenAI API (GPT-3.5-turbo)
- Uses 5-second timeout to prevent hanging
- Returns AI-generated suggestions tailored to the specific context
- **If OpenAI fails** (network error, timeout, invalid response):
  - Automatically falls back to local heuristic suggestions
  - Logs the error for debugging

**If OPENAI_API_KEY is NOT set:**
- Immediately uses local heuristic suggestions
- Logs a warning that OpenAI is not configured
- No external API calls made

**Guarantee**: The API always returns suggestions - it never crashes or returns empty results.

## Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure OpenAI API Key

Create a `.env` file:

```bash
cp .env.example .env
```

Edit `.env` and add your OpenAI API key:

```env
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
PORT=3000
```

Get your API key from: https://platform.openai.com/api-keys

### 3. Run the Server

Development mode (with auto-reload):
```bash
npm run dev
```

Production mode:
```bash
npm run build
npm start
```

The server will start on `http://localhost:3000`.

### 4. Test the API

Health check:
```bash
curl http://localhost:3000/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2025-11-16T12:00:00.000Z",
  "openai_configured": true
}
```

## API Documentation

### POST /api/habit-suggestions

Generate AI-powered habit suggestions based on context.

#### Request Body

```json
{
  "suggestion_type": "temptation_bundle",
  "identity": "a person who reads daily",
  "habit_name": "Read for 10 minutes",
  "two_minute_version": "Read one page",
  "time": "08:00",
  "location": "Living room couch",
  "existing_temptation_bundle": null,
  "existing_pre_ritual": null,
  "existing_environment_cue": null,
  "existing_environment_distraction": null
}
```

**Required Fields:**
- `suggestion_type`: One of `"temptation_bundle"`, `"pre_habit_ritual"`, `"environment_cue"`, `"environment_distraction"`
- `habit_name`: The habit you want suggestions for (e.g., "Read for 10 minutes")
- `time`: Time in HH:MM format (e.g., "08:00")

**Optional Fields:**
- `identity`: User's identity statement (e.g., "a person who reads daily")
- `two_minute_version`: Simplified 2-minute version of the habit
- `location`: Where the habit takes place
- `existing_temptation_bundle`: Current temptation bundle (if any)
- `existing_pre_ritual`: Current pre-habit ritual (if any)
- `existing_environment_cue`: Current environment cue (if any)
- `existing_environment_distraction`: Current distraction removal strategy (if any)

#### Response

```json
{
  "suggestions": [
    "Enjoy your morning coffee while reading on the couch",
    "Read while listening to soft instrumental music in the background",
    "Pair reading time with your favorite herbal tea"
  ]
}
```

#### Error Responses

**400 Bad Request** - Missing or invalid parameters:
```json
{
  "error": "Missing required field: habit_name"
}
```

**500 Internal Server Error** - Unexpected error (very rare, as fallback prevents most failures):
```json
{
  "error": "Could not generate suggestions"
}
```

## Example Requests

### Temptation Bundling (Morning Reading)

```bash
curl -X POST http://localhost:3000/api/habit-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "suggestion_type": "temptation_bundle",
    "identity": "a morning reader",
    "habit_name": "Read for 15 minutes",
    "time": "07:00",
    "location": "Bedroom reading chair"
  }'
```

### Pre-Habit Ritual (Meditation)

```bash
curl -X POST http://localhost:3000/api/habit-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "suggestion_type": "pre_habit_ritual",
    "habit_name": "Meditate for 5 minutes",
    "time": "06:30",
    "location": "Living room corner"
  }'
```

### Environment Cue (Exercise)

```bash
curl -X POST http://localhost:3000/api/habit-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "suggestion_type": "environment_cue",
    "habit_name": "Do 10 pushups",
    "time": "18:00",
    "location": "Home gym"
  }'
```

### Environment Distraction (Focus Work)

```bash
curl -X POST http://localhost:3000/api/habit-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "suggestion_type": "environment_distraction",
    "habit_name": "Write in journal",
    "time": "21:00",
    "location": "Desk"
  }'
```

### POST /api/habit-review

Generate AI-powered weekly review based on habit completion history.

#### Request Body

```json
{
  "habit": {
    "identity": "a person who reads daily",
    "habit_name": "Read for 10 minutes",
    "two_minute_version": "Read one page",
    "time": "22:00",
    "location": "In bed before sleep",
    "temptation_bundle": "Have herbal tea while reading",
    "pre_habit_ritual": "Take 3 deep breaths",
    "environment_cue": "Put book on pillow at 21:45",
    "environment_distraction": "Charge phone in kitchen"
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
}
```

**Required Fields:**
- `habit.habit_name`: The habit name (string)
- `history`: Array of completion entries (last 7-14 days recommended)

**Optional Fields:**
- All other habit fields (identity, time, location, environment design fields)

**History Format:**
- `date`: yyyy-MM-dd string
- `completed`: boolean (true = completed, false = missed)

#### Response

```json
{
  "summary": "You completed 'Read for 10 minutes' 5 out of 7 days this week (71%). Good progress! Keep building momentum.",
  "insights": [
    "Your longest streak was 3 days - you can maintain consistency!",
    "Weekdays are stronger than weekends - your routine helps consistency."
  ],
  "suggested_adjustments": [
    "Make it obvious: Set up a clear visual cue in your space.",
    "Keep your current system - it's working well!",
    "Focus on never missing twice in a row to maintain momentum."
  ]
}
```

**Response Fields:**
- `summary`: 2-4 sentence summary of the week (max 350 characters)
- `insights`: 2-4 concrete insights about patterns
- `suggested_adjustments`: 2-4 tiny tweaks aligned with Atomic Habits principles

#### Error Responses

**400 Bad Request** - Missing or invalid parameters:
```json
{
  "error": "Missing required field: habit.habit_name"
}
```

**500 Internal Server Error** - Unexpected error:
```json
{
  "error": "Could not generate weekly review"
}
```

#### Example Request

```bash
curl -X POST http://localhost:3000/api/habit-review \
  -H "Content-Type: application/json" \
  -d '{
    "habit": {
      "habit_name": "Meditate for 5 minutes",
      "identity": "a calm and mindful person",
      "time": "07:00",
      "location": "Living room corner"
    },
    "history": [
      { "date": "2025-11-10", "completed": true },
      { "date": "2025-11-09", "completed": true },
      { "date": "2025-11-08", "completed": false },
      { "date": "2025-11-07", "completed": true },
      { "date": "2025-11-06", "completed": true },
      { "date": "2025-11-05", "completed": true },
      { "date": "2025-11-04", "completed": true }
    ]
  }'
```

**Response:**
```json
{
  "summary": "You completed 'Meditate for 5 minutes' 6 out of 7 days this week (86%). Excellent consistency! Your habit is becoming automatic.",
  "insights": [
    "Your longest streak was 4 days - you can maintain consistency!",
    "Building a habit takes time - focus on consistency over perfection."
  ],
  "suggested_adjustments": [
    "Keep your current system - it's working well!",
    "Focus on never missing twice in a row to maintain momentum."
  ]
}
```

### POST /api/coach/onboarding

Generate a structured habit plan from conversational context collected during coach-led onboarding.

This endpoint powers the "Talk to the Coach" feature in the Flutter app, which helps users design their first habit through a short conversation.

#### Request Body

```json
{
  "desired_identity": "a reader",
  "habit_idea": "read more books",
  "when_in_day": "before bed around 9pm",
  "where_location": "in bed",
  "what_makes_it_enjoyable": "having tea",
  "user_name": "Alex"
}
```

**Optional Fields (all fields are optional):**
- `desired_identity`: What type of person they want to become (e.g., "a reader", "a healthy person")
- `habit_idea`: The habit they want to build (e.g., "read more", "exercise")
- `when_in_day`: When they plan to do it (e.g., "before bed", "morning coffee")
- `where_location`: Where they'll do it (e.g., "in bed", "at my desk")
- `what_makes_it_enjoyable`: What would make it enjoyable/obvious (e.g., "having tea", "music")
- `user_name`: User's name for personalization

**Note**: At least one field should be provided to generate a meaningful plan.

#### Response

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

**Response Fields:**

**`habit_plan` (required):**
- `identity`: Identity statement in "I am [identity]" format
- `habit_name`: Clear habit name (e.g., "Read every day")
- `tiny_version`: 2-minute version (e.g., "Read one page")
- `implementation_time`: HH:MM format (e.g., "21:00")
- `implementation_location`: Specific place (e.g., "In bed")
- `temptation_bundle`: Optional - enjoyable pairing
- `pre_habit_ritual`: Optional - 10-30 second ritual
- `environment_cue`: Optional - visual trigger
- `environment_distraction`: Optional - friction to remove

**`metadata` (required):**
- `confidence`: 0.0-1.0 confidence score
- `missing_fields`: Array of missing optional fields (or null)
- `notes`: Helpful message for the user (or null)

#### Error Responses

**400 Bad Request** - No context provided:
```json
{
  "error": "Insufficient context",
  "message": "Please provide at least one answer to generate a habit plan"
}
```

**503 Service Unavailable** - Coach temporarily unavailable:
```json
{
  "error": "Service unavailable",
  "message": "The coach is temporarily unavailable. Please try the manual form or try again later."
}
```

#### Example Request

```bash
curl -X POST http://localhost:3000/api/coach/onboarding \
  -H "Content-Type: application/json" \
  -d '{
    "desired_identity": "someone who exercises regularly",
    "habit_idea": "go for a morning walk",
    "when_in_day": "7am after waking up",
    "where_location": "around the neighborhood",
    "what_makes_it_enjoyable": "listening to podcasts"
  }'
```

**Response:**
```json
{
  "habit_plan": {
    "identity": "I am someone who exercises regularly",
    "habit_name": "Go for a morning walk",
    "tiny_version": "Walk for 2 minutes",
    "implementation_time": "07:00",
    "implementation_location": "Around the neighborhood",
    "temptation_bundle": "Listen to your favorite podcast",
    "pre_habit_ritual": "Put on your workout clothes immediately",
    "environment_cue": "Put running shoes by the door at night",
    "environment_distraction": "Put phone on Do Not Disturb mode"
  },
  "metadata": {
    "confidence": 0.9,
    "missing_fields": null,
    "notes": "Great plan! Review and adjust before saving."
  }
}
```

### POST /api/coach/daily-reflection

Generate personalized daily reflection insights based on today's habit completion status and user context.

This endpoint powers the "Reflect on today" feature in the Flutter app, which helps users understand why their habit succeeded or failed and suggests tiny adjustments for tomorrow.

#### Request Body

```json
{
  "habit": {
    "habit_name": "Read for 10 minutes",
    "identity": "I am a reader",
    "two_minute_version": "Read one page",
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
}
```

**Required Fields:**
- `habit.habit_name`: The habit name (string)
- `date`: Date in yyyy-MM-dd format
- `status`: One of `"completed"`, `"missed"`, or `"partial"`

**Optional Fields:**
- `habit.identity`: Identity statement
- `habit.two_minute_version`: Simplified 2-minute version
- `habit.time`: Implementation time (HH:MM format)
- `habit.location`: Implementation location
- `reflection.what_happened`: What happened today (user's observation)
- `reflection.what_helped_or_blocked`: What helped or blocked them
- `reflection.what_might_help_tomorrow`: User's ideas for improvement

#### Response

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

**Response Fields:**
- `coach_message`: Personalized, non-judgmental message (2-3 sentences)
- `insights`: 2-4 concrete insights about patterns
- `suggested_adjustments`: 2-4 tiny tweaks aligned with Atomic Habits
- `suggested_tomorrow_experiment`: One specific thing to try tomorrow

**Coaching Principles:**
- **Identity-first**: Reinforces identity regardless of outcome
- **Non-judgmental**: Never shames, focuses on systems not willpower
- **1% improvement**: Suggests smallest possible adjustments
- **Atomic Habits alignment**: Focuses on cues, friction, environment design

#### Error Responses

**400 Bad Request** - Missing or invalid parameters:
```json
{
  "error": "Invalid request",
  "message": "Missing or invalid habit.habit_name"
}
```

**503 Service Unavailable** - Coach temporarily unavailable:
```json
{
  "error": "Service unavailable",
  "message": "The coach is temporarily unavailable. Please try again later."
}
```

#### Example Requests

**Missed Habit:**
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
    "status": "missed",
    "reflection": {
      "what_happened": "I hit snooze and ran out of time.",
      "what_helped_or_blocked": "Phone alarm was too far, I stayed in bed."
    }
  }'
```

**Response:**
```json
{
  "coach_message": "You're still a calm person, even when you miss. Systems matter more than single days.",
  "insights": [
    "Hitting snooze disrupts your morning routine.",
    "Phone placement affects your ability to start."
  ],
  "suggested_adjustments": [
    "Put your meditation cushion next to your alarm.",
    "Do one breath exercise before touching your phone."
  ],
  "suggested_tomorrow_experiment": "Tomorrow: When alarm rings, do 3 deep breaths before anything else."
}
```

**Completed Habit:**
```bash
curl -X POST http://localhost:3000/api/coach/daily-reflection \
  -H "Content-Type: application/json" \
  -d '{
    "habit": {
      "habit_name": "Write in journal",
      "identity": "I am a writer",
      "time": "21:00",
      "location": "Desk"
    },
    "date": "2025-11-17",
    "status": "completed",
    "reflection": {
      "what_happened": "I wrote for 10 minutes after dinner.",
      "what_helped_or_blocked": "My journal was already on my desk."
    }
  }'
```

**Response:**
```json
{
  "coach_message": "You showed up as a writer today. That's proof your identity is becoming real.",
  "insights": [
    "Having your journal visible makes starting easier.",
    "Post-dinner timing works well for you."
  ],
  "suggested_adjustments": [
    "Keep your journal on the desk permanently.",
    "Consider adding a favorite pen as a temptation bundle."
  ],
  "suggested_tomorrow_experiment": "Tomorrow: Try the same routine. Consistency builds automaticity."
}
```

## Project Structure

```
backend/
├── src/
│   ├── services/
│   │   ├── suggestionService.ts        # Core LLM + heuristic logic for suggestions
│   │   ├── reviewService.ts            # Core LLM + heuristic logic for weekly reviews
│   │   ├── coachOnboardingService.ts   # Core LLM + heuristic logic for coach onboarding
│   │   └── dailyCoachService.ts        # Core LLM + heuristic logic for daily reflection
│   ├── routes/
│   │   ├── habitSuggestions.ts         # API route handler for suggestions
│   │   ├── habitReview.ts              # API route handler for weekly reviews
│   │   ├── coachOnboarding.ts          # API route handler for coach onboarding
│   │   └── dailyCoach.ts               # API route handler for daily reflection
│   └── server.ts                       # Express server setup
├── dist/                          # Compiled JavaScript (after build)
├── package.json
├── tsconfig.json
├── .env.example
├── .gitignore
└── README.md
```

## Architecture Details

### Suggestion Flow

1. **Request arrives** at `/api/habit-suggestions`
2. **Route handler** (`habitSuggestions.ts`) validates input and builds `HabitContext`
3. **Suggestion service** (`suggestionService.ts`) is called:
   - Checks if `OPENAI_API_KEY` exists
   - If yes → tries OpenAI with 5s timeout
   - If no / fails → uses heuristic fallback
4. **Response sent** with suggestions array

### Weekly Review Flow

1. **Request arrives** at `/api/habit-review`
2. **Route handler** (`habitReview.ts`) validates input and builds `HabitInfo` + `HistoryEntry[]`
3. **Review service** (`reviewService.ts`) is called:
   - Checks if `OPENAI_API_KEY` exists
   - If yes → tries OpenAI with 5s timeout
   - If no / fails → uses heuristic review
4. **Response sent** with summary, insights, and suggested adjustments

The review service analyzes completion patterns (weekday/weekend, streaks, completion rate) and provides:
- A short summary of the week
- Concrete insights about behavior patterns
- Actionable adjustments aligned with Atomic Habits (make it obvious, attractive, easy, satisfying)

### Coach Onboarding Flow

1. **Request arrives** at `/api/coach/onboarding`
2. **Route handler** (`coachOnboarding.ts`) validates input and builds `OnboardingCoachContext`
3. **Coach service** (`coachOnboardingService.ts`) is called:
   - Checks if `OPENAI_API_KEY` exists
   - If yes → tries OpenAI with 5s timeout to generate complete habit plan
   - If no / fails → uses heuristic plan generation
4. **Response sent** with `habit_plan` + `metadata`

The coach service synthesizes conversational answers into a structured habit plan with all required fields (identity, habit name, tiny version, time, location) and optional fields (temptation bundle, pre-habit ritual, environment design).

### Daily Coach Reflection Flow

1. **Request arrives** at `/api/coach/daily-reflection`
2. **Route handler** (`dailyCoach.ts`) validates input and builds `DailyReflectionRequest`
3. **Daily coach service** (`dailyCoachService.ts`) is called:
   - Checks if `OPENAI_API_KEY` exists
   - If yes → tries OpenAI with 5s timeout to generate personalized reflection
   - If no / fails → uses heuristic reflection
4. **Response sent** with `coach_message`, `insights`, `suggested_adjustments`, `suggested_tomorrow_experiment`

The daily coach service analyzes the day's outcome (completed/partial/missed) and user reflection notes to provide:
- A personalized, identity-affirming message
- Concrete insights about what worked or didn't work
- Tiny adjustments aligned with Atomic Habits principles (make it obvious, easy, attractive)
- One specific experiment to try tomorrow

### Key Components

#### `suggestionService.ts`

- **`generateSuggestions(context)`**: Main async function (LLM + fallback)
- **`callOpenAI(apiKey, context)`**: OpenAI API integration
- **`generateHeuristicSuggestions(context)`**: Local fallback logic
- **`buildPrompt(context)`**: Constructs OpenAI prompt from context

#### `habitSuggestions.ts`

- Express route handler
- Input validation (400 errors for missing/invalid fields)
- Error handling (500 errors for unexpected failures)

#### `reviewService.ts`

- **`generateWeeklyReview(habit, history)`**: Main async function (LLM + fallback)
- **`callOpenAI(apiKey, habit, history)`**: OpenAI API integration for reviews
- **`generateHeuristicReview(habit, history)`**: Local fallback review logic
- **`buildPrompt(habit, history)`**: Constructs OpenAI prompt with completion stats

#### `habitReview.ts`

- Express route handler for weekly reviews
- Input validation (400 errors for missing/invalid fields)
- Parses habit info and completion history
- Error handling (500 errors for unexpected failures)

#### `server.ts`

- Express app setup
- CORS enabled for Flutter app
- Health check endpoint
- Request logging

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OPENAI_API_KEY` | No | - | OpenAI API key. If not set, uses heuristics only. |
| `PORT` | No | 3000 | Server port |

## Development

### Running Locally

```bash
# Install dependencies
npm install

# Run in development mode (auto-reload with ts-node)
npm run dev

# Build TypeScript to JavaScript
npm run build

# Run production build
npm start
```

### Testing Without OpenAI

Simply don't set `OPENAI_API_KEY` and the server will use heuristic suggestions:

```bash
cd backend
npm install
npm run dev
```

You'll see:
```
🔑 OpenAI API Key: ❌ Not set (will use heuristics only)
```

### Testing With OpenAI

Set your API key in `.env`:
```env
OPENAI_API_KEY=sk-your-key-here
```

Run the server and you'll see:
```
🔑 OpenAI API Key: ✅ Configured
```

## Dependencies

### Production
- `express`: Web server framework
- `openai`: Official OpenAI Node.js SDK
- `dotenv`: Environment variable management
- `cors`: CORS middleware for Flutter app

### Development
- `typescript`: TypeScript compiler
- `ts-node`: Run TypeScript directly in dev mode
- `@types/express`, `@types/node`, `@types/cors`: TypeScript type definitions

## Integration with Flutter App

To connect the Flutter app to this backend:

1. Start the backend server (see Quick Start above)
2. In the Flutter app, update `lib/data/ai_suggestion_service.dart`:

```dart
// Change this line:
static const String _remoteLlmEndpoint = 'https://example.com/api/habit-suggestions';

// To:
static const String _remoteLlmEndpoint = 'http://localhost:3000/api/habit-suggestions';
// Or your deployed backend URL
```

3. The Flutter app will now call your real backend for suggestions

## Deployment

### Deploy to Production

1. Set environment variables on your hosting platform:
   ```
   OPENAI_API_KEY=sk-your-production-key
   PORT=3000
   ```

2. Build and run:
   ```bash
   npm run build
   npm start
   ```

### Recommended Platforms
- **Railway**: Easy Node.js deployment
- **Render**: Free tier available
- **Heroku**: Popular PaaS
- **DigitalOcean App Platform**: Simple deployment

### Docker (Optional)

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## Troubleshooting

### "OPENAI_API_KEY not set" Warning

This is expected if you haven't configured OpenAI. The backend will use heuristic suggestions instead. To use OpenAI:
1. Get an API key from https://platform.openai.com/api-keys
2. Add it to `.env` file
3. Restart the server

### OpenAI Timeout After 5s

The backend implements a 5-second timeout to prevent hanging. If OpenAI is slow:
- Check your internet connection
- Check OpenAI status: https://status.openai.com
- The system will automatically fall back to heuristics

### Port Already in Use

Change the port in `.env`:
```env
PORT=3001
```

Or set it when running:
```bash
PORT=3001 npm run dev
```

## License

MIT
