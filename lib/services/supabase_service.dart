import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_models.dart';

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
      print('✅ Supabase initialized successfully');
      print('🔗 Connected to: gktvfldykmzhynqthbdn.supabase.co');
    } catch (e) {
      print('❌ Error initializing Supabase: $e');
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
        print('✅ Login successful: ${response.user!.email}');
      }

      return response.user;
    } catch (e) {
      print('❌ Login error: $e');
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
        print('✅ Registration successful: ${response.user!.email}');
      }

      return response.user;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  /// Sign in with Google OAuth
  Future<User?> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.builtwithscience://login-callback/',
      );

      print('✅ Google sign-in initiated');
      return null; // OAuth returns user via callback
    } catch (e) {
      print('❌ Google sign-in error: $e');
      rethrow;
    }
  }

  /// Reset password via email
  Future<bool> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      print('✅ Password reset email sent to: $email');
      return true;
    } catch (e) {
      print('❌ Password reset error: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
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
        print('⚠️ User not logged in - saving locally only');
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
      print('✅ Workout set saved to cloud');
      return true;
    } catch (e) {
      print('❌ Error saving workout set: $e');
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
        print('⚠️ User not logged in - returning empty data');
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

      print('✅ Loaded ${workoutData.length} exercises from cloud');
      return workoutData;
    } catch (e) {
      print('❌ Error loading workout data: $e');
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
      print('✅ Session refreshed');
    } catch (e) {
      print('❌ Error refreshing session: $e');
    }
  }
}
