import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_models.dart';
import '../data/mock_data.dart';
import '../widgets/exercise_tracking_widget.dart';
import '../widgets/superset_tracking_widget.dart';
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
    // IMPORTANTE: exercises array índices começam em 0, mas IDs começam em 1
    // Então exercício com ID 1 está no índice 0, ID 7 está no índice 6, etc.
    if (widget.dayId == 1) { // Full Body A - 8 exercícios exatos do SQL
      exercises = [
        MockData.exercises[0], // Barbell Bench Press (id: 1, index: 0)
        MockData.exercises[6], // Barbell Romanian Deadlift (id: 7, index: 6)  
        MockData.exercises[9], // (Weighted) Pull-Ups (id: 10, index: 9)
        MockData.exercises[16], // Walking Lunges (quad focus) (id: 17, index: 16)
        // Superset A
        MockData.exercises[21], // Standing Mid-Chest Cable Fly (id: 22, index: 21)
        MockData.exercises[26], // Dumbbell Lateral Raise (id: 27, index: 26)
        // Superset B
        MockData.exercises[31], // Single Leg Weighted Calf Raise (id: 32, index: 31)
        MockData.exercises[35], // Standing Face Pulls (id: 36, index: 35)
      ];
    } else if (widget.dayId == 2) { // Full Body B - 8 exercícios corretos do CSV
      exercises = [
        MockData.exercises[39], // Barbell Back Squat (id: 40, index: 39)
        MockData.exercises[40], // Standing Barbell Overhead Press (id: 41, index: 40)
        MockData.exercises[41], // Seated Leg Curls (id: 42, index: 41)
        MockData.exercises[42], // DB Chest Supported Row (id: 43, index: 42) - SUPERSET A1
        MockData.exercises[4], // Banded Push-Ups (id: 5, index: 4) - SUPERSET A2
        MockData.exercises[43], // Incline DB Overhead Extensions (id: 44, index: 43)
        MockData.exercises[44], // Seated Weighted Calf Raise (id: 45, index: 44) - SUPERSET B1
        MockData.exercises[45], // Side Plank (id: 46, index: 45) - SUPERSET B2
      ];
    } else { // Full Body C - 8 exercícios corretos do CSV
      exercises = [
        MockData.exercises[46], // Barbell Deadlift (id: 47, index: 46)
        MockData.exercises[47], // Low Incline Dumbbell Press (id: 48, index: 47) - SUPERSET A1
        MockData.exercises[42], // DB Chest Supported Row (id: 43, index: 42) - SUPERSET A2
        MockData.exercises[48], // Seated Leg Extensions (id: 49, index: 48)
        MockData.exercises[27], // Cable Lateral Raise (id: 28, index: 27)
        MockData.exercises[49], // Seated Dumbbell Curls (id: 50, index: 49)
        MockData.exercises[35], // Standing Face Pulls (id: 36, index: 35) - SUPERSET B1
        MockData.exercises[45], // Side Plank (id: 46, index: 45) - SUPERSET B2
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
        // Lógica especial para Super Sets baseada no treino
        if (widget.dayId == 1) { // Full Body A
          if (_currentExerciseIndex == 4) {
            _currentExerciseIndex = 6; // Pular para Superset B
          } else if (_currentExerciseIndex == 6) {
            _completeWorkout(); // Fim do treino
            return;
          } else if (_currentExerciseIndex == 5 || _currentExerciseIndex == 7) {
            // Voltar para início do superset respectivo
            if (_currentExerciseIndex == 5) _currentExerciseIndex = 4;
            else _currentExerciseIndex = 6;
          } else {
            _currentExerciseIndex++; // Navegação normal
          }
        } else if (widget.dayId == 2) { // Full Body B
          if (_currentExerciseIndex == 3) {
            _currentExerciseIndex = 5; // Pular para exercício 6 (após Superset A)
          } else if (_currentExerciseIndex == 6) {
            _completeWorkout(); // Fim do treino
            return;
          } else if (_currentExerciseIndex == 4 || _currentExerciseIndex == 7) {
            // Voltar para início do superset respectivo
            if (_currentExerciseIndex == 4) _currentExerciseIndex = 3;
            else _currentExerciseIndex = 6;
          } else {
            _currentExerciseIndex++; // Navegação normal
          }
        } else { // Full Body C
          if (_currentExerciseIndex == 1) {
            _currentExerciseIndex = 3; // Pular para exercício 4 (após Superset A)
          } else if (_currentExerciseIndex == 6) {
            _completeWorkout(); // Fim do treino
            return;
          } else if (_currentExerciseIndex == 2 || _currentExerciseIndex == 7) {
            // Voltar para início do superset respectivo
            if (_currentExerciseIndex == 2) _currentExerciseIndex = 1;
            else _currentExerciseIndex = 6;
          } else {
            _currentExerciseIndex++; // Navegação normal
          }
        }
      });
      HapticFeedback.selectionClick();
    } else {
      _completeWorkout();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        // Lógica especial para Super Sets
        if (_currentExerciseIndex == 6) {
          // Voltando do Superset B para o Superset A
          _currentExerciseIndex = 4;
        } else if (_currentExerciseIndex == 5 || _currentExerciseIndex == 7) {
          // Nunca devemos estar diretamente aqui, mas se estivermos:
          if (_currentExerciseIndex == 5) {
            _currentExerciseIndex = 4; // Vai para Superset A
          } else {
            _currentExerciseIndex = 6; // Vai para Superset B
          }
        } else {
          // Navegação normal
          _currentExerciseIndex--;
        }
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

  void _showExerciseSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecione um exercício',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    final completedSets = _completedSets[exercise.id]?.length ?? 0;
                    final isSuperset = index > 3; // Exercícios 5-8 são supersets
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: index == _currentExerciseIndex 
                            ? Theme.of(context).colorScheme.primary
                            : completedSets > 0 
                                ? Colors.green 
                                : Colors.grey.shade300,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index == _currentExerciseIndex || completedSets > 0 
                                ? Colors.white 
                                : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        exercise.name,
                        style: TextStyle(
                          fontWeight: index == _currentExerciseIndex 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          if (isSuperset) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'SUPER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            completedSets > 0 
                                ? '✅ $completedSets/3 sets' 
                                : 'Não iniciado',
                            style: TextStyle(
                              color: completedSets > 0 ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: index == _currentExerciseIndex 
                          ? Icon(Icons.radio_button_checked, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _currentExerciseIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isInSuperset(int exerciseIndex) {
    if (widget.dayId == 1) { // Full Body A
      // Supersets são exercícios 5-6 (índices 4-5) e 7-8 (índices 6-7)
      return (exerciseIndex >= 4 && exerciseIndex <= 7);
    } else if (widget.dayId == 2) { // Full Body B
      // SUPERSET A: índices 3-4, SUPERSET B: índices 6-7
      return (exerciseIndex >= 3 && exerciseIndex <= 4) || (exerciseIndex >= 6 && exerciseIndex <= 7);
    } else { // Full Body C
      // SUPERSET A: índices 1-2, SUPERSET B: índices 6-7
      return (exerciseIndex >= 1 && exerciseIndex <= 2) || (exerciseIndex >= 6 && exerciseIndex <= 7);
    }
  }
  
  Map<String, dynamic>? _getSupersetPair(int exerciseIndex) {
    if (!_isInSuperset(exerciseIndex)) return null;
    
    if (widget.dayId == 1) { // Full Body A
      if (exerciseIndex == 4 || exerciseIndex == 5) {
        // Superset A: exercícios 4 e 5
        return {
          'exerciseA': _exercises[4],
          'exerciseB': _exercises[5],
          'indexA': 4,
          'indexB': 5,
          'name': 'Superset A',
        };
      } else if (exerciseIndex == 6 || exerciseIndex == 7) {
        // Superset B: exercícios 6 e 7
        return {
          'exerciseA': _exercises[6],
          'exerciseB': _exercises[7],
          'indexA': 6,
          'indexB': 7,
          'name': 'Superset B',
        };
      }
    } else if (widget.dayId == 2) { // Full Body B
      if (exerciseIndex == 3 || exerciseIndex == 4) {
        // Superset A: exercícios 3 e 4
        return {
          'exerciseA': _exercises[3], // DB Chest Supported Row
          'exerciseB': _exercises[4], // Banded Push-Ups
          'indexA': 3,
          'indexB': 4,
          'name': 'Superset A',
        };
      } else if (exerciseIndex == 6 || exerciseIndex == 7) {
        // Superset B: exercícios 6 e 7
        return {
          'exerciseA': _exercises[6], // Seated Weighted Calf Raise
          'exerciseB': _exercises[7], // Side Plank
          'indexA': 6,
          'indexB': 7,
          'name': 'Superset B',
        };
      }
    } else { // Full Body C
      if (exerciseIndex == 1 || exerciseIndex == 2) {
        // Superset A: exercícios 1 e 2
        return {
          'exerciseA': _exercises[1], // Low Incline Dumbbell Press
          'exerciseB': _exercises[2], // DB Chest Supported Row
          'indexA': 1,
          'indexB': 2,
          'name': 'Superset A',
        };
      } else if (exerciseIndex == 6 || exerciseIndex == 7) {
        // Superset B: exercícios 6 e 7
        return {
          'exerciseA': _exercises[6], // Standing Face Pulls
          'exerciseB': _exercises[7], // Side Plank
          'indexA': 6,
          'indexB': 7,
          'name': 'Superset B',
        };
      }
    }
    return null;
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
  final isInSuperset = _isInSuperset(_currentExerciseIndex);
  final supersetPair = _getSupersetPair(_currentExerciseIndex);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Mostrar menu de seleção de exercícios
            _showExerciseSelector();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isInSuperset && supersetPair != null 
                  ? '${widget.dayName} - ${supersetPair['name']}'
                  : '${widget.dayName} (${_currentExerciseIndex + 1}/${_exercises.length})'),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        ),
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
                  child: isInSuperset && supersetPair != null
                      ? SupersetTrackingWidget(
                          exerciseA: supersetPair['exerciseA'],
                          exerciseB: supersetPair['exerciseB'],
                          completedSetsA: _completedSets[supersetPair['exerciseA'].id] ?? [],
                          completedSetsB: _completedSets[supersetPair['exerciseB'].id] ?? [],
                          onSetCompleted: (setData) {
                            _saveSetData(setData.exerciseId, setData);
                          },
                          onRestNeeded: (seconds) {
                            _startRestTimer(seconds);
                          },
                          onSkipSuperset: () {
                            // Pular para próximo exercício após o superset
                            _nextExercise();
                          },
                        )
                      : ExerciseTrackingWidget(
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