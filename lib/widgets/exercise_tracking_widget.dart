import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/workout_models.dart';
import '../data/mock_data.dart';

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

  @override
  void initState() {
    super.initState();
    _loadVariations();
    _initializeControllers();
    _loadPreviousData();
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

  void _loadPreviousData() {
    // Carregar dados dos sets já completados
    for (final set in widget.completedSets) {
      if (_weightControllers.containsKey(set.setNumber)) {
        _weightControllers[set.setNumber]!.text = set.weightKg?.toString() ?? '';
        _repsControllers[set.setNumber]!.text = set.reps?.toString() ?? '';
        _notesControllers[set.setNumber]!.text = ''; // Adicionar campo de notas depois
        _difficulties[set.setNumber] = set.difficulty ?? 'Perfeito';
      }
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
        const SnackBar(
          content: Text('Por favor, insira peso e repetições válidos'),
          backgroundColor: Colors.red,
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
    // Tempos de descanso baseados no tipo de exercício
    int restSeconds = 90; // Padrão
    
    final exerciseName = widget.exercise.name.toLowerCase();
    if (exerciseName.contains('squat') || 
        exerciseName.contains('deadlift') || 
        exerciseName.contains('row')) {
      restSeconds = 120; // Exercícios compostos = mais descanso
    } else if (exerciseName.contains('curl') || 
               exerciseName.contains('extension') || 
               exerciseName.contains('raise')) {
      restSeconds = 60; // Exercícios de isolamento = menos descanso
    }

    // Mostrar snackbar com timer automático
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Set completo! Timer iniciado: ${restSeconds}s'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 2),
      ),
    );

    // Iniciar timer automaticamente
    widget.onRestNeeded(restSeconds);
  }

  Future<void> _openYouTubeVideo() async {
    if (_selectedVariation?.youtubeUrl != null) {
      final url = Uri.parse(_selectedVariation!.youtubeUrl);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao abrir vídeo: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vídeo não disponível para esta variação')),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (_selectedVariation != null && _selectedVariation!.variationName != "See Tutorial Video") ...[
                            const SizedBox(height: 4),
                            Text(
                              _selectedVariation!.variationName,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Exercício composto - Múltiplos grupos musculares',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Variação do Exercício',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExerciseVariation>(
                    value: _selectedVariation,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _variations.map((variation) => 
                      DropdownMenuItem<ExerciseVariation>(
                        value: variation,
                        child: Text(variation.variationName),
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
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                      : isCurrent
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? Theme.of(context).colorScheme.secondary
                        : isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
                                ? Theme.of(context).colorScheme.secondary
                                : isCurrent
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : Text(
                                    setNumber.toString(),
                                    style: TextStyle(
                                      color: isCurrent ? Colors.white : Theme.of(context).colorScheme.onSurface,
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
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Completo',
                              style: TextStyle(
                                color: Colors.white,
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
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