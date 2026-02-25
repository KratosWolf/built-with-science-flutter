import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../models/user_stats.dart';
import '../config/theme.dart';
import '../widgets/dashboard/volume_chart.dart';
import '../widgets/dashboard/comparison_card.dart';
import '../widgets/dashboard/personal_records_card.dart';
import '../widgets/dashboard/weekly_goal_card.dart';

enum TimePeriod {
  week,
  month,
  quarter,
  year,
  allTime,
}

enum SyncStatus {
  synced,   // Sem pendências → cloud_done (cinza)
  syncing,  // Sincronizando → cloud_upload (laranja)
  pending,  // Com pendências → cloud_off (amarelo warning)
}

extension TimePeriodExtension on TimePeriod {
  String get label {
    switch (this) {
      case TimePeriod.week:
        return 'Semana';
      case TimePeriod.month:
        return 'Mês';
      case TimePeriod.quarter:
        return 'Trimestre';
      case TimePeriod.year:
        return 'Ano';
      case TimePeriod.allTime:
        return 'Total';
    }
  }

  int? get days {
    switch (this) {
      case TimePeriod.week:
        return 7;
      case TimePeriod.month:
        return 30;
      case TimePeriod.quarter:
        return 90;
      case TimePeriod.year:
        return 365;
      case TimePeriod.allTime:
        return null; // null = all time
    }
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<WorkoutDay> _workoutDays = [];
  UserStats? _stats;
  int _currentStreak = 0;
  int _monthTotal = 0;
  DateTime? _lastWorkout;
  List<Map<String, dynamic>> _weeklyVolumes = [];
  TimePeriod _selectedPeriod = TimePeriod.month;
  Map<String, dynamic> _comparisonData = {};
  bool _isLoadingComparison = false;
  List<Map<String, dynamic>> _personalRecords = [];
  bool _isLoadingPRs = false;
  Map<String, dynamic> _weeklyProgress = {};
  bool _isLoadingWeeklyGoal = false;
  SyncStatus _syncStatus = SyncStatus.synced; // Estado inicial: sem pendências

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    // Verificar se usuário está logado
    if (!SupabaseService.instance.isLoggedIn) {
      debugPrint('⚠️ Usuário não logado - carregando dados locais');
      await _loadLocalData();
      return;
    }

    try {
      debugPrint('📊 Carregando estatísticas do Supabase...');

      // Buscar stats do Supabase com filtro de período
      final stats = await SupabaseService.instance.getUserStats(
        filterDays: _selectedPeriod.days,
      );

      // Buscar dados de volume semanal para o gráfico
      final weeklyVolumes = await SupabaseService.instance.getWeeklyVolumes(weeks: 8);

      // Buscar dados de comparação (apenas se não for "Total")
      Map<String, dynamic> comparisonData = {};
      if (_selectedPeriod != TimePeriod.allTime) {
        setState(() => _isLoadingComparison = true);
        comparisonData = await SupabaseService.instance.compareWithPreviousPeriod(
          days: _selectedPeriod.days!,
        );
        setState(() => _isLoadingComparison = false);
      }

      // Buscar Personal Records
      setState(() => _isLoadingPRs = true);
      final personalRecords = await SupabaseService.instance.getPersonalRecords();
      setState(() => _isLoadingPRs = false);

      // Buscar progresso semanal (meta) adaptado ao período
      setState(() => _isLoadingWeeklyGoal = true);
      final weeklyProgress = await SupabaseService.instance.getWeeklyProgress(
        filterDays: _selectedPeriod.days,
      );
      setState(() => _isLoadingWeeklyGoal = false);

      // Buscar dados de workout_sessions FINALIZADAS para o calendar
      final workoutSessionsData = await SupabaseService.instance.client
          .from('workout_sessions')
          .select()
          .eq('user_id', SupabaseService.instance.currentUser!.id)
          .eq('status', 'done')  // Apenas treinos concluídos
          .order('created_at', ascending: true);

      // Processar dados para o calendar
      List<WorkoutDay> days = [];
      Map<String, int> workoutsByDate = {};

      for (var session in workoutSessionsData) {
        final createdAt = session['created_at'] as String;
        final date = DateTime.parse(createdAt);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        // Cada sessão finalizada = 1 treino completo
        workoutsByDate[dateKey] = (workoutsByDate[dateKey] ?? 0) + 1;
      }

      workoutsByDate.forEach((dateStr, count) {
        try {
          final parsedDate = DateTime.parse(dateStr);
          days.add(WorkoutDay(date: parsedDate, workoutCount: count));
        } catch (e) {
          debugPrint('⚠️ Data inválida: $dateStr');
        }
      });

      days.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        _stats = stats;
        _workoutDays = days;
        _weeklyVolumes = weeklyVolumes;
        _comparisonData = comparisonData;
        _personalRecords = personalRecords;
        _weeklyProgress = weeklyProgress;
        _currentStreak = stats.currentStreak;
        _monthTotal = stats.totalWorkouts; // Aproximação
        _lastWorkout = stats.lastWorkoutDate;
        _isLoading = false;
      });

      debugPrint('✅ Dashboard carregado com ${days.length} dias de dados');
      debugPrint('   - Streak: ${stats.currentStreak} dias');
      debugPrint('   - Total workouts: ${stats.totalWorkouts}');
      debugPrint('   - Volume: ${stats.formattedVolume}');

      // Sync silencioso em background ao abrir dashboard (não bloqueia UI)
      setState(() => _syncStatus = SyncStatus.syncing);
      SyncService.instance.syncPendingQueue().then((result) {
        if (result['synced']! > 0) {
          debugPrint('✅ Startup sync: ${result['synced']} sets recuperados');
        }
        if (result['failed']! > 0) {
          debugPrint('⏳ Startup sync: ${result['failed']} sets ainda pendentes');
        }
        // Atualizar ícone após sync
        _checkSyncStatus();
      }).catchError((error) {
        debugPrint('❌ Erro no startup sync: $error');
        // Atualizar ícone mesmo com erro
        _checkSyncStatus();
      });

    } catch (e) {
      debugPrint('❌ Erro ao carregar dados do Supabase: $e');
      debugPrint('   Tentando carregar dados locais...');
      await _loadLocalData();
    }
  }

  /// Fallback para carregar dados locais (offline mode)
  Future<void> _loadLocalData() async {
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
        debugPrint('❌ Erro ao processar histórico local: $e');
        setState(() => _isLoading = false);
      }
    } else {
      debugPrint('📭 Nenhum dado local encontrado');
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

  /// Verifica status do sync (pendências na fila)
  Future<void> _checkSyncStatus() async {
    try {
      final stats = await SyncService.instance.getQueueStats();
      final pendingCount = stats['total'] as int;

      if (mounted) {
        setState(() {
          _syncStatus = pendingCount > 0 ? SyncStatus.pending : SyncStatus.synced;
        });

        debugPrint('🔄 Sync status: ${pendingCount > 0 ? 'PENDING ($pendingCount)' : 'SYNCED'}');
      }
    } catch (error) {
      debugPrint('❌ Erro ao verificar sync status: $error');
      // Em caso de erro, assumir synced (otimista)
      if (mounted) {
        setState(() => _syncStatus = SyncStatus.synced);
      }
    }
  }

  Color _getColorForCount(int count, BuildContext context) {
    final theme = Theme.of(context);
    // Usar escala de laranja para dark mode
    if (count == 0) return theme.colorScheme.surfaceContainerHighest;
    if (count == 1) return theme.colorScheme.primary.withOpacity(0.3);
    if (count == 2) return theme.colorScheme.primary.withOpacity(0.5);
    if (count == 3) return theme.colorScheme.primary.withOpacity(0.7);
    return theme.colorScheme.primary; // 4+
  }

  Widget _buildGitHubCalendar(BuildContext context) {
    final theme = Theme.of(context);
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
        final color = _getColorForCount(count, context);

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
      color: theme.colorScheme.surfaceContainer,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Últimos 90 dias',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
                Text('Menos', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                SizedBox(width: 8),
                Container(width: 12, height: 12, color: theme.colorScheme.surfaceContainerHighest),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: theme.colorScheme.primary.withOpacity(0.3)),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: theme.colorScheme.primary.withOpacity(0.5)),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: theme.colorScheme.primary.withOpacity(0.7)),
                SizedBox(width: 4),
                Container(width: 12, height: 12, color: theme.colorScheme.primary),
                SizedBox(width: 8),
                Text('Mais', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String emoji, String title, String value, Color color, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 36),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: theme.colorScheme.primary),
                SizedBox(width: 8),
                Text(
                  'Período de Análise',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TimePeriod.values.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPeriod = period;
                            _isLoading = true;
                          });
                          _loadWorkoutData();
                        }
                      },
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      labelStyle: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ícone de sync na AppBar (discreto, 3 estados)
  Widget _buildSyncIcon() {
    IconData icon;
    Color color;
    String tooltip;

    switch (_syncStatus) {
      case SyncStatus.syncing:
        icon = Icons.cloud_upload_outlined;
        color = AppTheme.primaryOrange;
        tooltip = 'Sincronizando...';
        break;
      case SyncStatus.pending:
        icon = Icons.cloud_off_outlined;
        color = AppTheme.warning; // #F59E0B
        tooltip = 'Backup pendente';
        break;
      case SyncStatus.synced:
        icon = Icons.cloud_done_outlined;
        color = AppTheme.textSecondary;
        tooltip = 'Backup em dia';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.analytics_outlined, size: 24),
            SizedBox(width: 10),
            Text(
              'Dashboard de Consistência',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          // Ícone de sync (discreto no canto direito)
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: _buildSyncIcon(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Seletor de período
                  _buildPeriodSelector(context),

                  // Cards de métricas
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            '🔥',
                            'Streak atual',
                            '${_stats?.currentStreak ?? _currentStreak}',
                            theme.colorScheme.primary,
                            context,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            '💪',
                            'Total treinos',
                            '${_stats?.totalWorkouts ?? _monthTotal}',
                            AppTheme.info,
                            context,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Segunda linha de cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            '📊',
                            'Volume total',
                            _stats?.formattedVolume ?? '0kg',
                            theme.colorScheme.primary,
                            context,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            '📈',
                            'Média semanal',
                            '${_stats?.formattedWeeklyAverage ?? '0.0'}x',
                            const Color(0xFF14B8A6), // Teal
                            context,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  // Card último treino
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMetricCard(
                      '📅',
                      'Último treino',
                      (_stats?.lastWorkoutDate ?? _lastWorkout) != null
                          ? () {
                              final date = _stats?.lastWorkoutDate ?? _lastWorkout!;
                              return '${date.day}/${date.month}/${date.year}';
                            }()
                          : 'Nenhum',
                      const Color(0xFF22C55E), // Success green
                      context,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Meta adaptada ao período (não mostrar para "Total")
                  if (_weeklyProgress['show_goal'] == true || _selectedPeriod != TimePeriod.allTime)
                    WeeklyGoalCard(
                      weeklyProgress: _weeklyProgress,
                      filterDays: _selectedPeriod.days,
                      periodName: _selectedPeriod.label,
                      onGoalUpdated: () {
                        // Recarregar dados após atualização da meta
                        setState(() => _isLoadingWeeklyGoal = true);
                        SupabaseService.instance.getWeeklyProgress(
                          filterDays: _selectedPeriod.days,
                        ).then((progress) {
                          setState(() {
                            _weeklyProgress = progress;
                            _isLoadingWeeklyGoal = false;
                          });
                        });
                      },
                    ),

                  // Comparação com período anterior (não mostrar para "Total")
                  if (_selectedPeriod != TimePeriod.allTime)
                    ComparisonCard(
                      comparisonData: _comparisonData,
                      isLoading: _isLoadingComparison,
                    ),

                  // Calendário estilo GitHub
                  _buildGitHubCalendar(context),

                  // Gráfico de Volume Semanal
                  VolumeChart(
                    weeklyData: _weeklyVolumes,
                    isLoading: _isLoading,
                  ),

                  // Personal Records
                  PersonalRecordsCard(
                    personalRecords: _personalRecords,
                    isLoading: _isLoadingPRs,
                  ),

                  // Mensagem motivacional
                  if (_workoutDays.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center, size: 64, color: theme.colorScheme.onSurfaceVariant),
                          SizedBox(height: 16),
                          Text(
                            'Comece seu primeiro treino!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Seus treinos aparecerão aqui',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
