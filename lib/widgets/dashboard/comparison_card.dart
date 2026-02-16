import 'package:flutter/material.dart';

class ComparisonCard extends StatelessWidget {
  final Map<String, dynamic> comparisonData;
  final bool isLoading;

  const ComparisonCard({
    Key? key,
    required this.comparisonData,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparação com Período Anterior',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _buildComparisonContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonContent() {
    final workoutsDiff = comparisonData['workoutsDiff'] as int;
    final workoutsPercent = comparisonData['workoutsPercent'] as double;
    final volumeDiff = comparisonData['volumeDiff'] as double;
    final volumePercent = comparisonData['volumePercent'] as double;

    // Check if there's any data
    final hasData = comparisonData['currentWorkouts'] > 0 ||
                    comparisonData['previousWorkouts'] > 0;

    if (!hasData) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.compare_arrows, size: 48, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                'Sem dados para comparar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Workouts comparison
        _buildComparisonRow(
          label: 'Treinos',
          diff: workoutsDiff,
          percent: workoutsPercent,
          isCount: true,
        ),
        SizedBox(height: 12),
        Divider(),
        SizedBox(height: 12),
        // Volume comparison
        _buildComparisonRow(
          label: 'Volume Total',
          diff: volumeDiff,
          percent: volumePercent,
          isCount: false,
        ),
      ],
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required num diff,
    required double percent,
    required bool isCount,
  }) {
    final isPositive = diff >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final sign = isPositive ? '+' : '';

    // Format the difference value
    String diffText;
    if (isCount) {
      diffText = '$sign$diff';
    } else {
      diffText = '$sign${diff.toStringAsFixed(0)} kg';
    }

    // Format the percentage
    final percentText = '${sign}${percent.toStringAsFixed(1)}%';

    return Row(
      children: [
        // Icon
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        // Label and values
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    diffText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      percentText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
