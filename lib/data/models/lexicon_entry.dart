import 'package:uuid/uuid.dart';

class LexiconEntry {
  final String id;
  final String userId;
  final String word;
  final String? definition;
  final String? etymology;
  final String? identityTag;
  final int masteryLevel;
  final DateTime? lastPracticedAt;
  final DateTime createdAt;

  LexiconEntry({
    required this.id,
    required this.userId,
    required this.word,
    this.definition,
    this.etymology,
    this.identityTag,
    this.masteryLevel = 0,
    this.lastPracticedAt,
    required this.createdAt,
  });

  factory LexiconEntry.create({
    required String userId,
    required String word,
    String? identityTag,
  }) {
    return LexiconEntry(
      id: const Uuid().v4(),
      userId: userId,
      word: word,
      identityTag: identityTag,
      createdAt: DateTime.now(),
    );
  }

  factory LexiconEntry.fromJson(Map<String, dynamic> json) {
    return LexiconEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      word: json['word'] as String,
      definition: json['definition'] as String?,
      etymology: json['etymology'] as String?,
      identityTag: json['identity_tag'] as String?,
      masteryLevel: json['mastery_level'] as int? ?? 0,
      lastPracticedAt: json['last_practiced_at'] != null
          ? DateTime.parse(json['last_practiced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'word': word,
      'definition': definition,
      'etymology': etymology,
      'identity_tag': identityTag,
      'mastery_level': masteryLevel,
      'last_practiced_at': lastPracticedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  LexiconEntry copyWith({
    String? definition,
    String? etymology,
    String? identityTag,
    int? masteryLevel,
    DateTime? lastPracticedAt,
  }) {
    return LexiconEntry(
      id: id,
      userId: userId,
      word: word,
      definition: definition ?? this.definition,
      etymology: etymology ?? this.etymology,
      identityTag: identityTag ?? this.identityTag,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
      createdAt: createdAt,
    );
  }
}
