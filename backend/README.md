# Atomic Habits Backend (Heuristic)

A minimal Express + TypeScript service that powers the `POST /api/habit-suggestions` endpoint used by the Flutter client.

## Setup

```bash
cd backend
npm install
```

## Running the dev server

```bash
npm run dev
```

The server listens on `PORT` (defaults to `3000`).

## Endpoint

`POST http://localhost:3000/api/habit-suggestions`

### Sample request

```bash
curl -X POST http://localhost:3000/api/habit-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "suggestion_type": "temptation_bundle",
    "identity": "I am a person who reads every day",
    "habit_name": "Read one page",
    "two_minute_version": "Open my book",
    "time": "22:00",
    "location": "In bed",
    "existing_temptation_bundle": null,
    "existing_pre_ritual": null,
    "existing_environment_cue": null,
    "existing_environment_distraction": null
  }'
```

### Sample response

```json
{
  "suggestions": [
    "Have a cup of herbal tea while you read.",
    "Light a candle and read with soft lighting.",
    "Listen to a calm instrumental playlist while you read."
  ]
}
```
