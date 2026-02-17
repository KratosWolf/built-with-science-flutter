import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PersonalRecordsCard extends StatelessWidget {
  final List<Map<String, dynamic>> personalRecords;
  final bool isLoading;

  const PersonalRecordsCard({
    Key? key,
    required this.personalRecords,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              children: [
                Text(
                  '🏆',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 8),
                Text(
                  'Personal Records',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  )
                : _buildRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (personalRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 48,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 8),
              Text(
                'Complete treinos para ver seus recordes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: personalRecords.asMap().entries.map((entry) {
        final index = entry.key;
        final pr = entry.value;
        return _buildRecordItem(pr, index);
      }).toList(),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> pr, int index) {
    final exerciseName = pr['exercise_name'] as String;
    final weight = (pr['weight'] as num).toDouble();
    final reps = pr['reps'] as int;
    final dateStr = pr['date'] as String;

    // Parse and format date
    String formattedDate = '';
    try {
      final date = DateTime.parse(dateStr);
      formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      formattedDate = 'N/A';
    }

    // Medal colors for top 3 (adjusted for dark theme)
    Color? medalColor;
    String? medal;
    Color? textColor;

    if (index == 0) {
      medalColor = Color(0xFFFFD700); // Gold
      medal = '🥇';
      textColor = Color(0xFFFFD700);
    } else if (index == 1) {
      medalColor = Color(0xFFC0C0C0); // Silver
      medal = '🥈';
      textColor = Color(0xFFC0C0C0);
    } else if (index == 2) {
      medalColor = Color(0xFFCD7F32); // Bronze
      medal = '🥉';
      textColor = Color(0xFFCD7F32);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: medalColor != null
            ? medalColor.withOpacity(0.08)
            : AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: medalColor?.withOpacity(0.3) ?? AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Medal or rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: medalColor != null
                  ? medalColor.withOpacity(0.15)
                  : AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                medal ?? '${index + 1}',
                style: TextStyle(
                  fontSize: medal != null ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    // Weight badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${weight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    // Reps badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$reps reps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 2),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
