import 'package:flutter/material.dart';

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
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(16),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
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
              Icon(Icons.emoji_events, size: 48, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                'Complete treinos para ver seus recordes',
                textAlign: TextAlign.center,
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

    // Medal colors for top 3
    Color? medalColor;
    String? medal;
    if (index == 0) {
      medalColor = Color(0xFFFFD700); // Gold
      medal = '🥇';
    } else if (index == 1) {
      medalColor = Color(0xFFC0C0C0); // Silver
      medal = '🥈';
    } else if (index == 2) {
      medalColor = Color(0xFFCD7F32); // Bronze
      medal = '🥉';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: medalColor != null ? medalColor.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: medalColor ?? Colors.grey.shade200,
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
              color: medalColor != null ? medalColor.withOpacity(0.2) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                medal ?? '${index + 1}',
                style: TextStyle(
                  fontSize: medal != null ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: medalColor != null ? Colors.grey[800] : Colors.grey[600],
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
                    color: Colors.grey[800],
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
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${weight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    // Reps badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$reps reps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              SizedBox(height: 2),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
