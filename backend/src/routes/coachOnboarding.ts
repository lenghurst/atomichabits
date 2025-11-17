import { Router, Request, Response } from 'express';
import {
  generateOnboardingHabitPlan,
  OnboardingCoachContext,
} from '../services/coachOnboardingService.js';

const router = Router();

/**
 * POST /api/coach/onboarding
 *
 * Generate a structured habit plan from conversational context
 *
 * REQUEST BODY (OnboardingCoachContext):
 * {
 *   "desired_identity": "a reader",
 *   "habit_idea": "read more books",
 *   "when_in_day": "before bed around 9pm",
 *   "where_location": "in bed",
 *   "what_makes_it_enjoyable": "having tea",
 *   "user_name": "Alex" (optional)
 * }
 *
 * RESPONSE (200 OK):
 * {
 *   "habit_plan": {
 *     "identity": "I am a reader",
 *     "habit_name": "Read every day",
 *     "tiny_version": "Read one page",
 *     "implementation_time": "21:00",
 *     "implementation_location": "In bed",
 *     "temptation_bundle": "Have herbal tea while reading",
 *     "pre_habit_ritual": "Take 3 deep breaths and open book",
 *     "environment_cue": "Put book on pillow at 20:45",
 *     "environment_distraction": "Charge phone in the kitchen"
 *   },
 *   "metadata": {
 *     "confidence": 0.85,
 *     "missing_fields": ["temptation_bundle"],
 *     "notes": "Review and adjust before saving."
 *   }
 * }
 *
 * ERROR RESPONSES:
 * - 400 Bad Request: Missing or invalid context
 * - 503 Service Unavailable: OpenAI failed and heuristics couldn't generate valid plan
 */
router.post('/api/coach/onboarding', async (req: Request, res: Response) => {
  try {
    const context = req.body as Partial<Record<string, unknown>>;

    console.log('📞 POST /api/coach/onboarding - Received request');

    // Validate that context exists and is an object
    if (!context || typeof context !== 'object') {
      console.error('❌ Invalid request: context is not an object');
      return res.status(400).json({
        error: 'Invalid request',
        message: 'Request body must be a valid context object',
      });
    }

    // Convert snake_case keys to camelCase for service
    const coachContext: OnboardingCoachContext = {
      desiredIdentity: typeof context.desired_identity === 'string' ? context.desired_identity : undefined,
      habitIdea: typeof context.habit_idea === 'string' ? context.habit_idea : undefined,
      whenInDay: typeof context.when_in_day === 'string' ? context.when_in_day : undefined,
      whereLocation: typeof context.where_location === 'string' ? context.where_location : undefined,
      whatMakesItEnjoyable: typeof context.what_makes_it_enjoyable === 'string' ? context.what_makes_it_enjoyable : undefined,
      userName: typeof context.user_name === 'string' ? context.user_name : undefined,
    };

    // Log what we received
    console.log('📝 Coach context:', {
      desiredIdentity: coachContext.desiredIdentity ? '✓' : '✗',
      habitIdea: coachContext.habitIdea ? '✓' : '✗',
      whenInDay: coachContext.whenInDay ? '✓' : '✗',
      whereLocation: coachContext.whereLocation ? '✓' : '✗',
      whatMakesItEnjoyable: coachContext.whatMakesItEnjoyable ? '✓' : '✗',
    });

    // Check if we have at least some context
    const hasAnyContext =
      coachContext.desiredIdentity ||
      coachContext.habitIdea ||
      coachContext.whenInDay ||
      coachContext.whereLocation;

    if (!hasAnyContext) {
      console.error('❌ Invalid request: no context provided');
      return res.status(400).json({
        error: 'Insufficient context',
        message: 'Please provide at least one answer to generate a habit plan',
      });
    }

    // Generate habit plan (with LLM + fallback)
    const result = await generateOnboardingHabitPlan(coachContext);

    // Convert camelCase response to snake_case for consistency with other endpoints
    const response = {
      habit_plan: {
        identity: result.habitPlan.identity,
        habit_name: result.habitPlan.habitName,
        tiny_version: result.habitPlan.tinyVersion,
        implementation_time: result.habitPlan.implementationTime,
        implementation_location: result.habitPlan.implementationLocation,
        temptation_bundle: result.habitPlan.temptationBundle || null,
        pre_habit_ritual: result.habitPlan.preHabitRitual || null,
        environment_cue: result.habitPlan.environmentCue || null,
        environment_distraction: result.habitPlan.environmentDistraction || null,
      },
      metadata: {
        confidence: result.metadata.confidence,
        missing_fields: result.metadata.missingFields || null,
        notes: result.metadata.notes || null,
      },
    };

    console.log(`✅ Generated habit plan: "${response.habit_plan.habit_name}" (confidence: ${response.metadata.confidence})`);

    return res.status(200).json(response);
  } catch (error) {
    console.error('❌ Error in /api/coach/onboarding:', error);

    return res.status(503).json({
      error: 'Service unavailable',
      message: 'The coach is temporarily unavailable. Please try the manual form or try again later.',
    });
  }
});

export default router;
