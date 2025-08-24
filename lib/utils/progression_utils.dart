import '../models/workout_models.dart';
import 'dart:math' as math;

/// Scientific progression calculation system based on RPE and performance analysis
/// Ported from Next.js TypeScript version with Dart optimizations
class ProgressionUtils {
  
  // Progression configuration by aggressiveness level
  static const Map<String, Map<String, Map<String, double>>> _progressionConfig = {
    'conservative': {
      'hit_easy': {'min': 0.0, 'max': 2.0},      // +0% to +2%
      'hit_ok': {'min': 0.0, 'max': 1.0},        // +0% to +1%
      'missed_hard': {'min': -2.0, 'max': 0.0},  // -2% to 0%
    },
    'standard': {
      'hit_easy': {'min': 2.5, 'max': 4.0},      // +2.5% to +4%
      'hit_ok': {'min': 0.0, 'max': 2.5},        // +0% to +2.5%
      'missed_hard': {'min': -2.5, 'max': 0.0},  // -2.5% to 0%
    },
    'aggressive': {
      'hit_easy': {'min': 4.0, 'max': 6.0},      // +4% to +6%
      'hit_ok': {'min': 1.0, 'max': 3.0},        // +1% to +3%
      'missed_hard': {'min': -5.0, 'max': -2.5}, // -5% to -2.5%
    },
  };
  
  // Minimum increments by exercise type
  static const Map<String, double> _minIncrements = {
    'compound': 2.5,   // kg
    'isolation': 1.25, // kg
  };
  
  /// Parse target reps string like "8-10", "6-12", "15+" into min/max
  static Map<String, int> parseTargetReps(String targetReps) {
    final cleanTarget = targetReps.replaceAll(RegExp(r'[^\d\-]'), '');
    final parts = cleanTarget.split('-');
    
    if (parts.length >= 2) {
      return {
        'min': int.tryParse(parts[0]) ?? 8,
        'max': int.tryParse(parts[1]) ?? 10,
      };
    } else if (parts.isNotEmpty) {
      final singleValue = int.tryParse(parts[0]) ?? 8;
      return {
        'min': singleValue,
        'max': singleValue,
      };
    }
    
    // Default fallback
    return {'min': 8, 'max': 10};
  }
  
  /// Determine performance category based on reps achieved and difficulty
  static String determinePerformance({
    required int lastReps,
    required String targetReps,
    String? difficulty,
    double? rpe,
  }) {
    final repRange = parseTargetReps(targetReps);
    final minReps = repRange['min']!;
    final maxReps = repRange['max']!;
    final hitTarget = lastReps >= minReps && lastReps <= maxReps;
    
    // If didn't hit target, always 'missed_hard'
    if (!hitTarget) return 'missed_hard';
    
    // If hit target, check difficulty
    if (difficulty != null) {
      switch (difficulty) {
        case 'easy':
          return 'hit_easy';
        case 'medium':
          return 'hit_ok';
        case 'hard':
        case 'max_effort':
        case 'failed':
          return 'missed_hard'; // Even if hit target, if it was too hard
      }
    }
    
    // If have RPE, use as reference (1-10 scale)
    if (rpe != null) {
      if (rpe <= 7.0) return 'hit_easy';
      if (rpe <= 8.5) return 'hit_ok';
      return 'missed_hard';
    }
    
    // Default: hit_ok
    return 'hit_ok';
  }
  
  /// Calculate percentage change based on performance and aggressiveness
  static double calculatePercentageChange({
    required String performance,
    required String aggressiveness,
  }) {
    final config = _progressionConfig[aggressiveness]?[performance];
    if (config == null) return 0.0;
    
    final min = config['min'] ?? 0.0;
    final max = config['max'] ?? 0.0;
    
    // Use average of range
    return (min + max) / 2;
  }
  
  /// Apply minimum increment rules for weight changes
  static double applyMinimumIncrement({
    required double oldWeight,
    required double newWeight,
    String exerciseType = 'compound',
  }) {
    final minIncrement = _minIncrements[exerciseType] ?? _minIncrements['compound']!;
    final difference = newWeight - oldWeight;
    
    // If positive change but smaller than minimum, apply minimum
    if (difference > 0 && difference < minIncrement) {
      return oldWeight + minIncrement;
    }
    
    // If change is very small (< 0.5kg), maintain weight
    if (difference.abs() < 0.5) {
      return oldWeight;
    }
    
    return newWeight;
  }
  
  /// Generate human-readable rationale for progression
  static String generateRationale({
    required String performance,
    required double percentageChange,
    required int lastReps,
    required String targetReps,
    String? difficulty,
    double? rpe,
  }) {
    final repRange = parseTargetReps(targetReps);
    final minReps = repRange['min']!;
    final maxReps = repRange['max']!;
    final difficultyText = difficulty != null ? " and felt '$difficulty'" : '';
    final rpeText = rpe != null ? " (RPE ${rpe.toStringAsFixed(1)})" : '';
    
    switch (performance) {
      case 'hit_easy':
        return '+${percentageChange.toStringAsFixed(1)}% because you hit target ($lastReps/$minReps-$maxReps)$difficultyText$rpeText with ease';
      
      case 'hit_ok':
        if (percentageChange > 0) {
          return '+${percentageChange.toStringAsFixed(1)}% because you hit target ($lastReps/$minReps-$maxReps)$difficultyText$rpeText appropriately';
        } else {
          return 'Maintain weight because you hit target ($lastReps/$minReps-$maxReps)$difficultyText$rpeText but it was challenging';
        }
      
      case 'missed_hard':
        if (lastReps < minReps) {
          return '${percentageChange.toStringAsFixed(1)}% because you missed target ($lastReps/$minReps-$maxReps)$difficultyText$rpeText';
        } else {
          return '${percentageChange.toStringAsFixed(1)}% because it was too difficult$difficultyText$rpeText even though you hit target';
        }
      
      default:
        return 'Maintain current weight and reps';
    }
  }
  
  /// Main progression calculation function
  static ProgressionSuggestion calculateProgression({
    required double lastWeight,
    required int lastReps,
    required String targetReps,
    String? difficulty,
    double? rpe,
    String aggressiveness = 'standard',
    String exerciseType = 'compound',
  }) {
    // Determine performance category
    final performance = determinePerformance(
      lastReps: lastReps,
      targetReps: targetReps,
      difficulty: difficulty,
      rpe: rpe,
    );
    
    // Calculate percentage change
    final percentageChange = calculatePercentageChange(
      performance: performance,
      aggressiveness: aggressiveness,
    );
    
    // Apply percentage change
    double suggestedWeight = lastWeight * (1 + percentageChange / 100);
    
    // Apply minimum increment rules
    suggestedWeight = applyMinimumIncrement(
      oldWeight: lastWeight,
      newWeight: suggestedWeight,
      exerciseType: exerciseType,
    );
    
    // Round to 0.25kg increments (standard plate loading)
    suggestedWeight = (suggestedWeight * 4).round() / 4;
    
    // Generate explanation
    final rationale = generateRationale(
      performance: performance,
      percentageChange: percentageChange,
      lastReps: lastReps,
      targetReps: targetReps,
      difficulty: difficulty,
      rpe: rpe,
    );
    
    return ProgressionSuggestion(
      type: suggestedWeight != lastWeight ? 'weight' : 'both',
      current: ProgressionData(weight: lastWeight, reps: lastReps),
      suggested: ProgressionData(weight: suggestedWeight, reps: lastReps),
      reason: rationale,
    );
  }
  
  /// Convert weight between units
  static double convertWeight(double weight, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return weight;
    
    if (fromUnit == 'kg' && toUnit == 'lb') {
      return weight * 2.20462;
    }
    
    if (fromUnit == 'lb' && toUnit == 'kg') {
      return weight / 2.20462;
    }
    
    return weight;
  }
  
  /// Calculate estimated 1RM using Epley formula
  static double calculate1RM(double weight, int reps) {
    if (reps <= 1) return weight;
    return weight * (1 + reps / 30.0);
  }
  
  /// Calculate estimated reps at given percentage of 1RM
  static int estimateRepsAt1RMPercentage(double percentage) {
    if (percentage >= 1.0) return 1;
    if (percentage >= 0.95) return 2;
    if (percentage >= 0.90) return 4;
    if (percentage >= 0.85) return 6;
    if (percentage >= 0.80) return 8;
    if (percentage >= 0.75) return 10;
    if (percentage >= 0.70) return 12;
    return 15;
  }
  
  /// Advanced progression with rep adjustment logic
  static ProgressionSuggestion calculateAdvancedProgression({
    required double lastWeight,
    required int lastReps,
    required String targetReps,
    required String difficulty,
    String aggressiveness = 'standard',
    String exerciseType = 'compound',
  }) {
    final repRange = parseTargetReps(targetReps);
    final minReps = repRange['min']!;
    final maxReps = repRange['max']!;
    final hitTarget = lastReps >= minReps && lastReps <= maxReps;
    
    // Advanced logic based on difficulty and target achievement
    switch (difficulty) {
      case 'easy':
        if (hitTarget) {
          if (lastReps < maxReps) {
            // Increase reps within range
            return ProgressionSuggestion(
              type: 'reps',
              current: ProgressionData(weight: lastWeight, reps: lastReps),
              suggested: ProgressionData(weight: lastWeight, reps: lastReps + 1),
              reason: 'Easy set. Increase to ${lastReps + 1} reps for more challenge.',
            );
          } else {
            // At max reps - increase weight
            final newWeight = (lastWeight * 1.025 * 4).round() / 4; // 2.5% increase
            return ProgressionSuggestion(
              type: 'both',
              current: ProgressionData(weight: lastWeight, reps: lastReps),
              suggested: ProgressionData(weight: newWeight, reps: minReps),
              reason: 'Easy at max reps. Increase weight to ${newWeight}kg and reset to $minReps reps.',
            );
          }
        }
        break;
        
      case 'medium':
        // Perfect - maintain
        return ProgressionSuggestion(
          type: 'both',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps),
          reason: 'Perfect difficulty. Maintain ${lastWeight}kg × $lastReps reps.',
        );
        
      case 'hard':
      case 'max_effort':
        if (hitTarget && lastReps > minReps) {
          // Reduce reps to make more manageable
          return ProgressionSuggestion(
            type: 'reps',
            current: ProgressionData(weight: lastWeight, reps: lastReps),
            suggested: ProgressionData(weight: lastWeight, reps: lastReps - 1),
            reason: 'Too challenging. Reduce to ${lastReps - 1} reps for better form.',
          );
        } else {
          // Reduce weight
          final reduction = difficulty == 'hard' ? 0.025 : 0.05; // 2.5% or 5%
          final newWeight = (lastWeight * (1 - reduction) * 4).round() / 4;
          return ProgressionSuggestion(
            type: 'weight',
            current: ProgressionData(weight: lastWeight, reps: lastReps),
            suggested: ProgressionData(weight: newWeight, reps: lastReps),
            reason: 'Too challenging. Reduce weight to ${newWeight}kg.',
          );
        }
        
      case 'failed':
        // Significant reduction
        final newWeight = (lastWeight * 0.90 * 4).round() / 4; // 10% reduction
        return ProgressionSuggestion(
          type: 'both',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: newWeight, reps: minReps),
          reason: 'Form breakdown. Reduce weight to ${newWeight}kg and focus on technique.',
        );
    }
    
    // Fallback to standard calculation
    return calculateProgression(
      lastWeight: lastWeight,
      lastReps: lastReps,
      targetReps: targetReps,
      difficulty: difficulty,
      aggressiveness: aggressiveness,
      exerciseType: exerciseType,
    );
  }
  
  /// Calculate training volume (sets × reps × weight)
  static double calculateVolume({
    required List<WorkoutSet> sets,
  }) {
    return sets.fold(0.0, (total, set) {
      final weight = set.weightKg ?? 0.0;
      final reps = set.reps ?? 0;
      return total + (weight * reps);
    });
  }
  
  /// Calculate average intensity (average %1RM across sets)
  static double calculateAverageIntensity({
    required List<WorkoutSet> sets,
    required double estimated1RM,
  }) {
    if (sets.isEmpty || estimated1RM <= 0) return 0.0;
    
    final totalIntensity = sets.fold(0.0, (total, set) {
      final weight = set.weightKg ?? 0.0;
      return total + (weight / estimated1RM);
    });
    
    return totalIntensity / sets.length;
  }
  
  /// Generate workout summary statistics
  static Map<String, dynamic> generateWorkoutSummary({
    required List<WorkoutSet> allSets,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (allSets.isEmpty) {
      return {
        'total_sets': 0,
        'total_volume': 0.0,
        'duration_minutes': 0,
        'exercises_count': 0,
      };
    }
    
    final uniqueExercises = allSets.map((s) => s.exerciseId).toSet().length;
    final totalVolume = calculateVolume(sets: allSets);
    final duration = endTime.difference(startTime).inMinutes;
    
    return {
      'total_sets': allSets.length,
      'total_volume': totalVolume.round(),
      'duration_minutes': duration,
      'exercises_count': uniqueExercises,
      'average_weight': allSets.isNotEmpty ? 
        (allSets.map((s) => s.weightKg ?? 0.0).reduce((a, b) => a + b) / allSets.length).round() : 0,
    };
  }
}