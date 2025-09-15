import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_models.dart';
import '../data/mock_data.dart';

class SupersetTrackingWidget extends StatefulWidget {
  final Exercise exerciseA;
  final Exercise exerciseB;
  final List<WorkoutSet> completedSetsA;
  final List<WorkoutSet> completedSetsB;
  final Function(WorkoutSet) onSetCompleted;
  final Function(int) onRestNeeded;
  final VoidCallback? onSkipSuperset;

  const SupersetTrackingWidget({
    super.key,
    required this.exerciseA,
    required this.exerciseB,
    required this.completedSetsA,
    required this.completedSetsB,
    required this.onSetCompleted,
    required this.onRestNeeded,
    this.onSkipSuperset,
  });

  @override
  State<SupersetTrackingWidget> createState() => _SupersetTrackingWidgetState();
}

class _SupersetTrackingWidgetState extends State<SupersetTrackingWidget> {
  // Controla qual exercício está ativo no momento
  bool _isExerciseA = true;
  int _currentSetNumber = 1;
  
  // Variações dos exercícios
  List<ExerciseVariation> _variationsA = [];
  List<ExerciseVariation> _variationsB = [];
  ExerciseVariation? _selectedVariationA;
  ExerciseVariation? _selectedVariationB;
  
  // Controllers para ambos os exercícios
  final Map<String, Map<int, TextEditingController>> _weightControllers = {
    'A': {},
    'B': {},
  };
  final Map<String, Map<int, TextEditingController>> _repsControllers = {
    'A': {},
    'B': {},
  };
  final Map<String, Map<int, String>> _difficulties = {
    'A': {},
    'B': {},
  };

  // Cache do último treino para cada exercício
  Map<String, dynamic>? _lastWorkoutDataA;
  Map<String, dynamic>? _lastWorkoutDataB;

  @override
  void initState() {
    super.initState();
    _loadVariations();
    _initializeControllers();
    _determineCurrentPosition();
    _loadLastWorkoutCache();
  }
  
  void _loadVariations() {
    // Carregar variações para exercício A
    _variationsA = MockData.exerciseVariations
        .where((v) => v.exerciseId == widget.exerciseA.id)
        .toList();
    _selectedVariationA = _variationsA.isNotEmpty
        ? _variationsA.firstWhere((v) => v.isPrimary, orElse: () => _variationsA.first)
        : null;

    // Carregar variações para exercício B
    _variationsB = MockData.exerciseVariations
        .where((v) => v.exerciseId == widget.exerciseB.id)
        .toList();
    _selectedVariationB = _variationsB.isNotEmpty
        ? _variationsB.firstWhere((v) => v.isPrimary, orElse: () => _variationsB.first)
        : null;
  }

  // Método auxiliar para obter nome do exercício com variação
  String _getExerciseName(bool isA) {
    if (isA) {
      return _selectedVariationA?.variationName ?? widget.exerciseA.name;
    } else {
      return _selectedVariationB?.variationName ?? widget.exerciseB.name;
    }
  }

  // Método auxiliar para obter nome do exercício atual
  String _getCurrentExerciseName() {
    return _getExerciseName(_isExerciseA);
  }

  void _initializeControllers() {
    for (int i = 1; i <= 3; i++) {
      // Para exercício A
      _weightControllers['A']![i] = TextEditingController();
      _repsControllers['A']![i] = TextEditingController();
      _difficulties['A']![i] = 'Perfeito';
      
      // Para exercício B
      _weightControllers['B']![i] = TextEditingController();
      _repsControllers['B']![i] = TextEditingController();
      _difficulties['B']![i] = 'Perfeito';
    }
    
    // Carregar dados já completados
    _loadCompletedData();
  }

  void _loadCompletedData() {
    // Carregar dados do exercício A
    for (final set in widget.completedSetsA) {
      if (set.setNumber <= 3) {
        _weightControllers['A']![set.setNumber]!.text = set.weightKg?.toString() ?? '';
        _repsControllers['A']![set.setNumber]!.text = set.reps?.toString() ?? '';
        _difficulties['A']![set.setNumber] = set.difficulty ?? 'Perfeito';
      }
    }
    
    // Carregar dados do exercício B
    for (final set in widget.completedSetsB) {
      if (set.setNumber <= 3) {
        _weightControllers['B']![set.setNumber]!.text = set.weightKg?.toString() ?? '';
        _repsControllers['B']![set.setNumber]!.text = set.reps?.toString() ?? '';
        _difficulties['B']![set.setNumber] = set.difficulty ?? 'Perfeito';
      }
    }
  }

  void _determineCurrentPosition() {
    // Determinar onde estamos na sequência do superset
    final setsA = widget.completedSetsA.length;
    final setsB = widget.completedSetsB.length;
    
    // Lógica: A1, B1, A2, B2, A3, B3
    if (setsA == 0 && setsB == 0) {
      _isExerciseA = true;
      _currentSetNumber = 1;
    } else if (setsA == 1 && setsB == 0) {
      _isExerciseA = false; // Próximo é B1
      _currentSetNumber = 1;
    } else if (setsA == 1 && setsB == 1) {
      _isExerciseA = true; // Próximo é A2
      _currentSetNumber = 2;
    } else if (setsA == 2 && setsB == 1) {
      _isExerciseA = false; // Próximo é B2
      _currentSetNumber = 2;
    } else if (setsA == 2 && setsB == 2) {
      _isExerciseA = true; // Próximo é A3
      _currentSetNumber = 3;
    } else if (setsA == 3 && setsB == 2) {
      _isExerciseA = false; // Próximo é B3
      _currentSetNumber = 3;
    } else {
      // Superset completo ou estado inconsistente
      _isExerciseA = true;
      _currentSetNumber = 3;
    }
  }

  void _completeCurrentSet() {
    final exercise = _isExerciseA ? widget.exerciseA : widget.exerciseB;
    final prefix = _isExerciseA ? 'A' : 'B';
    
    final weight = double.tryParse(_weightControllers[prefix]![_currentSetNumber]!.text);
    final reps = int.tryParse(_repsControllers[prefix]![_currentSetNumber]!.text);
    
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
      sessionId: 1,
      exerciseId: exercise.id,
      setNumber: _currentSetNumber,
      weightKg: weight,
      reps: reps,
      difficulty: _difficulties[prefix]![_currentSetNumber],
    );
    
    widget.onSetCompleted(setData);
    HapticFeedback.mediumImpact();
    
    // Determinar próximo exercício na sequência
    _moveToNext();
    
    // Iniciar timer de descanso - sempre 1:30 (90 segundos)
    widget.onRestNeeded(90); // Sempre 90 segundos entre sets
  }

  void _moveToNext() {
    setState(() {
      if (_isExerciseA) {
        // Acabamos de fazer A, próximo é B com mesmo set number
        _isExerciseA = false;
      } else {
        // Acabamos de fazer B, próximo é A com próximo set number
        if (_currentSetNumber < 3) {
          _isExerciseA = true;
          _currentSetNumber++;
        } else {
          // Superset completo
          _showCompletionMessage();
        }
      }
    });
  }

  void _showCompletionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎉 Superset completo! Próximo exercício...'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  Future<void> _openYouTubeVideo(bool isA) async {
    try {
      final variation = isA ? _selectedVariationA : _selectedVariationB;
      final exerciseName = isA ? widget.exerciseA.name : widget.exerciseB.name;
      
      print('🎬 Tentando abrir YouTube para ${isA ? "A" : "B"}: $exerciseName');
      print('🎬 Variação selecionada: ${variation?.variationName}');
      print('🎬 URL: ${variation?.youtubeUrl}');
      
      if (variation?.youtubeUrl != null && variation!.youtubeUrl.isNotEmpty) {
        final uri = Uri.parse(variation.youtubeUrl);
        print('🎬 URI parsed: $uri');
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('✅ YouTube aberto com sucesso');
        } else {
          print('❌ canLaunchUrl retornou false');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Não foi possível abrir: ${variation.youtubeUrl}')),
          );
        }
      } else {
        print('❌ URL não encontrada para $exerciseName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vídeo não disponível para $exerciseName')),
        );
      }
    } catch (e) {
      print('❌ Erro ao abrir YouTube: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir YouTube: $e')),
      );
    }
  }

  bool _isSetCompleted(String exercise, int setNumber) {
    if (exercise == 'A') {
      return widget.completedSetsA.any((s) => s.setNumber == setNumber);
    } else {
      return widget.completedSetsB.any((s) => s.setNumber == setNumber);
    }
  }

  @override
  void dispose() {
    for (final map in _weightControllers.values) {
      for (final controller in map.values) {
        controller.dispose();
      }
    }
    for (final map in _repsControllers.values) {
      for (final controller in map.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _isExerciseA ? widget.exerciseA : widget.exerciseB;
    final otherExercise = _isExerciseA ? widget.exerciseB : widget.exerciseA;
    final prefix = _isExerciseA ? 'A' : 'B';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Superset
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'SUPER SET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.flash_on, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Alternância: ${_getExerciseName(true)} ↔ ${_getExerciseName(false)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Cards dos Exercícios A1 e B1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isExerciseA ? Colors.blue.shade300 : Colors.blue.shade100,
                width: _isExerciseA ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'A1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getExerciseName(true),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.exerciseA.sets} sets x ${widget.exerciseA.repsTarget} reps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openYouTubeVideo(true),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_variationsA.isNotEmpty && _currentSetNumber == 1) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<ExerciseVariation>(
                      value: _selectedVariationA,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      items: _variationsA.map((variation) =>
                        DropdownMenuItem(
                          value: variation,
                          child: Text(
                            variation.variationName,
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      ).toList(),
                      onChanged: (ExerciseVariation? newVariation) {
                        setState(() {
                          _selectedVariationA = newVariation;
                        });
                      },
                    ),
                  ),
                ] else if (_selectedVariationA != null && _selectedVariationA!.variationName != widget.exerciseA.name) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Variação: ${_selectedVariationA!.variationName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Card do Exercício B1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !_isExerciseA ? Colors.green.shade300 : Colors.green.shade100,
                width: !_isExerciseA ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'B1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getExerciseName(false),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.exerciseB.sets} sets x ${widget.exerciseB.repsTarget} reps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openYouTubeVideo(false),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_variationsB.isNotEmpty && _currentSetNumber == 1) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<ExerciseVariation>(
                      value: _selectedVariationB,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      items: _variationsB.map((variation) =>
                        DropdownMenuItem(
                          value: variation,
                          child: Text(
                            variation.variationName,
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      ).toList(),
                      onChanged: (ExerciseVariation? newVariation) {
                        setState(() {
                          _selectedVariationB = newVariation;
                        });
                      },
                    ),
                  ),
                ] else if (_selectedVariationB != null && _selectedVariationB!.variationName != widget.exerciseB.name) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Variação: ${_selectedVariationB!.variationName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Indicador de progresso do Superset
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
                  'Sequência do Super Set:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSequenceIndicator('A1', _isSetCompleted('A', 1)),
                    _buildArrow(),
                    _buildSequenceIndicator('B1', _isSetCompleted('B', 1)),
                    _buildArrow(),
                    _buildSequenceIndicator('A2', _isSetCompleted('A', 2)),
                    _buildArrow(),
                    _buildSequenceIndicator('B2', _isSetCompleted('B', 2)),
                    _buildArrow(),
                    _buildSequenceIndicator('A3', _isSetCompleted('A', 3)),
                    _buildArrow(),
                    _buildSequenceIndicator('B3', _isSetCompleted('B', 3)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Exercício atual
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'AGORA: ${_isExerciseA ? "A" : "B"}$_currentSetNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getCurrentExerciseName(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Set $_currentSetNumber de 3',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                
                const SizedBox(height: 20),
                
                // Input fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightControllers[prefix]![_currentSetNumber],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Peso (kg)',
                          prefixIcon: const Icon(Icons.fitness_center),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _repsControllers[prefix]![_currentSetNumber],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Repetições',
                          prefixIcon: const Icon(Icons.repeat),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Dificuldade
                DropdownButtonFormField<String>(
                  value: _difficulties[prefix]![_currentSetNumber],
                  decoration: InputDecoration(
                    labelText: 'Dificuldade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Muito Fácil', child: Text('😴 Muito Fácil')),
                    DropdownMenuItem(value: 'Fácil', child: Text('🙂 Fácil')),
                    DropdownMenuItem(value: 'Perfeito', child: Text('💪 Perfeito')),
                    DropdownMenuItem(value: 'Difícil', child: Text('😤 Difícil')),
                    DropdownMenuItem(value: 'Muito Difícil', child: Text('🔥 Muito Difícil')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _difficulties[prefix]![_currentSetNumber] = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Botão de completar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _completeCurrentSet,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      _isExerciseA && _currentSetNumber < 3 
                          ? 'Completar e ir para ${otherExercise.name.split(' ').first}...'
                          : !_isExerciseA && _currentSetNumber == 3
                              ? 'Finalizar Super Set'
                              : 'Completar Set',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Preview do próximo
          if (!(_isExerciseA == false && _currentSetNumber == 3))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximo:',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          !_isExerciseA ? '${_getExerciseName(true)} - Set ${_currentSetNumber + 1}' : '${_getExerciseName(false)} - Set $_currentSetNumber',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: 20),
          
          // Botões de navegação rápida
          Row(
            children: [
              // Botão para pular para próximo exercício (fora do superset)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navegar para próximo exercício após o superset
                    widget.onSkipSuperset?.call();
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Pular SuperSet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botão para alternar exercício atual (A ↔ B)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExerciseA = !_isExerciseA;
                    });
                    HapticFeedback.selectionClick();
                  },
                  icon: Icon(_isExerciseA ? Icons.arrow_forward : Icons.arrow_back),
                  label: Text('Ir para ${_isExerciseA ? "B" : "A"}$_currentSetNumber'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceIndicator(String label, bool completed) {
    final isActive = (_isExerciseA && label.startsWith('A') && label.endsWith(_currentSetNumber.toString())) ||
                     (!_isExerciseA && label.startsWith('B') && label.endsWith(_currentSetNumber.toString()));
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: completed 
            ? Colors.green 
            : isActive 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: completed || isActive ? Colors.white : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return Icon(
      Icons.arrow_forward,
      size: 16,
      color: Colors.grey.shade400,
    );
  }

  Future<void> _loadLastWorkoutCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carregar cache do exercício A
      final cacheDataA = prefs.getString('lastWorkout_${widget.exerciseA.id}');
      if (cacheDataA != null) {
        _lastWorkoutDataA = jsonDecode(cacheDataA);
      }

      // Carregar cache do exercício B
      final cacheDataB = prefs.getString('lastWorkout_${widget.exerciseB.id}');
      if (cacheDataB != null) {
        _lastWorkoutDataB = jsonDecode(cacheDataB);
      }

      setState(() {}); // Atualizar UI com dados do cache
    } catch (e) {
      print('⚠️ Erro ao carregar cache do SuperSet: $e');
    }
  }

  Future<void> _saveToCache(WorkoutSet lastSet, bool isExerciseA) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercise = isExerciseA ? widget.exerciseA : widget.exerciseB;
      final selectedVariation = isExerciseA ? _selectedVariationA : _selectedVariationB;
      final cacheKey = 'lastWorkout_${exercise.id}';

      // Dados do último set (set 3) para usar no próximo treino
      final cacheData = {
        'exerciseId': exercise.id,
        'exerciseName': exercise.name,
        'lastSet3': {
          'weight': lastSet.weightKg,
          'reps': lastSet.reps,
          'difficulty': lastSet.difficulty,
          'date': DateTime.now().toIso8601String(),
        },
        'variationId': selectedVariation?.id,
        'variationName': selectedVariation?.variationName,
      };

      await prefs.setString(cacheKey, jsonEncode(cacheData));
      print('✅ Cache salvo para exercício ${exercise.name} (SuperSet)');
    } catch (e) {
      print('⚠️ Erro ao salvar cache do SuperSet: $e');
    }
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'Perfeito':
        return Colors.green;
      case 'Fácil':
        return Colors.blue;
      case 'Difícil':
        return Colors.orange;
      case 'Muito Difícil':
        return Colors.red;
      default:
        return Colors.grey;
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
}