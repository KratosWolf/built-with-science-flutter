import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_models.dart';
import '../data/mock_data.dart';
import '../config/theme.dart';

class SupersetTrackingWidget extends StatefulWidget {
  final Exercise exerciseA;
  final Exercise exerciseB;
  final List<WorkoutSet> completedSetsA;
  final List<WorkoutSet> completedSetsB;
  final Function(WorkoutSet) onSetCompleted;
  final Function(int) onRestNeeded;
  final VoidCallback? onSkipSuperset;
  final VoidCallback? onSupersetCompleted;

  const SupersetTrackingWidget({
    super.key,
    required this.exerciseA,
    required this.exerciseB,
    required this.completedSetsA,
    required this.completedSetsB,
    required this.onSetCompleted,
    required this.onRestNeeded,
    this.onSkipSuperset,
    this.onSupersetCompleted,
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
  final Map<String, Map<int, TextEditingController>> _notesControllers = {
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

  // Método auxiliar para obter label do set atual (A1 ou A2)
  String _getCurrentSetLabel(bool isA) {
    // No padrão A1-A2-A1-A2-A1-A2:
    // exerciseA sempre é A1, exerciseB sempre é A2
    if (isA) {
      return 'A1'; // Exercício A sempre é A1
    } else {
      return 'A2'; // Exercício B sempre é A2
    }
  }

  void _initializeControllers() {
    for (int i = 1; i <= 3; i++) {
      // Para exercício A
      _weightControllers['A']![i] = TextEditingController();
      _repsControllers['A']![i] = TextEditingController();
      _notesControllers['A']![i] = TextEditingController();
      _difficulties['A']![i] = 'Perfeito';

      // Para exercício B
      _weightControllers['B']![i] = TextEditingController();
      _repsControllers['B']![i] = TextEditingController();
      _notesControllers['B']![i] = TextEditingController();
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

  @override
  void didUpdateWidget(SupersetTrackingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recarregar dados dos controllers quando completedSets mudam
    if (oldWidget.completedSetsA != widget.completedSetsA ||
        oldWidget.completedSetsB != widget.completedSetsB) {
      _loadCompletedData();
      debugPrint('🔄 SuperSet: dados recarregados após mudança de props');
    }
  }

  void _determineCurrentPosition() {
    // Determinar onde estamos na sequência do superset
    final setsA = widget.completedSetsA.length;
    final setsB = widget.completedSetsB.length;

    // Lógica: A1, A2, A1, A2, A1, A2 (alternando entre exercícios A e B)
    if (setsA == 0 && setsB == 0) {
      _isExerciseA = true; // Começar com A1
      _currentSetNumber = 1;
    } else if (setsA == 1 && setsB == 0) {
      _isExerciseA = false; // Próximo é A2 (que é exerciseB)
      _currentSetNumber = 1;
    } else if (setsA == 1 && setsB == 1) {
      _isExerciseA = true; // Próximo é A1 novamente
      _currentSetNumber = 2;
    } else if (setsA == 2 && setsB == 1) {
      _isExerciseA = false; // Próximo é A2 novamente
      _currentSetNumber = 2;
    } else if (setsA == 2 && setsB == 2) {
      _isExerciseA = true; // Próximo é A1 final
      _currentSetNumber = 3;
    } else if (setsA == 3 && setsB == 2) {
      _isExerciseA = false; // Próximo é A2 final
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
      sessionId: 1,
      exerciseId: exercise.id,
      setNumber: _currentSetNumber,
      weightKg: weight,
      reps: reps,
      difficulty: _difficulties[prefix]![_currentSetNumber],
    );

    widget.onSetCompleted(setData);
    HapticFeedback.mediumImpact();

    // Salvar no cache quando completar o set 3 (último set)
    if (_currentSetNumber == 3) {
      _saveToCache(setData, _isExerciseA);
    }

    // CORREÇÃO FINAL: Timer só deve aparecer NO FINAL de TODO o SuperSet
    // Fluxo correto: A1→A2→A1→A2→A1→A2→⏱️
    //
    // Timer aparece APENAS quando:
    // 1. Acabamos de completar B (A2) - !_isExerciseA
    // 2. E é o último set (set 3) - _currentSetNumber == 3
    //
    // Isso significa que o timer SÓ toca após completar o ÚLTIMO A2 do SuperSet inteiro.
    final shouldShowTimer = !_isExerciseA && _currentSetNumber == 3;

    // Determinar próximo exercício na sequência
    _moveToNext();

    // Iniciar timer APENAS se completou TODO o SuperSet (último A2 do set 3)
    if (shouldShowTimer) {
      widget.onRestNeeded(90); // 90 segundos após completar SuperSet completo
      debugPrint('⏱️ Timer iniciado: SuperSet completo (A1→A2→A1→A2→A1→A2)');
    } else {
      debugPrint('⏭️ Sem timer: continuando SuperSet');
    }
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
          // Superset completo - chegamos ao final da sequência (B3)
          debugPrint('🎉 SuperSet completo! Chegamos no final da sequência');
          debugPrint('📋 ExerciseA: ${widget.exerciseA.name}');
          debugPrint('📋 ExerciseB: ${widget.exerciseB.name}');

          // Chamar callback automaticamente para finalizar/avançar
          // Usando addPostFrameCallback para evitar conflito com setState em curso
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onSupersetCompleted?.call();
          });
        }
      }
    });
  }

  Future<void> _openYouTubeVideo(bool isA) async {
    try {
      final variation = isA ? _selectedVariationA : _selectedVariationB;
      final exerciseName = isA ? widget.exerciseA.name : widget.exerciseB.name;
      
      debugPrint('🎬 Tentando abrir YouTube para ${isA ? "A" : "B"}: $exerciseName');
      debugPrint('🎬 Variação selecionada: ${variation?.variationName}');
      debugPrint('🎬 URL: ${variation?.youtubeUrl}');
      
      if (variation?.youtubeUrl != null && variation!.youtubeUrl.isNotEmpty) {
        final uri = Uri.parse(variation.youtubeUrl);
        debugPrint('🎬 URI parsed: $uri');
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          debugPrint('✅ YouTube aberto com sucesso');
        } else {
          debugPrint('❌ canLaunchUrl retornou false');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Não foi possível abrir: ${variation.youtubeUrl}'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      } else {
        debugPrint('❌ URL não encontrada para $exerciseName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vídeo não disponível para $exerciseName'),
            backgroundColor: AppTheme.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao abrir YouTube: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir YouTube: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
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
    for (final map in _notesControllers.values) {
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
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.primaryOrangeHover, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on, color: AppTheme.textPrimary, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'SUPER SET',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.flash_on, color: AppTheme.textPrimary, size: 24),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Alternância: ${_getExerciseName(true)} ↔ ${_getExerciseName(false)}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
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
              color: AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: _isExerciseA ? AppTheme.primaryOrange : AppTheme.borderColor,
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
                        color: AppTheme.info,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: const Text(
                        'A1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getExerciseName(true),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        '${widget.exerciseA.sets} sets x ${widget.exerciseA.repsTarget} reps',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openYouTubeVideo(true),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppTheme.textPrimary,
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
                      color: AppTheme.backgroundElevated,
                      border: Border.all(
                        color: AppTheme.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: DropdownButton<ExerciseVariation>(
                      value: _selectedVariationA,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: AppTheme.backgroundElevated,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      items: _variationsA.map((variation) =>
                        DropdownMenuItem(
                          value: variation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: AppTheme.backgroundElevated,
                            ),
                            child: Text(
                              variation.variationName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                      color: AppTheme.info.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      'Variação: ${_selectedVariationA!.variationName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.info,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
              color: AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: !_isExerciseA ? AppTheme.primaryOrange : AppTheme.borderColor,
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
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: const Text(
                        'A2',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getExerciseName(false),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        '${widget.exerciseB.sets} sets x ${widget.exerciseB.repsTarget} reps',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openYouTubeVideo(false),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppTheme.textPrimary,
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
                      color: AppTheme.backgroundElevated,
                      border: Border.all(
                        color: AppTheme.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: DropdownButton<ExerciseVariation>(
                      value: _selectedVariationB,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: AppTheme.backgroundElevated,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      items: _variationsB.map((variation) =>
                        DropdownMenuItem(
                          value: variation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: AppTheme.backgroundElevated,
                            ),
                            child: Text(
                              variation.variationName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                      color: AppTheme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      'Variação: ${_selectedVariationB!.variationName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
              color: AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sequência do Super Set:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSequenceIndicator('A1', _isSetCompleted('A', 1)),
                    _buildArrow(),
                    _buildSequenceIndicator('A2', _isSetCompleted('B', 1)),
                    _buildArrow(),
                    _buildSequenceIndicator('A1', _isSetCompleted('A', 2)),
                    _buildArrow(),
                    _buildSequenceIndicator('A2', _isSetCompleted('B', 2)),
                    _buildArrow(),
                    _buildSequenceIndicator('A1', _isSetCompleted('A', 3)),
                    _buildArrow(),
                    _buildSequenceIndicator('A2', _isSetCompleted('B', 3)),
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
              color: AppTheme.primaryOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.primaryOrange,
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
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'AGORA: ${_isExerciseA ? "A1" : "A2"}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getCurrentExerciseName(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Set $_currentSetNumber de 3',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
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

                const SizedBox(height: 16),

                // Campo de comentários
                TextField(
                  controller: _notesControllers[prefix]![_currentSetNumber],
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Comentários (opcional)',
                    hintText: 'Ex: Forma ruim, muito pesado...',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                          ? 'Próximo (A2)'
                          : !_isExerciseA && _currentSetNumber == 3
                              ? 'Finalizar Super Set'
                              : 'Completar Set',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: AppTheme.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.borderColor,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Próximo:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          !_isExerciseA ? '${_getExerciseName(true)} - Set ${_currentSetNumber + 1}' : '${_getExerciseName(false)} - Set $_currentSetNumber',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
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
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(
                      color: AppTheme.borderColor,
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
                  label: Text('Ir para ${_isExerciseA ? "A2" : "A1"}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(
                      color: AppTheme.borderColor,
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
    // No padrão A1-A2-A1-A2-A1-A2:
    // - _isExerciseA = true significa A1
    // - _isExerciseA = false significa A2
    final isActive = (_isExerciseA && label == 'A1') ||
                     (!_isExerciseA && label == 'A2');

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: completed
            ? AppTheme.success
            : isActive
                ? AppTheme.primaryOrange
                : AppTheme.backgroundElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: completed
              ? AppTheme.success
              : isActive
                  ? AppTheme.primaryOrange
                  : AppTheme.borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: completed || isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return const Icon(
      Icons.arrow_forward,
      size: 16,
      color: AppTheme.textSecondary,
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

      _prefillFromCache();
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar cache do SuperSet: $e');
    }
  }

  void _prefillFromCache() {
    // 1. Restaurar variação do exercício A
    if (_lastWorkoutDataA != null && _lastWorkoutDataA!['variationId'] != null) {
      final savedVariationId = _lastWorkoutDataA!['variationId'];
      _selectedVariationA = _variationsA.firstWhere(
        (v) => v.id == savedVariationId,
        orElse: () => _variationsA.first,
      );
      debugPrint('🔄 Variação A restaurada: ${_selectedVariationA?.variationName}');
    }

    // 2. Restaurar variação do exercício B
    if (_lastWorkoutDataB != null && _lastWorkoutDataB!['variationId'] != null) {
      final savedVariationId = _lastWorkoutDataB!['variationId'];
      _selectedVariationB = _variationsB.firstWhere(
        (v) => v.id == savedVariationId,
        orElse: () => _variationsB.first,
      );
      debugPrint('🔄 Variação B restaurada: ${_selectedVariationB?.variationName}');
    }

    // 3. Dados do exercício A - preencher TODOS os sets com dados do último treino
    _prefillExerciseSets('A', _lastWorkoutDataA);

    // 4. Dados do exercício B - preencher TODOS os sets com dados do último treino
    _prefillExerciseSets('B', _lastWorkoutDataB);

    setState(() {}); // Atualizar UI
  }

  void _prefillExerciseSets(String prefix, Map<String, dynamic>? cacheData) {
    if (cacheData == null) return;

    // Tentar novo formato (sets individuais)
    final setsMap = cacheData['sets'] as Map<String, dynamic>?;
    if (setsMap != null) {
      for (int i = 1; i <= 3; i++) {
        final setData = setsMap['set$i'] as Map<String, dynamic>?;
        if (setData != null) {
          if (setData['weight'] != null) {
            _weightControllers[prefix]![i]?.text = setData['weight'].toString();
          }
          if (setData['reps'] != null) {
            _repsControllers[prefix]![i]?.text = setData['reps'].toString();
          }
          if (setData['difficulty'] != null) {
            _difficulties[prefix]![i] = setData['difficulty'].toString();
          }
          if (setData['notes'] != null && setData['notes'].toString().isNotEmpty) {
            _notesControllers[prefix]![i]?.text = setData['notes'].toString();
          }
        }
      }
      debugPrint('🔄 Dados $prefix preenchidos (${setsMap.length} sets do cache)');
      return;
    }

    // Fallback: formato antigo (lastSet3) — preencher apenas set 1
    final lastSet3 = cacheData['lastSet3'] as Map<String, dynamic>?;
    if (lastSet3 != null) {
      if (lastSet3['weight'] != null) {
        _weightControllers[prefix]![1]?.text = lastSet3['weight'].toString();
      }
      if (lastSet3['reps'] != null) {
        _repsControllers[prefix]![1]?.text = lastSet3['reps'].toString();
      }
      if (lastSet3['difficulty'] != null) {
        _difficulties[prefix]![1] = lastSet3['difficulty'].toString();
      }
      if (lastSet3['notes'] != null && lastSet3['notes'].toString().isNotEmpty) {
        _notesControllers[prefix]![1]?.text = lastSet3['notes'].toString();
      }
      debugPrint('🔄 Dados $prefix preenchidos (fallback lastSet3 → set 1)');
    }
  }

  Future<void> _saveToCache(WorkoutSet lastSet, bool isExerciseA) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exercise = isExerciseA ? widget.exerciseA : widget.exerciseB;
      final selectedVariation = isExerciseA ? _selectedVariationA : _selectedVariationB;
      final prefix = isExerciseA ? 'A' : 'B';
      final cacheKey = 'lastWorkout_${exercise.id}';

      // Dados de TODOS os sets para usar no próximo treino
      final setsData = <String, dynamic>{};
      for (int i = 1; i <= 3; i++) {
        final weight = double.tryParse(_weightControllers[prefix]![i]?.text ?? '');
        final reps = int.tryParse(_repsControllers[prefix]![i]?.text ?? '');
        if (weight != null || reps != null) {
          setsData['set$i'] = {
            'weight': weight,
            'reps': reps,
            'difficulty': _difficulties[prefix]![i] ?? 'Perfeito',
            'notes': _notesControllers[prefix]![i]?.text ?? '',
          };
        }
      }

      final cacheData = {
        'exerciseId': exercise.id,
        'exerciseName': exercise.name,
        'sets': setsData,
        // Manter lastSet3 para compatibilidade
        'lastSet3': {
          'weight': lastSet.weightKg,
          'reps': lastSet.reps,
          'difficulty': lastSet.difficulty,
          'notes': _notesControllers[prefix]![3]?.text ?? '',
          'date': DateTime.now().toIso8601String(),
        },
        'variationId': selectedVariation?.id,
        'variationName': selectedVariation?.variationName,
      };

      await prefs.setString(cacheKey, jsonEncode(cacheData));
      debugPrint('✅ Cache salvo para exercício ${exercise.name} (SuperSet)');
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar cache do SuperSet: $e');
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
}