import 'dart:math';
import '../models/habit.dart';
import '../models/daily_metrics.dart';

/// KeystoneAnalyzer - Identifies habits with outsized positive effects
/// 
/// A "keystone habit" is one that, when completed, triggers positive ripple
/// effects across other areas of life. This analyzer uses correlation analysis
/// between habit completion and wellness metrics to identify these high-leverage
/// habits.
/// 
/// Examples:
/// - "On days you exercise, your mood averages 7.8 vs 5.2"
/// - "When you meditate, you complete 40% more of your other habits"
/// - "Early bedtime correlates with 2x better focus the next day"
class KeystoneAnalyzer {
  KeystoneAnalyzer._(); // Private constructor - use static methods
  
  // ========== Keystone Identification ==========
  
  /// Identify keystone habits from a list of habits and daily metrics
  /// 
  /// A habit is considered a keystone if it has strong positive correlations
  /// with:
  /// - Wellness metrics (mood, energy, focus, etc.)
  /// - Other habit completions
  /// - Overall daily success
  static List<KeystoneHabitResult> identifyKeystoneHabits(
    List<Habit> habits,
    List<DailyMetrics> metrics,
  ) {
    if (habits.isEmpty || metrics.length < 7) {
      return []; // Need minimum data
    }
    
    final results = <KeystoneHabitResult>[];
    
    for (final habit in habits) {
      final analysis = analyzeHabitImpact(habit, habits, metrics);
      
      if (analysis.isKeystone) {
        results.add(analysis);
      }
    }
    
    // Sort by keystone score (highest first)
    results.sort((a, b) => b.keystoneScore.compareTo(a.keystoneScore));
    
    return results;
  }
  
  /// Analyze the impact of a single habit
  static KeystoneHabitResult analyzeHabitImpact(
    Habit habit,
    List<Habit> allHabits,
    List<DailyMetrics> metrics,
  ) {
    final correlations = <HabitCorrelation>[];
    
    // Separate days by whether this habit was completed
    final daysWithHabit = <DailyMetrics>[];
    final daysWithoutHabit = <DailyMetrics>[];
    
    for (final day in metrics) {
      if (day.wasHabitCompleted(habit.id)) {
        daysWithHabit.add(day);
      } else {
        daysWithoutHabit.add(day);
      }
    }
    
    // Need minimum samples in both groups
    if (daysWithHabit.length < 3 || daysWithoutHabit.length < 3) {
      return KeystoneHabitResult.insufficient(habit);
    }
    
    // Analyze mood correlation
    final moodCorrelation = _analyzeMetricCorrelation(
      habit, 'Mood', daysWithHabit, daysWithoutHabit, (m) => m.mood
    );
    if (moodCorrelation != null) correlations.add(moodCorrelation);
    
    // Analyze energy correlation
    final energyCorrelation = _analyzeMetricCorrelation(
      habit, 'Energy', daysWithHabit, daysWithoutHabit, (m) => m.energy
    );
    if (energyCorrelation != null) correlations.add(energyCorrelation);
    
    // Analyze focus correlation
    final focusCorrelation = _analyzeMetricCorrelation(
      habit, 'Focus', daysWithHabit, daysWithoutHabit, (m) => m.focusRating
    );
    if (focusCorrelation != null) correlations.add(focusCorrelation);
    
    // Analyze sleep quality correlation
    final sleepCorrelation = _analyzeMetricCorrelation(
      habit, 'Sleep Quality', daysWithHabit, daysWithoutHabit, (m) => m.sleepQuality
    );
    if (sleepCorrelation != null) correlations.add(sleepCorrelation);
    
    // Analyze stress correlation (inverted - lower is better)
    final stressCorrelation = _analyzeMetricCorrelation(
      habit, 'Calm (inverse stress)', daysWithHabit, daysWithoutHabit, (m) => m.stressLevel
    );
    if (stressCorrelation != null) correlations.add(stressCorrelation);
    
    // Analyze impact on other habits
    final otherHabitsImpact = _analyzeOtherHabitsImpact(
      habit, allHabits, daysWithHabit, daysWithoutHabit
    );
    
    // Calculate overall keystone score
    final keystoneScore = _calculateKeystoneScore(correlations, otherHabitsImpact);
    
    return KeystoneHabitResult(
      habit: habit,
      correlations: correlations,
      otherHabitsImpact: otherHabitsImpact,
      keystoneScore: keystoneScore,
      sampleSize: metrics.length,
      daysWithHabit: daysWithHabit.length,
      daysWithoutHabit: daysWithoutHabit.length,
      isKeystone: keystoneScore >= 0.5,
    );
  }
  
  static HabitCorrelation? _analyzeMetricCorrelation(
    Habit habit,
    String metricName,
    List<DailyMetrics> daysWithHabit,
    List<DailyMetrics> daysWithoutHabit,
    int? Function(DailyMetrics) getMetric,
  ) {
    final withHabitValues = daysWithHabit
        .map(getMetric)
        .where((v) => v != null)
        .map((v) => v!.toDouble())
        .toList();
    
    final withoutHabitValues = daysWithoutHabit
        .map(getMetric)
        .where((v) => v != null)
        .map((v) => v!.toDouble())
        .toList();
    
    if (withHabitValues.length < 3 || withoutHabitValues.length < 3) {
      return null;
    }
    
    final avgWith = _average(withHabitValues);
    final avgWithout = _average(withoutHabitValues);
    final difference = avgWith - avgWithout;
    
    // Calculate correlation coefficient
    final correlation = _calculatePointBiserialCorrelation(
      withHabitValues, withoutHabitValues
    );
    
    // Calculate statistical significance (simplified)
    final significance = _calculateSignificance(
      withHabitValues, withoutHabitValues
    );
    
    return HabitCorrelation(
      habitId: habit.id,
      habitName: habit.name,
      metricName: metricName,
      avgWithHabit: avgWith,
      avgWithoutHabit: avgWithout,
      difference: difference,
      correlationCoefficient: correlation,
      sampleSize: withHabitValues.length + withoutHabitValues.length,
      pValue: significance,
    );
  }
  
  static OtherHabitsImpact _analyzeOtherHabitsImpact(
    Habit habit,
    List<Habit> allHabits,
    List<DailyMetrics> daysWithHabit,
    List<DailyMetrics> daysWithoutHabit,
  ) {
    final otherHabitIds = allHabits
        .where((h) => h.id != habit.id)
        .map((h) => h.id)
        .toList();
    
    if (otherHabitIds.isEmpty) {
      return OtherHabitsImpact(
        avgOtherHabitsWithThis: 0,
        avgOtherHabitsWithoutThis: 0,
        percentageIncrease: 0,
      );
    }
    
    // Calculate average other habits completed
    double countOtherHabitsCompleted(List<DailyMetrics> days) {
      if (days.isEmpty) return 0;
      
      int total = 0;
      for (final day in days) {
        for (final otherId in otherHabitIds) {
          if (day.wasHabitCompleted(otherId)) total++;
        }
      }
      return total / days.length;
    }
    
    final avgWith = countOtherHabitsCompleted(daysWithHabit);
    final avgWithout = countOtherHabitsCompleted(daysWithoutHabit);
    
    final percentageIncrease = avgWithout > 0
        ? ((avgWith - avgWithout) / avgWithout * 100)
        : (avgWith > 0 ? 100 : 0);
    
    return OtherHabitsImpact(
      avgOtherHabitsWithThis: avgWith,
      avgOtherHabitsWithoutThis: avgWithout,
      percentageIncrease: percentageIncrease,
    );
  }
  
  static double _calculateKeystoneScore(
    List<HabitCorrelation> correlations,
    OtherHabitsImpact otherHabitsImpact,
  ) {
    if (correlations.isEmpty) return 0;
    
    // Weight: wellness correlations (60%) + other habits impact (40%)
    
    // Average positive correlation strength
    final positiveCorrelations = correlations
        .where((c) => c.difference > 0 && c.pValue < 0.1)
        .toList();
    
    double wellnessScore = 0;
    if (positiveCorrelations.isNotEmpty) {
      final avgCorrelation = positiveCorrelations
          .map((c) => c.correlationCoefficient.abs())
          .reduce((a, b) => a + b) / positiveCorrelations.length;
      
      wellnessScore = avgCorrelation * 0.6;
    }
    
    // Other habits impact score
    double otherHabitsScore = 0;
    if (otherHabitsImpact.percentageIncrease > 0) {
      // Cap at 50% increase for max score
      otherHabitsScore = (otherHabitsImpact.percentageIncrease / 50).clamp(0, 1) * 0.4;
    }
    
    return (wellnessScore + otherHabitsScore).clamp(0, 1);
  }
  
  // ========== Statistical Helpers ==========
  
  static double _average(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  static double _standardDeviation(List<double> values) {
    if (values.length < 2) return 0;
    
    final avg = _average(values);
    final squaredDiffs = values.map((v) => pow(v - avg, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / (values.length - 1);
    
    return sqrt(variance);
  }
  
  static double _calculatePointBiserialCorrelation(
    List<double> group1,
    List<double> group2,
  ) {
    // Point-biserial correlation for binary vs continuous
    final n1 = group1.length;
    final n2 = group2.length;
    final n = n1 + n2;
    
    final m1 = _average(group1);
    final m2 = _average(group2);
    
    final allValues = [...group1, ...group2];
    final sd = _standardDeviation(allValues);
    
    if (sd == 0) return 0;
    
    final correlation = ((m1 - m2) / sd) * sqrt((n1 * n2) / (n * (n - 1)));
    
    return correlation.clamp(-1, 1);
  }
  
  static double _calculateSignificance(
    List<double> group1,
    List<double> group2,
  ) {
    // Simplified t-test approximation
    final n1 = group1.length;
    final n2 = group2.length;
    
    final m1 = _average(group1);
    final m2 = _average(group2);
    
    final s1 = _standardDeviation(group1);
    final s2 = _standardDeviation(group2);
    
    if (s1 == 0 && s2 == 0) return 1; // No variance
    
    // Pooled standard error
    final se = sqrt((s1 * s1 / n1) + (s2 * s2 / n2));
    
    if (se == 0) return 1;
    
    final t = (m1 - m2).abs() / se;
    
    // Rough p-value approximation (very simplified)
    // In production, use a proper statistical library
    if (t > 3.5) return 0.001;
    if (t > 2.5) return 0.01;
    if (t > 2.0) return 0.05;
    if (t > 1.5) return 0.1;
    return 0.5;
  }
  
  // ========== Insight Generation ==========
  
  /// Generate human-readable insights from keystone analysis
  static List<KeystoneInsight> generateInsights(
    List<KeystoneHabitResult> results,
  ) {
    final insights = <KeystoneInsight>[];
    
    for (final result in results) {
      if (!result.isKeystone) continue;
      
      // Main keystone insight
      insights.add(KeystoneInsight(
        habitName: result.habit.name,
        type: KeystoneInsightType.keystone,
        title: '${result.habit.name} is a keystone habit!',
        description: 'This habit has outsized positive effects on your overall wellbeing.',
        impactScore: result.keystoneScore,
      ));
      
      // Strongest correlation insight
      final strongestCorrelation = result.correlations
          .where((c) => c.difference > 0 && c.pValue < 0.1)
          .fold<HabitCorrelation?>(null, (best, current) =>
            best == null || current.difference > best.difference ? current : best
          );
      
      if (strongestCorrelation != null) {
        insights.add(KeystoneInsight(
          habitName: result.habit.name,
          type: KeystoneInsightType.correlation,
          title: 'Strong ${strongestCorrelation.metricName} boost',
          description: 'On days you complete "${result.habit.name}", '
              'your ${strongestCorrelation.metricName} averages '
              '${strongestCorrelation.avgWithHabit.toStringAsFixed(1)} vs '
              '${strongestCorrelation.avgWithoutHabit.toStringAsFixed(1)}.',
          impactScore: strongestCorrelation.correlationCoefficient.abs(),
        ));
      }
      
      // Other habits impact insight
      if (result.otherHabitsImpact.percentageIncrease > 20) {
        insights.add(KeystoneInsight(
          habitName: result.habit.name,
          type: KeystoneInsightType.cascade,
          title: 'Triggers other habits',
          description: 'When you do "${result.habit.name}", you complete '
              '${result.otherHabitsImpact.percentageIncrease.round()}% more of your other habits.',
          impactScore: result.otherHabitsImpact.percentageIncrease / 100,
        ));
      }
    }
    
    return insights;
  }
  
  /// Get recommendations based on keystone analysis
  static List<String> getRecommendations(List<KeystoneHabitResult> results) {
    final recommendations = <String>[];
    
    final keystones = results.where((r) => r.isKeystone).toList();
    
    if (keystones.isEmpty) {
      recommendations.add('Keep tracking! We need more data to identify your keystone habits.');
      return recommendations;
    }
    
    // Prioritize keystone habit
    final topKeystone = keystones.first;
    recommendations.add(
      'Prioritize "${topKeystone.habit.name}" - it has the biggest ripple effect on your day.'
    );
    
    // Morning keystone suggestion
    if (topKeystone.habit.implementationTime.compareTo('12:00') < 0) {
      recommendations.add(
        'Great choice having "${topKeystone.habit.name}" in the morning - keystone habits work best early.'
      );
    } else {
      recommendations.add(
        'Consider moving "${topKeystone.habit.name}" earlier in the day to maximize its ripple effects.'
      );
    }
    
    // Focus suggestion
    if (!topKeystone.habit.isPrimaryHabit) {
      recommendations.add(
        'Make "${topKeystone.habit.name}" your primary focus habit - its impact justifies extra attention.'
      );
    }
    
    return recommendations;
  }
}

/// Result of keystone analysis for a single habit
class KeystoneHabitResult {
  final Habit habit;
  final List<HabitCorrelation> correlations;
  final OtherHabitsImpact otherHabitsImpact;
  final double keystoneScore; // 0-1, higher = more keystone-like
  final int sampleSize;
  final int daysWithHabit;
  final int daysWithoutHabit;
  final bool isKeystone;
  final bool hasSufficientData;
  
  KeystoneHabitResult({
    required this.habit,
    required this.correlations,
    required this.otherHabitsImpact,
    required this.keystoneScore,
    required this.sampleSize,
    required this.daysWithHabit,
    required this.daysWithoutHabit,
    required this.isKeystone,
    this.hasSufficientData = true,
  });
  
  factory KeystoneHabitResult.insufficient(Habit habit) => KeystoneHabitResult(
    habit: habit,
    correlations: [],
    otherHabitsImpact: OtherHabitsImpact(
      avgOtherHabitsWithThis: 0,
      avgOtherHabitsWithoutThis: 0,
      percentageIncrease: 0,
    ),
    keystoneScore: 0,
    sampleSize: 0,
    daysWithHabit: 0,
    daysWithoutHabit: 0,
    isKeystone: false,
    hasSufficientData: false,
  );
}

/// Correlation between a habit and a metric
class HabitCorrelation {
  final String habitId;
  final String habitName;
  final String metricName;
  final double avgWithHabit;
  final double avgWithoutHabit;
  final double difference;
  final double correlationCoefficient;
  final int sampleSize;
  final double pValue;
  
  HabitCorrelation({
    required this.habitId,
    required this.habitName,
    required this.metricName,
    required this.avgWithHabit,
    required this.avgWithoutHabit,
    required this.difference,
    required this.correlationCoefficient,
    required this.sampleSize,
    required this.pValue,
  });
  
  bool get isStatisticallySignificant => pValue < 0.05;
  bool get isPositive => difference > 0;
  
  String get strengthDescription {
    final absCoeff = correlationCoefficient.abs();
    if (absCoeff >= 0.7) return 'Strong';
    if (absCoeff >= 0.4) return 'Moderate';
    if (absCoeff >= 0.2) return 'Weak';
    return 'Very weak';
  }
}

/// Impact on other habits completion
class OtherHabitsImpact {
  final double avgOtherHabitsWithThis;
  final double avgOtherHabitsWithoutThis;
  final double percentageIncrease;
  
  OtherHabitsImpact({
    required this.avgOtherHabitsWithThis,
    required this.avgOtherHabitsWithoutThis,
    required this.percentageIncrease,
  });
  
  bool get hasPositiveImpact => percentageIncrease > 10;
}

/// Types of keystone insights
enum KeystoneInsightType {
  keystone,     // Overall keystone identification
  correlation,  // Specific metric correlation
  cascade,      // Impact on other habits
  timing,       // Timing recommendation
}

/// A single keystone insight
class KeystoneInsight {
  final String habitName;
  final KeystoneInsightType type;
  final String title;
  final String description;
  final double impactScore; // 0-1
  
  KeystoneInsight({
    required this.habitName,
    required this.type,
    required this.title,
    required this.description,
    required this.impactScore,
  });
}
