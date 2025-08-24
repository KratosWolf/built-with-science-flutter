import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_models.dart';
import '../services/supabase_service.dart';
import '../widgets/exercise_selector.dart';
import '../widgets/rest_timer.dart';

/// WorkoutSessionScreen - Migrated from Next.js WorkoutPage
/// Handles complete workout session with progress tracking, rest timer, and smart progression
class WorkoutSessionScreen extends StatefulWidget {
  final int programId;
  final int programDayId;
  final String dayName;

  const WorkoutSessionScreen({
    Key? key,
    required this.programId,
    required this.programDayId,
    required this.dayName,
  }) : super(key: key);

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  // Workout session state
  WorkoutSession? _currentSession;
  List<DayExerciseData> _exercises = [];
  
  // Progress tracking
  Set<int> _completedExercises = {};
  int _currentExerciseIndex = 0;
  
  // Rest timer state
  bool _showRestTimer = false;
  int _restDuration = 120; // 2 minutes default
  
  // Loading states
  bool _isLoading = true;
  bool _isStartingWorkout = false;
  
  // UI state
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeWorkout() async {
    try {
      setState(() => _isLoading = true);
      
      // Mock data for workout exercises
      await Future.delayed(const Duration(milliseconds: 600));
      
      List<DayExerciseData> mockExercises = [];
      
      if (widget.dayName.contains('Full Body')) {
        // Full body workout exercises baseado no CSV original
        mockExercises = [
          DayExerciseData(exerciseId: 1, sets: 3, repsTarget: '8-10'), // Barbell Bench Press
          DayExerciseData(exerciseId: 7, sets: 3, repsTarget: '8-10'), // Barbell Romanian Deadlift  
          DayExerciseData(exerciseId: 10, sets: 3, repsTarget: '6-12'), // (Weighted) Pull-Ups
          DayExerciseData(exerciseId: 17, sets: 3, repsTarget: '8-10'), // Walking Lunges (per leg)
          DayExerciseData(exerciseId: 22, sets: 3, repsTarget: '10-15', isSuperset: true, supersetLabel: 'A', supersetExerciseLabel: 'A1'), // Standing Mid-Chest Cable Fly
          DayExerciseData(exerciseId: 27, sets: 3, repsTarget: '15-20', isSuperset: true, supersetLabel: 'A', supersetExerciseLabel: 'A2'), // Dumbbell Lateral Raise
        ];
      } else if (widget.dayName.contains('Upper')) {
        // Upper body exercises
        mockExercises = [
          DayExerciseData(exerciseId: 6, sets: 4, repsTarget: '6-8'),
          DayExerciseData(exerciseId: 7, sets: 3, repsTarget: '8-10'),
          DayExerciseData(exerciseId: 8, sets: 3, repsTarget: '10-12'),
          DayExerciseData(exerciseId: 9, sets: 3, repsTarget: '12-15'),
        ];
      } else if (widget.dayName.contains('Lower')) {
        // Lower body exercises
        mockExercises = [
          DayExerciseData(exerciseId: 10, sets: 4, repsTarget: '6-8'),
          DayExerciseData(exerciseId: 11, sets: 3, repsTarget: '8-10'),
          DayExerciseData(exerciseId: 12, sets: 3, repsTarget: '10-12'),
          DayExerciseData(exerciseId: 13, sets: 3, repsTarget: '15-20'),
        ];
      } else if (widget.dayName.contains('Push')) {
        // Push exercises
        mockExercises = [
          DayExerciseData(exerciseId: 14, sets: 4, repsTarget: '6-8'),
          DayExerciseData(exerciseId: 15, sets: 3, repsTarget: '8-10'),
          DayExerciseData(exerciseId: 16, sets: 3, repsTarget: '10-12'),
        ];
      } else if (widget.dayName.contains('Pull')) {
        // Pull exercises  
        mockExercises = [
          DayExerciseData(exerciseId: 17, sets: 4, repsTarget: '6-8'),
          DayExerciseData(exerciseId: 18, sets: 3, repsTarget: '8-10'),
          DayExerciseData(exerciseId: 19, sets: 3, repsTarget: '10-12'),
        ];
      } else if (widget.dayName.contains('Legs')) {
        // Leg exercises
        mockExercises = [
          DayExerciseData(exerciseId: 20, sets: 4, repsTarget: '6-8'),
          DayExerciseData(exerciseId: 21, sets: 3, repsTarget: '8-10'),
          DayExerciseData(exerciseId: 22, sets: 3, repsTarget: '12-15'),
        ];
      }
      
      setState(() {
        _exercises = mockExercises;
        _isLoading = false;
      });
      
      // Start workout session
      await _startWorkoutSession();
      
    } catch (e) {
      _showErrorSnackBar('Error loading workout: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startWorkoutSession() async {
    if (_isStartingWorkout || _currentSession != null) return;
    
    try {
      setState(() => _isStartingWorkout = true);
      
      // Mock workout session
      final session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 'mock_user_id',
        programId: widget.programId,
        programDayId: widget.programDayId,
        startedAt: DateTime.now(),
        status: 'in_progress',
      );
      
      setState(() {
        _currentSession = session;
        _isStartingWorkout = false;
      });
      
      // Keep screen on during workout
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      
    } catch (e) {
      _showErrorSnackBar('Error starting workout: $e');
      setState(() => _isStartingWorkout = false);
    }
  }

  Future<void> _finishWorkout() async {
    if (_currentSession == null) return;
    
    try {
      // Mock finish workout - just update local state
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Restore system UI
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Error finishing workout: $e');
    }
  }

  void _handleExerciseComplete(int exerciseId) {
    setState(() {
      _completedExercises.add(exerciseId);
    });
    
    // Trigger haptic feedback
    HapticFeedback.mediumImpact();
    
    // If not the last exercise, show rest timer
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _showRestTimer = true;
        _restDuration = _getRestDurationForCurrentExercise();
      });
    } else {
      // All exercises completed
      _finishWorkout();
    }
  }

  int _getRestDurationForCurrentExercise() {
    if (_currentExerciseIndex < _exercises.length) {
      // You could get this from the exercise data in the future
      // For now, use defaults based on exercise type
      return 120; // 2 minutes default
    }
    return 120;
  }

  void _handleRestComplete() {
    setState(() {
      _showRestTimer = false;
      _currentExerciseIndex = (_currentExerciseIndex + 1).clamp(0, _exercises.length - 1);
    });
    
    // Scroll to next exercise
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Congratulations! You completed ${widget.dayName}.'),
            const SizedBox(height: 8),
            Text('Exercises completed: ${_completedExercises.length}/${_exercises.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to program screen
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  bool get _allExercisesCompleted => 
    _exercises.isNotEmpty && _completedExercises.length == _exercises.length;

  double get _progressPercentage =>
    _exercises.isEmpty ? 0.0 : (_completedExercises.length / _exercises.length);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.dayName),
          backgroundColor: Colors.blue,
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
          title: Text(widget.dayName),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'No exercises found for this day.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Workout Session',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fitness_center, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_completedExercises.length}/${_exercises.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
          // Progress bar
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: LinearProgressIndicator(
              value: _progressPercentage,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _allExercisesCompleted ? Colors.green : Colors.blue,
              ),
            ),
          ),
          
          // Progress text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_progressPercentage * 100).round()}% Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_allExercisesCompleted)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'All Done!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Exercises list
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _exercises.length,
              onPageChanged: (index) {
                setState(() {
                  _currentExerciseIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final isCompleted = _completedExercises.contains(exercise.exerciseId);
                final isCurrent = index == _currentExerciseIndex;
                
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      // Exercise indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isCurrent 
                            ? Colors.blue.withOpacity(0.1)
                            : isCompleted 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent 
                              ? Colors.blue
                              : isCompleted 
                                ? Colors.green
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isCompleted 
                                  ? Colors.green
                                  : isCurrent 
                                    ? Colors.blue
                                    : Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isCompleted
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Exercise ${index + 1} of ${_exercises.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${exercise.sets} sets × ${exercise.repsTarget} reps',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCompleted)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                      
                      // Exercise selector
                      Expanded(
                        child: ExerciseSelector(
                          exerciseId: exercise.exerciseId,
                          sets: exercise.sets,
                          repsTarget: exercise.repsTarget,
                          isSuperset: exercise.isSuperset,
                          supersetLabel: exercise.supersetExerciseLabel,
                          sessionId: _currentSession?.id,
                          onDataChange: (data) {
                            // Check if all sets are completed
                            final completedSets = data.sets.where((set) =>
                              set.weightKg != null && set.reps != null && set.difficulty != null
                            ).length;
                            
                            if (completedSets == exercise.sets && !isCompleted) {
                              _handleExerciseComplete(exercise.exerciseId);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Navigation buttons
          if (!_allExercisesCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentExerciseIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentExerciseIndex < _exercises.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
          
          // Rest timer overlay
          if (_showRestTimer) _buildRestTimerOverlay(),
        ],
      ),
    );
  }
  
  Widget _buildRestTimerOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: RestTimer(
            initialSeconds: _restDuration,
            onComplete: _handleRestComplete,
            onSkip: _handleRestComplete,
            isActive: _showRestTimer,
          ),
        ),
      ),
    );
  }
}