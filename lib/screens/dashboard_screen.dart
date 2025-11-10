import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<WorkoutDay> _workoutDays = [];
  int _currentStreak = 0;
  int _monthTotal = 0;
  DateTime? _lastWorkout;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    final prefs = await SharedPreferences.getInstance();

    // Ler histórico de treinos (workout_history é uma lista de JSON)
    final historyJson = prefs.getString('workout_history');

    if (historyJson != null) {
      try {
        final List<dynamic> history = json.decode(historyJson);

        // Processar histórico
        Map<String, int> workoutsByDate = {};

        for (var workout in history) {
          if (workout is Map) {
            final dateStr = workout['date'] as String?;
            if (dateStr != null) {
              workoutsByDate[dateStr] = (workoutsByDate[dateStr] ?? 0) + 1;
            }
          }
        }

        // Converter para WorkoutDay
        List<WorkoutDay> days = [];
        workoutsByDate.forEach((date, count) {
          try {
            final parsedDate = DateTime.parse(date);
            days.add(WorkoutDay(date: parsedDate, workoutCount: count));
          } catch (e) {
            // Ignorar datas inválidas
          }
        });

        // Ordenar por data
        days.sort((a, b) => a.date.compareTo(b.date));

        setState(() {
          _workoutDays = days;
          _calculateMetrics();
          _isLoading = false;
        });
      } catch (e) {
        print('Erro ao processar histórico: $e');
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _calculateMetrics() {
    if (_workoutDays.isEmpty) {
      _currentStreak = 0;
      _monthTotal = 0;
      _lastWorkout = null;
      return;
    }

    // Último treino
    _lastWorkout = _workoutDays.last.date;

    // Total do mês
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));
    _monthTotal = _workoutDays.where((day) => day.date.isAfter(thirtyDaysAgo)).length;

    // Calcular streak (dias consecutivos)
    _currentStreak = 0;
    DateTime checkDate = DateTime.now();

    // Normalizar para comparar apenas datas (sem horas)
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    // Verificar se há treino hoje ou ontem para começar o streak
    bool foundRecent = false;
    for (var day in _workoutDays.reversed) {
      final dayNormalized = DateTime(day.date.year, day.date.month, day.date.day);
      final diff = checkDate.difference(dayNormalized).inDays;

      if (diff <= 1) {
        foundRecent = true;
        break;
      }
    }

    if (!foundRecent) {
      _currentStreak = 0;
      return;
    }

    // Contar streak
    for (var day in _workoutDays.reversed) {
      final dayNormalized = DateTime(day.date.year, day.date.month, day.date.day);
      final diff = checkDate.difference(dayNormalized).inDays;

      if (diff == 0) {
        _currentStreak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else if (diff == 1) {
        // Pode não ter treino hoje, mas ontem sim
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
  }

  Color _getColorForCount(int count) {
    if (count == 0) return Color(0xFFEBEDF0);
    if (count == 1) return Color(0xFF9BE9A8);
    if (count == 2) return Color(0xFF40C463);
    if (count == 3) return Color(0xFF30A14E);
    return Color(0xFF216E39); // 4+
  }

  Widget _buildGitHubCalendar() {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: 90));

    // Criar mapa de treinos por data
    Map<String, int> workoutMap = {};
    for (var day in _workoutDays) {
      final key = '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-${day.date.day.toString().padLeft(2, '0')}';
      workoutMap[key] = day.workoutCount;
    }

    // Criar grid de 91 dias
    List<Widget> weeks = [];
    DateTime currentDate = startDate;

    for (int week = 0; week < 13; week++) {
      List<Widget> days = [];

      for (int day = 0; day < 7; day++) {
        final key = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
        final count = workoutMap[key] ?? 0;
        final color = _getColorForCount(count);

        days.add(
          Tooltip(
            message: '${currentDate.day}/${currentDate.month}: $count treino${count != 1 ? 's' : ''}',
            child: Container(
              width: 12,
              height: 12,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );

        currentDate = currentDate.add(Duration(days: 1));
        if (currentDate.isAfter(now)) break;
      }

      weeks.add(Column(children: days));
      if (currentDate.isAfter(now)) break;
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Últimos 90 dias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weeks,
              ),
            ),
            SizedBox(height: 12),
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Menos', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                SizedBox(width: 8),
                Container(width: 12, height: 12, color: Color(0xFFEBEDF0)),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: Color(0xFF9BE9A8)),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: Color(0xFF40C463)),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: Color(0xFF30A14E)),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: Color(0xFF216E39)),
                SizedBox(width: 8),
                Text('Mais', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String emoji, String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard de Consistência'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cards de métricas
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            '🔥',
                            'Dias seguidos',
                            '$_currentStreak',
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            '💪',
                            'Treinos este mês',
                            '$_monthTotal',
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card último treino
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMetricCard(
                      '📅',
                      'Último treino',
                      _lastWorkout != null
                          ? '${_lastWorkout!.day}/${_lastWorkout!.month}/${_lastWorkout!.year}'
                          : 'Nenhum',
                      Colors.green,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Calendário estilo GitHub
                  _buildGitHubCalendar(),

                  // Mensagem motivacional
                  if (_workoutDays.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'Comece seu primeiro treino!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Seus treinos aparecerão aqui',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// Modelo para representar um dia de treino
class WorkoutDay {
  final DateTime date;
  final int workoutCount;

  WorkoutDay({required this.date, required this.workoutCount});
}
