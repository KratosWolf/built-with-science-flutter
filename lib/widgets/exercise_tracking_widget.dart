import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_models.dart';
import '../data/mock_data.dart';
import '../config/theme.dart';

class ExerciseTrackingWidget extends StatefulWidget {
  final Exercise exercise;
  final List<WorkoutSet> completedSets;
  final Function(WorkoutSet) onSetCompleted;
  final Function(int) onRestNeeded;

  const ExerciseTrackingWidget({
    super.key,
    required this.exercise,
    required this.completedSets,
    required this.onSetCompleted,
    required this.onRestNeeded,
  });

  @override
  State<ExerciseTrackingWidget> createState() => _ExerciseTrackingWidgetState();
}

class _ExerciseTrackingWidgetState extends State<ExerciseTrackingWidget> {
  final Map<int, TextEditingController> _weightControllers = {};
  final Map<int, TextEditingController> _repsControllers = {};
  final Map<int, TextEditingController> _notesControllers = {};
  final Map<int, String> _difficulties = {};
  
  int _currentSet = 1;
  final int _maxSets = 3; // 3 sets por exercício
  List<ExerciseVariation> _variations = [];
  ExerciseVariation? _selectedVariation;

  // Cache do último treino
  Map<String, dynamic>? _lastWorkoutData;

  @override
  void initState() {
    super.initState();
    _loadVariations();
    _initializeControllers();
    _loadPreviousData();
  }

  @override
  void didUpdateWidget(ExerciseTrackingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recarregar variações quando o exercício mudar
    if (oldWidget.exercise.id != widget.exercise.id) {
      _loadVariations();
      _initializeControllers();
      _loadPreviousData();
    }
  }
  
  void _loadVariations() {
    // Carregar variações do exercício atual
    _variations = MockData.exerciseVariations
        .where((v) => v.exerciseId == widget.exercise.id)
        .toList();
    
    // Selecionar primeira variação como padrão
    if (_variations.isNotEmpty) {
      _selectedVariation = _variations.first;
    }
  }

  void _initializeControllers() {
    for (int i = 1; i <= _maxSets; i++) {
      _weightControllers[i] = TextEditingController();
      _repsControllers[i] = TextEditingController();
      _notesControllers[i] = TextEditingController();
      _difficulties[i] = 'Perfeito';
    }
  }

  void _loadPreviousData() async {
    // Carregar dados dos sets já completados (sessão atual)
    for (final set in widget.completedSets) {
      if (_weightControllers.containsKey(set.setNumber)) {
        _weightControllers[set.setNumber]!.text = set.weightKg?.toString() ?? '';
        _repsControllers[set.setNumber]!.text = set.reps?.toString() ?? '';
        _notesControllers[set.setNumber]!.text = '';
        _difficulties[set.setNumber] = set.difficulty ?? 'Perfeito';
      }
    }

    // Carregar cache do último treino para pré-preenchimento
    await _loadLastWorkoutCache();
  }

  Future<void> _loadLastWorkoutCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'lastWorkout_${widget.exercise.id}';
      final cacheData = prefs.getString(cacheKey);

      if (cacheData != null) {
        _lastWorkoutData = jsonDecode(cacheData);
        _prefillFromCache();
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar cache: $e');
    }
  }

  void _prefillFromCache() {
    if (_lastWorkoutData == null) return;

    // 1. Restaurar variação selecionada
    if (_lastWorkoutData!['variationId'] != null) {
      final savedVariationId = _lastWorkoutData!['variationId'];
      _selectedVariation = _variations.firstWhere(
        (v) => v.id == savedVariationId,
        orElse: () => _variations.first,
      );
      debugPrint('🔄 Variação restaurada: ${_selectedVariation?.variationName}');
    }

    // 2. Pré-preencher dados do último treino (peso, reps, dificuldade)
    if (_lastWorkoutData!['lastSet3'] != null) {
      final lastSet3 = _lastWorkoutData!['lastSet3'];

      for (int setNumber = 1; setNumber <= _maxSets; setNumber++) {
        if (!_isSetCompleted(setNumber)) {
          _weightControllers[setNumber]!.text = lastSet3['weight']?.toString() ?? '';
          _repsControllers[setNumber]!.text = lastSet3['reps']?.toString() ?? '';
          _difficulties[setNumber] = lastSet3['difficulty'] ?? 'Perfeito';
          _notesControllers[setNumber]!.text = lastSet3['notes']?.toString() ?? '';
        }
      }
      debugPrint('🔄 Dados restaurados - Peso: ${lastSet3['weight']}, Reps: ${lastSet3['reps']}, Dificuldade: ${lastSet3['difficulty']}');
    }

    setState(() {}); // Atualizar UI
  }

  Future<void> _saveToCache(WorkoutSet lastSet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'lastWorkout_${widget.exercise.id}';

      // Dados do último set (set 3) para usar no próximo treino
      final cacheData = {
        'exerciseId': widget.exercise.id,
        'exerciseName': widget.exercise.name,
        'lastSet3': {
          'weight': lastSet.weightKg,
          'reps': lastSet.reps,
          'difficulty': lastSet.difficulty,
          'notes': _notesControllers[3]?.text ?? '',
          'date': DateTime.now().toIso8601String(),
        },
        'variationId': _selectedVariation?.id,
        'variationName': _selectedVariation?.variationName,
      };

      await prefs.setString(cacheKey, jsonEncode(cacheData));
      debugPrint('✅ Cache salvo para exercício ${widget.exercise.name}');
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar cache: $e');
    }
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'Perfeito':
        return AppTheme.success;
      case 'Fácil':
      case 'Muito Fácil':
        return AppTheme.info;
      case 'Difícil':
      case 'Muito Difícil':
        return AppTheme.error;
      case 'Falhei':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getDifficultyEmoji(String? difficulty) {
    switch (difficulty) {
      case 'Perfeito':
        return '😊';
      case 'Fácil':
        return '😌';
      case 'Difícil':
        return '😤';
      case 'Muito Difícil':
        return '🔥';
      default:
        return '🤔';
    }
  }

  @override
  void dispose() {
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    for (final controller in _repsControllers.values) {
      controller.dispose();
    }
    for (final controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isSetCompleted(int setNumber) {
    return widget.completedSets.any((set) => set.setNumber == setNumber);
  }

  void _completeSet(int setNumber) {
    final weight = double.tryParse(_weightControllers[setNumber]!.text);
    final reps = int.tryParse(_repsControllers[setNumber]!.text);
    
    if (weight == null || reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, insira peso e repetições válidos'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    final setData = WorkoutSet(
      sessionId: 1, // Temporary sessionId
      exerciseId: widget.exercise.id,
      setNumber: setNumber,
      weightKg: weight,
      reps: reps,
      difficulty: _difficulties[setNumber],
    );

    widget.onSetCompleted(setData);

    // Salvar no cache se for o set 3 (último set)
    if (setNumber == 3) {
      _saveToCache(setData);
    }

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Sempre iniciar timer após completar um set
    _startAutoRest();
    
    // Auto-avançar para próximo set se disponível
    if (setNumber < _maxSets) {
      setState(() {
        _currentSet = setNumber + 1;
      });
    }
  }

  void _startAutoRest() {
    // Tempo de descanso fixo de 1:30 (90 segundos) para todos os exercícios
    int restSeconds = 90;

    // Mostrar snackbar com timer automático
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Set completo! Timer iniciado: ${restSeconds}s'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );

    // Iniciar timer automaticamente
    widget.onRestNeeded(restSeconds);
  }

  String _getExerciseDescription(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    if (name.contains('bench') || name.contains('chest press') || name.contains('fly')) {
      return 'Exercício de peito - Foco em peitoral maior';
    } else if (name.contains('deadlift') || name.contains('hyperextension')) {
      return 'Exercício composto - Posterior/Hamstrings';
    } else if (name.contains('pull-up') || name.contains('chin-up') || name.contains('pulldown')) {
      return 'Exercício de costas - Múltiplos músculos';
    } else if (name.contains('lunge') || name.contains('squat') || name.contains('step')) {
      return 'Exercício de pernas - Foco em quadríceps';
    } else if (name.contains('lateral raise') || name.contains('upright row')) {
      return 'Exercício de ombros - Deltoides laterais';
    } else if (name.contains('calf')) {
      return 'Exercício de panturrilha - Gastrocnêmio/Sóleo';
    } else if (name.contains('face pull') || name.contains('arm circle')) {
      return 'Exercício de deltoides posteriores';
    } else {
      return 'Exercício de força e hipertrofia';
    }
  }

  Future<void> _openYouTubeVideo() async {
    if (_selectedVariation?.youtubeUrl != null) {
      final url = Uri.parse(_selectedVariation!.youtubeUrl);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao abrir vídeo: $e'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vídeo não disponível para esta variação'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do exercício
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.exercise.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                          if (_selectedVariation != null && _selectedVariation!.variationName != "See Tutorial Video") ...[
                            const SizedBox(height: 4),
                            Text(
                              _selectedVariation!.variationName,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Label com repetições sugeridas
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3), width: 1),
                            ),
                            child: Text(
                              '📊 Sugestão: ${widget.exercise.sets} sets x ${widget.exercise.repsTarget} reps',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryOrange,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getExerciseDescription(widget.exercise.name),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: _openYouTubeVideo,
                      icon: const Icon(Icons.play_circle_fill),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Seletor de variações
          if (_variations.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.borderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Variação do Exercício',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExerciseVariation>(
                    value: _selectedVariation,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _variations.map((variation) =>
                      DropdownMenuItem<ExerciseVariation>(
                        value: variation,
                        child: Text(
                          variation.variationName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    ).toList(),
                    onChanged: (newVariation) {
                      setState(() {
                        _selectedVariation = newVariation;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Sets tracking
          Text(
            'Sets',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de sets
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _maxSets,
            itemBuilder: (context, index) {
              final setNumber = index + 1;
              final isCompleted = _isSetCompleted(setNumber);
              final isCurrent = setNumber == _currentSet;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.success.withOpacity(0.1)
                      : isCurrent
                          ? AppTheme.primaryOrange.withOpacity(0.1)
                          : AppTheme.backgroundCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.success
                        : isCurrent
                            ? AppTheme.primaryOrange
                            : AppTheme.borderColor,
                    width: isCompleted || isCurrent ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.success
                                : isCurrent
                                    ? AppTheme.primaryOrange
                                    : AppTheme.backgroundElevated,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, color: AppTheme.textPrimary, size: 18)
                                : Text(
                                    setNumber.toString(),
                                    style: TextStyle(
                                      color: isCurrent ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Set $setNumber',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        // Tag de avaliação anterior
                        if (_lastWorkoutData != null && _lastWorkoutData!['lastSet3'] != null && !isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(_lastWorkoutData!['lastSet3']['difficulty']).withOpacity(0.1),
                              border: Border.all(
                                color: _getDifficultyColor(_lastWorkoutData!['lastSet3']['difficulty']),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Anterior: ${_getDifficultyEmoji(_lastWorkoutData!['lastSet3']['difficulty'])} ${_lastWorkoutData!['lastSet3']['difficulty']}',
                              style: TextStyle(
                                color: _getDifficultyColor(_lastWorkoutData!['lastSet3']['difficulty']),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Completo',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Input fields
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightControllers[setNumber],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            enabled: !isCompleted,
                            decoration: InputDecoration(
                              labelText: 'Peso (kg)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _repsControllers[setNumber],
                            keyboardType: TextInputType.number,
                            enabled: !isCompleted,
                            decoration: InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Difficulty dropdown
                    DropdownButtonFormField<String>(
                      value: _difficulties[setNumber],
                      decoration: InputDecoration(
                        labelText: 'Dificuldade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Muito Fácil', child: Text('Muito Fácil - +3 reps')),
                        DropdownMenuItem(value: 'Fácil', child: Text('Fácil - +2 reps')),
                        DropdownMenuItem(value: 'Perfeito', child: Text('Perfeito - +1 rep')),
                        DropdownMenuItem(value: 'Difícil', child: Text('Difícil - Limite')),
                        DropdownMenuItem(value: 'Falhei', child: Text('Falhei - Não acabei')),
                      ],
                      onChanged: isCompleted ? null : (value) {
                        setState(() {
                          _difficulties[setNumber] = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Campo de comentários
                    TextField(
                      controller: _notesControllers[setNumber],
                      enabled: !isCompleted,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Comentários (opcional)',
                        hintText: 'Ex: Muito pesado, forma ruim...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    
                    if (!isCompleted) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _completeSet(setNumber),
                          icon: const Icon(Icons.check),
                          label: const Text('Completar Set'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}