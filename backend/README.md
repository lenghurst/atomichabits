# Atomic Habits Backend - AI Suggestion Service

Backend API service for generating Atomic Habits-based suggestions using OpenAI LLM integration with automatic fallback to local heuristics.

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

## Project Structure

```
backend/
├── src/
│   ├── services/
│   │   └── suggestionService.ts   # Core LLM + heuristic logic
│   ├── routes/
│   │   └── habitSuggestions.ts    # API route handler
│   └── server.ts                  # Express server setup
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
