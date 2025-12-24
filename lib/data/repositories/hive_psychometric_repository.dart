import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/psychometric_profile.dart';
import 'psychometric_repository.dart';

/// Hive implementation of PsychometricRepository.
class HivePsychometricRepository implements PsychometricRepository {
  Box? _dataBox;
  static const String _boxName = 'habit_data';
  static const String _profileKey = 'psychometricProfile';
  
  @override
  Future<void> init() async {
    try {
      _dataBox = await Hive.openBox(_boxName);
    } catch (e) {
      if (kDebugMode) debugPrint('HivePsychometricRepository: Error opening box: $e');
    }
  }
  
  @override
  Future<PsychometricProfile?> getProfile() async {
    if (_dataBox == null) return null;
    final profileJson = _dataBox!.get(_profileKey);
    if (profileJson != null) {
      return PsychometricProfile.fromJson(Map<String, dynamic>.from(profileJson));
    }
    return null;
  }
  
  @override
  Future<void> saveProfile(PsychometricProfile profile) async {
    if (_dataBox == null) return;
    await _dataBox!.put(_profileKey, profile.toJson());
  }
  
  @override
  Future<void> clear() async {
    if (_dataBox == null) return;
    await _dataBox!.delete(_profileKey);
  }
}
