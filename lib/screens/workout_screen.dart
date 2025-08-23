import 'package:flutter/material.dart';
import '../models/workout_models.dart';
import '../data/user_exercises.dart';
import '../widgets/exercise_selector.dart';
import '../widgets/rest_timer.dart';

class WorkoutScreen extends StatefulWidget {
  final int programId;
  final int dayId;
  
  const WorkoutScreen({
    super.key,
    required this.programId,
    required this.dayId,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late List<DayExerciseData> exercises;
  Set<int> completedExercises = <int>{};
  int currentExercise = 0;
  bool showRestTimer = false;
  int restDuration = 120; // 2 minutos padrão
  
  @override
  void initState() {
    super.initState();
    // Para este exemplo, usamos os exercícios do dia 1 (Full Body A)
    exercises = UserExerciseData.day1Exercises;
  }

  void handleExerciseComplete(int exerciseId) {
    setState(() {
      completedExercises.add(exerciseId);
    });
    
    // Se não é o último exercício, mostrar timer de descanso
    if (currentExercise < exercises.length - 1) {
      setState(() {
        showRestTimer = true;
      });
    }
  }

  void handleRestComplete() {
    setState(() {
      showRestTimer = false;
      currentExercise = (currentExercise + 1).clamp(0, exercises.length - 1);
    });
  }

  bool get allExercisesCompleted {
    return exercises.isNotEmpty && completedExercises.length == exercises.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Body A'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Progresso',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${completedExercises.length}/${exercises.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (allExercisesCompleted)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                // Barra de progresso
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: exercises.isNotEmpty ? completedExercises.length / exercises.length : 0.0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercises.isNotEmpty ? ((completedExercises.length / exercises.length) * 100).round() : 0}% concluído',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mensagem de sucesso
                if (allExercisesCompleted)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parabéns! Treino concluído! 🎉',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              Text(
                                'Você completou todos os exercícios do Full Body A.',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Lista de exercícios
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final isCompleted = completedExercises.contains(exercise.exerciseId);
                      final isCurrent = index == currentExercise;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: isCurrent ? Border.all(color: Colors.blue.shade500, width: 2) : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Opacity(
                          opacity: isCompleted ? 0.7 : 1.0,
                          child: Column(
                            children: [
                              ExerciseSelector(
                                exerciseId: exercise.exerciseId,
                                sets: exercise.sets,
                                repsTarget: exercise.repsTarget,
                                isSuperset: exercise.isSuperset,
                                supersetLabel: exercise.supersetExerciseLabel,
                                onDataChange: (data) {
                                  // Verificar se todos os sets foram completados
                                  final completedSets = data.sets.where((set) => 
                                    set.weightKg != null && 
                                    set.reps != null && 
                                    set.difficulty != null
                                  ).length;
                                  
                                  if (completedSets == exercise.sets) {
                                    handleExerciseComplete(exercise.exerciseId);
                                  }
                                },
                              ),
                              
                              if (isCompleted)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: Colors.green.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Exercício Concluído',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Navegação
                if (!allExercisesCompleted)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: currentExercise > 0 ? () {
                            setState(() {
                              currentExercise = (currentExercise - 1).clamp(0, exercises.length - 1);
                            });
                          } : null,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Anterior'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                        
                        ElevatedButton.icon(
                          onPressed: currentExercise < exercises.length - 1 ? () {
                            setState(() {
                              currentExercise = (currentExercise + 1).clamp(0, exercises.length - 1);
                            });
                          } : null,
                          icon: const Icon(Icons.timer, size: 18),
                          label: const Text('Próximo'),
                        ),
                      ],
                    ),
                  ),
                
                if (allExercisesCompleted)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Finalizar Treino'),
                    ),
                  ),
              ],
            ),
          ),
          
          // Overlay do Rest Timer
          if (showRestTimer)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tempo de Descanso',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RestTimer(
                            initialSeconds: restDuration,
                            onComplete: handleRestComplete,
                            onSkip: handleRestComplete,
                            isActive: showRestTimer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Classe para dados do set de exercício
class ExerciseSetData {
  final int exerciseId;
  final int selectedVariationIndex;
  final String videoUrl;
  final List<WorkoutSetData> sets;

  ExerciseSetData({
    required this.exerciseId,
    required this.selectedVariationIndex,
    required this.videoUrl,
    required this.sets,
  });
}

class WorkoutSetData {
  final int setNumber;
  final double? weightKg;
  final int? reps;
  final String? difficulty;

  WorkoutSetData({
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.difficulty,
  });
}