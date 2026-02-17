import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_models.dart';
import '../utils/progression_utils.dart';
import '../config/theme.dart';

class ProgressionSuggestionCard extends StatelessWidget {
  final int? exerciseId;
  final String? exerciseName;
  final String? targetReps;
  final int variationIndex;
  final LastSetCache? lastSetCache;
  final Function(double weight, int reps)? onAcceptSuggestion;
  final String userAggressiveness;

  // Alternative constructor for direct suggestion
  final ProgressionSuggestion? suggestion;
  final VoidCallback? onAccept;

  const ProgressionSuggestionCard({
    super.key,
    this.exerciseId,
    this.exerciseName,
    this.targetReps,
    this.variationIndex = 1,
    this.lastSetCache,
    this.onAcceptSuggestion,
    this.userAggressiveness = 'standard',
    this.suggestion,
    this.onAccept,
  });

  // Constructor for direct suggestion use
  const ProgressionSuggestionCard.withSuggestion({
    super.key,
    required this.suggestion,
    required this.exerciseName,
    required this.onAccept,
  }) : exerciseId = null,
       targetReps = null,
       variationIndex = 1,
       lastSetCache = null,
       onAcceptSuggestion = null,
       userAggressiveness = 'standard';

  @override
  Widget build(BuildContext context) {
    // If we have a direct suggestion, use it
    if (suggestion != null) {
      return _buildProgressionCard(context, suggestion!);
    }

    // No cache available - first time doing exercise
    if (lastSetCache == null ||
        lastSetCache!.weightKg == null ||
        lastSetCache!.reps == null ||
        lastSetCache!.difficulty == null) {
      return _buildFirstTimeCard();
    }

    // Calculate progression suggestion
    if (targetReps == null) return const SizedBox.shrink();

    final calculatedSuggestion = ProgressionUtils.calculateAdvancedProgression(
      lastWeight: lastSetCache!.weightKg!,
      lastReps: lastSetCache!.reps!,
      targetReps: targetReps!,
      difficulty: lastSetCache!.difficulty!,
      aggressiveness: userAggressiveness,
    );

    return _buildProgressionCard(context, calculatedSuggestion);
  }

  Widget _buildFirstTimeCard() {
    return Card(
      elevation: 0,
      color: AppTheme.info.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.info.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'First Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.info,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This is your first time doing ${exerciseName ?? 'this exercise'}. Start with a comfortable weight and focus on proper form.',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates,
                       size: 16, color: AppTheme.info),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pro tip: Choose a weight that allows you to complete all reps with 2-3 reps in reserve.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionCard(BuildContext context, ProgressionSuggestion suggestion) {
    final isIncrease = suggestion.suggested.weight! > suggestion.current.weight!;
    final isDecrease = suggestion.suggested.weight! < suggestion.current.weight!;

    Color cardColor;
    Color accentColor;
    IconData icon;
    String title;

    if (isIncrease) {
      cardColor = AppTheme.success.withOpacity(0.1);
      accentColor = AppTheme.success;
      icon = Icons.trending_up;
      title = 'Increase Weight';
    } else if (isDecrease) {
      cardColor = AppTheme.warning.withOpacity(0.1);
      accentColor = AppTheme.warning;
      icon = Icons.trending_down;
      title = 'Reduce Weight';
    } else {
      cardColor = AppTheme.info.withOpacity(0.1);
      accentColor = AppTheme.info;
      icon = Icons.flag;
      title = 'Maintain Weight';
    }

    final weightChange = suggestion.suggested.weight! - suggestion.current.weight!;
    final percentageChange = suggestion.current.weight! != 0
        ? (weightChange / suggestion.current.weight!) * 100
        : 0.0;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SMART',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Weight comparison
            Row(
              children: [
                // Current
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${suggestion.current.weight}kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${suggestion.current.reps} reps',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_forward,
                    color: accentColor,
                    size: 24,
                  ),
                ),

                // Suggested
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Suggested',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${suggestion.suggested.weight}kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      if (percentageChange.abs() > 0.1)
                        Text(
                          '${percentageChange > 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Rationale
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 16,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why this suggestion?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          suggestion.reason,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();

                  if (onAccept != null) {
                    onAccept!();
                  } else if (onAcceptSuggestion != null) {
                    onAcceptSuggestion!(
                      suggestion.suggested.weight!,
                      suggestion.suggested.reps!,
                    );
                  }

                  // Show brief confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Applied: ${suggestion.suggested.weight}kg'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: accentColor,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  'Use ${suggestion.suggested.weight}kg',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: AppTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Future widget for showing progression trends over time
class ProgressionTrendCard extends StatelessWidget {
  final int exerciseId;
  final String exerciseName;
  final List<Map<String, dynamic>> progressionHistory;

  const ProgressionTrendCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.progressionHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (progressionHistory.length < 2) {
      return const SizedBox.shrink();
    }

    final first = progressionHistory.last;
    final latest = progressionHistory.first;
    final weightProgress = (latest['weight_kg'] ?? 0.0) - (first['weight_kg'] ?? 0.0);
    final estimated1RMProgress = (latest['estimated_1rm'] ?? 0.0) - (first['estimated_1rm'] ?? 0.0);

    return Card(
      elevation: 0,
      color: AppTheme.info.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.info.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppTheme.info),
                const SizedBox(width: 8),
                const Text(
                  'Progress Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTrendItem(
                    'Weight',
                    '${weightProgress > 0 ? '+' : ''}${weightProgress.toStringAsFixed(1)}kg',
                    weightProgress >= 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTrendItem(
                    'Est. 1RM',
                    '${estimated1RMProgress > 0 ? '+' : ''}${estimated1RMProgress.toStringAsFixed(1)}kg',
                    estimated1RMProgress >= 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String label, String value, bool isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: isPositive ? AppTheme.success : AppTheme.error,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPositive ? AppTheme.success : AppTheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
