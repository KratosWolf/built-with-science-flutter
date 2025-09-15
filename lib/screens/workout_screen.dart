import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_models.dart';
import '../services/supabase_service.dart';
// import '../widgets/exercise_selector.dart'; // Arquivo não existe
import '../widgets/rest_timer.dart';
import 'dart:async';
import 'dart:developer' as developer;

class WorkoutScreen extends StatefulWidget {
  final int programId;
  final int dayId;
  final String? dayName;
  
  const WorkoutScreen({
    super.key,
    required this.programId,
    required this.dayId,
    this.dayName,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with WidgetsBindingObserver {
  // Core workout state
  List<DayExerciseData> exercises = [];
  Set<int> completedExercises = <int>{};
  int currentExercise = 0;
  bool isLoading = true;
  String? errorMessage;
  
  // Session tracking
  WorkoutSession? currentSession;
  DateTime? workoutStartTime;
  Timer? workoutDurationTimer;
  int workoutDurationSeconds = 0;
  
  // Rest timer state
  bool showRestTimer = false;
  int restDuration = 120; // 2 minutes default
  
  // UI state
  bool keepScreenOn = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWorkoutData();
    _startWorkoutDurationTimer();
    _keepScreenAwake();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    workoutDurationTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused && currentSession != null) {
      // Auto-save progress when app goes to background
      _saveWorkoutProgress();
    } else if (state == AppLifecycleState.resumed) {
      // Check connection status when app resumes
      _checkConnectionAndSync();
    }
  }

  Future<void> _loadWorkoutData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load program day exercises
      final dayExercises = await // SupabaseService.getDayExercises(widget.dayId);
      
      // Start workout session
      final session = await // SupabaseService.startWorkoutSession(
        programId: widget.programId,
        programDayId: widget.dayId,
      );
      
      setState(() {
        exercises = dayExercises;
        currentSession = session;
        workoutStartTime = session.startedAt;
        isLoading = false;
      });
      
      developer.log('Workout loaded: ${exercises.length} exercises', name: 'WorkoutScreen');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading workout: $e';
      });
      developer.log('Error loading workout: $e', name: 'WorkoutScreen');
    }
  }

  void _startWorkoutDurationTimer() {
    workoutDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (workoutStartTime != null) {
        setState(() {
          workoutDurationSeconds = DateTime.now().difference(workoutStartTime!).inSeconds;
        });
      }
    });
  }

  void _keepScreenAwake() {
    if (keepScreenOn) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    }
  }

  Future<void> _checkConnectionAndSync() async {
    try {
      await // SupabaseService.setConnectionStatus(true);
      await // SupabaseService.syncOfflineData();
    } catch (e) {
      await // SupabaseService.setConnectionStatus(false);
      developer.log('Connection check failed: $e', name: 'WorkoutScreen');
    }
  }

  Future<void> _saveWorkoutProgress() async {
    if (currentSession == null) return;
    
    try {
      // Update session with current progress
      await // SupabaseService.updateWorkoutSession(
        currentSession!.id!,
        totalDurationSec: workoutDurationSeconds,
      );
    } catch (e) {
      developer.log('Error saving progress: $e', name: 'WorkoutScreen');
    }
  }

  void handleExerciseComplete(int exerciseId) {
    setState(() {
      completedExercises.add(exerciseId);
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Auto-scroll to next exercise
    if (currentExercise < exercises.length - 1) {
      _scrollToExercise(currentExercise + 1);
    }
    
    // Show rest timer if not the last exercise
    if (currentExercise < exercises.length - 1) {
      setState(() {
        showRestTimer = true;
      });
    }
    
    // Save progress
    _saveWorkoutProgress();
  }

  void handleRestComplete() {
    setState(() {
      showRestTimer = false;
      currentExercise = (currentExercise + 1).clamp(0, exercises.length - 1);
    });
    
    // Scroll to next exercise
    _scrollToExercise(currentExercise);
  }

  void _scrollToExercise(int index) {
    if (_scrollController.hasClients && index < exercises.length) {
      final double offset = index * 300.0; // Approximate height per exercise
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishWorkout() async {
    if (currentSession == null) return;
    
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Finish the session
      await // SupabaseService.updateWorkoutSession(
        currentSession!.id!,
        status: 'done',
        finishedAt: DateTime.now(),
        totalDurationSec: workoutDurationSeconds,
      );
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show completion dialog
      _showWorkoutCompleteDialog();
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading
      _showErrorDialog('Error finishing workout: $e');
    }
  }

  void _showWorkoutCompleteDialog() {
    final duration = Duration(seconds: workoutDurationSeconds);
    final formattedDuration = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange),
            SizedBox(width: 8),
            Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Great job completing ${widget.dayName ?? 'your workout'}!'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Duration: $formattedDuration'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Exercises: ${completedExercises.length}/${exercises.length}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close workout screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool get allExercisesCompleted {
    return exercises.isNotEmpty && completedExercises.length == exercises.length;
  }

  String get formattedDuration {
    final duration = Duration(seconds: workoutDurationSeconds);
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !(currentSession?.status == 'in_progress' && completedExercises.isNotEmpty),
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && currentSession?.status == 'in_progress' && completedExercises.isNotEmpty) {
          // Show confirmation dialog if workout is in progress
          final bool shouldPop = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Leave Workout?'),
              content: const Text('Your progress will be saved, but you can continue this workout later.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () {
                    _saveWorkoutProgress();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Leave'),
                ),
              ],
            ),
          ) ?? false;
          if (shouldPop) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.dayName ?? 'Workout'),
              Text(
                formattedDuration,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          actions: [
            // Connection status indicator
            if (!// SupabaseService.isOnline)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
              ),
            
            // Progress indicator
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Progress',
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
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Progress bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: exercises.isNotEmpty ? completedExercises.length / exercises.length : 0.0,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            allExercisesCompleted ? Colors.green : Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exercises.isNotEmpty ? ((completedExercises.length / exercises.length) * 100).round() : 0}% complete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Loading state
                  if (isLoading)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading workout...'),
                          ],
                        ),
                      ),
                    ),
                  
                  // Error state
                  if (errorMessage != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade400,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadWorkoutData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Success completion message
                  if (allExercisesCompleted && !isLoading)
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
                            Icons.celebration,
                            color: Colors.green.shade600,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amazing! Workout Complete! 🎉',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                Text(
                                  'You completed all exercises in $formattedDuration.',
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
                  
                  // Exercises list
                  if (!isLoading && errorMessage == null)
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          final isCompleted = completedExercises.contains(exercise.exerciseId);
                          final isCurrent = index == currentExercise;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              border: isCurrent ? Border.all(
                                color: Colors.blue.shade500, 
                                width: 2,
                              ) : null,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isCurrent ? [
                                BoxShadow(
                                  color: Colors.blue.shade200,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Opacity(
                              opacity: isCompleted ? 0.75 : 1.0,
                              child: Column(
                                children: [
                                  ExerciseSelector(
                                    exerciseId: exercise.exerciseId,
                                    sets: exercise.sets,
                                    repsTarget: exercise.repsTarget,
                                    isSuperset: exercise.isSuperset,
                                    supersetLabel: exercise.supersetExerciseLabel,
                                    sessionId: currentSession?.id,
                                    onDataChange: (data) {
                                      // Check if all sets are completed
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
                                      margin: const EdgeInsets.only(top: 8, bottom: 8),
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
                                                  'Exercise Complete',
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
                  
                  // Navigation buttons
                  if (!allExercisesCompleted && !isLoading && errorMessage == null)
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
                              _scrollToExercise(currentExercise);
                            } : null,
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Previous'),
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
                              _scrollToExercise(currentExercise);
                            } : null,
                            icon: const Icon(Icons.skip_next, size: 18),
                            label: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  
                  // Finish workout button
                  if (allExercisesCompleted && !isLoading)
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _finishWorkout,
                        icon: const Icon(Icons.celebration),
                        label: const Text('Finish Workout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Rest Timer Overlay
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
                                  'Rest Time',
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
      ),
    );
  }
}