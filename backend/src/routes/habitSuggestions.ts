import { Router, Request, Response } from 'express';
import { generateSuggestions, HabitContext } from '../services/suggestionService';

const router = Router();

/**
 * POST /api/habit-suggestions
 *
 * Generate AI-powered suggestions for habit formation based on Atomic Habits principles
 *
 * CLIENT CONTRACT: This endpoint is consumed by the Flutter app's AiSuggestionService
 * (lib/data/ai_suggestion_service.dart). The request/response format must stay aligned.
 *
 * Request body (all field names in snake_case):
 * {
 *   "suggestion_type": "temptation_bundle" | "pre_habit_ritual" | "environment_cue" | "environment_distraction",
 *   "identity": "string (optional)",
 *   "habit_name": "string (required)",
 *   "two_minute_version": "string (optional)",
 *   "time": "HH:MM (required, e.g., '08:00', '22:30')",
 *   "location": "string (optional)",
 *   "existing_temptation_bundle": "string (optional)",
 *   "existing_pre_ritual": "string (optional)",
 *   "existing_environment_cue": "string (optional)",
 *   "existing_environment_distraction": "string (optional)"
 * }
 *
 * Response:
 * {
 *   "suggestions": ["suggestion 1", "suggestion 2", "suggestion 3"]
 * }
 */
router.post('/api/habit-suggestions', async (req: Request, res: Response) => {
  try {
    // Validate required fields
    const { suggestion_type, habit_name, time } = req.body;

    if (!suggestion_type) {
      return res.status(400).json({
        error: 'Missing required field: suggestion_type'
      });
    }

    if (!habit_name) {
      return res.status(400).json({
        error: 'Missing required field: habit_name'
      });
    }

    if (!time) {
      return res.status(400).json({
        error: 'Missing required field: time'
      });
    }

    // Validate suggestion_type
    const validTypes = ['temptation_bundle', 'pre_habit_ritual', 'environment_cue', 'environment_distraction'];
    if (!validTypes.includes(suggestion_type)) {
      return res.status(400).json({
        error: `Invalid suggestion_type. Must be one of: ${validTypes.join(', ')}`
      });
    }

    // Build HabitContext from request body (maps snake_case from Flutter to interface)
    const context: HabitContext = {
      suggestionType: suggestion_type,
      identity: req.body.identity,
      habitName: habit_name,
      twoMinuteVersion: req.body.two_minute_version,
      time: time,
      location: req.body.location,
      existingTemptationBundle: req.body.existing_temptation_bundle || null,
      existingPreRitual: req.body.existing_pre_ritual || null,
      existingEnvironmentCue: req.body.existing_environment_cue || null,
      existingEnvironmentDistraction: req.body.existing_environment_distraction || null
    };

    console.log(`📥 Received suggestion request: ${suggestion_type} for "${habit_name}"`);

    // Generate suggestions (LLM with fallback to heuristics)
    const suggestions = await generateSuggestions(context);

    console.log(`📤 Returning ${suggestions.length} suggestions`);

    // Return suggestions
    return res.json({ suggestions });

  } catch (error) {
    console.error('❌ Error in /api/habit-suggestions:', error);

    return res.status(500).json({
      error: 'Could not generate suggestions'
    });
  }
});

export default router;
