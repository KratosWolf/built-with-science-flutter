import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VolumeChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final bool isLoading;

  const VolumeChart({
    Key? key,
    required this.weeklyData,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainer,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volume Semanal (kg)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: theme.colorScheme.primary),
                    ),
                  )
                : weeklyData.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.bar_chart, size: 48, color: theme.colorScheme.onSurfaceVariant),
                              SizedBox(height: 8),
                              Text(
                                'Sem dados suficientes',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: _calculateInterval(),
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < weeklyData.length) {
                                      return Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          weeklyData[index]['week'],
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    }
                                    return Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: _calculateInterval(),
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Text(
                                      _formatVolume(value),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3), width: 1),
                                left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3), width: 1),
                              ),
                            ),
                            minX: 0,
                            maxX: (weeklyData.length - 1).toDouble(),
                            minY: 0,
                            maxY: _getMaxY(),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _createSpots(),
                                isCurved: true,
                                curveSmoothness: 0.3,
                                color: theme.colorScheme.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: theme.colorScheme.primary,
                                      strokeWidth: 2,
                                      strokeColor: theme.colorScheme.surfaceContainer,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < weeklyData.length; i++) {
      final volume = (weeklyData[i]['volume'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), volume));
    }
    return spots;
  }

  double _getMaxY() {
    if (weeklyData.isEmpty) return 100;

    double maxVolume = 0;
    for (var week in weeklyData) {
      final volume = (week['volume'] as num).toDouble();
      if (volume > maxVolume) maxVolume = volume;
    }

    // Add 20% padding to the top
    return maxVolume * 1.2;
  }

  double _calculateInterval() {
    final maxY = _getMaxY();
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    return 2000;
  }

  String _formatVolume(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }
}
