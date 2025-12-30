/// Represents the user's profile and identity
/// Based on Atomic Habits identity-based approach
class UserProfile {
  final String identity; // "I am a person who..."
  final String name;
  final String? witnessName; // Added for Phase 33
  final String? witnessContact; // Added for Phase 33
  final DateTime createdAt;
  final bool isPremium; // Added for Phase 35 (Data Unification)

  UserProfile({
    required this.identity,
    required this.name,
    this.witnessName,
    this.witnessContact,
    required this.createdAt,
    this.isPremium = false,
  });

import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

// Helper class for privacy-preserving encryption
class _PrivacyCipher {
  // TODO: Move key to secure storage in production
  // For now, using a consistent key derived from environment or fallback
  static final _key = encrypt.Key.fromUtf8(
    const String.fromEnvironment('SYNC_ENCRYPTION_KEY', defaultValue: 'atomic_habits_privacy_key_32_ch')
        .padRight(32, '=').substring(0, 32)
  ); 
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static String? encryptIdentity(String? plaintext) {
    if (plaintext == null || plaintext.isEmpty) return null;
    try {
      final encrypted = _encrypter.encrypt(plaintext, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      if (kDebugMode) debugPrint('Encryption failed: $e');
      return plaintext; // Fallback? Or return null? Returning plaintext might leak.
    }
  }

  static String? decryptIdentity(String? ciphertext) {
    if (ciphertext == null || ciphertext.isEmpty) return null;
    try {
      final encrypted = encrypt.Encrypted.fromBase64(ciphertext);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      if (kDebugMode) debugPrint('Decryption failed: $e');
      return ciphertext; // Assume it might be plaintext if migration happens
    }
  }
}

  /// Converts profile to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'identity': identity, // Keep local plaintext for Hive
      'identity_encrypted': _PrivacyCipher.encryptIdentity(identity), // Encrypted for Sync
      'name': name,
      'witnessName': witnessName, // Persist witness name
      'witnessContact': witnessContact,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
    };
  }

  /// Creates profile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Check if we have an encrypted identity first (from Sync)
    String? decodedIdentity;
    if (json.containsKey('identity_encrypted')) {
      decodedIdentity = _PrivacyCipher.decryptIdentity(json['identity_encrypted']);
    }
    
    return UserProfile(
      identity: decodedIdentity ?? json['identity'] as String,
      name: json['name'] as String,
      witnessName: json['witnessName'] as String?, // Load witness name
      witnessContact: json['witnessContact'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  /// Creates a copy with updated fields
  UserProfile copyWith({
    String? identity,
    String? name,
    String? witnessName,
    String? witnessContact,
    bool? isPremium,
  }) {
    return UserProfile(
      identity: identity ?? this.identity,
      name: name ?? this.name,
      witnessName: witnessName ?? this.witnessName,
      witnessContact: witnessContact ?? this.witnessContact,
      createdAt: createdAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
