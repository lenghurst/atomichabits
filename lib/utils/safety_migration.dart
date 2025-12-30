import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

/// One-time migration script for Phase 61 Safety Enhancements
/// 
/// Applies default "Safety by Design" settings to existing contracts:
/// - share_psychometrics: false (DEFAULT SAFE)
/// - allow_nudges: true (DEFAULT ALLOWED)
/// - nudge_history: {} (EMPTY)
/// - blocked_witness_ids: [] (EMPTY)
class SafetyMigration {
  
  static Future<void> migrateExistingContracts() async {
    final supabase = Supabase.instance.client;
    
    print('Starting Safety Migration...');
    
    // 1. Fetch all contracts without safety fields
    // Note: Supabase will return null for missing columns if we select specific fields,
    // but here we are relying on the fact that existing rows have NULL or default for new columns.
    // Actually, we just update all rows to ensure consistency.
    // Ideally we filter where 'share_psychometrics' IS NULL.
    
    final response = await supabase
        .from(SupabaseTables.contracts)
        .select('id')
        .is_('share_psychometrics', null);
        
    final List<dynamic> contractsToMigrate = response as List<dynamic>;
    
    print('Found ${contractsToMigrate.length} contracts to migrate.');
    
    int successCount = 0;
    int failCount = 0;
    
    for (final contract in contractsToMigrate) {
      try {
        await supabase.from(SupabaseTables.contracts).update({
          'share_psychometrics': false,
          'allow_nudges': true,
          'nudge_history': {},
          'blocked_witness_ids': [],
          'allow_emergency_exit': true,
          'is_under_review': false,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', contract['id']);
        
        successCount++;
        if (successCount % 10 == 0) print('Migrated $successCount contracts...');
        
      } catch (e) {
        print('Failed to migrate contract ${contract['id']}: $e');
        failCount++;
      }
    }
    
    print('Migration Complete.');
    print('Success: $successCount');
    print('Failed: $failCount');
  }
}
