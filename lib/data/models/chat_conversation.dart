import 'dart:convert';
import 'package:hive/hive.dart';
import 'chat_message.dart';

/// Type of conversation context
enum ConversationType {
  onboarding,
  coaching,
  checkIn,
  troubleshooting;

  String toJson() => name;

  static ConversationType fromJson(String json) {
    return ConversationType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ConversationType.coaching,
    );
  }
}

/// A complete conversation with message history
class ChatConversation {
  final String id;
  final ConversationType type;
  final DateTime createdAt;
  DateTime lastUpdatedAt;
  final List<ChatMessage> messages;

  /// Related habit ID if this conversation is about a specific habit
  String? habitId;

  /// Summary of the conversation (for long-term storage)
  String? summary;

  /// Whether the conversation resulted in a habit being created
  bool habitCreated;

  /// Extracted data from onboarding conversations
  OnboardingData? onboardingData;
  
  /// System prompt for AI context
  String? systemPrompt;

  ChatConversation({
    required this.id,
    required this.type,
    required this.createdAt,
    DateTime? lastUpdatedAt,
    List<ChatMessage>? messages,
    this.habitId,
    this.summary,
    this.habitCreated = false,
    this.onboardingData,
    this.systemPrompt,
  }) : messages = messages ?? [],
       lastUpdatedAt = lastUpdatedAt ?? createdAt;

  /// Create a new onboarding conversation
  factory ChatConversation.onboarding() {
    return ChatConversation(
      id: 'onboarding_${DateTime.now().millisecondsSinceEpoch}',
      type: ConversationType.onboarding,
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
      onboardingData: OnboardingData(),
    );
  }

  /// Create a new coaching conversation
  factory ChatConversation.coaching({String? habitId}) {
    return ChatConversation(
      id: 'coaching_${DateTime.now().millisecondsSinceEpoch}',
      type: ConversationType.coaching,
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
      habitId: habitId,
    );
  }

  /// Create a new check-in conversation
  factory ChatConversation.checkIn({String? habitId}) {
    return ChatConversation(
      id: 'checkin_${DateTime.now().millisecondsSinceEpoch}',
      type: ConversationType.checkIn,
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
      habitId: habitId,
    );
  }

  /// Create from JSON
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      type: ConversationType.fromJson(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      habitId: json['habitId'] as String?,
      summary: json['summary'] as String?,
      habitCreated: json['habitCreated'] as bool? ?? false,
      onboardingData: json['onboardingData'] != null
          ? OnboardingData.fromJson(json['onboardingData'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'habitId': habitId,
      'summary': summary,
      'habitCreated': habitCreated,
      'onboardingData': onboardingData?.toJson(),
    };
  }

  /// Add a message to the conversation
  void addMessage(ChatMessage message) {
    messages.add(message);
    lastUpdatedAt = DateTime.now();
  }

  /// Get the last message
  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Get messages for API context (excludes system messages, formats for Gemini)
  List<Map<String, String>> getMessagesForApi() {
    return messages
        .where((m) => m.role != MessageRole.system && m.status == MessageStatus.complete)
        .map((m) => {
              'role': m.role == MessageRole.user ? 'user' : 'model',
              'content': m.content,
            })
        .toList();
  }

  /// Get conversation age in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Check if conversation is recent (within 60 days - extended for habit formation)
  bool get isRecent => ageInDays <= 60;

  @override
  String toString() => 'ChatConversation($id, ${messages.length} messages)';
}

/// Data extracted during onboarding conversation
class OnboardingData {
  String? identity;
  String? habitName;
  String? tinyVersion;
  String? implementationTime;
  String? implementationLocation;
  String? temptationBundle;
  String? preRitual;
  String? motivation;

  OnboardingData({
    this.identity,
    this.habitName,
    this.tinyVersion,
    this.implementationTime,
    this.implementationLocation,
    this.temptationBundle,
    this.preRitual,
    this.motivation,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      identity: json['identity'] as String?,
      habitName: json['habitName'] as String?,
      tinyVersion: json['tinyVersion'] as String?,
      implementationTime: json['implementationTime'] as String?,
      implementationLocation: json['implementationLocation'] as String?,
      temptationBundle: json['temptationBundle'] as String?,
      preRitual: json['preRitual'] as String?,
      motivation: json['motivation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'habitName': habitName,
      'tinyVersion': tinyVersion,
      'implementationTime': implementationTime,
      'implementationLocation': implementationLocation,
      'temptationBundle': temptationBundle,
      'preRitual': preRitual,
      'motivation': motivation,
    };
  }

  /// Check if we have enough data to create a habit
  bool get isComplete =>
      identity != null &&
      identity!.isNotEmpty &&
      habitName != null &&
      habitName!.isNotEmpty &&
      implementationTime != null &&
      implementationTime!.isNotEmpty &&
      implementationLocation != null &&
      implementationLocation!.isNotEmpty;

  /// Get a summary of collected data
  String get summary {
    final parts = <String>[];
    if (identity != null) parts.add('Identity: $identity');
    if (habitName != null) parts.add('Habit: $habitName');
    if (tinyVersion != null) parts.add('2-min version: $tinyVersion');
    if (implementationTime != null && implementationLocation != null) {
      parts.add('When/Where: $implementationTime at $implementationLocation');
    }
    return parts.join('\n');
  }
}

/// Service for persisting conversations to Hive
class ConversationStorage {
  static const String _boxName = 'conversations';
  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Save a conversation
  Future<void> save(ChatConversation conversation) async {
    if (_box == null) await init();
    await _box!.put(conversation.id, jsonEncode(conversation.toJson()));
  }

  /// Load a conversation by ID
  Future<ChatConversation?> load(String id) async {
    if (_box == null) await init();
    final json = _box!.get(id);
    if (json == null) return null;
    return ChatConversation.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Load all conversations
  Future<List<ChatConversation>> loadAll() async {
    if (_box == null) await init();
    final conversations = <ChatConversation>[];
    for (final json in _box!.values) {
      try {
        conversations.add(
          ChatConversation.fromJson(jsonDecode(json) as Map<String, dynamic>),
        );
      } catch (e) {
        // Skip corrupted entries
      }
    }
    // Sort by most recent first
    conversations.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    return conversations;
  }

  /// Load recent conversations (within 60 days)
  Future<List<ChatConversation>> loadRecent() async {
    final all = await loadAll();
    return all.where((c) => c.isRecent).toList();
  }

  /// Load conversations by type
  Future<List<ChatConversation>> loadByType(ConversationType type) async {
    final all = await loadAll();
    return all.where((c) => c.type == type).toList();
  }

  /// Delete a conversation
  Future<void> delete(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  /// Delete old conversations (older than 60 days)
  Future<int> cleanupOld() async {
    final all = await loadAll();
    int deleted = 0;
    for (final conversation in all) {
      if (!conversation.isRecent) {
        await delete(conversation.id);
        deleted++;
      }
    }
    return deleted;
  }
}
