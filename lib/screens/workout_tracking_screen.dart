import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_models.dart';
import '../data/mock_data.dart';
import '../widgets/exercise_tracking_widget.dart';
import '../widgets/rest_timer_widget.dart';
import '../services/supabase_service.dart';

class WorkoutTrackingScreen extends StatefulWidget {
  final int programId;
  final int dayId;
  final String dayName;
  final VoidCallback? onWorkoutCompleted;

  const WorkoutTrackingScreen({
    super.key,
    required this.programId,
    required this.dayId,
    required this.dayName,
    this.onWorkoutCompleted,
  });

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  List<Exercise> _exercises = [];
  int _currentExerciseIndex = 0;
  bool _isLoading = true;
  bool _isWorkoutComplete = false;
  DateTime? _workoutStartTime;
  Map<int, List<WorkoutSet>> _completedSets = {};
  bool _showRestTimer = false;
  int _restSeconds = 0;

  @override
  void initState() {
    super.initState();
    _cleanOldCache(); // Limpar cache antigo
    _loadWorkout();
    _debugShowAllCachedData(); // Debug: mostrar todos os dados salvos
  }
  
  Future<void> _debugShowAllCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    print('\n🔍 ===== DADOS SALVOS NO DISPOSITIVO =====');
    
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('last_workout_')) {
        final data = prefs.getStringList(key);
        print('📦 $key:');
        if (data != null) {
          for (final item in data) {
            print('   → $item');
          }
        }
      } else if (key.startsWith('next_workout_day_')) {
        final value = prefs.getInt(key);
        print('🎯 $key: $value');
      } else if (key == 'last_workout_date') {
        final value = prefs.getString(key);
        print('📅 Último treino: $value');
      } else if (key == 'last_workout_duration') {
        final value = prefs.getInt(key);
        if (value != null) {
          print('⏱️ Duração: ${value ~/ 60}min ${value % 60}s');
        }
      }
    }
    print('==========================================\n');
  }

  Future<void> _cleanOldCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Limpar cache de versões antigas (opcional - só executa uma vez)
    final hasCleanedCache = prefs.getBool('cache_cleaned_v2') ?? false;
    if (!hasCleanedCache) {
      print('🧹 Limpando cache antigo...');
      
      // Limpar todas as chaves de cache antigas
      final keys = prefs.getKeys();
      int removedKeys = 0;
      
      for (final key in keys) {
        if (key.startsWith('last_workout_')) {
          await prefs.remove(key);
          removedKeys++;
        }
      }
      
      await prefs.setBool('cache_cleaned_v2', true);
      print('✅ Cache limpo: $removedKeys chaves antigas removidas');
    } else {
      // Mostrar estatísticas do cache atual
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((k) => k.startsWith('last_workout_')).length;
      print('📊 Cache atual: $cacheKeys exercícios salvos');
    }
  }

  Future<void> _loadWorkout() async {
    setState(() => _isLoading = true);
    
    // Carregar exercícios baseados no dia do programa
    List<Exercise> exercises = [];
    
    // Selecionar exercícios baseados no programa real do usuário
    if (widget.dayId == 1) { // Full Body A - 8 exercícios exatos do SQL
      exercises = [
        MockData.exercises[0], // Barbell Bench Press (id: 1)
        MockData.exercises[6], // Barbell Romanian Deadlift (id: 7)  
        MockData.exercises[9], // (Weighted) Pull-Ups (id: 10)
        MockData.exercises[16], // Walking Lunges (quad focus) (id: 17)
        // Superset A
        MockData.exercises[21], // Standing Mid-Chest Cable Fly (id: 22)
        MockData.exercises[26], // Dumbbell Lateral Raise (id: 27)
        // Superset B
        MockData.exercises[31], // Single Leg Weighted Calf Raise (id: 32)
        MockData.exercises[35], // Standing Face Pulls (id: 36)
      ];
    } else if (widget.dayId == 2) { // Full Body B - Será implementado
      exercises = [
        MockData.exercises[1], // Flat Dumbbell Press
        MockData.exercises[7], // Dumbbell Romanian Deadlift
        MockData.exercises[14], // Lat Pulldown
        MockData.exercises[17], // Heel Elevated Split Squat
        MockData.exercises[22], // Seated Mid-Chest Cable Fly
        MockData.exercises[27], // Cable Lateral Raise
        MockData.exercises[32], // Toes-Elevated Smith Machine Calf Raise
        MockData.exercises[36], // Bent Over Dumbbell Face Pulls
      ];
    } else { // Full Body C - Será implementado
      exercises = [
        MockData.exercises[2], // Flat Machine Chest Press
        MockData.exercises[8], // Hyperextensions (back/hamstring)
        MockData.exercises[10], // (Weighted) Chin-Ups
        MockData.exercises[18], // Bulgarian Split Squat (quad focus)
        MockData.exercises[23], // Pec-Deck Machine Fly
        MockData.exercises[28], // Lying Incline Lateral Raise
        MockData.exercises[33], // Standing Weighted Calf Raise
        MockData.exercises[37], // (Weighted) Prone Arm Circles
      ];
    }
    
    // Carregar dados do último treino para cada exercício
    await _loadLastWorkoutData();
    
    // Cloud sync será implementado em versão futura
    // if (SupabaseService.instance.isLoggedIn) {
    //   await _loadAndMergeCloudData();
    // }
    
    setState(() {
      _exercises = exercises;
      _isLoading = false;
      _workoutStartTime = DateTime.now();
    });
  }

  Future<void> _loadLastWorkoutData() async {
    final prefs = await SharedPreferences.getInstance();
    
    print('🔄 Carregando dados do último treino...');
    
    for (final exercise in _exercises) {
      final cacheKey = 'last_workout_${widget.programId}_${widget.dayId}_${exercise.id}';
      final cachedData = prefs.getStringList(cacheKey);
      
      if (cachedData != null && cachedData.isNotEmpty) {
        print('📊 Cache encontrado para ${exercise.name}: ${cachedData.length} sets');
        
        // Criar lista de sets do cache
        List<WorkoutSet> cachedSets = [];
        
        for (final setString in cachedData) {
          final parts = setString.split(',');
          if (parts.length >= 4) {
            final setNumber = int.tryParse(parts[0]) ?? 1;
            final weight = double.tryParse(parts[1]);
            final reps = int.tryParse(parts[2]);
            
            // Traduzir valores antigos em inglês para português
            String difficulty = parts[3];
            final originalDifficulty = difficulty;
            
            switch (difficulty) {
              case 'Too Easy':
                difficulty = 'Muito Fácil';
                break;
              case 'Easy':
                difficulty = 'Fácil';
                break;
              case 'Perfect':
                difficulty = 'Perfeito';
                break;
              case 'Hard':
                difficulty = 'Difícil';
                break;
              case 'Too Hard':
              case 'Muito Difícil':
                difficulty = 'Difícil';
                break;
              case 'Failed':
                difficulty = 'Falhei';
                break;
            }
            
            if (originalDifficulty != difficulty) {
              print('🔄 Traduzindo dificuldade: $originalDifficulty → $difficulty');
            }
            
            if (weight != null && reps != null) {
              cachedSets.add(WorkoutSet(
                sessionId: 1,
                exerciseId: exercise.id,
                setNumber: setNumber,
                weightKg: weight,
                reps: reps,
                difficulty: difficulty,
              ));
              print('✅ Set carregado: Set $setNumber - ${weight}kg x ${reps}reps ($difficulty)');
            }
          }
        }
        
        if (cachedSets.isNotEmpty) {
          _completedSets[exercise.id] = cachedSets;
        }
      }
    }
  }

  Future<void> _loadAndMergeCloudData() async {
    try {
      print('☁️ Carregando dados da nuvem para mesclar...');
      
      final cloudData = await SupabaseService.instance.loadLastWorkoutData(
        widget.programId, 
        widget.dayId
      );
      
      if (cloudData.isNotEmpty) {
        print('📊 Dados da nuvem encontrados: ${cloudData.length} exercícios');
        
        // Mesclar dados da nuvem com dados locais
        // Prioridade: dados mais recentes (local vs nuvem)
        for (final entry in cloudData.entries) {
          final exerciseId = entry.key;
          final cloudSets = entry.value;
          
          // Se não temos dados locais, usar os da nuvem
          if (!_completedSets.containsKey(exerciseId)) {
            _completedSets[exerciseId] = cloudSets;
            print('📥 Usando dados da nuvem para exercício $exerciseId');
          } else {
            // TODO: Implementar merge inteligente baseado em timestamps
            // Por enquanto, manter dados locais se existirem
            print('🔄 Mantendo dados locais para exercício $exerciseId');
          }
        }
      } else {
        print('📭 Nenhum dado na nuvem encontrado');
      }
    } catch (error) {
      print('❌ Erro ao carregar dados da nuvem: $error');
    }
  }

  Future<void> _saveSetData(int exerciseId, WorkoutSet setData) async {
    final prefs = await SharedPreferences.getInstance();
    
    print('💾 Salvando set: Ex${exerciseId} - Set ${setData.setNumber} - ${setData.weightKg}kg x ${setData.reps}reps (${setData.difficulty})');
    
    // Garantir que dificuldade seja salva em português
    String difficulty = setData.difficulty ?? 'Perfeito';
    
    // Double-check translation - evitar salvar valores em inglês
    switch (difficulty) {
      case 'Too Easy':
        difficulty = 'Muito Fácil';
        break;
      case 'Easy':
        difficulty = 'Fácil';
        break;
      case 'Perfect':
        difficulty = 'Perfeito';
        break;
      case 'Hard':
        difficulty = 'Difícil';
        break;
      case 'Too Hard':
      case 'Muito Difícil':
        difficulty = 'Difícil';
        break;
      case 'Failed':
        difficulty = 'Falhei';
        break;
    }
    
    // Criar nova instância com dificuldade garantida em português
    final correctedSetData = WorkoutSet(
      sessionId: setData.sessionId,
      exerciseId: setData.exerciseId,
      setNumber: setData.setNumber,
      weightKg: setData.weightKg,
      reps: setData.reps,
      difficulty: difficulty,
    );
    
    // Adicionar set aos dados completos
    if (!_completedSets.containsKey(exerciseId)) {
      _completedSets[exerciseId] = [];
    }
    
    final existingSetIndex = _completedSets[exerciseId]!
        .indexWhere((set) => set.setNumber == correctedSetData.setNumber);
    
    if (existingSetIndex != -1) {
      _completedSets[exerciseId]![existingSetIndex] = correctedSetData;
    } else {
      _completedSets[exerciseId]!.add(correctedSetData);
    }
    
    // Salvar no cache local com mais detalhes - sempre em português
    final cacheKey = 'last_workout_${widget.programId}_${widget.dayId}_$exerciseId';
    final setStrings = _completedSets[exerciseId]!
        .map((set) => '${set.setNumber},${set.weightKg},${set.reps},${set.difficulty},${DateTime.now().toIso8601String()}')
        .toList();
    
    await prefs.setStringList(cacheKey, setStrings);
    print('✅ Cache local salvo com ${setStrings.length} sets para exercício $exerciseId');
    
    // Tentar salvar na nuvem se logado (sem bloquear se falhar)
    if (SupabaseService.instance.isLoggedIn) {
      try {
        final cloudSaved = await SupabaseService.instance.saveWorkoutSet(
          correctedSetData, 
          widget.programId, 
          widget.dayId
        ).timeout(const Duration(seconds: 5));
        
        if (cloudSaved) {
          print('☁️ Dados também salvos na nuvem');
        } else {
          print('⚠️ Falha ao salvar na nuvem, mantidos localmente');
        }
      } catch (error) {
        print('❌ Timeout/erro cloud sync: $error - dados mantidos localmente');
      }
    } else {
      print('📱 Modo offline - dados salvos apenas localmente');
    }
    
    // Vibração de feedback
    HapticFeedback.lightImpact();
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _showRestTimer = true;
      _restSeconds = seconds;
    });
  }

  void _onRestTimerComplete() {
    setState(() {
      _showRestTimer = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
      HapticFeedback.selectionClick();
    } else {
      _completeWorkout();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _completeWorkout() async {
    final duration = DateTime.now().difference(_workoutStartTime!);
    
    // Salvar estatísticas do treino
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_workout_date', DateTime.now().toIso8601String());
    await prefs.setInt('last_workout_duration', duration.inSeconds);
    
    setState(() {
      _isWorkoutComplete = true;
    });
    
    // Vibração de sucesso
    HapticFeedback.heavyImpact();
    
    // Notificar completion callback
    widget.onWorkoutCompleted?.call();
    
    // Mostrar dialog de conclusão
    _showCompletionDialog(duration);
  }

  void _showCompletionDialog(Duration duration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Treino Completo!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎉 Parabéns! Você completou o treino ${widget.dayName}'),
            const SizedBox(height: 12),
            Text('⏱️ Duração: ${duration.inMinutes}m ${duration.inSeconds % 60}s'),
            Text('💪 Exercícios: ${_exercises.length}'),
            Text('📊 Sets completados: ${_completedSets.values.fold(0, (sum, sets) => sum + sets.length)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar dialog
              Navigator.of(context).pop(); // Voltar para lista
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Carregando...'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Erro'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Nenhum exercício encontrado para este treino.'),
        ),
      );
    }

    final currentExercise = _exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dayName} (${_currentExerciseIndex + 1}/${_exercises.length})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Indicador de sincronização
          if (SupabaseService.instance.isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'Logado - Sincronizando na nuvem',
                child: Icon(
                  Icons.cloud_done,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'Apenas local - Faça login para sincronizar',
                child: Icon(
                  Icons.cloud_off,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
              ),
            ),
          
          if (_workoutStartTime != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    final elapsed = DateTime.now().difference(_workoutStartTime!);
                    return Text(
                      '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                // Indicador de progresso
                Container(
                  margin: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentExerciseIndex + 1) / _exercises.length,
                      minHeight: 8,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                
                // Widget de tracking do exercício atual
                Expanded(
                  child: ExerciseTrackingWidget(
                    exercise: currentExercise,
                    onSetCompleted: (setData) {
                      _saveSetData(currentExercise.id, setData);
                    },
                    onRestNeeded: (seconds) {
                      _startRestTimer(seconds);
                    },
                    completedSets: _completedSets[currentExercise.id] ?? [],
                  ),
                ),
                
                // Botões de navegação
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentExerciseIndex > 0)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _previousExercise,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Anterior'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              foregroundColor: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      if (_currentExerciseIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentExerciseIndex == _exercises.length - 1 
                              ? _completeWorkout 
                              : _nextExercise,
                          icon: Icon(_currentExerciseIndex == _exercises.length - 1 
                              ? Icons.check_circle 
                              : Icons.arrow_forward),
                          label: Text(_currentExerciseIndex == _exercises.length - 1 
                              ? 'Finalizar' 
                              : 'Próximo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentExerciseIndex == _exercises.length - 1 
                                ? Theme.of(context).colorScheme.secondary 
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Rest Timer Overlay
          if (_showRestTimer)
            RestTimerWidget(
              seconds: _restSeconds,
              onComplete: _onRestTimerComplete,
              onSkip: () => setState(() => _showRestTimer = false),
            ),
        ],
      ),
    );
  }
}