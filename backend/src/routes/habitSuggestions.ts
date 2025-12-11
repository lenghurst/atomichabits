import { Request, Response, Router } from 'express';
import { generateSuggestions, HabitContext, SuggestionType } from '../services/suggestionService.js';

interface HabitSuggestionRequest {
  suggestion_type?: unknown;
  identity?: unknown;
  habit_name?: unknown;
  two_minute_version?: unknown;
  time?: unknown;
  location?: unknown;
  existing_temptation_bundle?: unknown;
  existing_pre_ritual?: unknown;
  existing_environment_cue?: unknown;
  existing_environment_distraction?: unknown;
}

const ALLOWED_TYPES: SuggestionType[] = [
  'temptation_bundle',
  'pre_habit_ritual',
  'environment_cue',
  'environment_distraction',
];

function normalizeSuggestionType(value: unknown): SuggestionType | null {
  if (typeof value !== 'string') return null;
  const lowered = value.toLowerCase();
  return ALLOWED_TYPES.includes(lowered as SuggestionType) ? (lowered as SuggestionType) : null;
}

function validateRequest(body: HabitSuggestionRequest): { context?: HabitContext; error?: string } {
  const suggestionType = normalizeSuggestionType(body.suggestion_type);
  if (!suggestionType) {
    return { error: 'Invalid request: suggestion_type must be one of temptation_bundle, pre_habit_ritual, environment_cue, environment_distraction' };
  }

  if (typeof body.habit_name !== 'string' || !body.habit_name.trim()) {
    return { error: 'Invalid request: habit_name is required and must be a string' };
  }

  if (typeof body.time !== 'string' || !/^\d{2}:\d{2}$/.test(body.time)) {
    return { error: 'Invalid request: time is required and must be in HH:MM format' };
  }

  const optionalString = (value: unknown) => (typeof value === 'string' ? value : undefined);
  const optionalNullableString = (value: unknown) => {
    if (value === null) return null;
    return typeof value === 'string' ? value : undefined;
  };

  const context: HabitContext = {
    suggestionType,
    habitName: body.habit_name.trim(),
    time: body.time,
    identity: optionalString(body.identity),
    twoMinuteVersion: optionalString(body.two_minute_version),
    location: optionalString(body.location),
    existingTemptationBundle: optionalNullableString(body.existing_temptation_bundle),
    existingPreRitual: optionalNullableString(body.existing_pre_ritual),
    existingEnvironmentCue: optionalNullableString(body.existing_environment_cue),
    existingEnvironmentDistraction: optionalNullableString(body.existing_environment_distraction),
  };

  return { context };
}

export const habitSuggestionsRouter = Router();

habitSuggestionsRouter.post('/', (req: Request, res: Response) => {
  const { context, error } = validateRequest(req.body as HabitSuggestionRequest);

  if (error || !context) {
    res.status(400).json({ error });
    return;
  }

  const suggestions = generateSuggestions(context);
  res.status(200).json({ suggestions });
});
