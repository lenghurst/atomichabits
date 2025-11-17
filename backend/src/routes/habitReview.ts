import { Router, Request, Response } from 'express';
import { generateWeeklyReview, HabitInfo, HistoryEntry } from '../services/reviewService';

const router = Router();

/**
 * POST /api/habit-review
 *
 * Generate AI-powered weekly review for habit based on completion history
 *
 * CLIENT CONTRACT: This endpoint is consumed by the Flutter app's HistoryScreen
 * (lib/features/history/history_screen.dart). The request/response format must stay aligned.
 *
 * Request body:
 * {
 *   "habit": {
 *     "identity": "string (optional)",
 *     "habit_name": "string (required)",
 *     "two_minute_version": "string (optional)",
 *     "time": "string (optional, HH:MM format)",
 *     "location": "string (optional)",
 *     "temptation_bundle": "string (optional)",
 *     "pre_habit_ritual": "string (optional)",
 *     "environment_cue": "string (optional)",
 *     "environment_distraction": "string (optional)"
 *   },
 *   "history": [
 *     { "date": "yyyy-MM-dd", "completed": true },
 *     { "date": "yyyy-MM-dd", "completed": false },
 *     ...
 *   ]
 * }
 *
 * Response:
 * {
 *   "summary": "Short paragraph summarising the week (2-4 sentences, max 350 chars)",
 *   "insights": [
 *     "Concrete insight 1",
 *     "Concrete insight 2",
 *     ...
 *   ],
 *   "suggested_adjustments": [
 *     "Tiny tweak 1",
 *     "Tiny tweak 2",
 *     ...
 *   ]
 * }
 */
router.post('/api/habit-review', async (req: Request, res: Response) => {
  try {
    // Validate required fields
    const { habit, history } = req.body;

    if (!habit) {
      return res.status(400).json({
        error: 'Missing required field: habit'
      });
    }

    if (!habit.habit_name) {
      return res.status(400).json({
        error: 'Missing required field: habit.habit_name'
      });
    }

    if (!history || !Array.isArray(history)) {
      return res.status(400).json({
        error: 'Missing or invalid field: history (must be an array)'
      });
    }

    // Build HabitInfo from request body
    const habitInfo: HabitInfo = {
      identity: habit.identity,
      habitName: habit.habit_name,
      twoMinuteVersion: habit.two_minute_version,
      time: habit.time,
      location: habit.location,
      temptationBundle: habit.temptation_bundle,
      preHabitRitual: habit.pre_habit_ritual,
      environmentCue: habit.environment_cue,
      environmentDistraction: habit.environment_distraction,
    };

    // Parse history entries
    const historyEntries: HistoryEntry[] = history.map((entry: any) => ({
      date: entry.date as string,
      completed: entry.completed as boolean,
    }));

    console.log(`📥 Received review request for "${habitInfo.habitName}" with ${historyEntries.length} history entries`);

    // Generate weekly review (LLM with fallback to heuristics)
    const review = await generateWeeklyReview(habitInfo, historyEntries);

    console.log(`📤 Returning weekly review: ${review.insights.length} insights, ${review.suggestedAdjustments.length} adjustments`);

    // Return review
    return res.json(review);

  } catch (error) {
    console.error('❌ Error in /api/habit-review:', error);

    return res.status(500).json({
      error: 'Could not generate weekly review'
    });
  }
});

export default router;
