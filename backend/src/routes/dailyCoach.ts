import { Router, Request, Response } from 'express';
import {
  generateDailyReflection,
  DailyReflectionRequest,
  DailyStatus,
} from '../services/dailyCoachService.js';

const router = Router();

/**
 * POST /api/coach/daily-reflection
 *
 * Generate a daily reflection for today's habit completion/miss
 *
 * REQUEST BODY:
 * {
 *   "habit": {
 *     "habit_name": "Read for 10 minutes",
 *     "identity": "I am a reader",
 *     "two_minute_version": "Read one page",
 *     "time": "22:00",
 *     "location": "In bed"
 *   },
 *   "date": "2025-11-17",
 *   "status": "missed" | "completed" | "partial",
 *   "reflection": {
 *     "what_happened": "I scrolled my phone and fell asleep.",
 *     "what_helped_or_blocked": "I was exhausted after work.",
 *     "what_might_help_tomorrow": "Charge my phone outside the bedroom."
 *   }
 * }
 *
 * RESPONSE (200 OK):
 * {
 *   "coach_message": "Today didn't go as planned, but you're still a reader.",
 *   "insights": [
 *     "You tend to miss when you're tired after work.",
 *     "Your phone becomes a competing habit at bedtime."
 *   ],
 *   "suggested_adjustments": [
 *     "Move your phone charger out of the bedroom before 21:30.",
 *     "Start reading 15 minutes earlier, before exhaustion hits."
 *   ],
 *   "suggested_tomorrow_experiment": "Tomorrow, plug your phone in the kitchen at 21:15 and read one page."
 * }
 *
 * ERROR RESPONSES:
 * - 400 Bad Request: Missing required fields or invalid status
 * - 503 Service Unavailable: Coach temporarily unavailable
 */
router.post('/api/coach/daily-reflection', async (req: Request, res: Response) => {
  try {
    const body = req.body as Partial<Record<string, unknown>>;

    console.log('📘 POST /api/coach/daily-reflection - Received request');

    // Validate request body
    if (!body || typeof body !== 'object') {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Request body must be a valid object',
      });
    }

    // Validate habit object
    if (!body.habit || typeof body.habit !== 'object') {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Missing or invalid habit object',
      });
    }

    const habit = body.habit as Record<string, unknown>;

    // Validate required fields
    if (!habit.habit_name || typeof habit.habit_name !== 'string') {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Missing or invalid habit.habit_name',
      });
    }

    if (!body.date || typeof body.date !== 'string') {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Missing or invalid date (expected yyyy-MM-dd format)',
      });
    }

    // Validate date format (basic check)
    if (!body.date.match(/^\d{4}-\d{2}-\d{2}$/)) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Invalid date format. Expected yyyy-MM-dd',
      });
    }

    if (!body.status || typeof body.status !== 'string') {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Missing or invalid status',
      });
    }

    // Validate status value
    const validStatuses: DailyStatus[] = ['completed', 'missed', 'partial'];
    if (!validStatuses.includes(body.status as DailyStatus)) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Status must be one of: completed, missed, partial',
      });
    }

    // Build DailyReflectionRequest from snake_case to camelCase
    const reflection = body.reflection as Record<string, unknown> | undefined;

    const reflectionRequest: DailyReflectionRequest = {
      habit: {
        habitName: habit.habit_name as string,
        identity: typeof habit.identity === 'string' ? habit.identity : undefined,
        twoMinuteVersion: typeof habit.two_minute_version === 'string' ? habit.two_minute_version : undefined,
        time: typeof habit.time === 'string' ? habit.time : undefined,
        location: typeof habit.location === 'string' ? habit.location : undefined,
      },
      date: body.date as string,
      status: body.status as DailyStatus,
      reflection: {
        whatHappened: typeof reflection?.what_happened === 'string' ? reflection.what_happened : undefined,
        whatHelpedOrBlocked: typeof reflection?.what_helped_or_blocked === 'string' ? reflection.what_helped_or_blocked : undefined,
        whatMightHelpTomorrow: typeof reflection?.what_might_help_tomorrow === 'string' ? reflection.what_might_help_tomorrow : undefined,
      },
    };

    // Log request details
    console.log(`📝 Reflection for: ${reflectionRequest.habit.habitName} (${reflectionRequest.status})`);

    // Generate reflection
    const result = await generateDailyReflection(reflectionRequest);

    // Convert camelCase response to snake_case for consistency
    const response = {
      coach_message: result.coachMessage,
      insights: result.insights,
      suggested_adjustments: result.suggestedAdjustments,
      suggested_tomorrow_experiment: result.suggestedTomorrowExperiment,
    };

    console.log(`✅ Generated reflection with ${result.insights.length} insights`);

    return res.status(200).json(response);
  } catch (error) {
    console.error('❌ Error in /api/coach/daily-reflection:', error);

    return res.status(503).json({
      error: 'Service unavailable',
      message: 'The coach is temporarily unavailable. Please try again later.',
    });
  }
});

export default router;
