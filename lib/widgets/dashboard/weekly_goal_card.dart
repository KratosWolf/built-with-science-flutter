import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

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
      progressColor = Colors.green;
    } else if (progress >= 75) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(16),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.settings, size: 20),
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
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
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
                  color: progressColor.withOpacity(0.1),
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
    int selectedGoal = currentGoal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Definir Meta Semanal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quantos treinos por semana?',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '$selectedGoal treino${selectedGoal > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 16),
                  Slider(
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
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1', style: TextStyle(color: Colors.grey)),
                      Text('7', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await _supabaseService.setWeeklyGoal(selectedGoal);

                    if (success) {
                      Navigator.of(context).pop();
                      widget.onGoalUpdated();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Meta salva: $selectedGoal treinos/semana'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao salvar meta'),
                          backgroundColor: Colors.red,
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
