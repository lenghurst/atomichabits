/// Niche Configuration
/// 
/// Phase 19: "The Side Door Strategy" - Persona-Based Onboarding
/// 
/// Based on the "Bezos Side Door" approach: One app, multiple front doors.
/// Each niche gets customized language, examples, and hooks while
/// using the exact same codebase.
/// 
/// Target Niches (ranked by Matrix score):
/// 1. Indie Developer ("The Builder") - 4/4 score
/// 2. Content Creator ("The Writer/YouTuber") - 4/4 score
/// 3. PhD/Thesis Student ("The Deep Worker") - 4/4 score
/// 
/// Matrix Criteria:
/// - Boss Vacuum: No external enforcer
/// - Maker's Guilt: Identity tied to output
/// - Streak Victim: Burned by streak apps
/// - Digital Desk: Already at device
library;

/// User persona niches for customized onboarding
enum UserNiche {
  /// Default - no niche detected
  general,
  
  /// Indie Developer / Builder
  /// Entry: r/programming, HackerNews, Twitter/X dev community
  /// Hook: "Stop worshipping the Green Squares"
  developer,
  
  /// Writer / Content Creator / YouTuber
  /// Entry: r/writing, Medium, YouTube creator communities
  /// Hook: "The Algorithm wants perfection. You are human."
  writer,
  
  /// PhD Student / Academic / Researcher
  /// Entry: r/GradSchool, academic Twitter, thesis forums
  /// Hook: "Your thesis is too big. Write one sentence."
  academic,
  
  /// Language Learner (Duolingo refugees)
  /// Entry: r/languagelearning, Duolingo subreddit
  /// Hook: "Lost your 200-day streak? Start fresh here."
  languageLearner,
  
  /// Indie Maker / Solo Founder
  /// Entry: IndieHackers, r/SideProject
  /// Hook: "Ship daily, not perfectly."
  indieMaker,
}

/// Configuration for each niche
class NicheConfig {
  final UserNiche niche;
  final String displayName;
  final String tagline;
  final String landingSlug; // e.g., /devs, /writers
  final List<String> identityExamples;
  final List<String> habitExamples;
  final List<String> tinyVersionExamples;
  final String streakAntidote; // Message for streak refugees
  final String hookMessage;
  final List<String> detectionKeywords;
  final String emoji;
  
  const NicheConfig({
    required this.niche,
    required this.displayName,
    required this.tagline,
    required this.landingSlug,
    required this.identityExamples,
    required this.habitExamples,
    required this.tinyVersionExamples,
    required this.streakAntidote,
    required this.hookMessage,
    required this.detectionKeywords,
    required this.emoji,
  });
}

/// All niche configurations
class NicheConfigs {
  static const Map<UserNiche, NicheConfig> configs = {
    UserNiche.general: NicheConfig(
      niche: UserNiche.general,
      displayName: 'Habit Builder',
      tagline: 'Graceful Consistency > Fragile Streaks',
      landingSlug: '/',
      emoji: '🎯',
      identityExamples: [
        'I am someone who shows up every day',
        'I am someone who takes care of myself',
        'I am someone who does the important things',
      ],
      habitExamples: [
        'Morning routine',
        'Exercise',
        'Reading',
        'Meditation',
      ],
      tinyVersionExamples: [
        'Put on my workout clothes',
        'Read one page',
        'Take 2 deep breaths',
      ],
      streakAntidote: 'You don\'t need a perfect streak. You need to never miss twice.',
      hookMessage: 'Build habits that stick, without the anxiety of losing your streak.',
      detectionKeywords: [],
    ),
    
    UserNiche.developer: NicheConfig(
      niche: UserNiche.developer,
      displayName: 'The Builder',
      tagline: 'Ship Consistently, Not Perfectly',
      landingSlug: '/devs',
      emoji: '💻',
      identityExamples: [
        'I am a developer who ships',
        'I am someone who codes every day',
        'I am a builder who makes progress',
        'I am an engineer who writes clean code',
      ],
      habitExamples: [
        'Code on my side project',
        'Commit to open source',
        'Learn a new technology',
        'Write documentation',
        'Review my own code',
        'Refactor one function',
      ],
      tinyVersionExamples: [
        'Open VS Code and write one line',
        'Make one commit (even a typo fix)',
        'Read one paragraph of docs',
        'Write one unit test',
        'Delete one piece of dead code',
      ],
      streakAntidote: 'GitHub green squares are vanity metrics. Shipping is the real score.',
      hookMessage: 'Stop worshipping the Green Squares. Start shipping consistently.',
      detectionKeywords: [
        'code', 'coding', 'programming', 'developer', 'dev', 'engineer',
        'software', 'commit', 'github', 'git', 'ship', 'deploy', 'build',
        'app', 'project', 'side project', 'open source', 'contribute',
        'leetcode', 'algorithms', 'debug', 'refactor', 'pull request', 'pr',
      ],
    ),
    
    UserNiche.writer: NicheConfig(
      niche: UserNiche.writer,
      displayName: 'The Creator',
      tagline: 'Create Without Burnout',
      landingSlug: '/writers',
      emoji: '✍️',
      identityExamples: [
        'I am a writer',
        'I am a content creator',
        'I am someone who shares ideas',
        'I am a storyteller',
      ],
      habitExamples: [
        'Write my daily words',
        'Work on my novel',
        'Create content',
        'Journal my thoughts',
        'Draft a blog post',
        'Edit my manuscript',
      ],
      tinyVersionExamples: [
        'Write one sentence',
        'Open my draft and read the last paragraph',
        'Write for 2 minutes (not word count)',
        'Outline one section',
        'Edit one paragraph',
      ],
      streakAntidote: 'The algorithm rewards consistency, not perfection. You can miss a day and still win.',
      hookMessage: 'The Algorithm wants perfection. You are human. Stay in the game without burning out.',
      detectionKeywords: [
        'write', 'writing', 'writer', 'words', 'word count', 'novel',
        'blog', 'content', 'creator', 'youtube', 'youtuber', 'newsletter',
        'substack', 'medium', 'publish', 'draft', 'manuscript', 'story',
        'author', 'creative', 'journalism', 'copywriting', 'script',
      ],
    ),
    
    UserNiche.academic: NicheConfig(
      niche: UserNiche.academic,
      displayName: 'The Scholar',
      tagline: 'Small Steps to Big Ideas',
      landingSlug: '/scholars',
      emoji: '📚',
      identityExamples: [
        'I am a scholar',
        'I am a researcher who makes progress',
        'I am someone who finishes what they start',
        'I am a disciplined academic',
      ],
      habitExamples: [
        'Work on my thesis',
        'Write my dissertation',
        'Read research papers',
        'Analyze my data',
        'Review literature',
        'Write methodology section',
      ],
      tinyVersionExamples: [
        'Write one sentence of my thesis',
        'Read one abstract',
        'Open my document and re-read last paragraph',
        'Add one citation',
        'Organize one folder of references',
      ],
      streakAntidote: 'Your thesis won\'t be written in one sitting. One sentence today is progress.',
      hookMessage: 'Your thesis is too big. The 2-Minute Rule makes it small. Write one sentence today.',
      detectionKeywords: [
        'thesis', 'dissertation', 'phd', 'grad school', 'graduate',
        'research', 'paper', 'academic', 'professor', 'study', 'studying',
        'university', 'college', 'masters', 'doctorate', 'publish',
        'literature review', 'methodology', 'data analysis', 'defense',
      ],
    ),
    
    UserNiche.languageLearner: NicheConfig(
      niche: UserNiche.languageLearner,
      displayName: 'The Polyglot',
      tagline: 'Learn Languages Without Streak Anxiety',
      landingSlug: '/languages',
      emoji: '🌍',
      identityExamples: [
        'I am a language learner',
        'I am someone who speaks multiple languages',
        'I am a polyglot in training',
        'I am someone who connects with other cultures',
      ],
      habitExamples: [
        'Practice my target language',
        'Learn vocabulary',
        'Listen to native content',
        'Speak with natives',
        'Study grammar',
      ],
      tinyVersionExamples: [
        'Review 5 flashcards',
        'Read one sentence out loud',
        'Listen to 1 minute of native audio',
        'Write one sentence in target language',
        'Look up one new word',
      ],
      streakAntidote: 'Lost your Duolingo streak? Your language progress isn\'t lost. Start fresh here.',
      hookMessage: 'The owl doesn\'t own you. Learn languages without the streak guilt.',
      detectionKeywords: [
        'language', 'duolingo', 'spanish', 'french', 'german', 'japanese',
        'chinese', 'mandarin', 'korean', 'learn', 'study', 'vocabulary',
        'flashcards', 'anki', 'immersion', 'native', 'fluent', 'polyglot',
        'streak', 'lost my streak', 'owl', 'lingodeer', 'babbel',
      ],
    ),
    
    UserNiche.indieMaker: NicheConfig(
      niche: UserNiche.indieMaker,
      displayName: 'The Indie Maker',
      tagline: 'Build in Public, Ship Daily',
      landingSlug: '/makers',
      emoji: '🚀',
      identityExamples: [
        'I am a maker who ships',
        'I am a solo founder',
        'I am someone who builds products',
        'I am an indie hacker',
      ],
      habitExamples: [
        'Work on my product',
        'Talk to customers',
        'Ship a feature',
        'Write a changelog',
        'Market my product',
        'Engage on social media',
      ],
      tinyVersionExamples: [
        'Open my project and review yesterday\'s progress',
        'Write one tweet about my product',
        'Send one DM to a potential customer',
        'Fix one small bug',
        'Add one line to changelog',
      ],
      streakAntidote: 'Building in public isn\'t about daily posts. It\'s about consistent progress.',
      hookMessage: 'Ship daily, not perfectly. Progress over perfection.',
      detectionKeywords: [
        'indie', 'maker', 'product', 'startup', 'founder', 'saas',
        'launch', 'ship', 'build in public', 'side project', 'solo',
        'bootstrap', 'revenue', 'mrr', 'customers', 'users', 'growth',
        'indiehackers', 'producthunt', 'twitter', 'launch day',
      ],
    ),
  };
  
  /// Get config for a niche
  static NicheConfig getConfig(UserNiche niche) {
    return configs[niche] ?? configs[UserNiche.general]!;
  }
  
  /// Get all landing slugs for deep link routing
  static Map<String, UserNiche> get landingSlugs {
    return {
      for (final entry in configs.entries)
        entry.value.landingSlug: entry.key,
    };
  }
}

/// Service for detecting user niche from input
class NicheDetectionService {
  /// Detect niche from user's identity statement or habit description
  static NicheDetectionResult detectNiche(String input) {
    final lowerInput = input.toLowerCase();
    final scores = <UserNiche, int>{};
    
    for (final entry in NicheConfigs.configs.entries) {
      if (entry.key == UserNiche.general) continue;
      
      int score = 0;
      for (final keyword in entry.value.detectionKeywords) {
        if (lowerInput.contains(keyword)) {
          // Longer keywords are more specific, score higher
          score += keyword.length > 5 ? 2 : 1;
        }
      }
      
      if (score > 0) {
        scores[entry.key] = score;
      }
    }
    
    if (scores.isEmpty) {
      return NicheDetectionResult(
        detected: UserNiche.general,
        confidence: 1.0,
        allScores: {UserNiche.general: 1},
      );
    }
    
    // Find highest scoring niche
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topNiche = sorted.first.key;
    final topScore = sorted.first.value;
    final totalScore = scores.values.fold(0, (a, b) => a + b);
    final confidence = topScore / totalScore;
    
    return NicheDetectionResult(
      detected: topNiche,
      confidence: confidence,
      allScores: scores,
    );
  }
  
  /// Detect niche from landing page URL
  static UserNiche detectFromUrl(String? path) {
    if (path == null || path.isEmpty) return UserNiche.general;
    
    final slugs = NicheConfigs.landingSlugs;
    for (final entry in slugs.entries) {
      if (path.startsWith(entry.key) || path == entry.key) {
        return entry.value;
      }
    }
    
    return UserNiche.general;
  }
  
  /// Detect if user mentions being a "streak refugee"
  static bool isStreakRefugee(String input) {
    final lowerInput = input.toLowerCase();
    const refugeePatterns = [
      'lost my streak',
      'broke my streak',
      'quit duolingo',
      'gave up on',
      'streaks are',
      'hate streaks',
      'streak anxiety',
      'burned out',
      'used to use',
      'stopped using',
    ];
    
    return refugeePatterns.any((pattern) => lowerInput.contains(pattern));
  }
}

/// Result of niche detection
class NicheDetectionResult {
  final UserNiche detected;
  final double confidence; // 0.0 to 1.0
  final Map<UserNiche, int> allScores;
  
  const NicheDetectionResult({
    required this.detected,
    required this.confidence,
    required this.allScores,
  });
  
  bool get isConfident => confidence >= 0.6;
  bool get hasSecondaryNiche => allScores.length > 1;
  
  UserNiche? get secondaryNiche {
    if (allScores.length < 2) return null;
    final sorted = allScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted[1].key;
  }
}

/// Niche-specific prompt adapter
class NichePromptAdapter {
  /// Get customized identity prompt for a niche
  static String getIdentityPrompt(UserNiche niche) {
    final config = NicheConfigs.getConfig(niche);
    final examples = config.identityExamples.take(3).join('\n  - ');
    
    return '''
Who do you want to become? Think about the identity, not the outcome.

Examples for ${config.displayName}s:
  - $examples

What identity resonates with you?
''';
  }
  
  /// Get customized habit prompt for a niche
  static String getHabitPrompt(UserNiche niche, String identity) {
    final config = NicheConfigs.getConfig(niche);
    final examples = config.habitExamples.take(3).join(', ');
    
    return '''
As "$identity", what's ONE daily action that proves this identity?

${config.displayName}s often choose: $examples

What habit will you commit to?
''';
  }
  
  /// Get customized tiny version prompt for a niche
  static String getTinyVersionPrompt(UserNiche niche, String habit) {
    final config = NicheConfigs.getConfig(niche);
    final examples = config.tinyVersionExamples.take(3).map((e) => '  - "$e"').join('\n');
    
    return '''
"$habit" is a great choice! Now let's make it tiny.

The 2-Minute Rule: What's the smallest version that takes 2 minutes or less?

Examples:
$examples

What's your 2-minute version?
''';
  }
  
  /// Get welcome message for a niche
  static String getWelcomeMessage(UserNiche niche, {bool isStreakRefugee = false}) {
    final config = NicheConfigs.getConfig(niche);
    
    if (isStreakRefugee) {
      return '''
${config.emoji} Welcome, fellow ${config.displayName.toLowerCase()}!

${config.streakAntidote}

This app uses "Graceful Consistency" — if you miss a day, you're not starting over. You just need to "Never Miss Twice."

Let's build a habit that actually sticks.
''';
    }
    
    return '''
${config.emoji} Welcome, ${config.displayName}!

${config.hookMessage}

I'm The Architect, and I'll help you build ONE tiny habit using the Atomic Habits methodology.

Let's start with who you want to become.
''';
  }
  
  /// Inject niche context into AI prompt
  static String injectNicheContext(String basePrompt, UserNiche niche) {
    if (niche == UserNiche.general) return basePrompt;
    
    final config = NicheConfigs.getConfig(niche);
    
    final nicheContext = '''
[USER NICHE: ${config.displayName.toUpperCase()}]
Landing: ${config.landingSlug}
Tagline: "${config.tagline}"
Hook: "${config.hookMessage}"

When giving examples, use ${config.displayName.toLowerCase()}-specific language:
- Identity examples: ${config.identityExamples.take(2).join(', ')}
- Habit examples: ${config.habitExamples.take(3).join(', ')}
- Tiny version examples: ${config.tinyVersionExamples.take(2).join(', ')}

''';
    
    // Inject after <SYSTEM> tag
    return basePrompt.replaceFirst(
      '<SYSTEM>\n',
      '<SYSTEM>\n$nicheContext',
    );
  }
}
