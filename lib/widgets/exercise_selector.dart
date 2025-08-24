import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;

import '../models/workout_models.dart';
import '../services/supabase_service.dart';
import '../utils/progression_utils.dart';
import '../widgets/progression_suggestion_card.dart';
import '../data/user_exercises.dart';

class ExerciseSelector extends StatefulWidget {
  final int exerciseId;
  final int sets;
  final String repsTarget;
  final bool isSuperset;
  final String? supersetLabel;
  final int? sessionId;
  final Function(ExerciseSetData)? onDataChange;

  const ExerciseSelector({
    super.key,
    required this.exerciseId,
    required this.sets,
    required this.repsTarget,
    this.isSuperset = false,
    this.supersetLabel,
    this.sessionId,
    this.onDataChange,
  });

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Exercise data
  Exercise? exercise;
  List<ExerciseVariation> variations = [];
  int selectedVariationIndex = 1;
  
  // Set tracking
  List<WorkoutSetData> exerciseSets = [];
  Map<int, SetTimer> setTimers = {};
  
  // Text controllers for input fields
  Map<int, TextEditingController> weightControllers = {};
  Map<int, TextEditingController> repsControllers = {};
  Map<int, TextEditingController> notesControllers = {};
  
  // Progression data
  LastSetCache? lastSetCache;
  ProgressionSuggestion? progressionSuggestion;
  WorkoutUser? currentUser;
  
  // Loading states
  bool isLoadingProgression = true;
  bool isLoadingExercise = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in weightControllers.values) {
      controller.dispose();
    }
    for (var controller in repsControllers.values) {
      controller.dispose();
    }
    for (var controller in notesControllers.values) {
      controller.dispose();
    }
    weightControllers.clear();
    repsControllers.clear();
    notesControllers.clear();
    super.dispose();
  }

  TextEditingController _getOrCreateWeightController(int setNumber, double? initialValue) {
    final key = setNumber;
    if (!weightControllers.containsKey(key)) {
      weightControllers[key] = TextEditingController(text: initialValue?.toString() ?? '');
    }
    return weightControllers[key]!;
  }

  TextEditingController _getOrCreateRepsController(int setNumber, int? initialValue) {
    final key = setNumber;
    if (!repsControllers.containsKey(key)) {
      repsControllers[key] = TextEditingController(text: initialValue?.toString() ?? '');
    }
    return repsControllers[key]!;
  }

  TextEditingController _getOrCreateNotesController(int setNumber, String? initialValue) {
    final key = setNumber;
    if (!notesControllers.containsKey(key)) {
      notesControllers[key] = TextEditingController(text: initialValue ?? '');
    }
    return notesControllers[key]!;
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _loadExerciseData(),
        _loadUserData(),
        _loadProgressionData(),
        _loadLastWorkoutCache(),
      ]);
    } catch (e) {
      developer.log('Error initializing exercise data: $e', name: 'ExerciseSelector');
    }
  }

  Future<void> _loadExerciseData() async {
    try {
      setState(() => isLoadingExercise = true);
      
      // Load from Supabase or fallback to local data
      try {
        exercise = await SupabaseService.getExerciseById(widget.exerciseId);
        variations = await SupabaseService.getExerciseVariations(widget.exerciseId);
      } catch (e) {
        // Fallback to local data
        exercise = UserExerciseData.getUserExerciseById(widget.exerciseId);
        variations = UserExerciseData.getUserExerciseVariations(widget.exerciseId);
      }
      
      // Find primary variation or use first available
      final primaryVariation = variations.where((v) => v.isPrimary).firstOrNull;
      selectedVariationIndex = primaryVariation?.variationIndex ?? 
                               (variations.isNotEmpty ? variations.first.variationIndex : 1);
      
      setState(() => isLoadingExercise = false);
    } catch (e) {
      setState(() => isLoadingExercise = false);
      developer.log('Error loading exercise data: $e', name: 'ExerciseSelector');
    }
  }

  Future<void> _loadUserData() async {
    try {
      currentUser = await SupabaseService.getUserProfile();
    } catch (e) {
      developer.log('Error loading user data: $e', name: 'ExerciseSelector');
    }
  }

  Future<void> _loadProgressionData() async {
    try {
      setState(() => isLoadingProgression = true);
      
      // Try to load from Supabase first
      lastSetCache = await SupabaseService.getLastSetCache(widget.exerciseId);
      
      // Fallback to local cache if Supabase fails
      if (lastSetCache == null) {
        lastSetCache = await _getLocalLastSetCache();
      }
      
      // Generate progression suggestion if we have cache data
      if (lastSetCache != null && 
          lastSetCache!.weightKg != null && 
          lastSetCache!.reps != null && 
          lastSetCache!.difficulty != null) {
        
        progressionSuggestion = ProgressionUtils.calculateAdvancedProgression(
          lastWeight: lastSetCache!.weightKg!,
          lastReps: lastSetCache!.reps!,
          targetReps: widget.repsTarget,
          difficulty: lastSetCache!.difficulty!,
          aggressiveness: currentUser?.suggestionAggressiveness ?? 'standard',
        );
        
        // Pre-fill sets with suggested values
        _initializeSetsWithSuggestion();
      } else {
        // Initialize empty sets
        _initializeEmptySets();
      }
      
      setState(() => isLoadingProgression = false);
    } catch (e) {
      setState(() => isLoadingProgression = false);
      developer.log('Error loading progression data: $e', name: 'ExerciseSelector');
      _initializeEmptySets();
    }
  }

  Future<void> _loadLastWorkoutCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'last_workout_${widget.exerciseId}';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final cachedSets = (jsonData['sets'] as List<dynamic>?)
            ?.map((e) => CachedSet.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        
        // Initialize sets with cached data
        exerciseSets = List.generate(widget.sets, (index) {
          final cachedSet = cachedSets.isNotEmpty && index < cachedSets.length 
              ? cachedSets[index]
              : null;
          
          return WorkoutSetData(
            setNumber: index + 1,
            weightKg: cachedSet?.weight,
            reps: cachedSet?.reps,
            difficulty: cachedSet?.difficulty,
            notes: null, // Notes are session-specific, don't cache
          );
        });
        
        developer.log('Loaded cached workout data for exercise ${widget.exerciseId}', name: 'ExerciseSelector');
      } else {
        _initializeEmptySets();
      }
    } catch (e) {
      developer.log('Error loading workout cache: $e', name: 'ExerciseSelector');
      _initializeEmptySets();
    }
  }

  Future<LastSetCache?> _getLocalLastSetCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'exercise_cache_${widget.exerciseId}';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        return LastSetCache.fromJson(jsonData);
      }
    } catch (e) {
      developer.log('Error loading local cache: $e', name: 'ExerciseSelector');
    }
    return null;
  }

  void _initializeSetsWithSuggestion() {
    final suggestedWeight = progressionSuggestion?.suggested.weight ?? lastSetCache?.weightKg;
    final suggestedReps = progressionSuggestion?.suggested.reps ?? lastSetCache?.reps;
    
    exerciseSets = List.generate(widget.sets, (index) => 
      WorkoutSetData(
        setNumber: index + 1,
        weightKg: suggestedWeight,
        reps: suggestedReps,
      )
    );
  }

  void _initializeEmptySets() {
    exerciseSets = List.generate(widget.sets, (index) => 
      WorkoutSetData(setNumber: index + 1)
    );
  }

  void _onAcceptSuggestion(double weight, int reps) {
    setState(() {
      // Apply suggestion to all incomplete sets
      for (int i = 0; i < exerciseSets.length; i++) {
        if (exerciseSets[i].difficulty == null) {
          exerciseSets[i] = WorkoutSetData(
            setNumber: exerciseSets[i].setNumber,
            weightKg: weight,
            reps: reps,
            difficulty: exerciseSets[i].difficulty,
          );
        }
      }
    });
    
    // Notify parent of changes
    _notifyDataChange();
  }

  Future<void> _saveWorkoutSet(WorkoutSetData setData) async {
    if (widget.sessionId == null || 
        setData.weightKg == null || 
        setData.reps == null || 
        setData.difficulty == null) {
      return;
    }

    try {
      await SupabaseService.saveWorkoutSet(
        sessionId: widget.sessionId!,
        exerciseId: widget.exerciseId,
        variationIndex: selectedVariationIndex,
        setNumber: setData.setNumber,
        weightKg: setData.weightKg,
        reps: setData.reps,
        difficulty: setData.difficulty,
        durationSec: _getSetDuration(setData.setNumber),
      );
      
      // Check and update PR
      await SupabaseService.checkAndUpdatePR(
        exerciseId: widget.exerciseId,
        weightKg: setData.weightKg!,
        reps: setData.reps!,
        variationIndex: selectedVariationIndex,
        sessionId: widget.sessionId,
      );
      
      developer.log('Saved set: ${setData.weightKg}kg x ${setData.reps} reps', 
                   name: 'ExerciseSelector');
    } catch (e) {
      developer.log('Error saving workout set: $e', name: 'ExerciseSelector');
      // Data will be cached locally by SupabaseService for offline sync
    }
  }

  int? _getSetDuration(int setNumber) {
    final timer = setTimers[setNumber];
    if (timer != null && !timer.isActive) {
      return DateTime.now().difference(timer.startTime).inSeconds;
    }
    return null;
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
    final currentSet = exerciseSets[setIndex];
    
    final updatedSet = WorkoutSetData(
      setNumber: currentSet.setNumber,
      weightKg: field == 'weight' ? value : currentSet.weightKg,
      reps: field == 'reps' ? value : currentSet.reps,
      difficulty: field == 'difficulty' ? value : currentSet.difficulty,
      notes: field == 'notes' ? value : currentSet.notes,
    );
    
    setState(() {
      exerciseSets[setIndex] = updatedSet;
    });
    
    // Handle set completion
    if (field == 'difficulty' && value != null) {
      HapticFeedback.lightImpact();
      
      // Start/stop timers
      _startSetTimer(updatedSet.setNumber);
      if (updatedSet.setNumber > 1) {
        _stopSetTimer(updatedSet.setNumber - 1);
      }
      
      // Save set if complete
      if (updatedSet.weightKg != null && updatedSet.reps != null) {
        _saveWorkoutSet(updatedSet);
        _saveWorkoutCache(); // Save cache for next session
      }
    }
    
    _notifyDataChange();
  }

  void _notifyDataChange() {
    if (widget.onDataChange != null) {
      widget.onDataChange!(ExerciseSetData(
        exerciseId: widget.exerciseId,
        selectedVariationIndex: selectedVariationIndex,
        videoUrl: _getCurrentVideoUrl(),
        sets: exerciseSets,
      ));
    }
  }

  Future<void> _saveWorkoutCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'last_workout_${widget.exerciseId}';
      
      // Convert sets to cacheable format (only completed sets with weight/reps)
      final completedSets = exerciseSets
          .where((set) => set.weightKg != null && set.reps != null)
          .map((set) => CachedSet(
                setNumber: set.setNumber,
                weight: set.weightKg!,
                reps: set.reps!,
                difficulty: set.difficulty ?? 'medium',
              ))
          .toList();
      
      if (completedSets.isNotEmpty) {
        final cacheData = {
          'exerciseId': widget.exerciseId,
          'lastUpdated': DateTime.now().toIso8601String(),
          'sets': completedSets.map((set) => set.toJson()).toList(),
        };
        
        await prefs.setString(cacheKey, jsonEncode(cacheData));
        developer.log('Saved workout cache for exercise ${widget.exerciseId}', name: 'ExerciseSelector');
      }
    } catch (e) {
      developer.log('Error saving workout cache: $e', name: 'ExerciseSelector');
    }
  }

  String _getCurrentVideoUrl() {
    try {
      final variation = variations.firstWhere(
        (v) => v.variationIndex == selectedVariationIndex
      );
      return variation.youtubeUrl;
    } catch (e) {
      return UserExerciseData.getExerciseVideoUrl(
        widget.exerciseId, 
        variationIndex: selectedVariationIndex
      );
    }
  }

  CachedSet? _getPreviousSetData(int setNumber) {
    if (lastSetCache?.sets.isEmpty ?? true) return null;
    
    try {
      return lastSetCache!.sets.firstWhere((set) => set.setNumber == setNumber);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (isLoadingExercise) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (exercise == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Exercise not found (ID: ${widget.exerciseId})',
                style: TextStyle(color: Colors.red.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isSuperset 
          ? BorderSide(color: Colors.blue.shade500, width: 2) 
          : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(),
            const SizedBox(height: 16),
            _buildVariationSelector(),
            const SizedBox(height: 16),
            _buildVideoSection(),
            const SizedBox(height: 16),
            _buildProgressionSuggestion(),
            const SizedBox(height: 16),
            _buildSetsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Row(
      children: [
        if (widget.isSuperset && widget.supersetLabel != null) ...[
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
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.sets} sets • ${widget.repsTarget} reps',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        // Connection status indicator
        if (!SupabaseService.isOnline)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.cloud_off,
              color: Colors.orange.shade600,
              size: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildVariationSelector() {
    if (variations.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Variation:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
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
                      if (variation.isPrimary) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRIMARY',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
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
                  _notifyDataChange();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    final videoUrl = _getCurrentVideoUrl();
    if (videoUrl.isEmpty) return const SizedBox.shrink();

    final selectedVariation = variations.where(
      (v) => v.variationIndex == selectedVariationIndex
    ).firstOrNull;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Tutorial:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              selectedVariation?.variationName ?? 'Video Tutorial',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final Uri uri = Uri.parse(videoUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open: $videoUrl'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening video: ${e.toString()}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('Open'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionSuggestion() {
    if (isLoadingProgression) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ProgressionSuggestionCard(
      exerciseId: widget.exerciseId,
      exerciseName: exercise!.name,
      targetReps: widget.repsTarget,
      variationIndex: selectedVariationIndex,
      lastSetCache: lastSetCache,
      onAcceptSuggestion: _onAcceptSuggestion,
      userAggressiveness: currentUser?.suggestionAggressiveness ?? 'standard',
    );
  }

  Widget _buildSetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sets:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        ...exerciseSets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          final previousSetData = _getPreviousSetData(set.setNumber);
          
          return _buildSetWidget(index, set, previousSetData);
        }).toList(),
      ],
    );
  }

  Widget _buildSetWidget(int index, WorkoutSetData set, CachedSet? previousSetData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Set header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Set ${set.setNumber}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SetTimer(setNumber: set.setNumber, setTimers: setTimers),
                ],
              ),
              if (previousSetData != null)
                _buildPreviousSetInfo(previousSetData),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Set inputs
          Row(
            children: [
              // Weight input
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Weight (${currentUser?.unit ?? "kg"})',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _getOrCreateWeightController(set.setNumber, set.weightKg),
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    _updateSetData(index, 'weight', weight);
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Reps input
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _getOrCreateRepsController(set.setNumber, set.reps),
                  onChanged: (value) {
                    final reps = int.tryParse(value);
                    _updateSetData(index, 'reps', reps);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Difficulty selector
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: set.difficulty,
                isExpanded: true,
                hint: const Text('How did it feel?'),
                items: UserExerciseData.difficultyLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  _updateSetData(index, 'difficulty', value);
                },
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Notes field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Form notes, feeling, observations...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            maxLines: 2,
            controller: _getOrCreateNotesController(set.setNumber, set.notes),
            onChanged: (value) {
              _updateSetData(index, 'notes', value.isEmpty ? null : value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousSetInfo(CachedSet previousSetData) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Last time',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade600,
            ),
          ),
          Text(
            '${previousSetData.weight}kg × ${previousSetData.reps} reps',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              UserExerciseData.difficultyLabels[previousSetData.difficulty] ?? 
              previousSetData.difficulty,
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
    );
  }
}

// Set Timer Widget
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.green.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Set Timer data class
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

// Data classes
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
  final String? notes;

  WorkoutSetData({
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.difficulty,
    this.notes,
  });

  WorkoutSetData copyWith({
    int? setNumber,
    double? weightKg,
    int? reps,
    String? difficulty,
    String? notes,
  }) {
    return WorkoutSetData(
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      difficulty: difficulty ?? this.difficulty,
      notes: notes ?? this.notes,
    );
  }
}