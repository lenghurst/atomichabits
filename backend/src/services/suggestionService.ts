export type SuggestionType =
  | 'temptation_bundle'
  | 'pre_habit_ritual'
  | 'environment_cue'
  | 'environment_distraction';

export interface HabitContext {
  suggestionType: SuggestionType;
  identity?: string;
  habitName: string;
  twoMinuteVersion?: string;
  time: string; // "HH:MM"
  location?: string;
  existingTemptationBundle?: string | null;
  existingPreRitual?: string | null;
  existingEnvironmentCue?: string | null;
  existingEnvironmentDistraction?: string | null;
}

type HabitKind = 'reading' | 'walking' | 'mindfulness' | 'generic';
type TimeOfDay = 'morning' | 'afternoon' | 'evening' | 'late-night';

function getTimeOfDay(time: string): TimeOfDay {
  const [hoursString] = time.split(':');
  const hours = Number.parseInt(hoursString, 10);

  if (hours >= 5 && hours < 12) return 'morning';
  if (hours >= 12 && hours < 18) return 'afternoon';
  if (hours >= 18 && hours < 22) return 'evening';
  return 'late-night';
}

function detectHabitKind(context: HabitContext): HabitKind {
  const combined = `${context.habitName} ${context.twoMinuteVersion ?? ''}`.toLowerCase();
  if (/(read|book|study)/.test(combined)) return 'reading';
  if (/(walk|run|steps)/.test(combined)) return 'walking';
  if (/(meditate|breath|breathe)/.test(combined)) return 'mindfulness';
  return 'generic';
}

function readingSuggestions(type: SuggestionType): string[] {
  switch (type) {
    case 'temptation_bundle':
      return [
        'Have a cup of herbal tea while you read.',
        'Light a candle and read with soft lighting.',
        'Listen to a calm instrumental playlist while you read.',
      ];
    case 'pre_habit_ritual':
      return [
        'Take 3 slow breaths and open your book to your bookmark.',
        'Put your phone in another room, then sit on your reading spot.',
        'Write down one thing you\'re curious about, then start reading.',
      ];
    case 'environment_cue':
      return [
        'Put your book on your pillow so you see it before bed.',
        'Leave your book open on your bedside table.',
        'Place your book on the sofa where you usually sit.',
      ];
    case 'environment_distraction':
      return [
        'Charge your phone in the kitchen overnight.',
        'Log out of streaming apps on weeknights.',
        'Close all non-reading apps 10 minutes before your reading time.',
      ];
  }
}

function walkingSuggestions(type: SuggestionType, timeOfDay: TimeOfDay): string[] {
  const sunlight = timeOfDay === 'morning' ? 'Get outside within an hour of waking to take a short walk.' : 'Step outside for 5 minutes before starting your walk.';
  switch (type) {
    case 'temptation_bundle':
      return [
        'Listen to your favorite podcast only while you walk.',
        'Take photos of anything interesting you notice on the walk.',
        'Reward yourself with a fresh coffee or tea after finishing.',
      ];
    case 'pre_habit_ritual':
      return [
        'Do a 30-second stretch routine, then lace up your shoes.',
        sunlight,
        'Set a 10-minute timer and start walking as soon as it starts.',
      ];
    case 'environment_cue':
      return [
        'Place your walking shoes by the door 15 minutes before go-time.',
        'Lay out weather-appropriate clothes the night before.',
        'Set a daily calendar reminder titled "Walk time" at the exact time.',
      ];
    case 'environment_distraction':
      return [
        'Turn on Do Not Disturb until your walk is done.',
        'Schedule calls outside your planned walk window.',
        'Keep your phone in your pocket and only take it out for safety.',
      ];
  }
}

function mindfulnessSuggestions(type: SuggestionType): string[] {
  switch (type) {
    case 'temptation_bundle':
      return [
        'Light incense or a candle only when you meditate.',
        'Wrap yourself in a cozy blanket during meditation.',
        'Play a gentle ambient track you reserve for mindfulness.',
      ];
    case 'pre_habit_ritual':
      return [
        'Take three grounding breaths and feel your feet on the floor.',
        'Dim the lights and silence your devices before starting.',
        'Set a 5-minute timer and sit as soon as it begins.',
      ];
    case 'environment_cue':
      return [
        'Place your meditation cushion where you will see it at your time.',
        'Leave a glass of water on the cushion as a reminder.',
        'Add a calendar alert titled "Sit" with a bell sound.',
      ];
    case 'environment_distraction':
      return [
        'Close all unrelated browser tabs 10 minutes beforehand.',
        'Put your phone in another room while you meditate.',
        'Ask housemates for 10 minutes of quiet during your session.',
      ];
  }
}

function genericSuggestions(type: SuggestionType, timeOfDay: TimeOfDay): string[] {
  const windDown = timeOfDay === 'evening' || timeOfDay === 'late-night';
  const activation = windDown ? 'Set a gentle reminder and prepare your space 15 minutes before the habit.' : 'Do a quick countdown from 5 and start the habit immediately.';

  switch (type) {
    case 'temptation_bundle':
      return [
        'Pair the habit with a small treat you enjoy, like a specific drink.',
        'Play a favorite playlist you only use during this habit.',
        'Combine the habit with a comfort item such as a blanket or candle.',
      ];
    case 'pre_habit_ritual':
      return [
        activation,
        'Take three deep breaths and say your identity statement out loud.',
        'Remove one quick friction point (like clearing your workspace) before starting.',
      ];
    case 'environment_cue':
      return [
        'Place a visible cue in the spot you will do the habit.',
        'Set a calendar event at the exact time with a clear title.',
        windDown ? 'Lay out anything you need the night before.' : 'Keep needed tools within arm\'s reach at habit time.',
      ];
    case 'environment_distraction':
      return [
        'Silence or move distracting devices out of reach until done.',
        windDown ? 'Log out of high-stimulation apps after dinner.' : 'Block distracting sites for 30 minutes during the habit.',
        'Tell someone nearby you\'ll be unavailable for the next 15 minutes.',
      ];
  }
}

// TODO: Replace heuristic generation with an LLM call in a future iteration.
export function generateSuggestions(context: HabitContext): string[] {
  const timeOfDay = getTimeOfDay(context.time);
  const habitKind = detectHabitKind(context);

  switch (habitKind) {
    case 'reading':
      return readingSuggestions(context.suggestionType);
    case 'walking':
      return walkingSuggestions(context.suggestionType, timeOfDay);
    case 'mindfulness':
      return mindfulnessSuggestions(context.suggestionType);
    default:
      return genericSuggestions(context.suggestionType, timeOfDay);
  }
}
