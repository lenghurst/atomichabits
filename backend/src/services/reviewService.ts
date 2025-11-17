import OpenAI from 'openai';

// ========== TYPE DEFINITIONS ==========

export interface HabitInfo {
  identity?: string;
  habitName: string;
  twoMinuteVersion?: string;
  time?: string;
  location?: string;
  temptationBundle?: string;
  preHabitRitual?: string;
  environmentCue?: string;
  environmentDistraction?: string;
}

export interface HistoryEntry {
  date: string;       // "yyyy-MM-dd"
  completed: boolean;
}

export interface WeeklyReview {
  summary: string;
  insights: string[];
  suggestedAdjustments: string[];
}

// ========== HEURISTIC REVIEW (FALLBACK) ==========

/**
 * Generate a weekly review using local heuristic logic (no LLM required)
 * This is the fallback when OpenAI is unavailable or fails
 */
function generateHeuristicReview(
  habit: HabitInfo,
  history: HistoryEntry[]
): WeeklyReview {
  // Focus on last 7-14 days
  const recentHistory = history.slice(0, Math.min(14, history.length));
  const last7Days = recentHistory.slice(0, 7);

  // Calculate statistics
  const completedLast7 = last7Days.filter(entry => entry.completed).length;
  const completionRate = Math.round((completedLast7 / 7) * 100);

  // Calculate longest streak in last 7 days
  let currentStreak = 0;
  let longestStreak = 0;
  for (const entry of last7Days) {
    if (entry.completed) {
      currentStreak++;
      longestStreak = Math.max(longestStreak, currentStreak);
    } else {
      currentStreak = 0;
    }
  }

  // Check for patterns
  const weekdays = last7Days.filter((entry, index) => {
    const dayOfWeek = new Date(entry.date).getDay();
    return dayOfWeek >= 1 && dayOfWeek <= 5; // Mon-Fri
  });
  const weekends = last7Days.filter((entry, index) => {
    const dayOfWeek = new Date(entry.date).getDay();
    return dayOfWeek === 0 || dayOfWeek === 6; // Sat-Sun
  });

  const weekdayCompletions = weekdays.filter(e => e.completed).length;
  const weekendCompletions = weekends.filter(e => e.completed).length;

  // Build summary
  let summary = `You completed "${habit.habitName}" ${completedLast7} out of 7 days this week (${completionRate}%). `;
  if (completionRate >= 85) {
    summary += 'Excellent consistency! Your habit is becoming automatic.';
  } else if (completionRate >= 60) {
    summary += 'Good progress! Keep building momentum.';
  } else {
    summary += 'Room for improvement. Focus on making the habit easier and more obvious.';
  }

  // Build insights
  const insights: string[] = [];

  if (longestStreak >= 3) {
    insights.push(`Your longest streak was ${longestStreak} days - you can maintain consistency!`);
  }

  if (weekdays.length > 0 && weekends.length > 0) {
    if (weekdayCompletions / weekdays.length > weekendCompletions / weekends.length) {
      insights.push('Weekdays are stronger than weekends - your routine helps consistency.');
    } else if (weekendCompletions / weekends.length > weekdayCompletions / weekdays.length) {
      insights.push('Weekends are stronger than weekdays - work schedule may be interfering.');
    }
  }

  if (completionRate < 50) {
    insights.push('Less than 50% completion suggests the habit may be too difficult or poorly cued.');
  }

  if (insights.length === 0) {
    insights.push('Building a habit takes time - focus on consistency over perfection.');
  }

  // Build suggested adjustments
  const adjustments: string[] = [];

  if (completionRate < 60) {
    if (habit.twoMinuteVersion) {
      adjustments.push(`Make it even easier: Try just "${habit.twoMinuteVersion}" for the next week.`);
    } else {
      adjustments.push('Make it easier: Create a 2-minute version of this habit to lower the barrier.');
    }
  }

  if (!habit.environmentCue || habit.environmentCue.length < 10) {
    adjustments.push(`Make it obvious: Set up a clear visual cue in ${habit.location || 'your space'}.`);
  }

  if (weekdayCompletions / (weekdays.length || 1) < weekendCompletions / (weekends.length || 1)) {
    adjustments.push('Consider moving your habit 30 minutes earlier to avoid work conflicts.');
  }

  if (!habit.temptationBundle || habit.temptationBundle.length < 10) {
    adjustments.push('Make it attractive: Pair this habit with something you enjoy (temptation bundling).');
  }

  if (adjustments.length === 0) {
    adjustments.push('Keep your current system - it\'s working well!');
    adjustments.push('Focus on never missing twice in a row to maintain momentum.');
  }

  return {
    summary,
    insights,
    suggestedAdjustments: adjustments.slice(0, 4), // Max 4 adjustments
  };
}

// ========== LLM INTEGRATION WITH FALLBACK ==========

/**
 * Generate weekly review using OpenAI LLM, with automatic fallback to heuristics
 *
 * Behavior:
 * 1. If OPENAI_API_KEY is not set → use heuristics immediately
 * 2. If OPENAI_API_KEY is set → try LLM with 5s timeout
 * 3. If LLM fails (network, timeout, invalid response) → fall back to heuristics
 *
 * Guarantees: Always returns a WeeklyReview with at least 1 insight and 1 adjustment
 */
export async function generateWeeklyReview(
  habit: HabitInfo,
  history: HistoryEntry[]
): Promise<WeeklyReview> {
  const apiKey = process.env.OPENAI_API_KEY;

  // No API key → use heuristics immediately
  if (!apiKey) {
    console.warn('⚠️  OPENAI_API_KEY not set – using heuristic review only');
    return generateHeuristicReview(habit, history);
  }

  // Try LLM with timeout
  try {
    console.log(`🤖 Attempting OpenAI LLM call for weekly review...`);

    const review = await Promise.race([
      callOpenAI(apiKey, habit, history),
      createTimeout(5000, 'OpenAI request timeout after 5s')
    ]);

    // Validate LLM response
    if (review && review.summary && review.insights.length > 0 && review.suggestedAdjustments.length > 0) {
      console.log(`✅ OpenAI returned weekly review`);
      return review;
    } else {
      console.error('❌ OpenAI returned invalid review structure, using fallback');
      return generateHeuristicReview(habit, history);
    }
  } catch (error) {
    console.error('❌ OpenAI call failed:', error instanceof Error ? error.message : String(error));
    console.log('🔄 Falling back to heuristic review');
    return generateHeuristicReview(habit, history);
  }
}

/**
 * Call OpenAI API to generate weekly review
 */
async function callOpenAI(
  apiKey: string,
  habit: HabitInfo,
  history: HistoryEntry[]
): Promise<WeeklyReview> {
  const openai = new OpenAI({ apiKey });

  // Build prompt
  const prompt = buildPrompt(habit, history);

  const response = await openai.chat.completions.create({
    model: 'gpt-3.5-turbo',
    messages: [
      {
        role: 'system',
        content: 'You are an expert Atomic Habits coach specializing in behavior change and weekly habit reviews. You provide concrete, actionable insights based on completion patterns. Always respond with valid JSON only.'
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

  if (!parsed.summary || !Array.isArray(parsed.insights) || !Array.isArray(parsed.suggested_adjustments)) {
    throw new Error('OpenAI response missing required fields');
  }

  // Validate content
  if (parsed.summary.length === 0) {
    throw new Error('OpenAI returned empty summary');
  }

  if (parsed.insights.length === 0) {
    throw new Error('OpenAI returned empty insights');
  }

  if (parsed.suggested_adjustments.length === 0) {
    throw new Error('OpenAI returned empty adjustments');
  }

  return {
    summary: parsed.summary.trim().substring(0, 350), // Max 350 chars
    insights: parsed.insights
      .filter((s: unknown) => typeof s === 'string' && s.trim().length > 0)
      .map((s: string) => s.trim())
      .slice(0, 4), // Max 4 insights
    suggestedAdjustments: parsed.suggested_adjustments
      .filter((s: unknown) => typeof s === 'string' && s.trim().length > 0)
      .map((s: string) => s.trim())
      .slice(0, 4), // Max 4 adjustments
  };
}

/**
 * Build the prompt for OpenAI weekly review
 */
function buildPrompt(habit: HabitInfo, history: HistoryEntry[]): string {
  // Focus on last 7-14 days
  const recentHistory = history.slice(0, Math.min(14, history.length));
  const last7Days = recentHistory.slice(0, 7);

  // Calculate basic stats
  const completedLast7 = last7Days.filter(entry => entry.completed).length;
  const completionRate = Math.round((completedLast7 / 7) * 100);

  // Format history for prompt
  const historyText = last7Days
    .map(entry => `  - ${entry.date}: ${entry.completed ? 'Completed ✓' : 'Missed ✗'}`)
    .join('\n');

  return `Generate a weekly review for this Atomic Habits user.

HABIT CONTEXT:
- Identity: ${habit.identity || 'not specified'}
- Habit: ${habit.habitName}
- Two-minute version: ${habit.twoMinuteVersion || 'not specified'}
- Time: ${habit.time || 'not specified'}
- Location: ${habit.location || 'not specified'}
- Temptation bundle: ${habit.temptationBundle || 'not set'}
- Pre-habit ritual: ${habit.preHabitRitual || 'not set'}
- Environment cue: ${habit.environmentCue || 'not set'}
- Environment distraction: ${habit.environmentDistraction || 'not set'}

COMPLETION HISTORY (Last 7 Days):
${historyText}

COMPLETION RATE: ${completedLast7}/7 days (${completionRate}%)

Generate a weekly review with:
1. A short summary (2-4 sentences, max 350 characters) describing their week
2. 2-4 concrete insights about patterns you notice (weekday/weekend differences, streaks, consistency)
3. 2-4 tiny adjustments aligned with Atomic Habits principles:
   - Make it obvious (environment cues)
   - Make it attractive (temptation bundling)
   - Make it easy (2-minute rule, reduce friction)
   - Make it satisfying (tracking, rewards)

Focus on:
- Specific, actionable adjustments (not generic "try harder")
- Patterns in the completion data
- Environmental or system changes, not willpower
- Encouragement balanced with concrete next steps

Return ONLY valid JSON in this exact format:
{
  "summary": "...",
  "insights": ["...", "..."],
  "suggested_adjustments": ["...", "..."]
}`;
}

/**
 * Create a timeout promise that rejects after specified milliseconds
 */
function createTimeout(ms: number, message: string): Promise<never> {
  return new Promise((_, reject) => {
    setTimeout(() => reject(new Error(message)), ms);
  });
}
