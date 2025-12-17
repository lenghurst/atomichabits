/// Represents who sent the message
enum MessageRole {
  user,
  assistant,
  system;

  String toJson() => name;

  static MessageRole fromJson(String json) {
    return MessageRole.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MessageRole.user,
    );
  }
}

/// Represents the current state of a message
enum MessageStatus {
  sending,
  sent,
  streaming,
  complete,
  error;

  String toJson() => name;

  static MessageStatus fromJson(String json) {
    return MessageStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MessageStatus.complete,
    );
  }
}

/// A single chat message in a conversation
class ChatMessage {
  final String id;
  final MessageRole role;
  String content;
  final DateTime timestamp;
  MessageStatus status;
  final bool isVoiceInput;
  String? errorMessage;

  ChatMessage({
    required this.id,
    MessageRole? role,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.complete,
    this.isVoiceInput = false,
    this.errorMessage,
    bool? isUser,
  }) : role = role ?? (isUser == true ? MessageRole.user : MessageRole.assistant);

  /// Create a new user message
  factory ChatMessage.user({
    required String content,
    bool isVoiceInput = false,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.complete,
      isVoiceInput: isVoiceInput,
    );
  }

  /// Create a new assistant message (starts as streaming)
  factory ChatMessage.assistant({
    String content = '',
    MessageStatus status = MessageStatus.streaming,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      status: status,
    );
  }

  /// Create a system message (for context/instructions)
  factory ChatMessage.system({
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.system,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.complete,
    );
  }

  /// Create from JSON map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.fromJson(json['status'] as String),
      isVoiceInput: json['isVoiceInput'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toJson(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toJson(),
      'isVoiceInput': isVoiceInput,
      'errorMessage': errorMessage,
    };
  }

  /// Append content during streaming
  void appendContent(String chunk) {
    content += chunk;
  }

  /// Mark as complete
  void markComplete() {
    status = MessageStatus.complete;
  }

  /// Mark as error
  void markError(String message) {
    status = MessageStatus.error;
    errorMessage = message;
  }

  /// Check if message is from user
  bool get isUser => role == MessageRole.user;

  /// Check if message is from assistant
  bool get isAssistant => role == MessageRole.assistant;

  /// Check if currently streaming
  bool get isStreaming => status == MessageStatus.streaming;

  @override
  String toString() {
    final preview = content.length > 50 ? '${content.substring(0, 50)}...' : content;
    return 'ChatMessage($role: $preview)';
  }
}
