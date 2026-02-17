import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../config/theme.dart';

class WeeklyGoalCard extends StatefulWidget {
  final Map<String, dynamic> weeklyProgress;
  final VoidCallback onGoalUpdated;
  final int? filterDays;
  final String periodName;

  const WeeklyGoalCard({
    Key? key,
    required this.weeklyProgress,
    required this.onGoalUpdated,
    required this.filterDays,
    this.periodName = 'Semana',
  }) : super(key: key);

  @override
  State<WeeklyGoalCard> createState() => _WeeklyGoalCardState();
}

class _WeeklyGoalCardState extends State<WeeklyGoalCard> {
  final _supabaseService = SupabaseService.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usar period_goal se disponível, senão usar weekly_goal (fallback)
    final periodGoal = widget.weeklyProgress['period_goal'] as int? ??
                      widget.weeklyProgress['weekly_goal'] as int? ??
                      widget.weeklyProgress['goal'] as int? ?? 3;
    final weeklyGoal = widget.weeklyProgress['weekly_goal'] as int? ?? 3;
    final current = widget.weeklyProgress['current'] as int? ?? 0;
    final progress = widget.weeklyProgress['progress'] as double? ?? 0.0;
    final remaining = widget.weeklyProgress['remaining'] as int? ?? periodGoal;

    // Determine color based on progress
    Color progressColor;
    if (progress >= 100) {
      progressColor = AppTheme.success;
    } else if (progress >= 75) {
      progressColor = AppTheme.primaryOrange;
    } else {
      progressColor = AppTheme.textSecondary;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.all(16),
      color: AppTheme.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.borderColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '🎯',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Meta ${widget.periodName == 'Semana' ? 'Semanal' : 'do ${widget.periodName}'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => _showGoalDialog(context, weeklyGoal),
                  tooltip: 'Definir Meta Semanal',
                ),
              ],
            ),
            SizedBox(height: 16),

            // Progress text
            Text(
              '$current de $periodGoal treinos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              remaining > 0
                  ? 'Faltam $remaining treino${remaining > 1 ? 's' : ''}'
                  : 'Meta atingida! 🎉',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 12,
                backgroundColor: AppTheme.backgroundElevated,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            SizedBox(height: 8),

            // Percentage
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, int currentGoal) {
    final theme = Theme.of(context);
    int selectedGoal = currentGoal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
              title: Text(
                'Definir Meta Semanal',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quantos treinos por semana?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '$selectedGoal treino${selectedGoal > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryOrange,
                      inactiveTrackColor: AppTheme.backgroundElevated,
                      thumbColor: AppTheme.primaryOrange,
                      overlayColor: AppTheme.primaryOrange.withOpacity(0.2),
                      valueIndicatorColor: AppTheme.primaryOrange,
                      valueIndicatorTextStyle: TextStyle(color: AppTheme.textPrimary),
                    ),
                    child: Slider(
                      value: selectedGoal.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      label: selectedGoal.toString(),
                      onChanged: (value) {
                        setState(() {
                          selectedGoal = value.toInt();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      Text(
                        '7',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: AppTheme.textPrimary,
                  ),
                  onPressed: () async {
                    final success = await _supabaseService.setWeeklyGoal(selectedGoal);

                    if (success) {
                      Navigator.of(context).pop();
                      widget.onGoalUpdated();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Meta salva: $selectedGoal treinos/semana'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao salvar meta'),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                    }
                  },
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
