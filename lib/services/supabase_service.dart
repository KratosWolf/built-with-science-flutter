import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_models.dart';
import 'dart:convert';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Auth helpers
  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;

  // Authentication methods
  static Future<AuthResponse> signInAnonymously() async {
    return await _client.auth.signInAnonymously();
  }

  static Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // User profile methods
  static Future<WorkoutUser?> getUserProfile() async {
    if (!isAuthenticated) return null;

    final response = await _client
        .from('workout_users')
        .select()
        .eq('id', currentUserId!)
        .single();
    
    return WorkoutUser.fromJson(response);
  }

  static Future<WorkoutUser> createOrUpdateUserProfile({
    String? email,
    String? displayName,
    String unit = 'kg',
    String suggestionAggressiveness = 'standard',
    String videoPref = 'smart',
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final userData = {
      'id': currentUserId,
      'email': email ?? currentUser?.email,
      'display_name': displayName,
      'unit': unit,
      'suggestion_aggressiveness': suggestionAggressiveness,
      'video_pref': videoPref,
    };

    final response = await _client
        .from('workout_users')
        .upsert(userData)
        .select()
        .single();
    
    return WorkoutUser.fromJson(response);
  }

  // Exercise data methods (read-only, public data)
  static Future<List<Exercise>> getExercises() async {
    final response = await _client
        .from('exercises')
        .select()
        .order('name');
    
    return (response as List)
        .map((json) => Exercise.fromJson(json))
        .toList();
  }

  static Future<Exercise?> getExerciseById(int id) async {
    final response = await _client
        .from('exercises')
        .select()
        .eq('id', id)
        .single();
    
    return Exercise.fromJson(response);
  }

  static Future<List<ExerciseVariation>> getExerciseVariations(int exerciseId) async {
    final response = await _client
        .from('exercise_variations')
        .select()
        .eq('exercise_id', exerciseId)
        .order('variation_index');
    
    return (response as List)
        .map((json) => ExerciseVariation.fromJson(json))
        .toList();
  }

  static Future<String> getExerciseVideoUrl(int exerciseId, {int variationIndex = 1}) async {
    final response = await _client
        .from('exercise_variations')
        .select('youtube_url')
        .eq('exercise_id', exerciseId)
        .eq('variation_index', variationIndex)
        .single();
    
    return response['youtube_url'] ?? '';
  }

  // Program data methods
  static Future<List<Program>> getPrograms() async {
    final response = await _client
        .from('programs')
        .select()
        .order('id');
    
    return (response as List)
        .map((json) => Program.fromJson(json))
        .toList();
  }

  static Future<List<ProgramDay>> getProgramDays(int programId) async {
    final response = await _client
        .from('program_days')
        .select()
        .eq('program_id', programId)
        .order('day_index');
    
    return (response as List)
        .map((json) => ProgramDay.fromJson(json))
        .toList();
  }

  static Future<List<DayExerciseData>> getDayExercises(int programDayId) async {
    final response = await _client
        .from('day_exercises')
        .select()
        .eq('program_day_id', programDayId)
        .order('order_pos');
    
    return (response as List)
        .map((json) => DayExerciseData.fromJson(json))
        .toList();
  }

  // Workout session methods
  static Future<WorkoutSession> startWorkoutSession({
    required int programId,
    required int programDayId,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final sessionData = {
      'user_id': currentUserId,
      'program_id': programId,
      'program_day_id': programDayId,
      'started_at': DateTime.now().toIso8601String(),
      'status': 'in_progress',
    };

    final response = await _client
        .from('workout_sessions')
        .insert(sessionData)
        .select()
        .single();
    
    return WorkoutSession.fromJson(response);
  }

  static Future<WorkoutSession> finishWorkoutSession(int sessionId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final response = await _client
        .from('workout_sessions')
        .update({
          'finished_at': DateTime.now().toIso8601String(),
          'status': 'done',
        })
        .eq('id', sessionId)
        .eq('user_id', currentUserId!)
        .select()
        .single();
    
    return WorkoutSession.fromJson(response);
  }

  static Future<List<WorkoutSession>> getUserWorkoutSessions({int? limit}) async {
    if (!isAuthenticated) return [];

    var query = _client
        .from('workout_sessions')
        .select()
        .eq('user_id', currentUserId!)
        .order('started_at', ascending: false);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    
    return (response as List)
        .map((json) => WorkoutSession.fromJson(json))
        .toList();
  }

  // Workout set methods
  static Future<WorkoutSet> saveWorkoutSet({
    required int sessionId,
    required int exerciseId,
    int? variationIndex,
    required int setNumber,
    double? weightKg,
    int? reps,
    int? restSec,
    double? rpe,
    String? difficulty,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final setData = {
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'variation_index': variationIndex,
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'rest_sec': restSec,
      'rpe': rpe,
      'difficulty': difficulty,
    };

    final response = await _client
        .from('workout_sets')
        .insert(setData)
        .select()
        .single();
    
    final workoutSet = WorkoutSet.fromJson(response);
    
    // Update cache if set is complete
    if (weightKg != null && reps != null && difficulty != null) {
      await _updateLastSetCache(
        exerciseId: exerciseId,
        variationIndex: variationIndex ?? 1,
        weightKg: weightKg,
        reps: reps,
        difficulty: difficulty,
        sessionId: sessionId,
      );
    }
    
    return workoutSet;
  }

  static Future<List<WorkoutSet>> getSessionSets(int sessionId) async {
    if (!isAuthenticated) return [];

    final response = await _client
        .from('workout_sets')
        .select()
        .eq('session_id', sessionId)
        .order('exercise_id, set_number');
    
    return (response as List)
        .map((json) => WorkoutSet.fromJson(json))
        .toList();
  }

  // Last set cache methods
  static Future<LastSetCache?> getLastSetCache(int exerciseId) async {
    if (!isAuthenticated) return null;

    try {
      final response = await _client
          .from('last_set_cache')
          .select()
          .eq('user_id', currentUserId!)
          .eq('exercise_id', exerciseId)
          .single();
      
      return LastSetCache.fromJson(response);
    } catch (e) {
      // Cache doesn't exist for this exercise
      return null;
    }
  }

  static Future<void> _updateLastSetCache({
    required int exerciseId,
    required int variationIndex,
    required double weightKg,
    required int reps,
    required String difficulty,
    required int sessionId,
  }) async {
    if (!isAuthenticated) return;

    // Get all sets for this exercise in current session to build sets_data
    final sessionSets = await _client
        .from('workout_sets')
        .select()
        .eq('session_id', sessionId)
        .eq('exercise_id', exerciseId)
        .order('set_number');

    final setsData = (sessionSets as List)
        .where((set) => 
            set['weight_kg'] != null && 
            set['reps'] != null && 
            set['difficulty'] != null)
        .map((set) => {
              'setNumber': set['set_number'],
              'weight': set['weight_kg'],
              'reps': set['reps'],
              'difficulty': set['difficulty'],
            })
        .toList();

    final cacheData = {
      'user_id': currentUserId,
      'exercise_id': exerciseId,
      'variation_index': variationIndex,
      'weight_kg': weightKg,
      'reps': reps,
      'difficulty': difficulty,
      'sets_data': jsonEncode(setsData),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client
        .from('last_set_cache')
        .upsert(cacheData);
  }

  // Progression suggestion (computed locally using cached data)
  static Future<ProgressionSuggestion?> getProgressionSuggestion(
    int exerciseId,
    String targetRepsRange,
  ) async {
    final cache = await getLastSetCache(exerciseId);
    if (cache?.weightKg == null || cache?.reps == null || cache?.difficulty == null) {
      return null;
    }

    return _calculateProgression(
      cache!.weightKg!,
      cache.reps!,
      cache.difficulty!,
      targetRepsRange,
    );
  }

  static ProgressionSuggestion _calculateProgression(
    double lastWeight,
    int lastReps,
    String difficulty,
    String targetRepsRange,
  ) {
    final repsRange = targetRepsRange.split('-').map((r) => 
      int.tryParse(r.replaceAll(RegExp(r'[^\d]'), '')) ?? 0
    ).toList();
    final minReps = repsRange.isNotEmpty ? repsRange[0] : 8;
    final maxReps = repsRange.length > 1 ? repsRange[1] : minReps + 2;
    
    if (difficulty == 'easy') {
      if (lastReps < maxReps) {
        // Increase 1 rep until maximum
        return ProgressionSuggestion(
          type: 'reps',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps + 1),
          reason: 'Last set was easy. Increase to ${lastReps + 1} reps.',
        );
      } else {
        // At max reps, increase weight and reset to min reps
        final suggestedWeight = lastWeight + (lastWeight * 0.025); // 2.5% increase
        final roundedWeight = (suggestedWeight * 2).round() / 2;
        return ProgressionSuggestion(
          type: 'weight',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: roundedWeight, reps: minReps),
          reason: 'Max reps reached easily. Increase weight to ${roundedWeight}kg and return to $minReps reps.',
        );
      }
    } else if (difficulty == 'medium') {
      // Maintain weight and reps, ideal difficulty
      return ProgressionSuggestion(
        type: 'both',
        current: ProgressionData(weight: lastWeight, reps: lastReps),
        suggested: ProgressionData(weight: lastWeight, reps: lastReps),
        reason: 'Ideal difficulty. Maintain same weight and reps.',
      );
    } else if (difficulty == 'hard') {
      if (lastReps > minReps) {
        // Decrease 1 rep to make it easier
        return ProgressionSuggestion(
          type: 'reps',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps - 1),
          reason: 'Last set was too hard. Decrease to ${lastReps - 1} reps.',
        );
      } else {
        // Decrease weight by 5%
        final suggestedWeight = lastWeight - (lastWeight * 0.05);
        final roundedWeight = (suggestedWeight * 2).round() / 2;
        return ProgressionSuggestion(
          type: 'weight',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: roundedWeight, reps: lastReps),
          reason: 'Too hard at min reps. Decrease weight to ${roundedWeight}kg.',
        );
      }
    } else if (difficulty == 'max_effort') {
      // Slightly decrease weight or reps
      if (lastReps > minReps) {
        return ProgressionSuggestion(
          type: 'reps',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps - 1),
          reason: 'Max effort. Decrease to ${lastReps - 1} reps to maintain quality.',
        );
      } else {
        final suggestedWeight = lastWeight - (lastWeight * 0.025);
        final roundedWeight = (suggestedWeight * 2).round() / 2;
        return ProgressionSuggestion(
          type: 'weight',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: roundedWeight, reps: lastReps),
          reason: 'Max effort at min reps. Decrease weight to ${roundedWeight}kg.',
        );
      }
    } else if (difficulty == 'failed') {
      // Significantly decrease weight
      final suggestedWeight = lastWeight - (lastWeight * 0.10); // 10% reduction
      final roundedWeight = (suggestedWeight * 2).round() / 2;
      return ProgressionSuggestion(
        type: 'weight',
        current: ProgressionData(weight: lastWeight, reps: lastReps),
        suggested: ProgressionData(weight: roundedWeight, reps: minReps),
        reason: 'Failed execution. Decrease weight to ${roundedWeight}kg and return to $minReps reps.',
      );
    }

    // Default case
    return ProgressionSuggestion(
      type: 'both',
      current: ProgressionData(weight: lastWeight, reps: lastReps),
      suggested: ProgressionData(weight: lastWeight, reps: lastReps),
      reason: 'Maintain same weight and reps.',
    );
  }

  // Utility methods
  static Future<Map<String, dynamic>> getDashboardStats() async {
    if (!isAuthenticated) return {};

    final sessions = await getUserWorkoutSessions(limit: 30);
    final completedSessions = sessions.where((s) => s.status == 'done').length;
    final totalSessions = sessions.length;
    
    return {
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'completion_rate': totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0,
      'last_workout': sessions.isNotEmpty ? sessions.first.startedAt : null,
    };
  }
}