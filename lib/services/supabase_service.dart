import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_models.dart';
import '../models/user_stats.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseClient? _client;
  SupabaseService._();

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  User? get currentUser => _client?.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Initialize Supabase with credentials
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://gktvfldykmzhynqthbdn.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrdHZmbGR5a216aHlucXRoYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5Nzg4NzAsImV4cCI6MjA3MTU1NDg3MH0.Nd2KdEGj8hQApxmTk8nkBM81R4ROJPhwRMtgPXadGVw',
      );
      instance._client = Supabase.instance.client;
      debugPrint('✅ Supabase initialized successfully');
      debugPrint('🔗 Connected to: gktvfldykmzhynqthbdn.supabase.co');
    } catch (e) {
      debugPrint('❌ Error initializing Supabase: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('✅ Login successful: ${response.user!.email}');
      }

      return response.user;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  /// Sign up with email, password and full name
  Future<User?> signUpWithEmailPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        debugPrint('✅ Registration successful: ${response.user!.email}');
      }

      return response.user;
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      rethrow;
    }
  }

  /// Sign in with Google - Native Implementation
  /// Uses google_sign_in package for better UX (stays in app)
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔵 [1/6] Iniciando Google Sign-In nativo...');

      // Step 1: Configure Google Sign-In with Web Client ID
      // Using Web Client ID from current Firebase project (697794784510)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '697794784510-qr91a5c2e7lti6ce2449p0og1a5th4rs.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      debugPrint('🔵 [2/6] Fazendo sign-in com Google...');

      // Step 2: Trigger Google Sign-In flow (opens Google account picker in-app)
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ [CANCELADO] Usuário cancelou o login com Google');
        throw Exception('Login cancelado pelo usuário');
      }

      debugPrint('🔵 [3/6] Usuário selecionado: ${googleUser.email}');
      debugPrint('🔵 [4/6] Obtendo tokens de autenticação...');

      // Step 3: Get authentication tokens from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        debugPrint('❌ ID Token não disponível');
        throw Exception('Falha ao obter ID Token do Google');
      }

      debugPrint('🔵 [5/6] Tokens obtidos com sucesso');
      debugPrint('   - ID Token: ${googleAuth.idToken?.substring(0, 50)}...');
      debugPrint('   - Access Token: ${googleAuth.accessToken != null ? "Presente" : "Ausente"}');

      // Step 4: Sign in to Supabase with Google ID token
      debugPrint('🔵 [6/6] Autenticando no Supabase...');
      final AuthResponse response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        debugPrint('✅ Login com Google bem-sucedido!');
        debugPrint('   - Email: ${response.user!.email}');
        debugPrint('   - Nome: ${response.user!.userMetadata?['full_name'] ?? 'N/A'}');
        debugPrint('   - ID: ${response.user!.id}');
      }

      return response.user;
    } catch (e) {
      debugPrint('❌ Erro no login com Google: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Reset password via email
  Future<bool> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent to: $email');
      return true;
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Save workout set to Supabase
  Future<bool> saveWorkoutSet(
    WorkoutSet workoutSet,
    int programId,
    int dayId,
  ) async {
    try {
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in - saving locally only');
        return false;
      }

      final data = {
        'user_id': currentUser!.id,
        'program_id': programId,
        'day_id': dayId,
        'exercise_id': workoutSet.exerciseId,
        'set_number': workoutSet.setNumber,
        'weight_kg': workoutSet.weightKg,
        'reps': workoutSet.reps,
        'rpe': workoutSet.rpe,
        'difficulty': workoutSet.difficulty,
        'created_at': DateTime.now().toIso8601String(),
      };

      await client.from('workout_sets').insert(data);
      debugPrint('✅ Workout set saved to cloud');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving workout set: $e');
      return false;
    }
  }

  /// Save workout session to Supabase
  Future<bool> saveWorkoutSession({
    required int programId,
    required int dayId,
    required int durationSeconds,
  }) async {
    try {
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in - session not saved to cloud');
        return false;
      }

      final data = {
        'user_id': currentUser!.id,
        'program_id': programId,
        'day_id': dayId,
        'duration_seconds': durationSeconds,
        'completed_at': DateTime.now().toIso8601String(),
      };

      await client.from('workout_sessions').insert(data);
      debugPrint('✅ Workout session saved to cloud');
      debugPrint('   📊 Program: $programId, Day: $dayId, Duration: ${durationSeconds}s');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving workout session: $e');
      return false;
    }
  }

  /// Load last workout data from Supabase
  Future<Map<int, List<WorkoutSet>>> loadLastWorkoutData(
    int programId,
    int dayId,
  ) async {
    try {
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in - returning empty data');
        return {};
      }

      final response = await client
          .from('workout_sets')
          .select()
          .eq('user_id', currentUser!.id)
          .eq('program_id', programId)
          .eq('day_id', dayId)
          .order('created_at', ascending: false)
          .limit(100);

      final Map<int, List<WorkoutSet>> workoutData = {};

      for (final row in response) {
        final exerciseId = row['exercise_id'] as int;
        final workoutSet = WorkoutSet(
          sessionId: 0, // Temporary session ID for cloud data
          exerciseId: exerciseId,
          setNumber: row['set_number'] as int,
          weightKg: (row['weight_kg'] as num?)?.toDouble(),
          reps: row['reps'] as int?,
          rpe: (row['rpe'] as num?)?.toDouble(),
          difficulty: row['difficulty'] as String?,
        );

        if (!workoutData.containsKey(exerciseId)) {
          workoutData[exerciseId] = [];
        }
        workoutData[exerciseId]!.add(workoutSet);
      }

      debugPrint('✅ Loaded ${workoutData.length} exercises from cloud');
      return workoutData;
    } catch (e) {
      debugPrint('❌ Error loading workout data: $e');
      return {};
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return client.auth.onAuthStateChange;
  }

  /// Get current session
  Session? get currentSession => client.auth.currentSession;

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final session = client.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await client.auth.refreshSession();
      debugPrint('✅ Session refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing session: $e');
    }
  }

  /// Get user profile with statistics
  Future<UserProfile> getUserProfile() async {
    try {
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in - returning mock profile');
        return UserProfile.mock();
      }

      final user = currentUser!;
      final stats = await getUserStats();

      return UserProfile.fromSupabase(
        uid: user.id,
        email: user.email,
        displayName: user.userMetadata?['full_name'] as String?,
        photoUrl: user.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.tryParse(user.createdAt),
        stats: stats,
      );
    } catch (e) {
      debugPrint('❌ Error getting user profile: $e');
      return UserProfile.mock();
    }
  }

  /// Get user statistics from workout data
  /// [filterDays] - Optional filter to limit data to last N days (null = all time)
  Future<UserStats> getUserStats({int? filterDays}) async {
    try {
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in - returning empty stats');
        return UserStats.empty();
      }

      // Build query with optional date filter
      dynamic query = client
          .from('workout_sets')
          .select()
          .eq('user_id', currentUser!.id);

      // Apply date filter if provided
      if (filterDays != null) {
        final startDate = DateTime.now().subtract(Duration(days: filterDays));
        query = query.gte('created_at', startDate.toIso8601String());
        debugPrint('📊 Filtrando estatísticas: últimos $filterDays dias');
      } else {
        debugPrint('📊 Carregando estatísticas: todos os tempos');
      }

      final response = await query.order('created_at', ascending: true);

      if (response.isEmpty) {
        debugPrint('ℹ️  No workout data found - returning empty stats');
        return UserStats.empty();
      }

      // Calculate statistics
      final totalWorkouts = _calculateTotalWorkouts(response);
      final totalVolumeKg = _calculateTotalVolume(response);
      final streakData = _calculateStreaks(response);
      final weeklyAverage = _calculateWeeklyAverage(response);
      final lastWorkoutDate = _getLastWorkoutDate(response);
      final memberSince = DateTime.tryParse(currentUser!.createdAt);

      return UserStats(
        totalWorkouts: totalWorkouts,
        currentStreak: streakData['current'] ?? 0,
        bestStreak: streakData['best'] ?? 0,
        totalVolumeKg: totalVolumeKg,
        weeklyAverage: weeklyAverage,
        lastWorkoutDate: lastWorkoutDate,
        memberSince: memberSince,
      );
    } catch (e) {
      debugPrint('❌ Error getting user stats: $e');
      return UserStats.empty();
    }
  }

  /// Calculate total number of unique workouts (by date)
  int _calculateTotalWorkouts(List<dynamic> workoutSets) {
    final uniqueDates = <String>{};
    for (final set in workoutSets) {
      final createdAt = set['created_at'] as String;
      final date = createdAt.split('T')[0]; // Get date part only
      uniqueDates.add(date);
    }
    return uniqueDates.length;
  }

  /// Calculate total volume (weight * reps) in kg
  double _calculateTotalVolume(List<dynamic> workoutSets) {
    double total = 0.0;
    for (final set in workoutSets) {
      final weight = (set['weight_kg'] as num?)?.toDouble() ?? 0.0;
      final reps = (set['reps'] as int?) ?? 0;
      total += weight * reps;
    }
    return total;
  }

  /// Calculate current and best streaks (consecutive days with workouts)
  Map<String, int> _calculateStreaks(List<dynamic> workoutSets) {
    if (workoutSets.isEmpty) return {'current': 0, 'best': 0};

    // Get unique workout dates sorted
    final uniqueDates = <DateTime>{};
    for (final set in workoutSets) {
      final createdAt = set['created_at'] as String;
      final date = DateTime.parse(createdAt);
      uniqueDates.add(DateTime(date.year, date.month, date.day));
    }

    final sortedDates = uniqueDates.toList()..sort();

    int currentStreak = 0;
    int bestStreak = 0;
    int tempStreak = 1;

    for (int i = 0; i < sortedDates.length; i++) {
      if (i > 0) {
        final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          if (tempStreak > bestStreak) bestStreak = tempStreak;
          tempStreak = 1;
        }
      }
    }

    if (tempStreak > bestStreak) bestStreak = tempStreak;

    // Calculate current streak (must be recent)
    final today = DateTime.now();
    final lastDate = sortedDates.last;
    final daysSinceLastWorkout = today.difference(lastDate).inDays;

    if (daysSinceLastWorkout <= 1) {
      currentStreak = tempStreak;
    } else {
      currentStreak = 0;
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  /// Calculate weekly average of workouts
  double _calculateWeeklyAverage(List<dynamic> workoutSets) {
    if (workoutSets.isEmpty) return 0.0;

    final uniqueDates = <String>{};
    for (final set in workoutSets) {
      final createdAt = set['created_at'] as String;
      final date = createdAt.split('T')[0];
      uniqueDates.add(date);
    }

    final firstWorkout = DateTime.parse(workoutSets.first['created_at']);
    final lastWorkout = DateTime.parse(workoutSets.last['created_at']);
    final daysBetween = lastWorkout.difference(firstWorkout).inDays + 1;
    final weeks = daysBetween / 7.0;

    if (weeks < 1) return uniqueDates.length.toDouble();
    return uniqueDates.length / weeks;
  }

  /// Get last workout date
  DateTime? _getLastWorkoutDate(List<dynamic> workoutSets) {
    if (workoutSets.isEmpty) return null;
    final lastSet = workoutSets.last;
    return DateTime.parse(lastSet['created_at']);
  }

  /// Save user's selected program to Supabase
  Future<bool> saveUserSelectedProgram({
    required int programId,
    required String programName,
    required int daysPerWeek,
  }) async {
    try {
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in - program not saved to cloud');
        return false;
      }

      final data = {
        'user_id': currentUser!.id,
        'selected_program_id': programId,
        'selected_program_name': programName,
        'days_per_week': daysPerWeek,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Upsert - updates if exists, inserts if not
      await client.from('user_profiles').upsert(data, onConflict: 'user_id');
      debugPrint('✅ Selected program saved to cloud: $programName ($daysPerWeek days/week)');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving selected program: $e');
      return false;
    }
  }

  /// Get weekly volume data for charts (last 8 weeks by default)
  Future<List<Map<String, dynamic>>> getWeeklyVolumes({int weeks = 8}) async {
    if (!isLoggedIn) {
      debugPrint('⚠️ User not logged in - returning empty weekly volumes');
      return [];
    }

    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: weeks * 7));

      final response = await client
          .from('workout_sets')
          .select('weight_kg, reps, created_at')
          .eq('user_id', currentUser!.id)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: true);

      if (response.isEmpty) {
        debugPrint('ℹ️  No workout data for weekly volumes');
        return [];
      }

      // Group by week and calculate volume (weight * reps)
      Map<int, double> volumeByWeek = {};

      for (var set in response) {
        final createdAt = DateTime.parse(set['created_at'] as String);
        final weeksDiff = now.difference(createdAt).inDays ~/ 7;
        final weekIndex = weeks - weeksDiff - 1; // Reverse so week 0 is oldest

        if (weekIndex >= 0 && weekIndex < weeks) {
          final weight = (set['weight_kg'] as num?)?.toDouble() ?? 0.0;
          final reps = (set['reps'] as int?) ?? 0;
          final volume = weight * reps;

          volumeByWeek[weekIndex] = (volumeByWeek[weekIndex] ?? 0.0) + volume;
        }
      }

      // Convert to list format for chart
      List<Map<String, dynamic>> result = [];
      for (int i = 0; i < weeks; i++) {
        result.add({
          'week': 'S${i + 1}',
          'volume': volumeByWeek[i] ?? 0.0,
        });
      }

      debugPrint('✅ Weekly volumes calculated: ${result.length} weeks');
      return result;
    } catch (e) {
      debugPrint('❌ Error getting weekly volumes: $e');
      return [];
    }
  }

  /// Compare current period with previous period of equal length
  /// Returns comparison data with differences and percentages
  Future<Map<String, dynamic>> compareWithPreviousPeriod({required int days}) async {
    if (!isLoggedIn) {
      debugPrint('⚠️ User not logged in - returning empty comparison');
      return {
        'currentWorkouts': 0,
        'previousWorkouts': 0,
        'workoutsDiff': 0,
        'workoutsPercent': 0.0,
        'currentVolume': 0.0,
        'previousVolume': 0.0,
        'volumeDiff': 0.0,
        'volumePercent': 0.0,
      };
    }

    try {
      final now = DateTime.now();

      // Current period: last N days
      final currentStart = now.subtract(Duration(days: days));

      // Previous period: N days before current period
      final previousEnd = currentStart;
      final previousStart = previousEnd.subtract(Duration(days: days));

      debugPrint('📊 Comparing periods:');
      debugPrint('   Current: ${currentStart.toString().split(' ')[0]} to ${now.toString().split(' ')[0]}');
      debugPrint('   Previous: ${previousStart.toString().split(' ')[0]} to ${previousEnd.toString().split(' ')[0]}');

      // Query current period
      final currentResponse = await client
          .from('workout_sets')
          .select('weight_kg, reps, created_at')
          .eq('user_id', currentUser!.id)
          .gte('created_at', currentStart.toIso8601String())
          .lte('created_at', now.toIso8601String())
          .order('created_at', ascending: true);

      // Query previous period
      final previousResponse = await client
          .from('workout_sets')
          .select('weight_kg, reps, created_at')
          .eq('user_id', currentUser!.id)
          .gte('created_at', previousStart.toIso8601String())
          .lt('created_at', previousEnd.toIso8601String())
          .order('created_at', ascending: true);

      // Calculate current period stats
      final currentWorkouts = _calculateTotalWorkouts(currentResponse);
      final currentVolume = _calculateTotalVolume(currentResponse);

      // Calculate previous period stats
      final previousWorkouts = _calculateTotalWorkouts(previousResponse);
      final previousVolume = _calculateTotalVolume(previousResponse);

      // Calculate differences
      final workoutsDiff = currentWorkouts - previousWorkouts;
      final volumeDiff = currentVolume - previousVolume;

      // Calculate percentages (avoid division by zero)
      final workoutsPercent = previousWorkouts > 0
          ? ((workoutsDiff / previousWorkouts) * 100)
          : (currentWorkouts > 0 ? 100.0 : 0.0);

      final volumePercent = previousVolume > 0
          ? ((volumeDiff / previousVolume) * 100)
          : (currentVolume > 0 ? 100.0 : 0.0);

      debugPrint('✅ Comparison calculated:');
      debugPrint('   Workouts: $currentWorkouts vs $previousWorkouts (${workoutsPercent.toStringAsFixed(1)}%)');
      debugPrint('   Volume: ${currentVolume.toStringAsFixed(0)}kg vs ${previousVolume.toStringAsFixed(0)}kg (${volumePercent.toStringAsFixed(1)}%)');

      return {
        'currentWorkouts': currentWorkouts,
        'previousWorkouts': previousWorkouts,
        'workoutsDiff': workoutsDiff,
        'workoutsPercent': workoutsPercent,
        'currentVolume': currentVolume,
        'previousVolume': previousVolume,
        'volumeDiff': volumeDiff,
        'volumePercent': volumePercent,
      };
    } catch (e) {
      debugPrint('❌ Error comparing periods: $e');
      return {
        'currentWorkouts': 0,
        'previousWorkouts': 0,
        'workoutsDiff': 0,
        'workoutsPercent': 0.0,
        'currentVolume': 0.0,
        'previousVolume': 0.0,
        'volumeDiff': 0.0,
        'volumePercent': 0.0,
      };
    }
  }

  /// Get personal records (PRs) - top weights for each exercise
  Future<List<Map<String, dynamic>>> getPersonalRecords() async {
    if (!isLoggedIn) {
      debugPrint('⚠️ User not logged in - returning empty PRs');
      return [];
    }

    try {
      debugPrint('🏆 Fetching personal records...');

      // Buscar todos os sets com peso
      final response = await client
          .from('workout_sets')
          .select('exercise_id, weight_kg, reps, created_at')
          .eq('user_id', currentUser!.id)
          .not('weight_kg', 'is', null)
          .order('weight_kg', ascending: false)
          .limit(100);

      if (response.isEmpty) {
        debugPrint('ℹ️  No workout data for PRs');
        return [];
      }

      // Agrupar por exercício e pegar o maior peso de cada
      Map<int, Map<String, dynamic>> records = {};

      for (var set in response) {
        int exerciseId = set['exercise_id'] as int;
        double weight = (set['weight_kg'] as num?)?.toDouble() ?? 0.0;

        if (!records.containsKey(exerciseId) || weight > (records[exerciseId]!['weight'] ?? 0.0)) {
          records[exerciseId] = {
            'exercise_id': exerciseId,
            'exercise_name': getExerciseName(exerciseId),
            'weight': weight,
            'reps': set['reps'] as int? ?? 0,
            'date': set['created_at'] as String,
          };
        }
      }

      // Converter para lista e ordenar por peso
      var recordsList = records.values.toList();
      recordsList.sort((a, b) => (b['weight'] as double).compareTo(a['weight'] as double));

      // Retornar top 5 PRs
      final topPRs = recordsList.take(5).toList();

      debugPrint('✅ Found ${topPRs.length} personal records');
      for (var pr in topPRs) {
        debugPrint('   🏆 ${pr['exercise_name']}: ${pr['weight']}kg x ${pr['reps']} reps');
      }

      return topPRs;
    } catch (e) {
      debugPrint('❌ Error getting PRs: $e');
      return [];
    }
  }

  /// Helper method to map exercise variation IDs to names
  /// These IDs correspond to ExerciseVariation.id in mock_data.dart
  /// NOTE: ID 10 is an Exercise.id (not ExerciseVariation), added for legacy data migration
  String getExerciseName(int variationId) {
    // Complete map of all exercise variations from mock_data.dart
    const exerciseNames = {
      1: 'Barbell Bench Press',
      2: 'Flat Dumbbell Press',
      3: 'Flat Machine Chest Press',
      4: 'Flat Smith Machine Chest Press',
      5: 'Seated Flat Cable Press',
      6: 'Neutral Grip DB Press',
      7: 'Barbell Romanian Deadlift',
      8: 'Dumbbell Romanian Deadlift',
      9: 'Hyperextensions',
      10: '(Weighted) Pull-Ups', // Exercise.id (legacy data)
      11: 'Pull-Ups',
      12: 'Chin-Ups',
      13: 'Banded Pull-Ups',
      14: 'Pull-Up Negatives',
      15: 'Kneeling Lat Pulldown',
      16: 'Lat Pulldown',
      17: 'Inverted Row',
      18: 'Walking Lunges',
      19: 'Heel Elevated Split Squat',
      20: 'Bulgarian Split Squat',
      21: 'Reverse Lunges',
      22: 'Weighted Step-Ups',
      23: 'Standing Mid-Chest Cable Fly',
      24: 'Seated Mid-Chest Cable Fly',
      25: 'Pec-Deck Machine Fly',
      26: 'Dumbbell Fly',
      27: 'Banded Push-Ups',
      28: 'Dumbbell Lateral Raise',
      29: 'Cable Lateral Raise',
      30: 'Lying Incline Lateral Raise',
      31: 'Lean In Lateral Raise',
      32: 'Wide Grip BB Upright Row',
      33: 'Single Leg Calf Raise',
      34: 'Smith Machine Calf Raise',
      35: 'Standing Calf Raise',
      36: 'Leg Press Calf Raise',
      37: 'Standing Face Pulls',
      38: 'Bent Over DB Face Pulls',
      39: 'Prone Arm Circles',
      40: 'Wall Slides',
      41: 'Barbell Back Squat',
      42: 'Quad-Focused Leg Press',
      43: 'Smith Machine Squat',
      44: 'Barbell Back Box Squat',
      45: 'Weighted Step-Ups',
      46: 'Dumbbell Goblet Squat',
      47: 'Bulgarian Split Squat',
      48: 'Standing BB Overhead Press',
      49: 'Seated DB Shoulder Press',
      50: 'Standing DB Shoulder Press',
      51: 'Seated Neutral-Grip DB Press',
      52: 'Half Kneeling Landmine Press',
      53: 'Seated Leg Curls',
      54: 'Lying Leg Curls',
      55: 'Swiss Ball Leg Curls',
      56: 'Dumbbell Lying Leg Curls',
      57: 'DB Chest Supported Row',
      58: 'Barbell Row',
      59: 'Seated Cable Row',
      60: 'Chest Supported Machine Row',
      61: 'Incline DB Overhead Extensions',
      62: 'Overhead Rope Extensions',
      63: 'Cable Pushdowns',
      64: 'Incline Barbell Skullcrushers',
      65: 'Cross Cable Tricep Extensions',
      66: 'Seated Weighted Calf Raise',
      67: 'Seated Bodyweight Calf Raise',
      68: 'Side Plank',
      69: 'RKC Plank',
      70: 'Bird Dog',
      71: 'Palloff Press',
      72: 'Dead Bug',
      73: 'Barbell Deadlift',
      74: 'Sumo Deadlift',
      75: 'Trap Bar Deadlift',
      76: 'Dumbbell Romanian Deadlift',
      77: 'Hyperextensions',
      78: 'Glute Focused Leg Press',
      79: 'Low Incline Dumbbell Press',
      80: 'Incline Machine Chest Press',
      81: 'Low Incline Smith Machine Press',
      82: 'Low Incline Barbell Press',
      83: 'Low Incline Cable Press',
      84: 'Decline Push-Ups',
      85: 'Seated Leg Extensions',
      86: 'Sissy Squat',
      87: 'Heel Elevated Goblet Squat',
      88: 'Reverse Lunges',
      89: 'Seated Dumbbell Curls',
      90: 'Standing Cable Curl',
      91: 'Dumbbell Spider Curls',
      92: 'Banded Push-Ups',
      93: 'Close-Grip BB Bench Press',
      94: 'Close-Grip Push-Ups',
      95: 'Close-Grip Dumbbell Press',
      96: 'Close-Grip Smith Machine Press',
      97: 'Cable Pushdowns',
    };

    return exerciseNames[variationId] ?? 'Exercise #$variationId';
  }

  /// Save weekly workout goal locally
  Future<bool> setWeeklyGoal(int workoutsPerWeek) async {
    try {
      debugPrint('🔍 Tentando salvar meta: $workoutsPerWeek treinos/semana');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('weekly_workout_goal', workoutsPerWeek);

      debugPrint('✅ Meta semanal salva localmente: $workoutsPerWeek treinos/semana');
      return true;
    } catch (e) {
      debugPrint('❌ ERRO ao salvar meta: $e');
      return false;
    }
  }

  /// Get progress towards goal adapted to selected period
  /// [filterDays] - Number of days in the selected period (7, 30, 90, 365, or null for all time)
  Future<Map<String, dynamic>> getWeeklyProgress({required int? filterDays}) async {
    try {
      // Buscar meta base (treinos/semana) do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      int weeklyGoal = prefs.getInt('weekly_workout_goal') ?? 3;

      // Se for "Total" (allTime), não mostrar meta
      if (filterDays == null) {
        return {
          'weekly_goal': weeklyGoal,
          'period_goal': 0,
          'current': 0,
          'progress': 0.0,
          'remaining': 0,
          'period_weeks': 0.0,
          'show_goal': false,
        };
      }

      // Calcular meta para o período selecionado
      double weeksInPeriod = filterDays / 7.0;
      int periodGoal = (weeklyGoal * weeksInPeriod).round();

      // Buscar treinos atuais do período
      final stats = await getUserStats(filterDays: filterDays);
      int current = stats.totalWorkouts;

      // Calcular progresso
      double progress = periodGoal > 0 ? (current / periodGoal) * 100 : 0;
      progress = progress.clamp(0, 100);

      int remaining = (periodGoal - current).clamp(0, periodGoal);

      debugPrint('📊 Progresso do período ($filterDays dias):');
      debugPrint('   Meta base: $weeklyGoal treinos/semana');
      debugPrint('   Período: ${weeksInPeriod.toStringAsFixed(1)} semanas');
      debugPrint('   Meta do período: $periodGoal treinos');
      debugPrint('   Atual: $current treinos (${progress.toStringAsFixed(0)}%)');

      return {
        'weekly_goal': weeklyGoal,          // Meta base (treinos/semana)
        'period_goal': periodGoal,          // Meta ajustada ao período
        'current': current,
        'progress': progress,
        'remaining': remaining,
        'period_weeks': weeksInPeriod,
        'show_goal': true,
      };
    } catch (e) {
      debugPrint('❌ Error getting progress: $e');
      return {
        'weekly_goal': 3,
        'period_goal': 3,
        'current': 0,
        'progress': 0.0,
        'remaining': 3,
        'period_weeks': 1.0,
        'show_goal': true,
      };
    }
  }
}
