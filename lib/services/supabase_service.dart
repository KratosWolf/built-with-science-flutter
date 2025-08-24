import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_models.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Auth helpers
  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
  
  // Connection status
  static bool _isOnline = true;
  static bool get isOnline => _isOnline;
  
  // Offline cache keys
  static const String _offlineWorkoutKey = 'offline_workout_data';
  static const String _lastSyncKey = 'last_sync_timestamp';

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
    int? durationSec,
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
      'duration_sec': durationSec,
    };

    try {
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
          restSec: restSec,
        );
      }
      
      return workoutSet;
    } catch (e) {
      // If online save fails, cache for offline sync
      if (!_isOnline) {
        await _cacheOfflineData('workout_set', setData);
        
        // Return a local WorkoutSet instance
        return WorkoutSet(
          sessionId: sessionId,
          exerciseId: exerciseId,
          variationIndex: variationIndex,
          setNumber: setNumber,
          weightKg: weightKg,
          reps: reps,
          restSec: restSec,
          rpe: rpe,
          difficulty: difficulty,
          durationSec: durationSec,
        );
      }
      rethrow;
    }
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
    int? restSec,
  }) async {
    if (!isAuthenticated) return;

    try {
      final cacheData = {
        'user_id': currentUserId,
        'exercise_id': exerciseId,
        'variation_index': variationIndex,
        'weight_kg': weightKg,
        'reps': reps,
        'rest_sec': restSec,
        'difficulty': difficulty,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('last_set_cache')
          .upsert(cacheData);
      
      // Also cache locally for offline access
      await _cacheLocalLastSet(exerciseId, variationIndex, {
        'weight': weightKg,
        'reps': reps,
        'difficulty': difficulty,
        'rest_sec': restSec,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Error updating cache: $e', name: 'SupabaseService');
      
      // Fallback to local cache only
      await _cacheLocalLastSet(exerciseId, variationIndex, {
        'weight': weightKg,
        'reps': reps,
        'difficulty': difficulty,
        'rest_sec': restSec,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
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

  // Legacy simple progression calculation (kept for backwards compatibility)
  static ProgressionSuggestion _calculateProgression(
    double lastWeight,
    int lastReps,
    String difficulty,
    String targetRepsRange,
  ) {
    return _calculateAdvancedProgression(lastWeight, lastReps, difficulty, targetRepsRange);
  }

  // Offline functionality
  static Future<void> _cacheOfflineData(String type, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_offlineWorkoutKey) ?? '[]';
      final List<dynamic> offlineData = jsonDecode(existingData);
      
      offlineData.add({
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await prefs.setString(_offlineWorkoutKey, jsonEncode(offlineData));
      developer.log('Cached offline data: $type', name: 'SupabaseService');
    } catch (e) {
      developer.log('Error caching offline data: $e', name: 'SupabaseService');
    }
  }
  
  static Future<void> _cacheLocalLastSet(int exerciseId, int variationIndex, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'last_set_${exerciseId}_$variationIndex';
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      developer.log('Error caching local last set: $e', name: 'SupabaseService');
    }
  }
  
  static Future<Map<String, dynamic>?> _getLocalLastSet(int exerciseId, int variationIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'last_set_${exerciseId}_$variationIndex';
      final data = prefs.getString(key);
      return data != null ? jsonDecode(data) : null;
    } catch (e) {
      developer.log('Error getting local last set: $e', name: 'SupabaseService');
      return null;
    }
  }
  
  static Future<void> syncOfflineData() async {
    if (!isAuthenticated || !_isOnline) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineDataString = prefs.getString(_offlineWorkoutKey);
      
      if (offlineDataString == null) return;
      
      final List<dynamic> offlineData = jsonDecode(offlineDataString);
      
      for (final item in offlineData) {
        try {
          final type = item['type'];
          final data = item['data'];
          
          switch (type) {
            case 'workout_set':
              await _client.from('workout_sets').insert(data);
              break;
            case 'workout_session':
              await _client.from('workout_sessions').insert(data);
              break;
            // Add more sync types as needed
          }
        } catch (e) {
          developer.log('Error syncing item: $e', name: 'SupabaseService');
        }
      }
      
      // Clear offline data after successful sync
      await prefs.remove(_offlineWorkoutKey);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      developer.log('Offline data synced successfully', name: 'SupabaseService');
    } catch (e) {
      developer.log('Error syncing offline data: $e', name: 'SupabaseService');
    }
  }
  
  static Future<void> setConnectionStatus(bool isOnline) async {
    _isOnline = isOnline;
    
    if (isOnline) {
      // Attempt to sync when coming back online
      await syncOfflineData();
    }
  }
  
  // Enhanced progression suggestion with fallback to local cache
  static Future<ProgressionSuggestion?> getProgressionSuggestionWithFallback(
    int exerciseId,
    String targetRepsRange, {
    int variationIndex = 1,
  }) async {
    // Try online first
    try {
      final cache = await getLastSetCache(exerciseId);
      if (cache?.weightKg != null && cache?.reps != null && cache?.difficulty != null) {
        return _calculateAdvancedProgression(
          cache!.weightKg!,
          cache.reps!,
          cache.difficulty!,
          targetRepsRange,
        );
      }
    } catch (e) {
      developer.log('Online cache failed, trying local: $e', name: 'SupabaseService');
    }
    
    // Fallback to local cache
    final localCache = await _getLocalLastSet(exerciseId, variationIndex);
    if (localCache != null) {
      final weight = localCache['weight']?.toDouble();
      final reps = localCache['reps']?.toInt();
      final difficulty = localCache['difficulty']?.toString();
      
      if (weight != null && reps != null && difficulty != null) {
        return _calculateAdvancedProgression(weight, reps, difficulty, targetRepsRange);
      }
    }
    
    return null;
  }
  
  // Enhanced progression calculation based on Next.js algorithm
  static ProgressionSuggestion _calculateAdvancedProgression(
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
    
    // Determine if user hit the target rep range
    final hitTarget = lastReps >= minReps && lastReps <= maxReps;
    
    if (!hitTarget && lastReps < minReps) {
      // Missed target - reduce weight or reps
      final weightReduction = lastWeight * 0.05; // 5% reduction
      final newWeight = ((lastWeight - weightReduction) * 4).round() / 4; // Round to .25
      
      return ProgressionSuggestion(
        type: 'weight',
        current: ProgressionData(weight: lastWeight, reps: lastReps),
        suggested: ProgressionData(weight: newWeight, reps: minReps),
        reason: 'Missed target reps ($lastReps/$minReps-$maxReps). Reduce weight to ${newWeight}kg and aim for $minReps reps.',
      );
    }
    
    // Hit target - adjust based on difficulty
    switch (difficulty) {
      case 'easy':
        if (lastReps < maxReps) {
          // Increase reps within range
          return ProgressionSuggestion(
            type: 'reps',
            current: ProgressionData(weight: lastWeight, reps: lastReps),
            suggested: ProgressionData(weight: lastWeight, reps: lastReps + 1),
            reason: 'Easy set. Increase to ${lastReps + 1} reps to challenge yourself more.',
          );
        } else {
          // At max reps and easy - increase weight
          final weightIncrease = lastWeight * 0.025; // 2.5% increase
          final newWeight = ((lastWeight + weightIncrease) * 4).round() / 4;
          
          return ProgressionSuggestion(
            type: 'both',
            current: ProgressionData(weight: lastWeight, reps: lastReps),
            suggested: ProgressionData(weight: newWeight, reps: minReps),
            reason: 'Easy at max reps. Increase weight to ${newWeight}kg and reset to $minReps reps.',
          );
        }
        
      case 'medium':
        // Perfect - maintain
        return ProgressionSuggestion(
          type: 'both',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps),
          reason: 'Perfect difficulty. Maintain ${lastWeight}kg × $lastReps reps.',
        );
        
      case 'hard':
      case 'max_effort':
        if (lastReps > minReps) {
          // Reduce reps to make it more manageable
          return ProgressionSuggestion(
            type: 'reps',
            current: ProgressionData(weight: lastWeight, reps: lastReps),
            suggested: ProgressionData(weight: lastWeight, reps: lastReps - 1),
            reason: 'Too challenging. Reduce to ${lastReps - 1} reps for better form.',
          );
        } else {
          // At min reps - reduce weight
          final weightReduction = lastWeight * (difficulty == 'hard' ? 0.025 : 0.05);
          final newWeight = ((lastWeight - weightReduction) * 4).round() / 4;
          
          return ProgressionSuggestion(
            type: 'weight',
            current: ProgressionData(weight: lastWeight, reps: lastReps),
            suggested: ProgressionData(weight: newWeight, reps: lastReps),
            reason: 'Too challenging at minimum reps. Reduce weight to ${newWeight}kg.',
          );
        }
        
      case 'failed':
        // Significant reduction
        final weightReduction = lastWeight * 0.10; // 10% reduction
        final newWeight = ((lastWeight - weightReduction) * 4).round() / 4;
        
        return ProgressionSuggestion(
          type: 'both',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: newWeight, reps: minReps),
          reason: 'Form breakdown. Reduce weight to ${newWeight}kg and focus on proper technique.',
        );
        
      default:
        return ProgressionSuggestion(
          type: 'both',
          current: ProgressionData(weight: lastWeight, reps: lastReps),
          suggested: ProgressionData(weight: lastWeight, reps: lastReps),
          reason: 'Maintain current weight and reps.',
        );
    }
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
  
  // Personal Records tracking
  static Future<void> checkAndUpdatePR({
    required int exerciseId,
    required double weightKg,
    required int reps,
    int variationIndex = 1,
    int? sessionId,
  }) async {
    if (!isAuthenticated) return;
    
    try {
      // Calculate estimated 1RM using Epley formula
      final estimated1RM = reps == 1 ? weightKg : weightKg * (1 + reps / 30.0);
      
      // Check current PR
      final currentPR = await _client
          .from('exercise_prs')
          .select()
          .eq('user_id', currentUserId!)
          .eq('exercise_id', exerciseId)
          .eq('variation_index', variationIndex)
          .eq('pr_type', '1rm')
          .maybeSingle();
      
      bool shouldUpdate = false;
      
      if (currentPR == null) {
        shouldUpdate = true;
      } else {
        final currentEstimated1RM = currentPR['estimated_1rm'];
        shouldUpdate = estimated1RM > currentEstimated1RM;
      }
      
      if (shouldUpdate) {
        await _client.from('exercise_prs').upsert({
          'user_id': currentUserId,
          'exercise_id': exerciseId,
          'variation_index': variationIndex,
          'pr_type': '1rm',
          'weight_kg': weightKg,
          'reps': reps,
          'estimated_1rm': estimated1RM,
          'session_id': sessionId,
          'achieved_at': DateTime.now().toIso8601String(),
        });
        
        developer.log('New PR! Exercise $exerciseId: ${estimated1RM.toStringAsFixed(1)}kg (estimated 1RM)', name: 'SupabaseService');
      }
    } catch (e) {
      developer.log('Error updating PR: $e', name: 'SupabaseService');
    }
  }
  
  // Get exercise PRs
  static Future<List<Map<String, dynamic>>> getUserPRs({int? exerciseId}) async {
    if (!isAuthenticated) return [];
    
    try {
      final response = await _client
          .from('exercise_prs')
          .select('*, exercises(name)')
          .eq('user_id', currentUserId!)
          .order('achieved_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Error getting PRs: $e', name: 'SupabaseService');
      return [];
    }
  }
  
  // Update workout session with duration
  static Future<WorkoutSession> updateWorkoutSession(int sessionId, {
    String? status,
    DateTime? finishedAt,
    int? totalDurationSec,
    String? notes,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    final updateData = <String, dynamic>{};
    
    if (status != null) updateData['status'] = status;
    if (finishedAt != null) updateData['finished_at'] = finishedAt.toIso8601String();
    if (totalDurationSec != null) updateData['total_duration_sec'] = totalDurationSec;
    if (notes != null) updateData['notes'] = notes;
    
    final response = await _client
        .from('workout_sessions')
        .update(updateData)
        .eq('id', sessionId)
        .eq('user_id', currentUserId!)
        .select()
        .single();
    
    return WorkoutSession.fromJson(response);
  }
  
  // Batch operations for better performance
  static Future<List<WorkoutSet>> saveMultipleWorkoutSets(List<Map<String, dynamic>> sets) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    
    try {
      final response = await _client
          .from('workout_sets')
          .insert(sets)
          .select();
      
      return (response as List)
          .map((json) => WorkoutSet.fromJson(json))
          .toList();
    } catch (e) {
      // If online batch save fails, cache all sets for offline sync
      if (!_isOnline) {
        for (final setData in sets) {
          await _cacheOfflineData('workout_set', setData);
        }
        
        // Return local WorkoutSet instances
        return sets.map((setData) => WorkoutSet(
          sessionId: setData['session_id'],
          exerciseId: setData['exercise_id'],
          variationIndex: setData['variation_index'],
          setNumber: setData['set_number'],
          weightKg: setData['weight_kg']?.toDouble(),
          reps: setData['reps'],
          restSec: setData['rest_sec'],
          rpe: setData['rpe']?.toDouble(),
          difficulty: setData['difficulty'],
          durationSec: setData['duration_sec'],
        )).toList();
      }
      rethrow;
    }
  }

  // Statistics methods
  static Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      // For now, return mock data since we don't have user auth
      // In production, this would query based on current user
      
      final totalWorkouts = await _client
          .from('workout_sessions')
          .select('id')
          .count();

      final totalSetsResult = await _client
          .from('workout_sets')
          .select('id')
          .count();

      final volumeResult = await _client
          .from('workout_sets')
          .select('weight_kg, reps')
          .not('weight_kg', 'is', null)
          .not('reps', 'is', null);

      double totalVolume = 0.0;
      for (final set in volumeResult) {
        final weight = (set['weight_kg'] as num?)?.toDouble() ?? 0.0;
        final reps = (set['reps'] as num?)?.toInt() ?? 0;
        totalVolume += weight * reps;
      }

      // Calculate current streak (mock for now)
      final currentStreak = await _calculateWorkoutStreak();

      return {
        'total_workouts': totalWorkouts.count,
        'total_sets': totalSetsResult.count,
        'total_volume_kg': totalVolume,
        'current_streak': currentStreak,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      // Return default values on error
      return {
        'total_workouts': 0,
        'total_sets': 0,
        'total_volume_kg': 0.0,
        'current_streak': 0,
      };
    }
  }

  static Future<List<PersonalRecord>> getRecentPersonalRecords({int limit = 5}) async {
    try {
      final result = await _client
          .from('personal_records')
          .select('''
            *,
            exercises (name)
          ''')
          .order('achieved_at', ascending: false)
          .limit(limit);

      return result.map((pr) => PersonalRecord(
        id: pr['id'],
        exerciseId: pr['exercise_id'],
        exerciseName: pr['exercises']['name'],
        variationIndex: pr['variation_index'] ?? 1,
        weightKg: (pr['weight_kg'] as num).toDouble(),
        reps: pr['reps'],
        estimated1rm: (pr['estimated_1rm'] as num?)?.toDouble(),
        achievedAt: DateTime.parse(pr['achieved_at']),
      )).toList();
    } catch (e) {
      print('Error getting recent PRs: $e');
      return [];
    }
  }

  static Future<Map<String, double>> getExerciseProgressOverTime() async {
    try {
      // Calculate progress as improvement percentage over time for top exercises
      final result = await _client
          .from('workout_sets')
          .select('''
            weight_kg,
            exercises (name)
          ''')
          .not('weight_kg', 'is', null)
          .order('created_at', ascending: true);

      final Map<String, List<double>> exerciseWeights = {};
      
      for (final set in result) {
        final exerciseName = set['exercises']['name'] as String;
        final weight = (set['weight_kg'] as num).toDouble();
        
        exerciseWeights.putIfAbsent(exerciseName, () => []);
        exerciseWeights[exerciseName]!.add(weight);
      }

      final Map<String, double> progress = {};
      
      for (final entry in exerciseWeights.entries) {
        final weights = entry.value;
        if (weights.length >= 2) {
          final firstWeight = weights.first;
          final lastWeight = weights.last;
          if (firstWeight > 0) {
            final progressPercent = (lastWeight - firstWeight) / firstWeight;
            progress[entry.key] = progressPercent;
          }
        }
      }

      // Return top 5 exercises with most progress
      final sortedProgress = progress.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return Map.fromEntries(sortedProgress.take(5));
    } catch (e) {
      print('Error getting exercise progress: $e');
      return {};
    }
  }

  static Future<int> _calculateWorkoutStreak() async {
    try {
      // Simple streak calculation - consecutive days with workouts
      final now = DateTime.now();
      var streak = 0;
      var checkDate = DateTime(now.year, now.month, now.day);
      
      for (int i = 0; i < 30; i++) { // Check up to 30 days back
        final workoutsOnDate = await _client
            .from('workout_sessions')
            .select('id')
            .gte('started_at', checkDate.toIso8601String())
            .lt('started_at', checkDate.add(const Duration(days: 1)).toIso8601String())
            .count();
        
        if (workoutsOnDate.count > 0) {
          streak++;
        } else if (i > 0) {
          // Break streak if no workout found (but allow today to be empty)
          break;
        }
        
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
      
      return streak;
    } catch (e) {
      print('Error calculating workout streak: $e');
      return 0;
    }
  }
}