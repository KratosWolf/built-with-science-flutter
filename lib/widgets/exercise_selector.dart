import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/workout_models.dart';
import '../data/user_exercises.dart';
import '../screens/workout_screen.dart';

class ExerciseSelector extends StatefulWidget {
  final int exerciseId;
  final int sets;
  final String repsTarget;
  final bool isSuperset;
  final String? supersetLabel;
  final Function(ExerciseSetData)? onDataChange;

  const ExerciseSelector({
    super.key,
    required this.exerciseId,
    required this.sets,
    required this.repsTarget,
    this.isSuperset = false,
    this.supersetLabel,
    this.onDataChange,
  });

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  Exercise? exercise;
  List<ExerciseVariation> variations = [];
  int selectedVariationIndex = 1;
  List<WorkoutSetData> exerciseSets = [];
  LastSetCache? lastCache;
  ProgressionSuggestion? suggestion;
  Map<int, SetTimer> setTimers = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    exercise = UserExerciseData.getUserExerciseById(widget.exerciseId);
    variations = UserExerciseData.getUserExerciseVariations(widget.exerciseId);
    
    _loadLastWorkoutCache();
  }

  Future<void> _loadLastWorkoutCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'exercise_cache_${widget.exerciseId}';
    final cachedData = prefs.getString(cacheKey);
    
    if (cachedData != null) {
      try {
        final parsedCache = LastSetCache.fromJson(jsonDecode(cachedData));
        setState(() {
          lastCache = parsedCache;
          selectedVariationIndex = parsedCache.variationIndex ?? 1;
          
          // Gerar sugestão baseada no último treino
          if (parsedCache.weightKg != null && parsedCache.reps != null && parsedCache.difficulty != null) {
            suggestion = UserExerciseData.getProgressionSuggestion(
              parsedCache.weightKg!,
              parsedCache.reps!,
              parsedCache.difficulty!,
              widget.repsTarget,
            );
            
            // Pré-preencher com dados sugeridos
            exerciseSets = List.generate(widget.sets, (index) => 
              WorkoutSetData(
                setNumber: index + 1,
                weightKg: suggestion?.suggested.weight ?? parsedCache.weightKg,
                reps: suggestion?.suggested.reps ?? parsedCache.reps,
              )
            );
          }
        });
      } catch (e) {
        debugPrint('Error parsing exercise cache: $e');
      }
    }
    
    // Inicializar sets vazios se não há cache
    if (exerciseSets.isEmpty) {
      setState(() {
        exerciseSets = List.generate(widget.sets, (index) => 
          WorkoutSetData(setNumber: index + 1)
        );
      });
    }
  }

  Future<void> _saveToCache(WorkoutSetData setData) async {
    if (setData.weightKg != null && setData.reps != null && setData.difficulty != null) {
      // Obter sets completos com dados válidos
      final completedSets = exerciseSets
          .where((set) => set.weightKg != null && set.reps != null && set.difficulty != null)
          .map((set) => CachedSet(
                setNumber: set.setNumber,
                weight: set.weightKg!,
                reps: set.reps!,
                difficulty: set.difficulty!,
              ))
          .toList();

      final cacheData = LastSetCache(
        userId: 'user_1', // TODO: Obter do contexto de autenticação
        exerciseId: widget.exerciseId,
        variationIndex: selectedVariationIndex,
        weightKg: setData.weightKg,
        reps: setData.reps,
        difficulty: setData.difficulty,
        sets: completedSets,
      );
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'exercise_cache_${widget.exerciseId}';
      await prefs.setString(cacheKey, jsonEncode(cacheData.toJson()));
    }
  }

  void _startSetTimer(int setNumber) {
    setState(() {
      setTimers[setNumber] = SetTimer(
        startTime: DateTime.now(),
        isActive: true,
      );
    });
  }

  void _stopSetTimer(int setNumber) {
    if (setTimers.containsKey(setNumber)) {
      setState(() {
        setTimers[setNumber] = setTimers[setNumber]!.copyWith(isActive: false);
      });
    }
  }

  void _updateSetData(int setIndex, String field, dynamic value) {
    final newSets = List<WorkoutSetData>.from(exerciseSets);
    final currentSet = newSets[setIndex];
    
    final updatedSet = WorkoutSetData(
      setNumber: currentSet.setNumber,
      weightKg: field == 'weight' ? value : currentSet.weightKg,
      reps: field == 'reps' ? value : currentSet.reps,
      difficulty: field == 'difficulty' ? value : currentSet.difficulty,
    );
    
    newSets[setIndex] = updatedSet;
    setState(() {
      exerciseSets = newSets;
    });
    
    // Iniciar cronômetro quando dificuldade for selecionada
    if (field == 'difficulty' && value != null) {
      final setNumber = updatedSet.setNumber;
      _startSetTimer(setNumber);
      
      // Parar timer anterior se existir
      final previousSetNumber = setNumber - 1;
      if (previousSetNumber > 0) {
        _stopSetTimer(previousSetNumber);
      }
    }
    
    // Salvar no cache se o set está completo
    if (field == 'difficulty' && updatedSet.weightKg != null && updatedSet.reps != null) {
      _saveToCache(updatedSet);
    }
    
    // Notificar componente pai
    if (widget.onDataChange != null) {
      widget.onDataChange!(ExerciseSetData(
        exerciseId: widget.exerciseId,
        selectedVariationIndex: selectedVariationIndex,
        videoUrl: UserExerciseData.getExerciseVideoUrl(widget.exerciseId, variationIndex: selectedVariationIndex),
        sets: exerciseSets,
      ));
    }
  }

  CachedSet? _getPreviousSetDifficulty(int setNumber) {
    if (lastCache?.sets.isEmpty ?? true) return null;
    
    try {
      return lastCache!.sets.firstWhere((set) => set.setNumber == setNumber);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exercise == null || variations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Exercício não encontrado (ID: ${widget.exerciseId})',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final currentVideoUrl = UserExerciseData.getExerciseVideoUrl(widget.exerciseId, variationIndex: selectedVariationIndex);
    final selectedVariation = variations.firstWhere((v) => v.variationIndex == selectedVariationIndex);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isSuperset ? BorderSide(color: Colors.blue.shade500, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do Exercício
            Row(
              children: [
                if (widget.isSuperset && widget.supersetLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.supersetLabel!,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (widget.isSuperset) const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.sets} sets • ${widget.repsTarget} reps',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Dropdown de Variações
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Variação do Exercício:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedVariationIndex,
                      isExpanded: true,
                      items: variations.map((variation) {
                        return DropdownMenuItem<int>(
                          value: variation.variationIndex,
                          child: Row(
                            children: [
                              if (variation.isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PRINCIPAL',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              if (variation.isPrimary) const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  variation.variationName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newVariationIndex) {
                        if (newVariationIndex != null) {
                          setState(() {
                            selectedVariationIndex = newVariationIndex;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // URL do Vídeo
            if (currentVideoUrl.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Tutorial:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        selectedVariation.variationName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Abrir URL do vídeo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Abrir: $currentVideoUrl')),
                        );
                      },
                      icon: const Icon(Icons.open_in_new, size: 12),
                      label: const Text('Abrir', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Sugestão de Progressão
            if (suggestion != null && lastCache != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'SUGESTÃO',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Baseado no último treino:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            suggestion!.reason,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Último: ${lastCache!.weightKg}kg × ${lastCache!.reps} reps (${lastCache!.difficulty})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Sets
            Column(
              children: exerciseSets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;
                final previousSetData = _getPreviousSetDifficulty(set.setNumber);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Header do Set com tag anterior e timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Set ${set.setNumber}:',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _SetTimer(setNumber: set.setNumber, setTimers: setTimers),
                            ],
                          ),
                          if (previousSetData != null)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border.all(color: Colors.blue.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Last workout',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                  Text(
                                    '${previousSetData.weight}kg × ${previousSetData.reps} reps',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      UserExerciseData.difficultyLabels[previousSetData.difficulty] ?? previousSetData.difficulty,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.blue.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Inputs do Set
                      Row(
                        children: [
                          // Peso
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Peso (kg)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                    text: set.weightKg?.toString() ?? '',
                                  ),
                                  onChanged: (value) {
                                    final weight = double.tryParse(value);
                                    _updateSetData(index, 'weight', weight);
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Reps
                          Expanded(
                            flex: 1,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                text: set.reps?.toString() ?? '',
                              ),
                              onChanged: (value) {
                                final reps = int.tryParse(value);
                                _updateSetData(index, 'reps', reps);
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Dificuldade
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: set.difficulty,
                                  isExpanded: true,
                                  hint: const Text(
                                    'Dificuldade',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  items: UserExerciseData.difficultyLabels.entries.map((entry) {
                                    return DropdownMenuItem<String>(
                                      value: entry.key,
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    _updateSetData(index, 'difficulty', value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para exibir timer em tempo real
class _SetTimer extends StatefulWidget {
  final int setNumber;
  final Map<int, SetTimer> setTimers;

  const _SetTimer({
    required this.setNumber,
    required this.setTimers,
  });

  @override
  State<_SetTimer> createState() => _SetTimerState();
}

class _SetTimerState extends State<_SetTimer> {
  Timer? _timer;
  int currentTime = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final setTimer = widget.setTimers[widget.setNumber];
      if (setTimer?.isActive ?? false) {
        final elapsed = DateTime.now().difference(setTimer!.startTime).inSeconds;
        if (mounted) {
          setState(() {
            currentTime = elapsed;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setTimer = widget.setTimers[widget.setNumber];
    
    if (!(setTimer?.isActive ?? false)) return const SizedBox.shrink();

    final minutes = currentTime ~/ 60;
    final seconds = currentTime % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 2),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Classe para controlar timer de set
class SetTimer {
  final DateTime startTime;
  final bool isActive;

  SetTimer({
    required this.startTime,
    required this.isActive,
  });

  SetTimer copyWith({
    DateTime? startTime,
    bool? isActive,
  }) {
    return SetTimer(
      startTime: startTime ?? this.startTime,
      isActive: isActive ?? this.isActive,
    );
  }
}