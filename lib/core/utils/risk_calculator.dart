/// RiskCalculator - Consolidated risk assessment logic
///
/// Centralizes the bitmask definitions and logic for user vulnerability.
/// Replaces scattered integer constants in psychometric_profile, etc.
// ignore_for_file: constant_identifier_names

class RiskCalculator {
  // Constants matching existing codebase (backward compatibility)
  static const int RISK_NONE = 0;
  
  /// Weekends often disrupt routine
  static const int RISK_WEEKEND = 1;       // 1 << 0
  
  /// Travel disrupts context
  static const int RISK_TRAVEL = 2;        // 1 << 1
  
  /// Evening fatigue/depletion
  static const int RISK_EVENING = 4;       // 1 << 2
  
  /// Morning inertia
  static const int RISK_MORNING = 8;       // 1 << 3
  
  /// Social pressure
  static const int RISK_SOCIAL = 16;       // 1 << 4
  
  /// High stress detected
  static const int RISK_STRESS = 32;       // 1 << 5
  
  /// High physical/mental fatigue
  static const int RISK_FATIGUE = 64;      // 1 << 6

  /// Check if a risk factor is present in the mask
  static bool hasRisk(int mask, int risk) => (mask & risk) != 0;

  /// Add a risk factor to the mask
  static int addRisk(int mask, int risk) => mask | risk;

  /// Remove a risk factor from the mask
  static int removeRisk(int mask, int risk) => mask & ~risk;

  /// Combine multiple risk factors
  static int combine(List<int> risks) {
    if (risks.isEmpty) return RISK_NONE;
    return risks.fold(0, (acc, curr) => acc | curr);
  }

  /// Get descriptive labels for active risks
  static List<String> getLabels(int mask) {
    final labels = <String>[];
    if (hasRisk(mask, RISK_WEEKEND)) labels.add('Weekend');
    if (hasRisk(mask, RISK_TRAVEL)) labels.add('Travel');
    if (hasRisk(mask, RISK_EVENING)) labels.add('Evening');
    if (hasRisk(mask, RISK_MORNING)) labels.add('Morning');
    if (hasRisk(mask, RISK_SOCIAL)) labels.add('Social');
    if (hasRisk(mask, RISK_STRESS)) labels.add('Stress');
    if (hasRisk(mask, RISK_FATIGUE)) labels.add('Fatigue');
    return labels;
  }
}
