import OpenAI from 'openai';

// ========== TYPE DEFINITIONS ==========

export interface HabitContext {
  suggestionType: 'temptation_bundle' | 'pre_habit_ritual' | 'environment_cue' | 'environment_distraction';
  identity?: string;
  habitName: string;
  twoMinuteVersion?: string;
  time: string;  // "HH:MM"
  location?: string;
  existingTemptationBundle?: string | null;
  existingPreRitual?: string | null;
  existingEnvironmentCue?: string | null;
  existingEnvironmentDistraction?: string | null;
}

// ========== HEURISTIC SUGGESTIONS (FALLBACK) ==========

/**
 * Generate suggestions using local heuristic logic (no LLM required)
 * This is the fallback when OpenAI is unavailable or fails
 */
function generateHeuristicSuggestions(context: HabitContext): string[] {
  const { suggestionType, habitName, time, location, identity } = context;

  switch (suggestionType) {
    case 'temptation_bundle':
      return generateTemptationBundleSuggestions(habitName, time, location || '');
    case 'pre_habit_ritual':
      return generatePreHabitRitualSuggestions(habitName, identity || '');
    case 'environment_cue':
      return generateEnvironmentCueSuggestions(habitName, time, location || '');
    case 'environment_distraction':
      return generateEnvironmentDistractionSuggestions(habitName, time, location || '');
    default:
      return [
        'Create a specific plan for when and where to do this habit',
        'Start with a 2-minute version to make it easy to begin',
        'Track your progress to build momentum'
      ];
  }
}

function generateTemptationBundleSuggestions(habitName: string, time: string, location: string): string[] {
  const timeOfDay = parseTimeOfDay(time);
  const habitLower = habitName.toLowerCase();

  // Reading habits
  if (habitLower.includes('read')) {
    if (timeOfDay === 'evening' || timeOfDay === 'night') {
      return [
        'Have a cup of herbal tea while reading',
        'Light a candle and read with soft lighting',
        'Listen to calm instrumental music while you read'
      ];
    } else if (timeOfDay === 'morning') {
      return [
        'Enjoy your morning coffee while reading',
        'Read while having breakfast',
        'Read in a sunny spot with your favorite beverage'
      ];
    } else {
      return [
        'Have a cup of tea or coffee while reading',
        'Read while listening to ambient music',
        'Read in your favorite comfy chair'
      ];
    }
  }

  // Exercise/Movement habits
  if (habitLower.includes('walk') || habitLower.includes('run') ||
      habitLower.includes('exercise') || habitLower.includes('stretch')) {
    return [
      'Listen to your favorite podcast while exercising',
      'Create a pump-up playlist for your workout',
      'Watch an episode of your favorite show on the treadmill'
    ];
  }

  // Meditation/Mindfulness habits
  if (habitLower.includes('meditate') || habitLower.includes('breathe') ||
      habitLower.includes('mindful')) {
    return [
      'Light incense or a scented candle during meditation',
      'Play nature sounds or calming music',
      'Meditate in your favorite spot with soft lighting'
    ];
  }

  // Writing/Journaling habits
  if (habitLower.includes('write') || habitLower.includes('journal')) {
    return [
      'Write while sipping your favorite hot beverage',
      'Light a candle and play soft background music',
      'Write at a café with a special drink'
    ];
  }

  // Default based on time
  if (timeOfDay === 'morning') {
    return [
      'Pair it with your morning coffee or tea',
      'Do it while listening to energizing music',
      'Combine it with morning sunlight exposure'
    ];
  } else {
    return [
      'Listen to your favorite music or podcast',
      'Enjoy a beverage you love while doing it',
      'Do it in your favorite comfortable spot'
    ];
  }
}

function generatePreHabitRitualSuggestions(habitName: string, identity: string): string[] {
  const habitLower = habitName.toLowerCase();

  // Reading habits
  if (habitLower.includes('read')) {
    return [
      'Take 3 slow breaths and open your book to the bookmark',
      'Put your phone in another room, then sit in your reading chair',
      'Write down one thing you\'re curious about, then start reading'
    ];
  }

  // Exercise habits
  if (habitLower.includes('walk') || habitLower.includes('run') || habitLower.includes('exercise')) {
    return [
      'Put on your workout clothes immediately when you decide to exercise',
      'Fill your water bottle and take 3 deep breaths',
      'Play your workout playlist and do 5 jumping jacks'
    ];
  }

  // Meditation habits
  if (habitLower.includes('meditate') || habitLower.includes('breathe')) {
    return [
      'Close your eyes and take 3 deep breaths',
      'Roll your shoulders back and relax your jaw',
      'Light a candle or incense before sitting down'
    ];
  }

  // Default generic rituals
  return [
    'Take 3 slow, deep breaths before starting',
    'Put your phone in another room or on airplane mode',
    identity ? `Say aloud: "I am a person who ${identity}"` : 'State your intention aloud before beginning'
  ];
}

function generateEnvironmentCueSuggestions(habitName: string, time: string, location: string): string[] {
  const habitLower = habitName.toLowerCase();
  const locationLower = location.toLowerCase();

  // Reading habits
  if (habitLower.includes('read')) {
    if (locationLower.includes('bed') || parseTimeOfDay(time) === 'night') {
      return [
        'Put your book on your pillow before bed',
        'Leave your book open on your nightstand',
        'Place your book on top of your phone charger'
      ];
    } else {
      return [
        'Place your book on the seat where you usually sit',
        'Put your book on top of the TV remote',
        'Leave your book open to your current page'
      ];
    }
  }

  // Exercise habits
  if (habitLower.includes('walk') || habitLower.includes('run') || habitLower.includes('exercise')) {
    return [
      'Lay out your workout clothes the night before',
      'Put your running shoes by the door where you\'ll see them',
      'Leave your yoga mat unrolled in the middle of the room'
    ];
  }

  // Default
  return [
    'Place your habit trigger where you can\'t miss it',
    `Put a visual reminder in ${location || 'your usual spot'}`,
    'Leave everything you need in plain sight'
  ];
}

function generateEnvironmentDistractionSuggestions(habitName: string, time: string, location: string): string[] {
  const habitLower = habitName.toLowerCase();
  const timeOfDay = parseTimeOfDay(time);

  // Focus-based habits
  if (habitLower.includes('read') || habitLower.includes('write') ||
      habitLower.includes('study') || habitLower.includes('meditate')) {
    return [
      'Charge your phone in another room during this time',
      'Log out of social media apps or use website blockers',
      'Turn off TV and close all browser tabs'
    ];
  }

  // Evening habits
  if (timeOfDay === 'evening' || timeOfDay === 'night') {
    return [
      'Charge your phone in the kitchen overnight',
      'Log out of Netflix and YouTube on weeknights',
      'Set your router to disable Wi-Fi at bedtime'
    ];
  }

  // Morning habits
  if (timeOfDay === 'morning') {
    return [
      'Put your phone across the room so you can\'t snooze',
      'Delete social media apps or move them off your home screen',
      'Use a physical alarm clock instead of your phone'
    ];
  }

  // Generic fallback
  return [
    'Put your phone on airplane mode or in another room',
    'Close all apps and browser tabs not related to your habit',
    'Remove or hide any items that tempt you away from this habit'
  ];
}

// ========== LLM INTEGRATION WITH FALLBACK ==========

/**
 * Generate habit suggestions using OpenAI LLM, with automatic fallback to heuristics
 *
 * Behavior:
 * 1. If OPENAI_API_KEY is not set → use heuristics immediately
 * 2. If OPENAI_API_KEY is set → try LLM with 5s timeout
 * 3. If LLM fails (network, timeout, invalid response) → fall back to heuristics
 *
 * Guarantees: Always returns a non-empty array of suggestions
 */
export async function generateSuggestions(context: HabitContext): Promise<string[]> {
  const apiKey = process.env.OPENAI_API_KEY;

  // No API key → use heuristics immediately
  if (!apiKey) {
    console.warn('⚠️  OPENAI_API_KEY not set – using heuristic suggestions only');
    return generateHeuristicSuggestions(context);
  }

  // Try LLM with timeout
  try {
    console.log(`🤖 Attempting OpenAI LLM call for ${context.suggestionType}...`);

    const suggestions = await Promise.race([
      callOpenAI(apiKey, context),
      createTimeout(5000, 'OpenAI request timeout after 5s')
    ]);

    // Validate LLM response
    if (Array.isArray(suggestions) && suggestions.length > 0) {
      console.log(`✅ OpenAI returned ${suggestions.length} suggestions`);
      return suggestions;
    } else {
      console.error('❌ OpenAI returned invalid/empty suggestions, using fallback');
      return generateHeuristicSuggestions(context);
    }
  } catch (error) {
    console.error('❌ OpenAI call failed:', error instanceof Error ? error.message : String(error));
    console.log('🔄 Falling back to heuristic suggestions');
    return generateHeuristicSuggestions(context);
  }
}

/**
 * Call OpenAI API to generate suggestions
 */
async function callOpenAI(apiKey: string, context: HabitContext): Promise<string[]> {
  const openai = new OpenAI({ apiKey });

  // Build prompt based on suggestion type
  const prompt = buildPrompt(context);

  const response = await openai.chat.completions.create({
    model: 'gpt-3.5-turbo',
    messages: [
      {
        role: 'system',
        content: 'You are an expert Atomic Habits coach specializing in behavior change. You provide concrete, practical suggestions based on James Clear\'s principles. Always respond with valid JSON only.'
      },
      {
        role: 'user',
        content: prompt
      }
    ],
    temperature: 0.6,
    max_tokens: 300,
    response_format: { type: 'json_object' }
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error('OpenAI returned empty response');
  }

  // Parse and validate JSON
  const parsed = JSON.parse(content);

  if (!parsed.suggestions || !Array.isArray(parsed.suggestions)) {
    throw new Error('OpenAI response missing "suggestions" array');
  }

  const suggestions = parsed.suggestions
    .filter((s: unknown) => typeof s === 'string' && s.trim().length > 0)
    .map((s: string) => s.trim());

  if (suggestions.length === 0) {
    throw new Error('OpenAI returned empty suggestions array');
  }

  return suggestions.slice(0, 3); // Return max 3 suggestions
}

/**
 * Build the prompt for OpenAI based on suggestion type and context
 */
function buildPrompt(context: HabitContext): string {
  const {
    suggestionType,
    identity,
    habitName,
    twoMinuteVersion,
    time,
    location,
    existingTemptationBundle,
    existingPreRitual,
    existingEnvironmentCue,
    existingEnvironmentDistraction
  } = context;

  let typeDescription = '';

  switch (suggestionType) {
    case 'temptation_bundle':
      typeDescription = `Temptation bundling: Pair the habit "${habitName}" with something enjoyable. The suggestions should be concrete activities that make the habit more attractive by linking it to immediate pleasure.`;
      break;
    case 'pre_habit_ritual':
      typeDescription = `Pre-habit ritual: Create a 10-30 second ritual to get into the right mental state before "${habitName}". The ritual should be simple, repeatable, and signal to the brain that it's time to start the habit.`;
      break;
    case 'environment_cue':
      typeDescription = `Environment cue: Create a visible environmental trigger for "${habitName}". The cue should be placed in ${location || 'the relevant location'} and make the habit obvious at ${time}.`;
      break;
    case 'environment_distraction':
      typeDescription = `Environment distraction removal: Add friction to remove distractions that compete with "${habitName}". The suggestions should make bad habits harder to do by increasing steps or removing triggers.`;
      break;
  }

  return `Generate exactly 3 short, concrete, practical suggestions for the following habit:

SUGGESTION TYPE: ${typeDescription}

CONTEXT:
- Identity: ${identity || 'not specified'}
- Habit: ${habitName}
- Two-minute version: ${twoMinuteVersion || 'not specified'}
- Time: ${time}
- Location: ${location || 'not specified'}

EXISTING HABITS:
- Temptation bundle: ${existingTemptationBundle || 'none'}
- Pre-habit ritual: ${existingPreRitual || 'none'}
- Environment cue: ${existingEnvironmentCue || 'none'}
- Environment distraction: ${existingEnvironmentDistraction || 'none'}

Return ONLY valid JSON in this exact format:
{
  "suggestions": [
    "suggestion 1",
    "suggestion 2",
    "suggestion 3"
  ]
}

Each suggestion must be:
- Short (1-2 sentences max)
- Concrete and actionable
- Tailored to the time, location, and habit context
- Aligned with Atomic Habits principles`;
}

/**
 * Create a timeout promise that rejects after specified milliseconds
 */
function createTimeout(ms: number, message: string): Promise<never> {
  return new Promise((_, reject) => {
    setTimeout(() => reject(new Error(message)), ms);
  });
}

// ========== HELPER FUNCTIONS ==========

function parseTimeOfDay(time: string): string {
  try {
    const [hourStr] = time.split(':');
    const hour = parseInt(hourStr, 10);

    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  } catch {
    return 'midday';
  }
}
