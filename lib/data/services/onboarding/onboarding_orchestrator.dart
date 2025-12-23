import 'dart:async';
import 'package:flutter/foundation.dart';
import '../ai/ai_service_manager.dart';
import '../deep_link_service.dart';
import '../../models/onboarding_data.dart';
import '../../models/chat_conversation.dart' hide OnboardingData;
import '../../models/chat_message.dart';
import '../../../config/ai_model_config.dart';
import '../../../config/niche_config.dart';
import 'ai_response_parser.dart';
import 'conversation_guardrails.dart';

/// Result of a conversational message exchange
class ConversationResult {
  final ChatMessage? response;
  final OnboardingData? extractedData;
  final String? displayText;
  final String? error;
  final bool shouldFallbackToManual;

  ConversationResult({
    this.response,
    this.extractedData,
    this.displayText,
    this.error,
    this.shouldFallbackToManual = false,
  });

  factory ConversationResult.success({
    required ChatMessage response,
    OnboardingData? extractedData,
    String? displayText,
  }) {
    return ConversationResult(
      response: response,
      extractedData: extractedData,
      displayText: displayText,
    );
  }

  factory ConversationResult.error(String message) {
    return ConversationResult(error: message);
  }

  factory ConversationResult.fallback() {
    return ConversationResult(shouldFallbackToManual: true);
  }
}

/// Orchestrates the AI onboarding flow
/// 
/// The "Brain" of both Phase 1 (Magic Wand) and Phase 2 (Conversational UI).
/// Connects UI to AI services, handles tier selection, and manages fallbacks.
/// 
/// Phase 24: "Side Door" Routing
/// If a pending invite is detected (from deep link or clipboard), this service
/// signals to skip standard onboarding and route directly to WitnessAcceptScreen.
class OnboardingOrchestrator extends ChangeNotifier {
  final AIServiceManager _aiServiceManager;
  
  /// Deep link service reference for Side Door routing (Phase 24)
  DeepLinkService? _deepLinkService;
  
  /// Current conversation state
  ChatConversation? _conversation;
  
  /// Number of messages sent in current conversation
  int _messageCount = 0;
  
  /// Last request timestamp for rate limiting
  DateTime? _lastRequestTime;
  
  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  /// Error state
  String? _error;
  String? get error => _error;
  
  /// Extracted habit data (Phase 2)
  OnboardingData? _extractedData;
  OnboardingData? get extractedData => _extractedData;
  
  /// Detected user niche (Phase 19: Side Door Strategy)
  UserNiche _userNiche = UserNiche.general;
  UserNiche get userNiche => _userNiche;
  
  /// Whether user is a "streak refugee" (burned by Duolingo, etc.)
  bool _isStreakRefugee = false;
  bool get isStreakRefugee => _isStreakRefugee;
  
  /// Entry source for attribution
  String? _entrySource;
  String? get entrySource => _entrySource;
  
  /// Phase 24: Pending invite code (from deep link, install referrer, or clipboard)
  String? _pendingInviteCode;
  String? get pendingInviteCode => _pendingInviteCode;
  
  /// Phase 24: Whether there's a pending invite requiring Side Door routing
  bool get hasPendingInvite => _pendingInviteCode != null && _pendingInviteCode!.isNotEmpty;
  
  /// Phase 24: Whether the invite came from clipboard (vs direct deep link)
  bool _inviteFromClipboard = false;
  bool get inviteFromClipboard => _inviteFromClipboard;
  
  /// Phase 24.B: Whether the invite came from Install Referrer API
  bool _inviteFromInstallReferrer = false;
  bool get inviteFromInstallReferrer => _inviteFromInstallReferrer;
  
  /// Phase 24.B: Source of the invite (for analytics)
  String? _inviteSource;
  String? get inviteSource => _inviteSource;
  
  /// Phase 24.B: Whether deferred deep link check is in progress
  bool _isCheckingDeferredLink = false;
  bool get isCheckingDeferredLink => _isCheckingDeferredLink;
  
  /// Phase 27.5: Premium user flag (set from AppSettings.developerMode)
  bool _isPremiumUser = false;
  bool get isPremiumUser => _isPremiumUser;
  
  /// Phase 27.5: Set premium user flag (called from UI with AppSettings)
  void setPremiumUser(bool value) {
    _isPremiumUser = value;
    notifyListeners();
  }
  
  /// Current conversation accessor
  ChatConversation? get conversation => _conversation;
  
  /// Loading state callback (legacy - kept for backward compatibility)
  final void Function(bool isLoading)? onLoadingChanged;
  
  /// Error callback (legacy - kept for backward compatibility)
  final void Function(String error)? onError;

  OnboardingOrchestrator({
    required AIServiceManager aiServiceManager,
    DeepLinkService? deepLinkService,
    this.onLoadingChanged,
    this.onError,
  }) : _aiServiceManager = aiServiceManager,
       _deepLinkService = deepLinkService;

  /// Check if AI services are available
  bool get isAiAvailable => AIModelConfig.hasAnyAI;

  /// Get current tier based on configuration
  AiTier getCurrentTier({bool isBreakHabit = false, bool isPremiumUser = false}) {
    return AIModelConfig.selectTier(
      isPremiumUser: isPremiumUser,
      isBreakHabit: isBreakHabit,
    );
  }

  /// Magic Wand: One-shot completion for Phase 1
  /// 
  /// Takes user's habit name and identity, asks AI to fill in the rest.
  /// Returns [OnboardingData] with suggested values for:
  /// - tinyVersion (2-minute rule)
  /// - implementationTime
  /// - implementationLocation
  /// - environmentCue
  /// - temptationBundle (optional)
  /// - preHabitRitual (optional)
  Future<OnboardingData?> magicWandComplete({
    required String habitName,
    required String identity,
    bool isBreakHabit = false,
  }) async {
    // Check rate limiting
    if (!_checkRateLimit()) {
      onError?.call('Please wait a moment before trying again.');
      return null;
    }

    // Check AI availability
    if (!isAiAvailable) {
      onError?.call('AI service is not configured. Please enter details manually.');
      return null;
    }

    onLoadingChanged?.call(true);

    try {
      // Build the prompt for structured data extraction
      final prompt = _buildMagicWandPrompt(
        habitName: habitName,
        identity: identity,
        isBreakHabit: isBreakHabit,
      );

      // Phase 24: Start conversation with AIServiceManager
      _conversation = await _aiServiceManager.startConversation(
        isPremiumUser: _isPremiumUser, // Phase 27.5: Now uses developerMode from settings
        isBreakHabit: isBreakHabit,
        type: ConversationType.onboarding,
      );

      // Send the message with timeout
      final response = await _sendWithTimeout(prompt);
      
      if (response == null || response.status == MessageStatus.error) {
        onError?.call('Failed to get AI suggestions. Please try again or enter details manually.');
        return null;
      }

      // Parse the structured response
      final data = AiResponseParser.extractHabitData(response.content);
      
      if (data != null) {
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Magic Wand extracted data: $data');
        }
        return data;
      }
      
      // Try fallback parsing
      final fallbackData = AiResponseParser.extractWithFallback(response.content);
      if (fallbackData != null) {
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Magic Wand used fallback parsing: $fallbackData');
        }
        return fallbackData;
      }

      // No structured data found - return conversational text as error
      final conversationalText = AiResponseParser.extractConversationalText(response.content);
      onError?.call('AI provided suggestions but couldn\'t extract structured data. Please enter details manually.');
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: AI response without structured data: $conversationalText');
      }
      return null;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Magic Wand error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      onError?.call('An error occurred. Please try again or enter details manually.');
      return null;
    } finally {
      onLoadingChanged?.call(false);
    }
  }

  /// Check if we should use manual fallback based on user frustration
  bool shouldFallbackToManual(String userMessage) {
    return ConversationGuardrails.isFrustrated(userMessage);
  }

  /// Validate user message before sending
  MessageValidation validateMessage(String message) {
    return ConversationGuardrails.validateMessage(message);
  }

  /// Build the Magic Wand prompt for structured data extraction
  /// Phase 17: Enhanced with THINKING PROTOCOL and NEGATIVE CONSTRAINTS
  String _buildMagicWandPrompt({
    required String habitName,
    required String identity,
    required bool isBreakHabit,
  }) {
    final habitTypeDescription = isBreakHabit 
        ? 'breaking a bad habit' 
        : 'building a positive habit';

    // Phase 17: Check if the habit name violates guardrails
    final guardrailResult = ConversationGuardrails.validateHabit(habitName);
    final guardrailWarning = guardrailResult.needsCorrection
        ? '''
[WARNING: HABIT NEEDS ADJUSTMENT]
The user's habit "$habitName" violates the 2-minute rule or is too vague.
You MUST create a smaller/more specific tinyVersion. Do not accept habits that
take more than 2 minutes.

'''
        : '';

    return '''
You are The Architect, an expert habit coach using James Clear's Atomic Habits methodology.

$guardrailWarning[THINKING PROTOCOL]
Before generating the plan, think through:
1. "Is '$habitName' specific enough? If not, make tinyVersion MORE specific."
2. "Can the tinyVersion be done in 2 minutes? If not, make it SMALLER."
3. "Does '$identity' describe WHO they want to become? If vague, strengthen it."
4. "What time/location makes this habit OBVIOUS and EASY?"

[NEGATIVE CONSTRAINTS - ENFORCE THESE]
- tinyVersion MUST be completable in 2 minutes or less
- DO NOT suggest "30 minutes", "a chapter", "full workout", etc.
- Make it RIDICULOUSLY small: "one page", "one pushup", "2 deep breaths"

The user wants help $habitTypeDescription. They provided:
- **Habit**: $habitName
- **Identity**: $identity
${isBreakHabit ? '- **Type**: Breaking a bad habit (needs substitution plan)' : '- **Type**: Building a positive habit'}

Generate a complete habit plan with:
1. **tinyVersion**: MUST be doable in 2 minutes (negotiate DOWN from user's habit if needed)
2. **implementationTime**: Specific time (format: "HH:MM" or trigger like "After breakfast")
3. **implementationLocation**: Specific place
4. **environmentCue**: Visual trigger in their environment
5. **temptationBundle**: Optional pairing with something enjoyable
6. **preHabitRitual**: Optional 30-second mindset ritual
${isBreakHabit ? '''
7. **replacesHabit**: The bad habit being replaced
8. **rootCause**: Why they do the bad habit
9. **substitutionPlan**: Healthy alternative''' : ''}

[RESPONSE FORMAT]
Brief encouragement (2-3 sentences) + JSON block:

[HABIT_DATA]
{
  "name": "$habitName",
  "identity": "$identity",
  "isBreakHabit": $isBreakHabit,
  "habitEmoji": "relevant emoji",
  "tinyVersion": "2-MINUTE VERSION (smaller than user might expect!)",
  "implementationTime": "07:30",
  "implementationLocation": "At your desk",
  "environmentCue": "Place X on your Y",
  "temptationBundle": "While enjoying Z",
  "preHabitRitual": "Take 3 deep breaths"${isBreakHabit ? ''',
  "replacesHabit": "The bad habit being replaced",
  "rootCause": "The underlying trigger",
  "substitutionPlan": "What to do instead"''' : ''},
  "isComplete": true
}
[/HABIT_DATA]

CRITICAL: The tinyVersion must be so small it feels almost silly. That's the point.
''';
  }

  /// Send message with timeout and retry logic
  /// Phase 24: Now uses AIServiceManager instead of direct GeminiChatService
  Future<ChatMessage?> _sendWithTimeout(String message) async {
    try {
      final response = await _aiServiceManager
          .sendMessage(
            userMessage: message,
          )
          .timeout(
            AIModelConfig.apiTimeout,
            onTimeout: () {
              throw TimeoutException('AI request timed out');
            },
          );

      _messageCount++;
      _lastRequestTime = DateTime.now();

      return response;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Request timed out, attempting retry...');
      }
      
      // One retry as per AIModelConfig.maxRetries
      try {
        final retryResponse = await _aiServiceManager
            .sendMessage(
              userMessage: message,
            )
            .timeout(AIModelConfig.apiTimeout);
        
        _messageCount++;
        _lastRequestTime = DateTime.now();
        
        return retryResponse;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Retry also failed: $e');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Send error: $e');
      }
      return null;
    }
  }

  /// Check rate limiting
  bool _checkRateLimit() {
    if (_lastRequestTime == null) return true;
    
    final elapsed = DateTime.now().difference(_lastRequestTime!);
    return elapsed.inSeconds >= AIModelConfig.minSecondsBetweenRequests;
  }

  /// Check if conversation is at turn limit
  bool isAtTurnLimit() {
    return _messageCount >= AIModelConfig.maxConversationTurns;
  }

  /// Reset conversation state
  void resetConversation() {
    _conversation = null;
    _messageCount = 0;
    _extractedData = null;
    _error = null;
    _isLoading = false;
    _userNiche = UserNiche.general;
    _isStreakRefugee = false;
    _entrySource = null;
    // Note: Don't reset pending invite - it's handled separately
    notifyListeners();
  }
  
  // ============================================================
  // PHASE 24: "Side Door" Routing
  // PHASE 24.B: "The Standard Protocol" - Install Referrer Integration
  // ============================================================
  
  /// Set the deep link service reference
  void setDeepLinkService(DeepLinkService service) {
    _deepLinkService = service;
    
    // Check for pending invite immediately
    _checkForPendingInvite();
  }
  
  /// Check for pending invite from deep link, install referrer, or clipboard
  /// 
  /// Phase 24: This is the entry point for "Side Door" routing.
  /// Phase 24.B: Now includes Install Referrer API for zero-friction viral loop.
  /// 
  /// Priority order:
  /// 1. Direct deep link (app opened via link)
  /// 2. Install Referrer (Play Store passed invite_code)
  /// 3. Clipboard Bridge (user copied link before install)
  /// 
  /// If an invite is pending, the UI should skip standard onboarding
  /// and route directly to WitnessAcceptScreen.
  Future<String?> checkForPendingInvite() async {
    return _checkForPendingInvite();
  }
  
  /// Check for deferred deep links with loading state
  /// 
  /// Phase 24.B: This method handles the race condition where the
  /// onboarding screen might render before the deferred link check completes.
  /// 
  /// Use this in initState() of onboarding screens to:
  /// 1. Show a brief "Checking invites..." state (~500ms)
  /// 2. Wait for DeepLinkService to complete its checks
  /// 3. Then decide whether to show onboarding or Side Door
  Future<String?> checkForDeferredDeepLink() async {
    _isCheckingDeferredLink = true;
    notifyListeners();
    
    try {
      // Wait for DeepLinkService to complete its initialization
      // This includes Install Referrer and Clipboard checks
      if (_deepLinkService != null && _deepLinkService!.isCheckingDeferredLink) {
        // Wait up to 2 seconds for the check to complete
        int waitMs = 0;
        while (_deepLinkService!.isCheckingDeferredLink && waitMs < 2000) {
          await Future.delayed(const Duration(milliseconds: 100));
          waitMs += 100;
        }
      }
      
      // Now check for pending invite
      return await _checkForPendingInvite();
    } finally {
      _isCheckingDeferredLink = false;
      notifyListeners();
    }
  }
  
  Future<String?> _checkForPendingInvite() async {
    // First check deep link service
    if (_deepLinkService != null) {
      if (_deepLinkService!.hasPendingInvite) {
        _pendingInviteCode = _deepLinkService!.pendingInviteCode;
        _inviteFromClipboard = _deepLinkService!.inviteFromClipboard;
        _inviteFromInstallReferrer = _deepLinkService!.inviteFromInstallReferrer;
        _inviteSource = _deepLinkService!.inviteSource;
        
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Found pending invite: $_pendingInviteCode');
          debugPrint('  Source: $_inviteSource');
          debugPrint('  From clipboard: $_inviteFromClipboard');
          debugPrint('  From install referrer: $_inviteFromInstallReferrer');
        }
        
        notifyListeners();
        return _pendingInviteCode;
      }
      
      // Try clipboard check as fallback
      final clipboardInvite = await _deepLinkService!.checkClipboardForInvite();
      if (clipboardInvite != null) {
        _pendingInviteCode = clipboardInvite;
        _inviteFromClipboard = true;
        _inviteSource = 'clipboard';
        
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Found invite in clipboard: $_pendingInviteCode');
        }
        
        notifyListeners();
        return _pendingInviteCode;
      }
    }
    
    return null;
  }
  
  /// Get the Side Door route (if applicable)
  /// 
  /// Returns the route path for Side Door navigation, or null if no invite pending.
  /// Use this to determine initial navigation in the app.
  String? getSideDoorRoute() {
    if (!hasPendingInvite) return null;
    
    // Route to witness accept screen with invite code
    return '/witness/accept/$_pendingInviteCode';
  }
  
  /// Clear the pending invite after handling
  /// 
  /// Call this after the user has either accepted or declined the invite.
  void clearPendingInvite() {
    _pendingInviteCode = null;
    _inviteFromClipboard = false;
    _inviteFromInstallReferrer = false;
    _inviteSource = null;
    
    // Also clear from deep link service
    _deepLinkService?.clearPendingDeepLink();
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('OnboardingOrchestrator: Cleared pending invite');
    }
  }
  
  /// Set a pending invite explicitly (for testing or manual handling)
  void setPendingInvite(String inviteCode, {bool fromClipboard = false, bool fromInstallReferrer = false, String? source}) {
    _pendingInviteCode = inviteCode;
    _inviteFromClipboard = fromClipboard;
    _inviteFromInstallReferrer = fromInstallReferrer;
    _inviteSource = source ?? (fromClipboard ? 'clipboard' : (fromInstallReferrer ? 'install_referrer' : 'direct_link'));
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('OnboardingOrchestrator: Set pending invite: $inviteCode (source: $_inviteSource)');
    }
  }
  
  /// Check if we should show the "Side Door" entry
  /// 
  /// Returns true if:
  /// 1. There's a pending invite code
  /// 2. The user hasn't already been through onboarding
  /// 
  /// This is used by the UI to decide whether to show standard onboarding
  /// or route directly to the witness acceptance flow.
  bool shouldUseSideDoor({bool isFirstLaunch = true}) {
    return hasPendingInvite && isFirstLaunch;
  }
  
  // ============================================================
  // PHASE 19: Niche Detection & Side Door Strategy
  // ============================================================
  
  /// Set niche from landing page URL (e.g., /devs, /writers)
  void setNicheFromUrl(String? path) {
    _userNiche = NicheDetectionService.detectFromUrl(path);
    _entrySource = path;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('OnboardingOrchestrator: Niche set from URL: $_userNiche (path: $path)');
    }
  }
  
  /// Set niche explicitly (for testing or manual override)
  void setNiche(UserNiche niche, {String? source}) {
    _userNiche = niche;
    _entrySource = source;
    notifyListeners();
  }
  
  /// Detect niche from user input (called during conversation)
  void detectNicheFromInput(String input) {
    // Check for streak refugee patterns
    if (NicheDetectionService.isStreakRefugee(input)) {
      _isStreakRefugee = true;
    }
    
    // Only detect if not already set from URL
    if (_userNiche == UserNiche.general) {
      final result = NicheDetectionService.detectNiche(input);
      if (result.isConfident) {
        _userNiche = result.detected;
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Niche detected from input: $_userNiche (confidence: ${result.confidence})');
        }
      }
    }
    
    notifyListeners();
  }
  
  /// Get niche-specific welcome message
  String getWelcomeMessage() {
    return NichePromptAdapter.getWelcomeMessage(
      _userNiche,
      isStreakRefugee: _isStreakRefugee,
    );
  }
  
  /// Get niche-specific identity prompt
  String getIdentityPrompt() {
    return NichePromptAdapter.getIdentityPrompt(_userNiche);
  }
  
  /// Get niche-specific habit prompt
  String getHabitPrompt(String identity) {
    return NichePromptAdapter.getHabitPrompt(_userNiche, identity);
  }
  
  /// Get niche-specific tiny version prompt
  String getTinyVersionPrompt(String habit) {
    return NichePromptAdapter.getTinyVersionPrompt(_userNiche, habit);
  }
  
  /// Get niche config for current user
  NicheConfig get nicheConfig => NicheConfigs.getConfig(_userNiche);

  /// Get conversation summary for debugging
  String get conversationSummary {
    if (_conversation == null) return 'No active conversation';
    return 'Conversation: ${_conversation!.id}, Messages: $_messageCount/${AIModelConfig.maxConversationTurns}';
  }

  // ============================================================
  // PHASE 2: Conversational Chat Methods
  // ============================================================

  /// Start a new onboarding conversation
  /// Phase 24: Now uses AIServiceManager with tier selection
  Future<ChatConversation?> startConversation({bool isBreakHabit = false}) async {
    _conversation = await _aiServiceManager.startConversation(
      isPremiumUser: _isPremiumUser, // Phase 27.5: Now uses developerMode from settings
      isBreakHabit: isBreakHabit,
      type: ConversationType.onboarding,
    );
    _messageCount = 0;
    _extractedData = null;
    _error = null;
    notifyListeners();
    return _conversation;
  }

  /// Send a conversational message and get a response
  /// 
  /// Phase 2: Handles the full chat flow with:
  /// - Frustration detection (escape hatch)
  /// - Rate limiting
  /// - Turn limit enforcement
  /// - Habit data extraction from AI responses
  Future<ConversationResult> sendConversationalMessage({
    required String userMessage,
    required String userName,
  }) async {
    // Check rate limiting
    if (!_checkRateLimit()) {
      return ConversationResult.error('Please wait a moment before trying again.');
    }

    // Check turn limit
    if (isAtTurnLimit()) {
      return ConversationResult.fallback();
    }

    // Check for frustration patterns
    if (shouldFallbackToManual(userMessage)) {
      return ConversationResult.fallback();
    }

    // Start conversation if needed
    if (_conversation == null) {
      await startConversation();
    }

    _isLoading = true;
    _error = null;
    onLoadingChanged?.call(true);
    notifyListeners();

    try {
      // Build the conversational prompt
      final prompt = _buildConversationalPrompt(
        userMessage: userMessage,
        userName: userName,
      );

      // Send message with timeout
      final response = await _sendWithTimeout(prompt);

      if (response == null || response.status == MessageStatus.error) {
        _error = 'Failed to get response. Please try again.';
        onError?.call(_error!);
        return ConversationResult.error(_error!);
      }

      // Extract any habit data from the response
      final extractedData = AiResponseParser.extractHabitData(response.content);
      if (extractedData != null) {
        // Inject niche data into extracted data
        _extractedData = extractedData.copyWith(
          userNiche: _userNiche,
          entrySource: _entrySource,
          isStreakRefugee: _isStreakRefugee,
        );
      }

      // Get display text (strip JSON markers for UI)
      final displayText = AiResponseParser.extractConversationalText(response.content);

      return ConversationResult.success(
        response: response,
        extractedData: extractedData,
        displayText: displayText,
      );

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Conversation error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      _error = 'An error occurred. Please try again.';
      onError?.call(_error!);
      return ConversationResult.error(_error!);
    } finally {
      _isLoading = false;
      onLoadingChanged?.call(false);
      notifyListeners();
    }
  }

  /// Build the conversational prompt for ongoing chat
  /// Phase 17: Enhanced with guardrail injection
  /// Phase 19: Enhanced with niche context injection
  String _buildConversationalPrompt({
    required String userMessage,
    required String userName,
  }) {
    // Phase 19: Detect niche from user input if not already set
    detectNicheFromInput(userMessage);
    
    // Build context from collected data
    final collectedInfo = <String>[];
    if (_extractedData != null) {
      if (_extractedData!.identity != null) {
        collectedInfo.add('- Identity: ${_extractedData!.identity}');
      }
      if (_extractedData!.name != null) {
        collectedInfo.add('- Habit name: ${_extractedData!.name}');
      }
      if (_extractedData!.tinyVersion != null) {
        collectedInfo.add('- 2-minute version: ${_extractedData!.tinyVersion}');
      }
      if (_extractedData!.implementationTime != null) {
        collectedInfo.add('- Time: ${_extractedData!.implementationTime}');
      }
      if (_extractedData!.implementationLocation != null) {
        collectedInfo.add('- Location: ${_extractedData!.implementationLocation}');
      }
    }

    final contextSection = collectedInfo.isNotEmpty
        ? '''
[PROGRESS SO FAR]
${collectedInfo.join('\n')}

'''
        : '';

    // Phase 17: Check for guardrail violations and inject guidance
    final guardrailResult = ConversationGuardrails.validateHabit(userMessage);
    final guardrailSection = guardrailResult.needsCorrection
        ? '''
[GUARDRAIL VIOLATION DETECTED]
Issue: ${guardrailResult.type.name}
Your response MUST address this: ${guardrailResult.guidance}
Do NOT accept the habit as-is. Guide the user to fix the issue.

'''
        : '';
    
    // Phase 19: Build niche context section
    final nicheSection = _buildNicheContextSection();
    
    // Phase 19: Build streak refugee context if applicable
    final refugeeSection = _isStreakRefugee
        ? '''
[STREAK REFUGEE DETECTED]
This user has mentioned frustration with streak-based apps.
Emphasize "Graceful Consistency" and "Never Miss Twice" philosophy.
Reassure them that missing a day doesn't reset progress.
Use the antidote: "${nicheConfig.streakAntidote}"

'''
        : '';

    return '''
You are The Architect, an expert Atomic Habits coach helping $userName create their first habit.

$nicheSection$refugeeSection$guardrailSection$contextSection[USER MESSAGE]
$userName says: "$userMessage"

$guardrailSection$contextSection[USER MESSAGE]
$userName says: "$userMessage"

[THINKING PROTOCOL]
Before responding, consider:
1. Is this habit specific enough to act on?
2. Could this be done in 2 minutes or less?
3. Does it connect to an identity?
4. What might cause it to fail?

[NEGATIVE CONSTRAINTS]
REJECT habits that are:
- Over 2 minutes (negotiate down)
- Vague ("exercise more" -> ask for specific action)
- Outcome goals ("lose weight" -> ask for daily action)
- Multiple habits (focus on ONE)

[INSTRUCTIONS]
1. If guardrail violation detected, address it first
2. Respond naturally as a coach - be warm but concise (2-3 sentences)
3. Ask ONE question at a time
4. Use: Identity -> Habit -> 2-Minute Rule -> Implementation flow
5. Use niche-specific examples and language when available

[HABIT_DATA FORMAT]
When you have ALL: [identity, name, tinyVersion, time, location], output:
[HABIT_DATA]
{
  "identity": "I am someone who...",
  "name": "The habit name",
  "tinyVersion": "2-minute version (MANDATORY - must be doable in 2 min)",
  "implementationTime": "HH:MM or descriptive",
  "implementationLocation": "Where",
  "environmentCue": "Optional cue",
  "temptationBundle": "Optional bundle",
  "preHabitRitual": "Optional ritual",
  "isComplete": true
}
[/HABIT_DATA]

Only include [HABIT_DATA] when ALL required fields are complete AND the habit passes all guardrails.
''';
  }

  /// Set loading state with notification
  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(loading);
    notifyListeners();
  }
  
  /// Build niche context section for AI prompts
  /// Phase 19: Niche-based Side Door Strategy
  String _buildNicheContextSection() {
    if (_userNiche == UserNiche.general) return '';
    
    final config = nicheConfig;
    final identityExamples = config.identityExamples.take(2).join(', ');
    final habitExamples = config.habitExamples.take(3).join(', ');
    final tinyExamples = config.tinyVersionExamples.take(2).join(', ');
    
    return '''
[USER NICHE: ${config.displayName.toUpperCase()}]
${config.emoji} This user identifies as a ${config.displayName.toLowerCase()}.
Tagline: "${config.tagline}"

When providing examples, use ${config.displayName.toLowerCase()}-specific language:
- Identity examples: $identityExamples
- Habit examples: $habitExamples
- Tiny version examples: $tinyExamples

Hook message: "${config.hookMessage}"

''';
  }
}
