import OpenAI from 'openai';

// ========== TYPE DEFINITIONS ==========

export interface DailyHabitInfo {
  identity?: string;
  habitName: string;
  twoMinuteVersion?: string;
  time?: string;       // "HH:MM" optional
  location?: string;   // short phrase
}

export type DailyStatus = 'completed' | 'missed' | 'partial';

export interface DailyReflectionInput {
  whatHappened?: string;
  whatHelpedOrBlocked?: string;
  whatMightHelpTomorrow?: string;
}

export interface DailyReflectionRequest {
  habit: DailyHabitInfo;
  date: string;          // "yyyy-MM-dd"
  status: DailyStatus;
  reflection: DailyReflectionInput;
}

export interface DailyReflectionResponse {
  coachMessage: string;            // 1–2 short sentences, non-judgemental
  insights: string[];              // 1–3 bullet insights
  suggestedAdjustments: string[];  // 1–3 small tweaks for system
  suggestedTomorrowExperiment: string; // one concrete "try this tomorrow"
}

// ========== HEURISTIC REFLECTION (FALLBACK) ==========

/**
 * Generate a basic daily reflection using heuristic logic
 * This is the fallback when OpenAI is unavailable or fails
 */
function generateHeuristicReflection(req: DailyReflectionRequest): DailyReflectionResponse {
  console.log(`🔄 Generating heuristic reflection for ${req.status} day`);

  const { habit, status, reflection } = req;

  if (status === 'completed') {
    return {
      coachMessage: `Great work today! You showed up as ${habit.identity || 'someone building this habit'}. Small wins compound into big changes.`,
      insights: [
        reflection.whatHelpedOrBlocked
          ? `What worked: ${reflection.whatHelpedOrBlocked}`
          : 'You completed the habit — that\'s what matters most',
        'Consistency beats perfection every time',
      ].slice(0, 2),
      suggestedAdjustments: [
        reflection.whatMightHelpTomorrow
          ? `Tomorrow: ${reflection.whatMightHelpTomorrow}`
          : 'Keep the same conditions that worked today',
      ],
      suggestedTomorrowExperiment: 'Repeat exactly what worked today — same time, same place, same ritual.',
    };
  }

  if (status === 'partial') {
    return {
      coachMessage: `You made an effort today, and that counts. Progress isn\'t always perfect, but showing up is what builds ${habit.identity || 'the habit'}.`,
      insights: [
        'Partial completion is still progress',
        reflection.whatHelpedOrBlocked
          ? `Friction point: ${reflection.whatHelpedOrBlocked}`
          : 'Consider what made it harder to finish',
      ],
      suggestedAdjustments: [
        reflection.whatMightHelpTomorrow || 'Make the 2-minute version even smaller tomorrow',
      ],
      suggestedTomorrowExperiment: reflection.whatMightHelpTomorrow
        ? `Tomorrow, try: ${reflection.whatMightHelpTomorrow}`
        : 'Tomorrow, do just the first 30 seconds and see how you feel.',
    };
  }

  // status === 'missed'
  return {
    coachMessage: `Today didn\'t go as planned, but you\'re still ${habit.identity || 'building this habit'}. Missing once won\'t break you — it\'s the pattern that matters.`,
    insights: [
      'Every day is a new chance to show up',
      reflection.whatHelpedOrBlocked
        ? `Today\'s blocker: ${reflection.whatHelpedOrBlocked}`
        : 'Identify what got in the way so you can plan around it',
    ],
    suggestedAdjustments: [
      reflection.whatMightHelpTomorrow || 'Make it 1% easier tomorrow — adjust time, place, or the 2-minute version',
    ],
    suggestedTomorrowExperiment: reflection.whatMightHelpTomorrow
      ? `Tomorrow: ${reflection.whatMightHelpTomorrow}`
      : `Tomorrow, set up your environment ${habit.location ? `at ${habit.location}` : ''} 15 minutes before ${habit.time || 'your habit time'}.`,
  };
}

// ========== LLM INTEGRATION WITH FALLBACK ==========

/**
 * Generate daily reflection using OpenAI LLM, with automatic fallback to heuristics
 *
 * Behavior:
 * 1. If OPENAI_API_KEY is not set → use heuristics immediately
 * 2. If OPENAI_API_KEY is set → try LLM with 5s timeout
 * 3. If LLM fails (network, timeout, invalid response) → fall back to heuristics
 *
 * Guarantees: Always returns a DailyReflectionResponse
 */
export async function generateDailyReflection(
  req: DailyReflectionRequest
): Promise<DailyReflectionResponse> {
  const apiKey = process.env.OPENAI_API_KEY;

  // No API key → use heuristics immediately
  if (!apiKey) {
    console.warn('⚠️  OPENAI_API_KEY not set – using heuristic reflection');
    return generateHeuristicReflection(req);
  }

  // Try LLM with timeout
  try {
    console.log(`🤖 Attempting OpenAI LLM call for daily reflection (${req.status})...`);

    const result = await Promise.race([
      callOpenAI(apiKey, req),
      createTimeout(5000, 'OpenAI request timeout after 5s')
    ]);

    // Validate LLM response
    if (result && result.coachMessage && result.insights && result.suggestedAdjustments && result.suggestedTomorrowExperiment) {
      console.log(`✅ OpenAI returned reflection for ${req.status} day`);
      return result;
    } else {
      console.error('❌ OpenAI returned invalid reflection structure, using fallback');
      return generateHeuristicReflection(req);
    }
  } catch (error) {
    console.error('❌ OpenAI call failed:', error instanceof Error ? error.message : String(error));
    console.log('🔄 Falling back to heuristic reflection');
    return generateHeuristicReflection(req);
  }
}

/**
 * Call OpenAI API to generate daily reflection
 */
async function callOpenAI(
  apiKey: string,
  req: DailyReflectionRequest
): Promise<DailyReflectionResponse> {
  const openai = new OpenAI({ apiKey });

  // Build prompt
  const prompt = buildPrompt(req);

  const response = await openai.chat.completions.create({
    model: 'gpt-3.5-turbo',
    messages: [
      {
        role: 'system',
        content: `You are an Atomic Habits coach helping someone reflect on their day.

CORE PRINCIPLES:
1. Identity-first: Remind them who they are becoming (e.g., "You're still a reader")
2. 1% improvement: Focus on tiny adjustments, not perfection
3. Systems over willpower: Suggest environmental or timing tweaks, not motivation
4. Non-judgemental: Never shame, never overpromise, just support

TONE:
- Warm but not gushing
- Specific and actionable
- Short sentences (max 200 chars per string)
- British English

FIELD RULES:
- coach_message: 1–2 sentences max. Acknowledge the day and link to identity.
- insights: 1–3 bullets. What patterns or blockers surfaced today.
- suggested_adjustments: 1–3 bullets. Small system tweaks (time, place, cue, distraction removal).
- suggested_tomorrow_experiment: 1 sentence. One concrete thing to try tomorrow.

RESPONSE FORMAT:
Always respond with strict JSON only. No markdown, no extra keys.`
      },
      {
        role: 'user',
        content: prompt
      }
    ],
    temperature: 0.6,
    max_tokens: 500,
    response_format: { type: 'json_object' }
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error('OpenAI returned empty response');
  }

  // Parse and validate JSON
  const parsed = JSON.parse(content);

  if (!parsed.coach_message || !parsed.insights || !parsed.suggested_adjustments || !parsed.suggested_tomorrow_experiment) {
    throw new Error('OpenAI reflection missing required fields');
  }

  // Validate insights and adjustments are arrays
  if (!Array.isArray(parsed.insights) || !Array.isArray(parsed.suggested_adjustments)) {
    throw new Error('OpenAI reflection insights/adjustments must be arrays');
  }

  // Limit array lengths
  const insights = parsed.insights.slice(0, 3);
  const suggestedAdjustments = parsed.suggested_adjustments.slice(0, 3);

  return {
    coachMessage: parsed.coach_message.trim(),
    insights,
    suggestedAdjustments,
    suggestedTomorrowExperiment: parsed.suggested_tomorrow_experiment.trim(),
  };
}

/**
 * Build the prompt for OpenAI daily reflection
 */
function buildPrompt(req: DailyReflectionRequest): string {
  const { habit, date, status, reflection } = req;

  return `Generate a daily reflection for ${date}.

HABIT CONTEXT:
- Identity: ${habit.identity || 'Not specified'}
- Habit: ${habit.habitName}
- 2-minute version: ${habit.twoMinuteVersion || 'Not specified'}
- Time: ${habit.time || 'Not specified'}
- Location: ${habit.location || 'Not specified'}

TODAY'S STATUS: ${status}

USER REFLECTION:
${status === 'completed' ? '✅ Completed today' : status === 'partial' ? '⚠️ Partially completed' : '❌ Missed today'}

Q: What happened today?
A: ${reflection.whatHappened || 'Not provided'}

Q: What helped or got in the way?
A: ${reflection.whatHelpedOrBlocked || 'Not provided'}

Q: What might make it 1% easier tomorrow?
A: ${reflection.whatMightHelpTomorrow || 'Not provided'}

TASK:
Generate a supportive daily reflection following Atomic Habits principles.

Return ONLY this JSON structure:
{
  "coach_message": "Today didn't go as planned, but you're still a reader. Missing once won't break you.",
  "insights": [
    "You tend to miss when you're tired after work",
    "Phone becomes a competing habit at bedtime"
  ],
  "suggested_adjustments": [
    "Move phone charger out of bedroom before 21:30",
    "Start reading 15 minutes earlier, before exhaustion hits"
  ],
  "suggested_tomorrow_experiment": "Tomorrow, plug your phone in the kitchen at 21:15 and read one page as soon as you get into bed."
}

Make it:
- ${status === 'completed' ? 'Celebratory but not over-the-top' : status === 'partial' ? 'Encouraging and focused on what worked' : 'Understanding and focused on making it easier'}
- Specific to their context (${habit.habitName}, ${habit.time || 'their time'}, ${habit.location || 'their location'})
- Actionable for tomorrow
- Identity-anchored (remind them they are ${habit.identity || 'building this habit'})`;
}

/**
 * Create a timeout promise that rejects after specified milliseconds
 */
function createTimeout(ms: number, message: string): Promise<never> {
  return new Promise((_, reject) => {
    setTimeout(() => reject(new Error(message)), ms);
  });
}
